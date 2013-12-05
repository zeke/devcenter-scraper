---
title: High Availability on Heroku Postgres
slug: heroku-postgres-ha
url: https://devcenter.heroku.com/articles/heroku-postgres-ha
description: High Availability on Heroku Postgres
---

All Premium and Enterprise tier plans come with the High Availability (HA) feature, which involves a database cluster and management system designed to increase database availability in the face of hardware or software failure that would otherwise lead to longer downtime. When a primary database with this feature fails, it is automatically replaced with another replica database called a standby. 

>note
>Like followers, HA standbys are physically located on different availability zones to protect against AZ-wide failures.

The database instance that exhibited failure is consequently destroyed and the standby is reconstructed.

When this happens, it is possible for a small, but bounded, amount of recently committed data to be lost.

The value of your `DATABASE_URL` and `HEROKU_POSTGRES_*_URL` config vars may change on a failover event (the names do not change). If you are connecting to this database from outside of Heroku, make sure you are [setting your credentials correctly](https://devcenter.heroku.com/articles/connecting-to-heroku-postgres-databases-from-outside-of-heroku#credentials).

>callout
>The standby node is hidden from your application. If you need followers for horizontal read scaling or reporting, create a new Standard Tier follower database of your primary.

## Failover conditions

In order to prevent problems commonly seen with hair-trigger failover systems, we run a suite of checks to ensure that failover is the appropriate response. After our systems initially detect a problem, we confirm that the database is truly unavailable by running several checks for two minutes across multiple dynos. This prevents transient problems from triggering a failover.

Like [followers](heroku-postgres-follower-databases), standbys are kept up to date asynchronously. This means that it is possible for data to be committed on the primary database but not yet on the standby. In order to minimize data loss we take two very important steps.
First, we do not attempt the failover if the standby is more than 10 segments behind. This means the maximum possible loss is 160MB or 10 minutes, whichever is less.
Second, if any of the 10 segments were successfully archived through [continuous protection](heroku-postgres-data-safety-and-continuous-protection), but not applied during the two minute confirmation period, we make sure they are applied before bringing the standby out of read-only mode.
Typically there is little loss to committed data.

## After failover

After a successful failover, there are a few things to keep in mind. First, the URL for the database will have changed, and your app will automatically restart with the new credentials. Secondly, the [new database's cache](understanding-postgres-data-caching) will be cold, so your application's performance may be degraded for a short period of time. This will fix itself through normal usage. Finally, a new standby is automatically recreated, and HA procedures cannot be performed until it becomes available and meets our failover conditions.

## HA Status

You can check the status of HA for your database by running `heroku pg:info`. Under normal situations will show `HA Status: Available`. After unfollowing or after a failover event, it will show `HA Status: Temporarily Unavailable` while rebuilding the standby. It can also show 'Temporarily Unavailable' when the standby is more than 10 segments behind, as failover will not be attempted at that time.