---
title: Heroku Postgres Database Tuning
slug: heroku-postgres-database-tuning
url: https://devcenter.heroku.com/articles/heroku-postgres-database-tuning
description: A description of how the VACUUM mechanism works in Heroku Postgres, and how best to use it.
---

Postgres uses a mechanism called
[MVCC](https://devcenter.heroku.com/articles/postgresql-concurrency)
to track changes in your database. As a side effect, some rows become
"dead": no longer visible to any running transaction. 

Dead rows are generated not just by `DELETE` operations, but also by `UPDATE`s, as
well as transactions that have to be rolled back. 

Your database needs periodic maintenance to clean out these dead rows: this is essentially a form of garbage collection. 

Typically, this happens automatically, but it can be useful to understand the details and tune the maintenance settings as needed.

### Vacuuming a database

The built-in mechanism for managing this cleanup is called
`VACUUM`. This can be run as a regular command, but Postgres also
includes facilities for running the `VACUUM` process automatically in
the background as a maintenance task, periodically trying to clean out
old data where necessary. This autovacuum process will perform its
maintenance based on a set of configuration parameters. 

The default Heroku configuration is enough for many applications, but in some
situations, you may need to make some changes or occasionally take
manual action.

### Determining bloat

To check whether you need to vacuum, you can run a query to give you
information on table and index "bloat" (extra space taken by these
database objects on disk due to dead rows). The simplest way to do
this is to install the
[pg-extras](https://github.com/heroku/heroku-pg-extras) plugin for the
Heroku Toolbelt.

Once installed, you can check bloat by running the following command:

```term
$ heroku pg:bloat DATABASE_URL --app sushi
 type  | schemaname |    object_name          | bloat |   waste
-------+------------+-------------------------+-------+-----------
 table | public     | users                   |   1.0 | 109 MB
 table | public     | logs                    |   1.0 | 47 MB
 index | public     | queue_classic_jobs_pkey |   3.1 | 25 MB
 table | public     | reviews                 |   2.2 | 16 MB
 table | public     | queue_classic_jobs      |  32.5 | 1512 kB
...
```

This shows the bloat factor (the fraction of the original table that
exists as bloat), and the total bloat (in bytes) in each table and
index in the system. There are no units to bloat--it is a ratio.

A very large bloat factor on a table or index can lead to poor
performance for some queries, as Postgres will plan them without
considering the bloat.

The threshold for excessive bloat varies according to your query
patterns and the size of the table, but generally anything with a
bloat factor over 10 is worth looking into, especially on tables over
100MB.

To check on vacuuming in your database, you can use another pg-extras
command:

```term
$ heroku pg:vacuum_stats DATABASE_URL --app sushi
 schema |         table      | last_vacuum | last_autovacuum  |    rowcount    | dead_rowcount  | autovacuum_threshold | expect_autovacuum 
--------+--------------------+-------------+------------------+----------------+----------------+----------------------+-------------------
 public | queue_classic_jobs |             | 2013-05-20 16:54 |         82,617 |         36,056 |         16,573       | yes
 public | logs               |             | 2013-05-20 16:27 |              1 |             18 |             50       | 
 public | reviews            |             | 2013-05-20 01:36 |             87 |              0 |             67       | 
 public | users              |             | 2013-05-20 16:28 |              0 |             23 |             50       | 
...
```

This will tell you when each table was last vacuumed, and whether that
was through a manual action or the autovacuum background worker. It
also shows the threshold number of dead rows that will trigger an
autovacuum for that particular table, and whether you should expect an
autovacuum to occur.

### VACUUM variants

Bloat can be contained by ensuring that `VACUUM` runs regularly, and
reduced by running `VACUUM FULL` if it's getting out of hand. Note
that the autovacuum process will only ever run a regular, non-full
`VACUUM` command.

Note that while `VACUUM FULL` offers a more exhaustive cleanup,
actually reducing bloat (rather than just flagging that space as
available, as with regular `VACUUM`), it's also a much more
heavyweight operation: `VACUUM FULL` actually rewrites the entire
table, and thus prevents any other statements from running
concurrently (even simple `SELECT` queries). Generally, it's a good
idea to keep autovacuum in an aggressive-enough configuration so that
`VACUUM FULL` is never needed.

In some cases, where a table is only used to track transient data
(e.g., a work queue), it may be useful to run the `TRUNCATE` command
instead. This will delete all the data in the table in a batch
operation. For very bloated tables, this can be much faster than a
`DELETE` and `VACUUM FULL`.


### Automatic vacuuming with autovacuum

The most effective way to manage bloat is by tweaking autovacuum
settings as necessary.

There are primarily two ways that can be used to control autovacuum.
The first is changing when a table is actually elligible for `VACUUM`.
This is controlled by two settings (on Heroku, the changes can
currently only be made per-table):

```term
$ heroku pg:psql
=> ALTER TABLE users SET (autovacuum_vacuum_threshold = 50);
ALTER TABLE
=> ALTER TABLE users SET (autovacuum_vacuum_scale_factor = 0.2);
ALTER TABLE
```

The threshold is a raw number of dead rows needed, and the scale
factor is the fraction of live rows in the table that must exist as
dead rows. The defaults are 50 and 0.2, as seen above.

Together, these two make up the actual threshold (as seen
in `pg:vacuum_stats` above) according to the following formula:

    vacuum threshold = autovacuum_vacuum_threshold +
        autovacuum_vacuum_scale_factor * number of rows

On large tables, you may want to decrease the scale factor to allow
vacuum to start making progress earlier. For very small tables, you
may decrease the threshold, though this is typically not necessary.

Furthermore, autovacuum has a built in cost-based rate-limiting
mechanism, to avoid having it overwhelm the system with `VACUUM`
activity. In busy databases, however, this can mean that autovacuum
does not make progress quickly enough, leading to excessive bloat.

To avoid that, you can change the back-off settings to be less
deferential. These changes can be made at the database level.

```term
$ heroku pg:psql
=> select current_database();
 current_database 
------------------
 dd5ir2j6frrtr0
(1 row)
=> ALTER DATABASE dd5ir2j6frrtr0 SET vacuum_cost_limit = 300;
ALTER DATABASE
=> ALTER DATABASE dd5ir2j6frrtr0 SET vacuum_cost_page_dirty = 25;
ALTER DATABASE
=> ALTER DATABASE dd5ir2j6frrtr0 SET vacuum_cost_page_miss = 7;
ALTER DATABASE
=> ALTER DATABASE dd5ir2j6frrtr0 SET vacuum_cost_page_hit = 0;
ALTER DATABASE
```

The cost limit determines how much "cost" (in terms of I/O operations)
autovacuum can accrue before being forced to take a break; the cost
delay determines how long that break is (in milliseconds). Note that
these settings affect both autovacuum and manual vacuum
(autovacuum-only variants do exist, but they can only be set per-table
on Heroku Postgres at this time). The cost limit is set to 200 by
default. Increasing the cost limit (up to 1000 or so) or adjusting the
`vacuum_cost_page_*` parameters can help autovacuum progress more
efficiently.


### Manual vacuuming

If your database happens to have a very periodic workload, it may be
more efficient to use a simple worker process to "manually" run a
`VACUUM` (or even `VACUUM FULL`, if the locking is not an issue) and
trigger it with a tool like [Heroku
Scheduler](https://devcenter.heroku.com/articles/scheduler) during the
"off" hours.

A manual `VACUUM` does not have a threshold for when it "kicks in": it
is always triggered by running the `VACUUM` command. The cost-based
back-off (as with autovacuum) still applies, but it is turned off by
default (the `vacuum_cost_delay` is set to 0). You can increase this
per-table if you find that a manual `VACUUM` has too much impact on
your regular workload.

To run `VACUUM`, open a psql shell to the desired database and simply
issue the command:

```term
$ heroku pg:psql
=> VACUUM;
WARNING:  skipping "pg_authid" --- only superuser can vacuum it
WARNING:  skipping "pg_database" --- only superuser can vacuum it
WARNING:  skipping "pg_tablespace" --- only superuser can vacuum it
WARNING:  skipping "pg_pltemplate" --- only superuser can vacuum it
WARNING:  skipping "pg_auth_members" --- only superuser can vacuum it
WARNING:  skipping "pg_shdepend" --- only superuser can vacuum it
WARNING:  skipping "pg_shdescription" --- only superuser can vacuum it
WARNING:  skipping "pg_db_role_setting" --- only superuser can vacuum it
VACUUM
```

The warnings you'll see are expected and can be ignored. You can also
restrict `VACUUM` to a particular table, if only one or two need
manual vacuuming:

 ```term
 $ heroku pg:psql
 => VACUUM users;
 VACUUM
 ```

When running `VACUUM`, you can add the `VERBOSE` keyword for more
details about its progress.

```term
$ heroku pg:psql
d7lrq1eg4otc3i=> VACUUM VERBOSE;
INFO:  vacuuming "public.reviews"
INFO:  index "reviews_pkey" now contains 0 row versions in 1 pages
DETAIL:  0 index row versions were removed.
0 index pages have been deleted, 0 are currently reusable.
CPU 0.00s/0.00u sec elapsed 0.00 sec.
INFO:  index "reviews_user_index" now contains 0 row versions in 1 pages
DETAIL:  0 index row versions were removed.
0 index pages have been deleted, 0 are currently reusable.
CPU 0.00s/0.00u sec elapsed 0.00 sec.
INFO:  "users": found 0 removable, 0 nonremovable row versions in 0 out of 0 pages
DETAIL:  0 dead row versions cannot be removed yet.
There were 0 unused item pointers.
0 pages are entirely empty.
CPU 0.00s/0.00u sec elapsed 0.00 sec.
...
VACUUM
```

With carefully managed autovacuum settings, manual vacuuming should
rarely be necessary, but it's important to understand how it works.        