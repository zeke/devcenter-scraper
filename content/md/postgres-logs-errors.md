---
title: Understanding Heroku Postgres Log Statements and Common Errors
slug: postgres-logs-errors
url: https://devcenter.heroku.com/articles/postgres-logs-errors
description: Heroku Postgres log statements and common errors.
---

[Heroku Postgres](heroku-postgresql) logs to the [logplex](logplex) which collates and publishes your application's log-stream. You can isolate Heroku Postgres events [with the `heroku logs` command](logging) by filtering for the `postgres` process.

>warning
>Logs are a production-tier feature. They are not available on hobby-tier databases.

```term
$ heroku logs -p postgres -t
2012-11-01T17:41:42+00:00 app[postgres]: [15521-1]  [CHARCOAL] LOG:  checkpoint starting: time
2012-11-01T17:41:43+00:00 app[postgres]: [15522-1]  [CHARCOAL] LOG:  checkpoint complete: wrote 6 buffers (0.0%); 0 transaction log file(s) added, 0 rem...
```

Besides seeing system-level Postgres activity, these logs are also useful for understanding your application's use of Postgres and for diagnosing common errors. This article lists common log statements, their purpose, and any action that should be taken.

## LOG: duration: 66.565 ms ...

    [12-1] u8akd9ajka [BRONZE] LOG:  duration: 64.847 ms  statement: SELECT  "articles".* FROM "articles"...

Queries taking longer than 50ms (or 2 seconds on Postgres 9.2+, where `pg_stat_statements` becomes available as a better alternative) are logged so they can be identified and optimized. Although small numbers of these long-running queries will not adversely effect application performance, a large quantity may. 

