---
title: Heroku Postgres Rollback
slug: heroku-postgres-rollback
url: https://devcenter.heroku.com/articles/heroku-postgres-rollback
description: Heroku Postgres rollback allows you to roll back the state of your database to a previous point in time.
---

Heroku Postgres rollback allows you to "roll back" the state of your
database to a previous point in time, just as [heroku releases:rollback](releases#rollback)
allows you to roll back to an older deployment of your application.

Rollback does not affect your primary database, but instead follows the 
same pattern as [fork](https://devcenter.heroku.com/articles/heroku-postgres-fork): 
it provisions a new database that is not directly connected to the
primary in any way. Like a fork, a rollback will take some time to
become available.

The rollback period available varies by database plan.

## Use-cases

Rollback is a great safety net in case of a critical data loss issue
(e.g., accidentally dropping an important table). It can also be invaluable
for forensics or even one-off analytics runs when some important data had
not been captured.

## Creating a Rollback Database

Creating a rollback database uses the same mechanism as creating a
[follower](heroku-postgres-follower-databases): provisioning occurs
on creation of a new database add-on with the `--rollback` flag.
The flag can take either the config var name of the database on the
same app, an argument of the form `appname::HEROKU_POSTGRESQL_COLOR`,
or the full URL of any Heroku Postgres database.

Before you roll back, you need to ensure the desired rollback point is
available for your database. Different database plans have different
rollback availability. To check your current database, you can use
the `pg:info` command:

```term
$ heroku pg:info --app sushi
=== HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
Plan:        Standard Yanari
Status:      Available
Data Size:   584.6 MB
Tables:      29
PG Version:  9.2.4
Connections: 8
Fork/Follow: Available
Rollback:    from 2013-10-18 20:00 UTC
Created:     2013-04-18 20:14 UTC
Maintenance: not required
```

>warning
>Rollback is not available on a new fork for a period after
>forking, nor on followers for a time after unfollowing.
>You can always check rollback availability via `heroku pg:info`

In addition, you must specify the time to roll back to. There are two
ways to indicate the desired time: either an explicit timestamp, or a
relative time interval.

An explicit timestamp should be of the format `2013-10-22 12:34+00:00`,
including the time zone offset. You may also use a symbolic time zone;
e.g., `2013-10-22 12:34 US/Pacific`. An interval should be of the
format `3 days 7 hours 22 minutes`. A recovery time must be passed
with the `--to` flag, and a recovery interval with `--by`. At least
one must be present, but not both.

>warning
>Rollback is not accurate down to the second at this time: seconds
>specified in the recovery time or interval are ignored.

A full rollback command looks like this:

```term
$ heroku addons:add heroku-postgresql:standard-yanari --rollback green --to '2013-10-21 15:52:52+00' --app sushi
Adding heroku-postgresql:standard-yanari on sushi... done, v754 ($50/mo)
Attached as HEROKU_POSTGRESQL_YELLOW_URL
Database will become available after it completes rolling back
to 2013-10-21 15:52:00 +0000 (08:37:22 ago)
Use `heroku pg:wait` to track status.
Use `heroku addons:docs heroku-postgresql` to view documentation.
```

The target recovery time (and how long ago this is) will be echoed in
the output of the provisioning command.

Preparing a rollback can take anywhere from several minutes to several
hours, depending on the size of your dataset. The `heroku pg:wait`
command shows the provisioning status of any new databases and can be
used to determine when the rollback is up-to-date:

```term
$ heroku pg:wait --app sushi
Waiting for database HEROKU_POSTGRESQL_YELLOW_URL... available
```

## Deprovisioning

When you are done with the rollback, deprovision it using
`heroku addons:remove`:

>note
>Be sure to remove the `_URL` suffix from the database name in this command.

```term
$ heroku addons:remove HEROKU_POSTGRESQL_YELLOW --app sushi
    !    WARNING: Destructive Action
    !    This command will affect the app: sushi
    !    To proceed, type "sushi" or re-run this command with --confirm sushi
```
         