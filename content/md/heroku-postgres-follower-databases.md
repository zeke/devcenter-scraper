---
title: Creating and Managing Heroku Postgres Follower Databases
slug: heroku-postgres-follower-databases
url: https://devcenter.heroku.com/articles/heroku-postgres-follower-databases
description: Use Heroku Postgres followers to create database replicas, master-slave setups, hot standbys and to quickly upgrade/migrate databases.
---

> callout
> You can also use `heroku pg:psql` with followers to safely run ad-hoc queries against your production data.

Database replication serves many purposes including increasing read throughput with a master-slave configuration, additional availability with a hot standby, serving as a reporting database, and seamless migrations and upgrades. Though these strategies all serve different purposes they are all based on the ability to create and manage copies of a master (or lead) database. On Heroku Postgres this functionality is exposed as the follow feature.

> warning
> Followers are only supported on [Standard, Premium, and Enterprise tier database plans](heroku-postgres-plans). Follow these steps to [upgrade from a Hobby tier (dev or basic)](upgrade-heroku-postgres-with-pgbackups) plan to a production plan.

> callout
> Followers like all Heroku Postgres databases are charged on a pro-rated basis based on the plan of the follower. 

A database follower is a *read-only* copy of the master database that stays up-to-date with the master database data. As writes and other data modifications are committed in the master database the changes are streamed, in real-time, to the follower databases.

## Create a follower

