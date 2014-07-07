---
title: Forking Your Heroku Postgres Database
slug: heroku-postgres-fork
url: https://devcenter.heroku.com/articles/heroku-postgres-fork
description: Forking creates a new database containing a snapshot of an existing database at the current point in time.
---

Forking creates a new database containing a snapshot of an existing database at the current point in time. Forked databases differ from follower databases in that they *do not* stay up-to-date with the original database and are themselves writable.

>warning
>Forking is only supported on [production tier database plans](heroku-postgres-plans). Follow these steps to [upgrade from a starter tier (dev or basic)](upgrade-heroku-postgres-with-pgbackups) plan to a production plan.

## Use-cases

Forked databases provide a risk-free way of working with your production data and schema. For example, they can be used to test new schema migrations or to load test your application on a different database plan. The are also valuable as snapshots of your data at a point-in-time for later analysis or forensics.

## Create a fork

>callout
>Creating forks is subject to the same limitations as [creating followers](https://devcenter.heroku.com/articles/heroku-postgres-follower-databases#create-a-follower).

Forking a database uses the same mechanism as creating a [follower](heroku-postgres-follower-databases) -- namely that provisioning occurs on creation of a new database add-on with the `--fork` flag. The flag can take either the config var name of the database on the same app, an argument of the form `appname::HEROKU_POSTGRESQL_COLOR_URL`, or the full url of any Heroku Postgres database.

>note
>Forks do not have to be the same database plan as their master. Production tier database plans can be forked to all other production tier plans. If your database is on an older 32-bit machine then the follower may only be followed by the same plan, you can identify this by running heroku pg:info on your database.


```term
$ heroku addons:add heroku-postgresql:crane --fork HEROKU_POSTGRESQL_CHARCOAL_URL
Adding heroku-postgresql:crane on sushi... done, v71 ($50/mo)
Attached as HEROKU_POSTGRESQL_SILVER_URL
Database will become available after it completes forking
Use `heroku pg:wait` to track status
```

Preparing a fork can take anywhere from several minutes to several hours, depending on the size of your dataset. The `heroku pg:wait` command outputs the provisioning status of any new databases and can be used to determine when the fork is up-to-date.

```term
$ heroku pg:wait
Waiting for database HEROKU_POSTGRESQL_SILVER_URL... available
```

De-provision a fork using `heroku addons:remove`:

>callout
>Be sure to remove the `_URL` suffix from the database name in this command.

```term
$ heroku addons:remove HEROKU_POSTGRESQL_SILVER

!    WARNING: Destructive Action
!    This command will affect the app: sushi
!    To proceed, type "sushi" or re-run this command with --confirm sushi 
```

## Fork Fast option

Forks can be created faster using the `--fast` flag, however they will be up to 30 hours out-of-date. This option is useful if there have been no major changes (such as schema migrations or large data imports) to your database in the last 30 hours.

```term
$ heroku addons:add heroku-postgresql:premium-ika --fork HEROKU_POSTGRESQL_CHARCOAL_URL --fast
 
Adding heroku-postgresql:premium-ika on dashboard... done, v1022 ($1200/mo)
Attached as HEROKU_POSTGRESQL_BLUE_URL
 
Fork will contain data from 5/26/2014 at 13:56 UTC (about 16 hours old)
To create a fork with up-to-date data, exclude the `--fast` flag.
 
Database will become available after it completes forking
Use `heroku pg:wait` to track status.
Use `heroku addons:docs heroku-postgresql` to view documentation ```