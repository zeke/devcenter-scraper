---
title: Heroku Postgres Metrics Logs
slug: heroku-postgres-metrics-logs
url: https://devcenter.heroku.com/articles/heroku-postgres-metrics-logs
description: A description of the log format used by Heroku Postgres Standard and Premium Tier databases.
---

Heroku Postgres [Standard and Premium Tier database](https://devcenter.heroku.com/articles/heroku-postgres-plans#standard-tier) users will see database-related events on their app's log stream. This can be useful for recording and analyzing usage over time.

<div class="callout">
Heroku Postgres Metrics which appear via `heroku-postgres` are separate from standard alerts emitted from Postgres itself which appear for all applications via `postgres`.
</div>

## Log format

```term
2013-05-07T17:41:06+00:00 source=HEROKU_POSTGRESQL_VIOLET sample#current_transaction=1873 sample#db_size=26219348792bytes sample#tables=13 sample#active-connections=92 sample#waiting-connections=1 sample#index-cache-hit-rate=0.99723 sample#table-cache-hit-rate=0.99118 sample#load-avg-1m=1.42 sample#load-avg-5m=1.45 sample#load-avg-15m=1.34 sample#read-iops=0 sample#write-iops=2.875 sample#memory-total=1692568kB sample#memory-free=73876kB sample#memory-cached=1344128kB sample#memory-postgres=22388kB
```


The attributes found on the log are, for all standard and premium tier databases:

* `source`: The database name the measurements relate to.
* The log line's timestamp is the time at which the measurements were taken.
* `sample#db_size`: The number of bytes contained in the database. This includes all
table and index data on disk, including database bloat.
* `sample#tables`: The number of tables in the database.
* `sample#active-connections`: The number of [connections](https://devcenter.heroku.com/articles/heroku-postgres-plans#standard-tier) established on the database.
* `sample#current_transaction`: The current transaction ID, which can be used to track writes over time.
* ` sample#index-cache-hit-rate`: Rate of index lookups served from [shared buffer cache](https://devcenter.heroku.com/articles/understanding-postgres-data-caching), rounded to five decimal points.
* `sample#table-cache-hit-rate`: Rate of table lookups served from [shared buffer cache](https://devcenter.heroku.com/articles/understanding-postgres-data-caching), rounded to five decimal points.
* `sample#waiting-connections`: Number of connections waiting on a lock to be acquired. If many connections are waiting, this can be a sign of mishandled [database concurrency](https://devcenter.heroku.com/articles/postgresql-concurrency).
* `sample#load-avg-1m`, `sample#load-avg-5m` and `sample#load-avg-15m`: The average system load over a period of 1 minute, 5 minutes and 15 minutes, divided by the number of available cpu.
* `sample#read-iops` and `sample#write-iops`: Number of reads or writes operations in I/O sizes of 16KB blocks.
* `sample#memory-total`: Total amount of memory available in kB.
* `sample#memory-free`: Amount of free memory available in kB.
* `sample#memory-cached`: Amount of cached memory in kB.
* `sample#memory-postgres`: Approximate amount of memory used by PostgreSQL in kB. 