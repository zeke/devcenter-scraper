---
title: Migrating Heroku Postgres Databases Between Apps Using PG Backups
slug: migrate-heroku-postgres-with-pgbackups
url: https://devcenter.heroku.com/articles/migrate-heroku-postgres-with-pgbackups
description: The PG Backups add-on can be used to migrate Heroku Postgres databases between applications.
---

  Often times it is necessary to transfer the contents of one application's database to another application. For instance, when maintaining both a staging and production environment of a single application you may wish to take a snapshot of the production data and import it to staging for testing purposes.

The [PG Backups add-on](https://addons.heroku.com/pgbackups) is useful not only for capturing regular backups of your database but also as a data migration tool across applications. This assumes you have the PG Backups add-on already installed on both  applications involved in the transfer.

<p class="note" markdown="1">
Transferring data between databases *of the same application* as part of a database upgrade is also well-supported. See [upgrading starter tier databases with PG Backups](upgrade-heroku-postgres-with-pgbackups) or [upgrading production databases using followers](heroku-postgres-follower-databases#database-upgrades-and-migrations-with-changeovers).
</p>

For the purpose of consistency the database being migrated _from_ will be called the source database while the database being migrated _to_ will be called the target database.

<p class="warning" markdown="1">
Migration for large databases (with a dump size of more than about 5GB) are not
supported using this mechanism at this time. The breaking point is when `heroku
pgbackups:url -a source-app` produces more than one URL for your backup. For
production databases, you can [create a fork](https://devcenter.heroku.com/articles/heroku-postgres-fork)
across applications instead by using the full URL of the source database.
</p>

## Capture source snapshot

The first step is to capture a snapshot of the source database using `heroku pgbackups`.

<p class="callout" markdown="1">
The `--expire` flag tells pgbackups to automatically expire the oldest manual backup if the retention limit is reached.
</p>

    :::term
    $ heroku pgbackups:capture -a source-app --expire

    DATABASE_URL  ----backup--->  b001

    Capturing... done
    Storing... done

## Create target backup

To ensure that you can easily revert the target database back to its state before the transfer it's recommended that you make a backup.

    :::term
    $ heroku pgbackups:capture -a target-app --expire

If you need to revert the target database back because of a botched transfer or other mistake you can do so with:

    :::term
    $ heroku pgbackups:restore HEROKU_POSTGRESQL_TURQUOISE -a target-app

## Transfer to target database

To restore the source database snapshot to the target database you will need to invoke `pgbackups` from the target application, referencing the recent snapshot URL of the source database. This is a destructive operation: the restore operation will drop existing data and replace it with the contents of the backup. The contents of the database prior to a restore will not be recoverable. 

<p class="warning" markdown="1">
Pay special attention to the `-a app-name` flags as they specify the source and target destinations and can be mistakenly transposed.
</p>

    :::term
    $ heroku pgbackups:restore HEROKU_POSTGRESQL_TURQUOISE -a target-app \
        `heroku pgbackups:url -a source-app`

This command tells PG Backups to restore the most recent backup of `source-app` *to* the database located at `HEROKU_POSTGRESQL_TURQUOISE` where the color is the specific color of your database on the `target-app` application.

Depending on the size of the dataset being migrated both the capture and restore steps can take some time. See the [PG Backups add-on docs](pgbackups) for more detailed description of the various `pgbackup` commands.
        