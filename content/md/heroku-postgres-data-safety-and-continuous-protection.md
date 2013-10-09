---
title: Heroku Postgres Data Safety and Continuous Protection
slug: heroku-postgres-data-safety-and-continuous-protection
url: https://devcenter.heroku.com/articles/heroku-postgres-data-safety-and-continuous-protection
description: How we protect your data on Heroku Postgres through continuous protection via wal-e and backups via pgbackups and dumps.
---

Postgres offers a number of ways to replicate, backup and export your data. Some are extremely lightweight and have little performance impact on a running database, while others are rather expensive and may adversely impact a database under load.

This article explores how Heroku Postgres uses these methods to provide continuous protection, as well as data portability and how you may choose what is appropriate for your data. 

### The Different Types of Backups
The types of backups available for Postgres are broadly divided into physical and logical backups. Physical backups may be snapshots of the file-system, a binary copy of the database cluster files or a replicated external system, while logical backups are a SQL-like dump of the schema and data of certain objects within the database. Physical backups offer some of least computationally intensive methods of data durability available while being very limited in how they may be restored. Logical backups are much more flexible, but can be very slow and require substantial computational resources during backup and restore. How these methods are used within Heroku Postgres is explored below.

## Physical Backups on Heroku Postgres
Heroku Postgres uses physical backups for Continuous Protection by persisting binary copies of the database cluster files, also known as base backups, and write ahead log (WAL) files to external, reliable storage. 

>callout
>All Heroku Postgres databases are protected through continuous physical backups.

