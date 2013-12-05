---
title: Using PG Backups to Upgrade Heroku Postgres Databases
slug: upgrade-heroku-postgres-with-pgbackups
url: https://devcenter.heroku.com/articles/upgrade-heroku-postgres-with-pgbackups
description: Use the PG Backups add-on to upgrade from a starter tier database plan to a production tier plan.
---

<p class="note" markdown="1">
Upgrading between two [non-hobby tier](heroku-postgres-plans#standard-tier) Heroku Postgres databases is best accomplished [using followers](heroku-postgres-follower-databases#database-upgrades-and-migrations-with-changeovers). The PG Backups-based approach described here is useful to upgrade from a [starter tier](heroku-postgres-plans#standard-tier) database, where followers are not supported, or older [32-bit production database](postgres-logs-errors#this-database-does-not-support-forking-and-following).
</p>

The [PG Backups add-on](https://addons.heroku.com/pgbackups) is useful not only for capturing regular backups of your database but also as an upgrade tool for [hobby tier](heroku-postgres-plans#hobby-tier) databases. PG Backups can be used to migrate between starter tier databases or from a starter tier database to a production tier database. 

Before beginning you should ensure you've installed the pgbackups addon:

    heroku addons:add pgbackups

The steps to upgrade from a starter tier database are the same independent of the plan you're upgrading to. This assumes you have the PG Backups add-on already installed on the application you wish to upgrade.

<p class="warning" markdown="1">
Upgrading databases necessarily involves some amount of downtime. Please plan accordingly.
</p>

## Provision new plan

Provision a new database of the plan you want to upgrade to. If you're unsure of which plan is right for you please consider reading the [Choosing the Right Heroku Postgres Plan](heroku-postgres-plans) article.

### Upgrading from dev to basic

<div class="callout">
If you are upgrading from an older version your new database by default will be 9.2. If you wish to remain on an identical version you should use the `version` flag.
</div>

If you are upgrading from the `dev` starter tier plan to a `basic` starter tier plan you will first need to provision a new `basic` database.

    :::term
    $ heroku addons:add heroku-postgresql:basic
    Adding heroku-postgresql:basic on sushi... done, v122 ($9/mo)
    Attached as HEROKU_POSTGRESQL_PINK_URL
    Database has been created and is available
    Use `heroku addons:docs heroku-postgresql:basic` to view documentation.

<p class="note" markdown="1">
Take note of this new database name (`HEROKU_POSTGRESQL_PINK` here) as you will refer to it when restoring the backup.
</p>

### Upgrading to production tier

If you are upgrading from one of the starter tier database plans (`dev` or `basic`) to a production tier plan, provision the new production database.

    :::term
    $ heroku addons:add heroku-postgresql:crane
    Adding heroku-postgresql:crane on sushi... done, v122 ($50/mo)
    The database should be available in 3-5 minutes
    Use `heroku pg:wait` to track status
    Use `heroku addons:docs heroku-postgresql:crane` to view documentation.

Production databases may take a few minutes to be fully provisioned. Use `pg:wait` to wait until the process is completed before proceeding with the upgrade.

    :::term
    $ heroku pg:wait
    Waiting for database HEROKU_POSTGRESQL_PINK_URL... available

<p class="note" markdown="1">
Take note of this new database name (`HEROKU_POSTGRESQL_PINK` here) as you will refer to it when restoring the backup.
</p>

## Prevent new updates

It is important that no new data is written to your application during the upgrade process or it will not be transferred to the new database. To accomplish this, place your app into [maintenance mode](maintenance-mode) and scale down to zero all non-web dynos (maintenance mode automatically scales down all web dynos).

<p class="warning" markdown="1">
Your application will be unavailable starting at this point in the upgrade process.
</p>

    :::term
    $ heroku maintenance:on
    Enabling maintenance mode for sushi... done
    
    $ heroku ps:scale worker=0
    Scaling worker processes... done, now running 0

## Capture backup

Capture a backup of the original database using `heroku pgbackups`.

<p class="callout" markdown="1">
The `--expire` flag tells pgbackups to automatically expire the oldest manual backup if the retention limit is reached.
</p>

    :::term
    $ heroku pgbackups:capture --expire

    DATABASE_URL  ----backup--->  b001

    Capturing... done
    Storing... done

## Restore to upgraded database

To restore the database capture from the original database to the new upgraded database simply use `pgbackups:restore` with the `HEROKU_POSTGRESQL_COLOR` name of the *new* database (`PINK` in this example).

    :::term
    $ heroku pgbackups:restore HEROKU_POSTGRESQL_PINK
    
    HEROKU_POSTGRESQL_PINK  <---restore---  b001 (most recent)
                                            DATABASE_URL
                                            2011/03/08 09:41.57
                                            543.7MB

This step may take some time depending on the size of your dataset. Wait until the restoration completes before proceeding.

## Promote upgraded database

<p class="note" markdown="1">
Please take care to note that the port number for your database may change during this process. You should ensure that the port is parsed correctly from the URL.
</p>

At this point the new database is populated with the data from the original database but is not yet the active database for your application. If you wish for the new upgraded database to be the primary database for your application you will need to promote it.

    :::term
    $ heroku pg:promote HEROKU_POSTGRESQL_PINK
    Promoting HEROKU_POSTGRESQL_PINK_URL to DATABASE_URL... done

The upgraded database is now the primary database (though the application is not yet receiving new requests).

## Make application active

To resume normal application operation scale any non-web dynos back to their original levels and turn off maintenance mode.

    :::term
    $ heroku ps:scale worker=1    
    $ heroku maintenance:off

Your application is now receiving requests to your upgraded database instance. This can be confirmed by running `heroku pg:info` -- the database denoted by `DATABASE_URL` is considered the primary database.

## Remove old database

<p class="warning" markdown="1">
The original database will continue to run (and incur charges) even after the upgrade. If desired, remove it after the upgrade is successful.
</p>

    :::term
    $ heroku addons:remove HEROKU_POSTGRESQL_ORANGE

Where `HEROKU_POSTGRESQL_ORANGE` is your database name as seen on the output of `heroku addons`.