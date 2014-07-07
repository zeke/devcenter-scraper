---
title: Expensive Queries
slug: expensive-queries
url: https://devcenter.heroku.com/articles/expensive-queries
description: View trending information for queries on a database, track the queries executed per minute, average time, and total IO time on Heroku Postgres.
---

Expensive queries are the most significant cause of performance issues
on Heroku Postgres databases. Optimizing expensive queries can yield tremendous improvements to you application's performance and overall response times.

Heroku Postgres ([Standard Tier](https://devcenter.heroku.com/articles/heroku-postgres-plans#standard-tier) and [above](https://devcenter.heroku.com/articles/heroku-postgres-plans#premium-tier)) monitors trending information for queries on a database, tracking the queries executed per minute, average time, and total IO time. 

To view the expensive queries for your database, navigate to your [database list](https://postgres.heroku.com/databases) and scroll down to the "Expensive Queries" section. A graph of the trending information for a query can be viewed by clicking on the query. The timezone on the graph is your local browser time. One week of performance information is stored.

![Alt text](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/349-original.jpg 'Expensive Query Screenshot')

## Causes of Expensive Queries

The most common causes of expensive queries are:

* Lack of indexes, causing slow lookups on large tables,
* Unused indexes, causing slow `INSERT`, `UPDATE` and `DELETE` operations,
* Inefficient schema leading to bad queries, and
* Queries that are written poorly and require rewrite

## Solutions to Expensive Queries

These are some guidelines that may help fixing expensive queries:

* Run `EXPLAIN ANALYZE` to find out what is taking up most of the execution                                        time of the query. A sequential scan on a large table is typically, but not
always, a bad sign. Efficient indexes can improve query performance
dramatically. Consider [all Postgres techniques](https://devcenter.heroku.com/articles/postgresql-indexes) such as partial indexes and
others when devising your index strategy.
* Find out if there are unused indexes by running `heroku pg:unused_indexes`,
available on the pg-extras plugin, and remove them.
* Upgrade your database to the latest version: Postgres performance is known to improve on every release. 