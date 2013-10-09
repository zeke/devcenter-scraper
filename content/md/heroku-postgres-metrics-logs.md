---
title: Heroku Postgres Metrics Logs
slug: heroku-postgres-metrics-logs
url: https://devcenter.heroku.com/articles/heroku-postgres-metrics-logs
description: A description of the log format used by Heroku Postgres Production Tier databases.
---

Heroku Postgres [Production Tier database](https://devcenter.heroku.com/articles/heroku-postgres-plans#production-tier) users will see database-related events on their app's log stream. This can be useful for recording and analyzing usage over time.

## Log format

```term
2013-05-07T17:41:06+00:00 source=HEROKU_POSTGRESQL_VIOLET sample#current_transaction=1873 sample#db_size=26219348792bytes sample#tables=13 sample#active-connections=92 sample#waiting-connections=1 sample#index-cache-hit-rate=0.99723 sample#table-cache-hit-rate=0.99118
```


The attributes found on the log are:

* `sample#db_size`: The number of bytes contained in the database. This includes all
table and index data on disk, including database bloat.
* `sample#tables`: The number of tables in the database.
* `sample#active-connections`: The number of [connections](https://devcenter.heroku.com/articles/heroku-postgres-plans#production-tier) established on the database.
* `sample#current_transaction`: The current transaction ID, which can be used to track writes over time.
* ` sample#index-cache-hit-rate`: Rate of index lookups served from [shared buffer cache](https://devcenter.heroku.com/articles/understanding-postgres-data-caching), rounded to five decimal points.
* `sample#table-cache-hit-rate`: Rate of table lookups served from [shared buffer cache](https://devcenter.heroku.com/articles/understanding-postgres-data-caching), rounded to five decimal points.
* `sample#waiting-connections`: Number of connections waiting on a lock to be acquired. If many connections are waiting, this can be a sign of mishandled [database concurrency](https://devcenter.heroku.com/articles/postgresql-concurrency). 
* `source`: The database name the measurements relate to.
* The log line's timestamp is the time at which the measurements were taken.