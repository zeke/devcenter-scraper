---
title: Expensive Queries
slug: expensive-queries
url: https://devcenter.heroku.com/articles/expensive-queries
description: View trending information for queries on a database, track the queries executed per minute, average time, and total IO time on Heroku Postgres.
---

Expensive queries are the most significant cause of performance issues
on Heroku Postgres databases. Optimizing expensive queries can yield tremendous improvements to you application's performance and overall response times.

Heroku Postgres monitors trending information for queries on a database, tracking the queries executed per minute, average time, and total IO time. 

>callout
>Expensive Queries functionality is supported on Heroku Postgres database versions greater than 9.2. It is also not supported on the [Hobby tier](https://devcenter.heroku.com/articles/heroku-postgres-plans#plan-tiers).

To view the expensive queries for your database, navigate to your [database list](https://postgres.heroku.com/databases) and scroll down to the "Expensive Queries" section. A graph of the trending information for a query can be viewed by clicking on the query. The timezone on the graph is your local browser time. One week of performance information is stored.

![Expensive Queries Screenshot](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/351-original.jpg 'Expensive Queries Screenshot')

## Causes of Expensive Queries

The most common causes of expensive queries are:

* Lack of indexes, causing slow lookups on large tables,
* Unused indexes, causing slow `INSERT`, `UPDATE` and `DELETE` operations,
* Inefficient schema leading to bad queries
* Queries with inefficient designs
* Large databases size or lock contention, causing slow `COPY` operations (usually used for [logical backups](https://devcenter.heroku.com/articles/heroku-postgres-data-safety-and-continuous-protection#logical-backups-on-heroku-postgres)). 

## Solutions to Expensive Queries

These are some guidelines that may help fixing expensive queries:

* Run `EXPLAIN ANALYZE` (though [pg:psql](https://devcenter.heroku.com/articles/heroku-postgresql#pg-psql)) to find out what is taking up most of the execution time of the query. A sequential scan on a large table is typically, but not always, a bad sign. Efficient indexes can improve query performance dramatically. Consider [all Postgres techniques](https://devcenter.heroku.com/articles/postgresql-indexes) such as partial indexes and
others when devising your index strategy.
* Look for unused indexes by running `heroku pg:diagnose`. Drop any that are not required. 
* Upgrade your database to the latest version: Postgres performance is known to improve on every release. 
* For large database, prefer relying on our [continuous protection](https://devcenter.heroku.com/articles/heroku-postgres-data-safety-and-continuous-protection#physical-backups-on-heroku-postgres) for day to day disaster recovery purposes. Remove any auto `pgbackups` plans and use pgbackups strictly for [extracting or migrating data](https://devcenter.heroku.com/articles/heroku-postgres-data-safety-and-continuous-protection#logical-backups-on-heroku-postgres).
* For smaller database, slow logical backups can be a result of lock contention.