A follower can be created for any Standard, Premium, or Enterprise tier database that is itself not a follower (that is, followers cannot be chained). Followers cannot be created for a period on newly forked databases (this applies to both [explicit forks](https://devcenter.heroku.com/articles/heroku-postgres-fork) and forks created through [unfollow](#unfollow)). The exact timeframe varies depending on the size of the database to be followed, and is typically between a few minutes and a few hours. When a database is ready to support followers, that information will be shown in `heroku pg:info`:

```term
$ heroku pg:info
=== HEROKU_POSTGRESQL_PURPLE_URL (DATABASE_URL)
...
Fork/Follow: Available
...
```

> note
> The lag between a master and follower databases varies greatly depending on the amount and frequency of data updates. It is possibile for long running queries on the follower to increase your lag time, though once those queries are done your follower should catch up. Under normal usage it is common for your follower to be within a few seconds or less of your leader.

To create a follower database you must first know the add-on name of the master database. Use `heroku pg:info` to find its `HEROKU_POSTGRESQL_*COLOR*_URL` name.

```term
$ heroku pg:info
=== HEROKU_POSTGRESQL_CHARCOAL_URL (DATABASE_URL)
Plan:        Crane
Status:      available
...
```

> callout
> If more than one database is listed, the one currently serving as the master will most often be the one assigned to the `DATABASE_URL` (listed after the database name).

Create a follower database by provisioning a new heroku-postgresql [Standard, Production or Enterprise tier](heroku-postgres-plans) add-on database and specify the master database to follow with the `--follow` flag. The flag can take either the config var name of the database on the same app, an argument of the form `appname::HEROKU_POSTGRES_COLOR_URL`, or the full url of any Heroku Postgres database.

> note
> Followers do not have to be the same database plan as their master. Production tier database plans can be followed by, and can follow, all other production tier plans. If you are on an older 32-bit machine then the follower may only be followed by the same plan, you can identify this by running heroku pg:info on your database.

```term
$ heroku addons:add heroku-postgresql:ronin --follow HEROKU_POSTGRESQL_CHARCOAL_URL
Adding heroku-postgresql:ronin to sushi... done, v71 ($200/mo)
Attached as HEROKU_POSTGRESQL_WHITE
Follower will become available for read-only queries when up-to-date
Use `heroku pg:wait` to track status
```

Preparing a follower can take anywhere from several minutes to several hours, depending on the size of your dataset. The `heroku pg:wait` command outputs the provisioning status of any new databases and can be used to determine when the follower is up-to-date.

```term
$ heroku pg:wait
Waiting for database HEROKU_POSTGRESQL_WHITE_URL... available
```

## Unfollow

The `heroku pg:unfollow` command stops the follower from receiving updates from its master database and transforms it into a full read/write database containing all of the data received up to that point. This creates a database [fork](https://devcenter.heroku.com/articles/heroku-postgres-fork).

```term
$ heroku pg:unfollow HEROKU_POSTGRESQL_WHITE_URL
!    HEROKU_POSTGRESQL_WHITE_URL will become writable and no longer
!    follow HEROKU_POSTGRESQL_CHARCOAL. This cannot be undone.

!    WARNING: Potentially Destructive Action
!    This command will affect the app: sushi
!    To proceed, type "sushi" or re-run this command with --confirm sushi

> sushi
Unfollowing... done
```

> warning
> Unfollowing a database is not the same as de-provisioning it. You will still be charged for the database. To completely de-provision a database use the `heroku addons:remove HEROKU_POSTGRESQL_WHITE` command.

## Database upgrades and migrations with changeovers

> warning
> Using followers to migrate databases is not supported on the [Hobby tier](heroku-postgres-plans#hobby-tier). Use [the pgbackups-based migration process](upgrade-heroku-postgres-with-pgbackups) if you have a Hobby tier (dev or basic) database plan.

In addition to providing data redundancy, followers can also be used to change database plans with minimal downtime. At a high level, a follower is created in order to move your data from one database to another (which can be the same or different production tier database plans). Once it has received the majority of the data and is closely following your main database, you will prevent new data from being written (usually by enabling maintenance mode on your app). The follower will then fully catch-up to the main database. The follower is then promoted to be the primary database for the application.

> warning
> Though this process will incur very little app downtime it may require several hours for a follower to prepare, so please schedule the procedure accordingly.

### Create follower

To begin, create a new follower for your database and wait for the follower to catch up to the master database.

```term
$ heroku addons:add heroku-postgresql:crane --follow HEROKU_POSTGRESQL_WHITE_URL --app sushi
Adding heroku-postgresql:crane to sushi... done, v71 ($50/mo)
Attached as HEROKU_POSTGRESQL_LAVENDER
Follower will become available for read-only queries when up-to-date
Use `heroku pg:wait` to track status

$ heroku pg:wait
Waiting for database HEROKU_POSTGRESQL_LAVENDER_URL... available
```

Once a follower is caught up, it will generally be within 200 commits of the database. Monitor how many commits a follower is behind with the `pg:info` command (looking at the `Behind By` row of the follower database):

```term
$ heroku pg:info --app sushi
=== HEROKU_POSTGRESQL_LAVENDER
Plan:        Crane
Status:      available
...
=== HEROKU_POSTGRESQL_WHITE 
Plan:        Crane
Status:      available
...
Following:   HEROKU_POSTGRESQL_LAVENDER (DATABASE_URL)
Behind By:   125 commits
```

### Prevent new data updates

It is important that no new data is written to your application during the migration process, or else it may not be transferred to the new database. To accomplish this, place your app into [maintenance mode](maintenance-mode) and spin down all non-web dynos (which continue to run, even with maintenance mode enabled).

> warning
> This phase of the process takes your application offline. Please consider this when planning the migration.

```term
$ heroku maintenance:on
Enabling maintenance mode for sushi... done

$ heroku ps:scale worker=0
Scaling worker processes... done, now running 0
```

### Promote follower

In maintenance mode no new data will be written to the master database. Wait for the follower database to catch up to the master (as indicated by being behind by `0 commits`).

```term
$ heroku pg:info
=== HEROKU_POSTGRESQL_LAVENDER_URL
Plan:        Crane
Status:      available
...
=== HEROKU_POSTGRESQL_WHITE_URL
Plan:        Crane
Status:      available
...
Following:   HEROKU_POSTGRESQL_LAVENDER_URL (DATABASE_URL)
Behind By:   0 commits
```

When the follower is caught up and no new data is being generated, issue an unfollow command to relinquish its follower duties and make it a full, writeable, database. Promoting it will then set it as the primary database (at the `DATABASE_URL` location) used by your application:

```term
$ heroku pg:unfollow HEROKU_POSTGRESQL_WHITE_URL
$ heroku pg:promote HEROKU_POSTGRESQL_WHITE_URL
Promoting HEROKU_POSTGRESQL_WHITE_URL to DATABASE_URL... done
```

The follower database is now the primary database (though the application is not yet receiving new requests).

> callout
> If your Heroku Postgres database is not connected to a Heroku application you will need to retrieve the `HEROKU_POSTGRESQL_WHITE_URL` and update your application to use it as your primary database.

### Make application active

To resume normal application operation scale any non-web dynos back to their original levels and turn off maintenance mode.

```term
$ heroku ps:scale worker=1    
$ heroku maintenance:off
```

Your application is now receiving requests and operating off the new database. Your original database will continue to run (and incur charges). If desired, remove it after the changeover is successful.

> callout
> Be sure to remove the `_URL` suffix from the database name in this command.

```term
$ heroku addons:remove HEROKU_POSTGRESQL_LAVENDER
```

### Monitoring followers

Because followers are asynchronously updated they may be behind their leader by some number of commits. You can view the number of commits your follower is behind by running `heroku pg:info`. If your follower is increasing in the number of commits it is behind it may be due to long running transactions on your database. Using the [pg-extras](https://github.com/heroku/heroku-pg-extras/) plugin you can run `heroku pg:ps` to get currently running transactions, then if any have been running for longer than expected you may cancel those with: 

```term
$ heroku pg:kill PROCESSID
```

## High availability with followers

>note
>Heroku Postgres premium plans have the HA feature with automated failover. Read more about [how it works](https://devcenter.heroku.com/articles/heroku-postgres-ha).

Having a follower provisioned, even if not being actively used as a read slave, ensures that you always have a hot standby available for immediate promotion in situations where the primary database becomes corrupted or unavailable. As a general practice, applications desiring high-availability should provision a hot standby follower.

> callout
> Follower databases are guaranteed to be provisioned on geographically separate infrastructure than the primary database, providing purely additive uptime over a single database.

### Manual failover

Heroku does not automatically promote a follower database when the primary database is corrupt or inaccessible. If this functionality is required, use a premium or enterprise tier plan that does offer HA. Performing a database failover is the same manual process as a database migration starting with the [prevent data updates step](#prevent-new-data-updates).