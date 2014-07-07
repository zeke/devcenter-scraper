---
title: Choosing the Right Heroku Postgres Plan
slug: heroku-postgres-plans
url: https://devcenter.heroku.com/articles/heroku-postgres-plans
description: Understand the differences between the various Heroku Postgres plans and how to choose which one is most appropriate for your use-case.
---

[Heroku Postgres](heroku-postgresql) offers a wide spectrum of plans
appropriate for everything from personal blogs all the way to
large-dataset and high-transaction applications. Choosing the right
plan depends on the unique usage characteristics of your app as well
as your organization's availability and uptime expectations.

## Plan tiers

>callout
>If you're on one of our legacy plans you can still provision and use those. Details of those plans can be found at [https://devcenter.heroku.com/articles/heroku-postgres-legacy-plans](https://devcenter.heroku.com/articles/heroku-postgres-legacy-plans)

[Heroku Postgres's many plans](https://postgres.heroku.com/pricing)
are segmented in four broad tiers. While each tier has a few differences, the key factor in each tier is the uptime expectation for your database. The four tiers are designed as:

* **Hobby Tier** designed for apps that can tolerate up to 4 hrs of downtime
* **Standard Tier** designed for apps that can tolerate up to 1 hr of downtime
* **Premium Tier** designed for apps that can tolerate up to 15 minutes of downtime
* **Enterprise Tier** designed for apps where an SLA is needed

*All uptime expectations are given based on a 30 day month*

For a full breakdown of the differences between tiers:

| Heroku Postgres tier   | Downtime Tolerance            | Backups Available | Fork | Follow  | Rollback | HA   | SLA |
| ---------------------- | ----------------------------- | ----------------- | ---- | ------- | -------- | ---- | --- |
| Hobby                  | Up to 4 hrs downtime per mo.  | Yes               | No   | No      | No       | No   | No  |
| Standard               | Up to 1 hr downtime per mo.   | Yes               | Yes  | Yes     | 1 hour   | No   | No  |
| Premium                | Up to 15 min downtime per mo. | Yes               | Yes  | Yes     | 1 week   | Yes  | No  |
| Enterprise             | Up to 15 min downtime per mo. | Yes               | Yes  | Yes     | 1 month  | Yes  | Yes |

### Shared features

All tiers share the following features:

* Fully managed database service with automatic health checks
* Write-ahead log (WAL) off-premise storage every 60 seconds, ensuring
  minimal data loss in case of catastrophic failure
* [Data clips](https://postgres.heroku.com/blog/past/2012/1/31/simple_data_sharing_with_data_clips/)
  for easy and secure sharing of data and queries
* SSL-protected psql/libpq access
* Running unmodified Postgres v9.1, v9.2, v9.3 (v9.0 is available on
  production tier only) for guaranteed compatibility
* Postgres [extensions](heroku-postgres-extensions-postgis-full-text-search)
* A full-featured [web UI](https://postgres.heroku.com/databases)

## Hobby tier

The hobby tier, which includes the [`hobby-dev` and `hobby-basic`
plans](https://addons.heroku.com/heroku-postgresql), has the following
limitations:

* Enforced row limits of 10,000 rows for `hobby-dev` and 10,000,000 for `hobby-basic` plans
* Max of 20 connections
* No in-memory cache: The lack of an in-memory cache limits the
  performance capabilities since the data can't be accessed on
  low-latency storage.
* No [fork/follow](heroku-postgres-follower-databases) support: Fork
  and follow, used to create replica databases and master-slave
  setups, are not supported.
* Expected uptime of 99.5% each month
* Unannounced maintenances and database upgrades
* No postgres logs

### Row limit enforcement

When you are over the hobby tier row limits and try to insert you will see a Postgres error:

    permission denied for relation <table name>

The row limits of the hobby tier database plans are enforced with the following mechanism:

1. When a `hobby-dev` database hits 7,000 rows, or a `hobby-basic` database hits 7
   million rows , the owner receives a warning e-mail stating they are
   nearing their row limits.
2. When the database exceeds its row capacity, the owner will receive
   an additional notification. At this point, the database will receive a
   7 day grace period to either reduce the number of records, or
   [migrate to another plan](heroku-postgres-follower-databases#database-upgrades-and-migrations-with-changeovers).
3. If the number of rows still exceeds the plan capacity after 7
   days, `INSERT` privileges will be revoked on the database. Data can
   still be read, updated or deleted from database. This ensures that
   users still have the ability to bring their database into compliance,
   and retain access to their data.
4. Once the number of rows is again in compliance with the plan limit,
   `INSERT` privileges are automatically restored to the database. Note
   that the database sizes are checked asynchronously, so it may take a
   few minutes for the privileges to be restored.

## Standard tier

The Standard tier is designed for production applications, where while uptime is important, are able to tolerate up to 1 hour of downtime in a given month. All standard tier databases include:

* No row limitations
* Increasing amounts of in-memory cache
* [Fork and follow](heroku-postgres-follower-databases) support
* [Rollback](https://devcenter.heroku.com/articles/heroku-postgres-rollback)
* [Database metrics published](https://devcenter.heroku.com/articles/heroku-postgres-metrics-logs) to application log stream for further analysis
* Priority service restoration on disruptions

Within the Standard tier plans have differing memory, connection limits, and storage limits. The plans for the standard tier are:

| Plan Name | Provisioning name                    | Cache Size | Storage limit   | Connection limit | Monthly Price |
| --------- | ------------------------------------ | ---------- | --------------- | ---------------- | ----- |
| Yanari    | heroku-postgresql:standard-yanari    | 400 MB     | 64 GB           | 60               | $50   |
| Tengu     | heroku-postgresql:standard-tengu     | 1.7 GB     | 256 GB          | 200              | $200  | 
| Ika       | heroku-postgresql:standard-ika       | 7.5 GB     | 512 GB          | 400              | $750  |
| Baku      | heroku-postgresql:standard-baku      | 34 GB      | 1 TB            | 500              | $2000 |
| Mecha     | heroku-postgresql:standard-mecha     | 64 GB      | 1 TB            | 500              | $3500 |


## Premium tier

The Premium tier is designed for production applications, where while uptime is important, are able to tolerate up to 15 minutes of downtime in a given month. All premium tier databases include:

* No row limitations
* Increasing amounts of in-memory cache
* [Fork and follow](heroku-postgres-follower-databases) support
* [Rollback](https://devcenter.heroku.com/articles/heroku-postgres-rollback)
* [Database metrics published](https://devcenter.heroku.com/articles/heroku-postgres-metrics-logs) to application log stream for further analysis
* Priority service restoration on disruptions

Within the premium tier plans have differing memory, connection limits, and storage limits. The plans for the premium tier are:

| Plan Name | Provisioning name                   | Cache Size | Storage limit   | Connection limit | Monthly Price |
| --------- | ----------------------------------- | ---------- | --------------- | ---------------- | ----- |
| Yanari    | heroku-postgresql:premium-yanari    | 400 MB     | 64 GB           | 60               | $200  |
| Tengu     | heroku-postgresql:premium-tengu     | 1.7 GB     | 256 GB          | 200              | $350  |
| Ika       | heroku-postgresql:premium-ika       | 7.5 GB     | 512 GB          | 400              | $1200 |
| Baku      | heroku-postgresql:premium-baku      | 34 GB      | 1 TB            | 500              | $3500 |
| Mecha     | heroku-postgresql:premium-mecha     | 68 GB      | 1 TB            | 500              | $6000 |


## Cache size

Each [production tier plan's](https://www.heroku.com/pricing)
RAM size constitutes the total amount of System Memory on the 
underlying instance's hardware, most of which is given to
Postgres and used for caching. While a small amount of RAM is
used for managing each connection and other tasks, Postgres will 
take advantage of almost all this RAM for its cache. Learn more
about how this works [in this article](https://devcenter.heroku.com/articles/understanding-postgres-data-caching)

Postgres constantly manages the cache of your data: rows you've
written, indexes you've made, and metadata Postgres keeps. When the
data needed for a query is entirely in that cache, performance is very
fast. Queries made from cached data are often 100-1000x faster than
from the full data set.

>note
>99% or more of queries served from well engineered, high performance
>web applications will be served from cache.

Conversely, having to fall back to disk is at least an order of
magnitude slower. Additionally, columns with large data types
(e.g. large text columns) are stored out-of-line via
[TOAST](http://www.postgresql.org/docs/current/static/storage-toast.html),
and accessing large amounts of TOASTed data can be slow.

### General guidelines

Access patterns vary greatly from application to application. Many
applications only access a small, recently-changed portion of their
overall data. Postgres can always keep that portion in cache as time
goes on, and as a result these applications can perform well on
smaller plans.

Other applications which frequently access all of their data don't
have that luxury and can see dramatic increases in performance by
ensuring that their entire dataset fits in memory. To determine the
total size of your dataset use the `heroku pg:info` command and look
for the `Data Size` row:

```term
$ heroku pg:info
=== HEROKU_POSTGRESQL_CHARCOAL_URL (DATABASE_URL)
Plan:        Crane
Status:      available
Data Size:   9.4 MB
...
```

Though a crude measure, choosing a plan that has at least as much
in-memory cache available as the size of your total dataset will
ensure high cache ratios. However, you will eventually reach the point
where you have more data than the largest plan, and you will have to
shard. Plan ahead for sharding: it takes a long time to execute a
sharding strategy.

### Determining required cache-size

There is no substitute for observing the database demands of your
application with live traffic to determine the appropriate
cache-size. Cache hit ratio should be in the 99%+ range. Uncommon
queries should be less than 100ms and common ones less than 10ms.

>callout
>[This blog post](http://www.craigkerstiens.com/2012/10/01/understanding-postgres-performance/)
>includes a deeper discussion of Postgres performance concerns and techniques.

To measure the cache hit ratio for tables:

```sql
SELECT
    'cache hit rate' AS name,
     sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) AS ratio
FROM pg_statio_user_tables;
```

or the cache hit ratio for indexes:

```sql
SELECT
    'index hit rate' AS name,
    (sum(idx_blks_hit)) / sum(idx_blks_hit + idx_blks_read) AS ratio
FROM pg_statio_user_indexes
```

>callout
>You can also install the [pg extras plugin](http://www.github.com/heroku/heroku-pg-extras)
>and then simply run heroku pg:cache_hit.

Both queries should indicate a `ratio` near `0.99`:

```sql
heap_read | heap_hit |         ratio          
-----------+----------+------------------------
       171 |   503551 | 0.99966041175571094090
```

When the cache hit ratio begins to decrease, upgrading your database
will generally put it back in the green. The best way is to use the
[fast-changeover technique](heroku-postgres-follower-databases#database-upgrades-and-migrations-with-changeovers) to move between
plans, watch [New Relic](https://addons.heroku.com/newrelic), and see
what works best for your application's access patterns.

## Stand-alone vs. add-on provisioning

Heroku Postgres can be provisioned as a [stand-alone service](https://postgres.heroku.com/)
or attached to an application on Heroku [as an add-on](heroku-postgresql).
Though the same plans are available across both services and the underlying
technology and management infrastructure is the same there are some key differences.

When you provision a database from
[postgres.heroku.com](http://postgres.heroku.com), you do
not have direct CLI access for database administration.
Administration of these databases is only supported through the web
interface.

Many features will first be accessible via the heroku CLI for add-on
databases and may not manifest in the web UI until much later. Such
examples include [automatic credential
rotation](https://postgres.heroku.com/blog/past/2012/7/17/rotate_database_credentials_on_heroku_postgres_/)
and [pg:reset](heroku-postgresql#pg-reset).

Heroku Postgres databases created with the `heroku addons:add` command
are provisioned as add-ons and are tied to a specific application on
Heroku. Though they are listed and available for management in the
Heroku Postgres web UI their management features can also be accessed
via the heroku CLI. They retain all the features of the stand-alone
service and include features only accessible via the CLI.

If you are interested in CLI administration, you should create
the database via the CLI, even if you intend to principally
access it via [postgres.heroku.com](https://postgres.heroku.com/).

>note
>Applications on Heroku requiring a SQL database should [provision
>Heroku Postgres as an add-on](heroku-postgresql) with the `heroku
>addons:add heroku-postgresql` command.
         