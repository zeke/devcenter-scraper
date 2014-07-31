---
title: Using PG Backups to Upgrade Heroku Postgres Databases
slug: upgrade-heroku-postgres-with-pgbackups
url: https://devcenter.heroku.com/articles/upgrade-heroku-postgres-with-pgbackups
description: Use the PG Backups add-on to upgrade from a starter tier database plan to a production tier plan.
---

>note
>Upgrading between two [non-hobby tier](heroku-postgres-plans#standard-tier) Heroku Postgres databases is best accomplished [using followers](heroku-postgres-follower-databases#database-upgrades-and-migrations-with-changeovers). The PG Backups-based approach described here is useful to upgrade from a [starter tier](heroku-postgres-plans#standard-tier) database, where followers are not supported, or older [32-bit production database](postgres-logs-errors#this-database-does-not-support-forking-and-following), and when upgrading across PostgreSQL versions.

The [PG Backups add-on](https://addons.heroku.com/pgbackups) is useful not only for capturing regular backups of your database but also as an upgrade tool for [hobby tier](heroku-postgres-plans#hobby-tier) databases. PG Backups can be used to migrate between starter tier databases or from a starter tier database to a production tier database. 

Before beginning you should ensure you've installed the pgbackups addon and that your toolbelt is up-to-date:

```term
$ heroku addons:add pgbackups
$ heroku update
```

The steps to upgrade from a starter tier database are the same independent of the plan you're upgrading to. This assumes you have the PG Backups add-on already installed on the application you wish to upgrade.

>warning
>Upgrading databases necessarily involves some amount of downtime. Please plan accordingly.

## Provision new plan

Provision a new database of the plan you want to upgrade to. If you're unsure of which plan is right for you please consider reading the [Choosing the Right Heroku Postgres Plan](heroku-postgres-plans) article.

### Upgrading from dev to basic

>callout
>If you are upgrading from an older version your new database by default will be 9.3. If you wish to remain on an identical version you should use the `version` flag.

If you are upgrading from the `dev` starter tier plan to a `basic` starter tier plan you will first need to provision a new `basic` database.

```term
$ heroku addons:add heroku-postgresql:hobby-basic
Adding heroku-postgresql:hobby-basic on sushi... done, v122 ($9/mo)
Attached as HEROKU_POSTGRESQL_PINK_URL
Database has been created and is available
Use `heroku addons:docs heroku-postgresql:basic` to view documentation.
```

>note
>Take note of this new database name (`HEROKU_POSTGRESQL_PINK` here) as you will refer to it when restoring the backup.

### Upgrading to production tier

If you are upgrading from one of the starter tier database plans (`dev` or `basic`) to a standard or premium tier plan, provision the new standard or premium database.

```term
$ heroku addons:add heroku-postgresql:standard-tengu
Adding heroku-postgresql:standard-tengu on sushi... done, v122 ($200/mo)
The database should be available in 3-5 minutes
Use `heroku pg:wait` to track status
Use `heroku addons:docs heroku-postgresql:standard-tengu` to view documentation.
```

Production databases may take a few minutes to be fully provisioned. Use `pg:wait` to wait until the process is completed before proceeding with the upgrade.

```term
$ heroku pg:wait
Waiting for database HEROKU_POSTGRESQL_PINK_URL... available
```

>note
>Take note of this new database name (`HEROKU_POSTGRESQL_PINK` here) as you will refer to it when restoring the backup.

## Prevent new updates

It is important that no new data is written to your application during the upgrade process or it will not be transferred to the new database. To accomplish this, place your app into [maintenance mode](maintenance-mode). If you have scheduler jobs running as well you will want to disable those.

>warning
>Your application will be unavailable starting at this point in the upgrade process.

```term
$ heroku maintenance:on
Enabling maintenance mode for sushi... done
```

Any non-web dynos should be scaled down as well (maintenance mode automatically scales down all web dynos).

```term
$ heroku ps:scale worker=0
Scaling worker processes... done, now running 0
```

## Transfer data to new database

To transfer data from your current database to the newly provisioned database, simply use the `pgbackups:transfer` command with the 
`HEROKU_POSTGRESQL_COLOR` name of your *new* database (`PINK` in this example).
    
 ```term
 $ heroku pgbackups:transfer HEROKU_POSTGRESQL_PINK

 !    WARNING: Destructive Action
 !    Transfering data from DATABASE_URL to HEROKU_POSTGRESQL_PINK
 !    To proceed, type "sushi" or re-run this command with --confirm sushi

 > sushi
```

This step may take some time depending on the size of your dataset. Wait until the transfer completes before proceeding.

>note
>Note that the upgraded database may be smaller (as seen in heroku pg:info), since this process avoids moving [MVCC bloat](https://devcenter.heroku.com/articles/heroku-postgres-database-tuning) to the new database.

## Promote new database

>note
>Please take care to note that the port number for your database may change during this process. You should ensure that the port is parsed correctly from the URL.


At this point the new database is populated with the data from the original database but is not yet the active database for your application. If you wish for the new upgraded database to be the primary database for your application you will need to promote it.

```term
$ heroku pg:promote HEROKU_POSTGRESQL_PINK
Promoting HEROKU_POSTGRESQL_PINK_URL to DATABASE_URL... done
```

The upgraded database is now the primary database (though the application is not yet receiving new requests).

## Make application active

To resume normal application operation, scale any non-web dynos back to their original levels (if the application was not previously using non-web dynos, skip this step in order to avoid scaling any dynos that you may not need).

```term
$ heroku ps:scale worker=1    
```

Finally, turn off maintenance mode.

```term
$ heroku maintenance:off
```

Your application is now receiving requests to your upgraded database instance. This can be confirmed by running `heroku pg:info` -- the database denoted by `DATABASE_URL` is considered the primary database.

## Remove old database

>warning
>The original database will continue to run (and incur charges) even after the upgrade. If desired, remove it after the upgrade is successful.

```term
$ heroku addons:remove HEROKU_POSTGRESQL_ORANGE
```

Where `HEROKU_POSTGRESQL_ORANGE` is your database name as seen on the output of `heroku addons`.

## Transfering databases between Heroku applications

You may want to transfer the contents of one application’s database to another application's database. For instance, when maintaining both a staging and production environment of a single application you may wish to take a snapshot of the production data and import it to staging for testing purposes.

>note
>For the purpose of consistency the database being migrated from will be called the `source` database while the database being migrated to will be called the `target` database.

To transfer the source database to the target database you will need to invoke pgbackups from the target application, referencing a source database. This is a **destructive** operation: the transfer operation will drop existing data and replace it with the contents of the source database. The contents of the database prior to a transfer will **not** be recoverable. If the target database already contains data, capturing a backup with `pgbackups:capture` prior to transfering is a good idea.

>note
>The example below uses the syntax `APPLICATION::DATABASE` to reference another application in-line with your `pgbackups:transfer` call.

```term
 $ heroku pgbackups:transfer HEROKU_POSTGRESQL_PINK sushi-staging::HEROKU_POSTGRESQL_OLIVE -a sushi

 !    WARNING: Destructive Action
 !    Transfering data from HEROKU_POSTGRESQL_PINK to SUSHI-STAGING::COLOR
 !    To proceed, type "sushi" or re-run this command with --confirm sushi

 > sushi
```

This command tells PG Backups to transfer the data in the `HEROKU_POSTGRESQL_PINK` database attached to application `sushi` to the database `HEROKU_POSTGRESQL_OLIVE` attached to application `sushi-staging`. 