Base backups are taken while the database is fully available and make a verbatim copy of Postgres' data files. This includes dead tuples, bloat, indexes and all structural characteristics of the currently running database. On Heroku Postgres, a base backup capture is rate limited to about 10MB/s and imposes a minimal load on the running database. Committed transactions are recorded as WAL files, which are able to be replayed on top of the base backups, providing a method of completely reconstructing the state of a database. Base backups and WAL files are pushed to AWS' S3 object store through an application called [WAL-E](https://github.com/wal-e/wal-e) as soon as they are made available by Postgres. 

All databases managed by Heroku Postgres provide continuous protection by persisting base backups and WAL files to S3. Also, [fork](https://devcenter.heroku.com/articles/heroku-postgres-fork) and [follower](https://devcenter.heroku.com/articles/heroku-postgres-follower-databases) database are implemented by fetching persistent base backups and WAL files and replaying them on a fresh Postgres installation. Storing these physical backups in a highly available object store also enables us to recover entire databases in the event of hardware failure, data corruption or a large scale service interruption.

>note
>Due to the nature of these binary base backups and WAL files, they are only able to be restored to Postgres installations with the same architecture, major version and build options as the source database. This means that [upgrades](https://devcenter.heroku.com/articles/upgrade-heroku-postgres-with-pgbackups) across architectures and major versions of Postgres require a logical backup to complete.

## Logical Backups on Heroku Postgres
Logical backups are an extremely flexible method of exporting data from Heroku Postgres and restoring it to almost any database installation, but can be quite painful for moving large data sets. 

>callout
>Frequent logical backups of large databases under load can be slow, degrade the performance of other queries and prevent necessary maintenance operations from running. 

Logical backups are captured using [pg_dump](http://www.postgresql.org/docs/9.2/interactive/app-pgdump.html) and can be restored with [pg_restore](http://www.postgresql.org/docs/9.2/static/app-pgrestore.html) or [psql](http://www.postgresql.org/docs/9.2/static/app-psql.html), depending on the dump file format. Script format dumps are plain-text files of SQL commands that would reconstruct the database at the time of capture and are restored by piping them through psql. Archive file formats are more flexible and performant than script formats and the "custom" format allows for compression as well as opportunistic reordering of all archived items. Archive file formats are restored through pg_restore. 

### pg_dump
The `pg_dump` application uses a regular Postgres connection to run a series of SQL COPY commands in a single transaction to produce a consistent snapshot across the database. `pg_dump`'s single transaction is serializable, which will force Postgres to maintain state from the beginning of the transaction to the end. This blocks [VACUUM and other automatic maintenance processes](https://devcenter.heroku.com/articles/heroku-postgres-database-tuning) until the data copy is complete. `pg_dump` uses a single backend to read all live tuples in the database through a circular buffer that preserves Postgres' cache but will displace and potentially ruin the OS's and filesystem's caches. The `pg_dump` backend will consume as much filesystem IO as available and will contend for resources with concurrently running queries. The file that is produced by `pg_dump` will be much smaller than the size of the database as reported by `pg_database_size` as it will only contain the live dataset of the database and instructions on how to re-make indexes, but not the indexes themselves. Also, if a 'custom' archive file format is used, it will be compressed by default.

### pg_restore
The `pg_restore` application similarly uses a regular Postgres connection to load a dump into a Postgres database. The restore will create the necessary schema, load data through COPY commands, create indexes, add constraints and create any triggers that were dumped from the source database. The loading data, creating indexes and creating constraints phases may be extremely slow as each requires disk IO and computation in order to write, process and alter the restored data for normal operation. Certain parts of the restore may be run over several parallel connections, which is accomplished through the `--jobs=number-of-jobs` command line flag to `pg_restore`. As each job is one process, more than one jobs per CPU core in the database instance will lead to resource contention and may lead to decreased performance. 

### PGBackups
On Heroku Postgres, `pg_dump` and `pg_restore` running on Heroku are available through the [PGBackups](https://devcenter.heroku.com/articles/pgbackups) addon. During a scheduled run of PGBackups or manual run of `heroku pgbackups:capture`, PGBackups will launch a dedicated dyno to take a dump of your database and upload it to S3. A `pgbackups:capture` run may be canceled through a normal `psql` connection:

```term
$ heroku pg:psql
=> SELECT pid, query FROM pg_stat_activity WHERE query LIKE 'COPY%';  
  pid  |                       query
-------+----------------------------------------------------
 21374 | COPY public.users (id, created_at, name) TO stdout;
(1 row)
=> SELECT pg_cancel_backend(21374);
 pg_cancel_backend 
-------------------
 t
(1 row)
```

As for restoring data to your database, `heroku pgbackups:restore` will take any dump file that is accessible to a dyno running on Heroku, such as one available on S3, and restore it to your Heroku Postgres database. 

For directly transferring a logical backup between Heroku Postgres databases, `heroku pgbackups:transfer` will use a dedicated dyno to pipe the output of `pg_dump` directly to `pg_restore`, removing the need to transfer the dump file to a location external to Heroku. The data transfer is also piped through `pv`, an application better known as [pipeviewer](http://linux.die.net/man/1/pv), to provide more visibility into the transfer. However, creating indexes, adding constraints and doing basic sanity checking at the end of the `pgbackups:transfer` run will not be reflected in `pv`'s logging, so the transfer may appear to hang, but is working in the background. 

### The performance impact of logical backups
Capturing a logical backup from a database will subject it to increased load. As all data is read, a logical backup capture will evict well cached data from non-Postgres caches, consume finite disk IO capacity, pause auto-maintenance tasks and degrade the performance of other queries. As the size of a database and/or the load the database is under grows, this period of degraded performance and neglected auto-maintenance will also grow. Balancing your database's performance with your backup requirements is necessary in order to avoid unpleasant surprises. 

In general, PGBackups are intended for moderately loaded databases up to 20 GB. Contention for the IO, memory and CPU needed for backing up a larger database becomes prohibitive at a moderate load and the longer run time increases the chance of an error that will end your backup capture prematurely. 

## Combining physical and logical backups
Fork and followers may be employed to reduce the load of a logical backup. Capturing a logical backup from a follower will preserve the leader's performance and allow the backup operation to consume as many resources as necessary for the dump to succeed. Launching a short lived fork will also allow for logical backups to be taken without effecting your primary database's performance, although the initial base backup of a new fork will compete with the logical backup for disk IO. 

At the moment, PGBackups are only able to capture automatic backups of the database at the `DATABASE_URL` config var. Until this changes, we suggest using the [Heroku Scheduler](https://addons.heroku.com/scheduler) addon to tune when your logical backups are taken. 