Ideally, frequently used queries should be optimized to require < 10ms to execute. Queries are typically optimized by [adding indexes](postgresql-indexes) to avoid sequential scans of the database. Use [EXPLAIN](http://www.postgresql.org/docs/9.1/static/sql-explain.html) to diagnose queries. 

## LOG: checkpoint starting...

    2012-11-01T17:41:42+00:00 app[postgres]: [15521-1]  [CHARCOAL] LOG:  checkpoint starting: time
    2012-11-01T17:41:43+00:00 app[postgres]: [15522-1]  [CHARCOAL] LOG:  checkpoint complete: wrote 6 buffers (0.0%); 0 transaction log file(s) added, 0 rem...

`LOG:  checkpoint starting` and the corresponding `LOG:  checkpoint complete` statements are part of Postgres' [Write-Ahead Logging (WAL)](http://www.postgresql.org/docs/9.1/static/wal-intro.html) functionality. Postgres automatically puts a checkpoint in the transaction log every so often. You can find more information [here](http://www.postgresql.org/docs/9.1/static/sql-checkpoint.html).

These statements are part of normal operation and no action is required.

## LOG: could not receive data from client: Connection reset by peer 
## LOG: unexpected EOF on client connection

    app[postgres]: LOG:  could not receive data from client: Connection reset by peer
    app[postgres]: LOG:  unexpected EOF on client connection
    heroku[router]: at=error code=H13 desc="Connection closed without response" method=GET path=/crash host=pgeof.herokuapp.com dyno=web.1 connect=1ms service=10ms status=503 bytes=0
    heroku[web.1]: Process exited with status 1
    heroku[web.1]: State changed from up to crashed

Although this log is emitted from postgres, the cause for the error has nothing to do with the database itself. Your application happened crash while connected to postgres, and did not clean up its connection to the database. Postgres noticed that the client (your application) disappeared without ending the connection properly, and logged a message saying so.

If you are not seeing your application's backtrace, you may need to ensure that you are, in fact, logging to stdout (instead of a file) and that you have stdout sync'd.

## FATAL:  too many connections for role

    FATAL:  too many connections for role "[role name]"

This occurs on Hobby Tier (hobby-dev and hobby-basic) plans, which have a [max connection limit of 20 per user](https://devcenter.heroku.com/articles/heroku-postgres-plans#hobby-tier). To resolve this error, close some connections to your database by stopping background workers, reducing the number of dynos, or restarting your application in case it has created connection leaks over time. A discussion on handling connections in a Rails application can be found [here](https://devcenter.heroku.com/articles/concurrency-and-database-connections).

## FATAL: could not receive data ...

    FATAL: could not receive data from WAL stream: SSL error: sslv3 alert unexpected message

[Replication from a primary database to a follower](heroku-postgres-follower-databases) was interrupted either because of a transient network error or because SSL failed to renegotiate. This is a transient problem and postgres should automatically recover.

You can always find out the current number of commits a follower is behind by using `heroku pg:info`. Each follower has a "Behind By" entry that indicates how many commits the follower is behind its master.

```term
$ heroku pg:info --app sushi
=== HEROKU_POSTGRESQL_WHITE 
...
Following    HEROKU_POSTGRESQL_LAVENDER (DATABASE_URL)
Behind By    125 commits
```

## FATAL: role "role-name"…

    FATAL: role "u8akd9ajka" is not permitted to log in (PG::Error)

This occurs when you have de-provisioned a [hobby tier database](heroku-postgres-plans#hobby-tier) but are still trying to connect to it. To resolve:

* If required, [provision a new database](heroku-postgresql) via `heroku addons:add heroku-postgresql`
* Use `heroku pg:promote HEROKU_POSTGRESQL_<new-database-color>` to promote it, making it the primary database for your application.

## FATAL: terminating connection due to administrator command

    FATAL: terminating connection due to administrator command

This message indicates a backend connection was terminated. This can happen when a user issues `pg:kill` from the command line client, or similarly runs `SELECT pg_cancel_backend(pid);` from a psql session.

## FATAL: remaining connection slots are reserved for non-replication superuser connections

    FATAL: remaining connection slots are reserved for non-replication superuser connections

Each database plan has a maximum allowed number of connections available, which vary by plan. This message indicates you have reach the maximum number allowed for your applications, and remaining connections are reserved for super user access (restricted to Heroku Postgres staff). See [Heroku Postgres Production Tier Technical Characterization](https://devcenter.heroku.com/articles/heroku-postgres-production-tier-technical-characterization) for details on connection limits for a given plan. 

## temporary file: path "file path", size "file size"

    temporary file: path "base/pgsql_tmp/pgsql_tmp23058.672", size 1073741824

We configure Postgres to log temporary file names and sizes when the size exceeds 10240 kilobytes. Temporary files can be created when performing sorts, hashes or for temporary query results, and log entries are made for each file when it is deleted.

This log entry is just a informational, as creating a large number of temporary files impacts query performance.

## PGError: permission denied for relation

    PGError: ERROR:  permission denied for relation table-name

Heroku Postgres [hobby tier databases](heroku-postgres-plans#hobby-tier) have row limits enforced. When you are [over your row limit](heroku-postgres-plans#row-limit-enforcement) and attempt to insert data you will see this error. [Upgrade to a production tier database](upgrade-heroku-postgres-with-pgbackups) or reduce the number of total rows to remove this constraint.

## PGError: operator does not exist

    PGError: ERROR:  operator does not exist: character varying = integer

Postgres is more sensitive with data types than MySQL or SQlite. Postgres will check and throw errors when an operator is applied to an unsupported data type. For instance, you can't compare strings with integers without casting.

Make sure the operator is adequate for the data type or that the necessary [type casts](http://www.postgresql.org/docs/9.1/static/sql-expressions.html#SQL-SYNTAX-TYPE-CASTS) have been applied.

## PGError: relation "table-name" does not exist

    PGError: ERROR: relation "documents" does not exist

This is the standard message displayed by Postgres when a table doesn't exist. That means your query is referencing a table that is not on the database.

Make sure your migrations ran normally, and that you're referencing a table that exists.

## PGError: column "column-name" cannot...

    PGError: ERROR: column "verified_at" cannot be cast to type "date"

This occurs when Postgres doesn't know how to cast all the row values in that table to the specified type. Most likely it means you have an integer or a string in that column.

Inspect all affected column values and manually remove or translate values that can't be converted to the required type.

## PGError: SSL SYSCALL error: EOF detected

Errors with similar root causes include:

* `no connection to the server`
* `SSL error: decryption failed or bad record mac`
* `could not receive data from server: Connection timed out`

These errors indicate a client side violation of the wire protocol. This happens for one of two reasons:

* The Postgres connection is shared between more than one process or thread. Typical offenders are Resque workers or Unicorn. Be sure to [correctly establish the PG connection after the fork or thread has initialized](forked-pg-connections) to resolve this issue.
* Abrupt client (application side) disconnections. This can happen for many reasons, from your app crashing, to transient network availability. When your app tries to issue a query again against postgres, the connection is just gone, leading to a crash. When Heroku detects a crash, we kill that dyno and start a new one, which re-establishes the connection.

## PGError: prepared statement "a30" already exists

This is similar to the above--there is no protocol violation, but the
client is mistakenly trying to set up a prepared statement with the
same name as an existing one without cleaning up the original (the
name of the prepared statement in the error will, of course, vary).

This is also typically caused by [a Postgres connection shared improperly](forked-pg-connections)
between more than one process or thread.

## This database does not support forking and following

Some older Ronin and Fugu databases provisioned on a 32-bit processor architecture don't support forking and following to current plans, all of which are 64-bit. If have one of these databases, you will see an error message such as this:

```term
$ heroku addons:add heroku-postgresql:ika --follow HEROKU_POSTGRESQL_RED
----> Adding heroku-postgresql:ika to sushi... failed
 !    This database does not support forking and following to the ika plan.
 !    Please see http://devcenter.heroku.com/articles/unsupported-fork-follow
```

Your database is fine and is still supported. However if you'd like to use the fork or follow feature you will need to first create a fresh database with [PG Backups](upgrade-heroku-postgres-with-pgbackups) from which you can then fork or follow. 