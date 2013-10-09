---
title: Correctly Establishing Postgres Connections in Forked Environments
slug: forked-pg-connections
url: https://devcenter.heroku.com/articles/forked-pg-connections
description: Connecting to a Postgres database from a forked environment requires that each connection be established after forking has occurred.
---

  By design, connections to Postgres databases are persistent to reduce
the performance impact of having to re-establish a connection for
every invocation. While this increases the performance of your
application it also requires properly establishing the connection,
especially in forked environments.

## Forked environments

If you are using a framework or library that utilizes forked
processes, connections to Postgres (and any other resources) should be
established after the fork completes. This ensures that each forked
process has its own connection and avoids several of the most common
connections errors such as `no connection to the server` and `SSL
SYSCALL error: EOF detected`

Connection instructions for several common frameworks and libraries
are included here.

## Database connection pools

When using a fork-based server of any kind, each fork will receive its
own database connection pool.  For this reason, most applications
using fork-based web servers receive the best performance when the
application-level (e.g. Rails, Sequel, Django, etc) connection pool is
not used, or used with a pool size of one.

Overuse of database connections can result in lower overall
performance, "out of memory" errors reported by the database server,
and the database server's refusal to accept connections from
additional clients (connection limit reached).

Applications that are exempt from this advice tend to have been
purposefully written to take advantage of or require multiple
simultaneous transactions within the context of a single HTTP request.

## Ruby on Rails

Important Postgres reconnection bugs have been fixed in ActiveRecord
3.2.9. Previous releases (3.1, 3.0, 2.x) have not received these
enhancements. If you're using ActiveRecord 3.2, upgrading to a version
at or above 3.2.9 is recommended.

For previous versions, exiting the process when `PGError` is
propagated from the application is recommended since Heroku will
automatically [restart crashed
dynos](dynos#automatic-dyno-restarts).

## Unicorn server

[Unicorn](http://unicorn.bogomips.org/) is a Rack HTTP server that
uses forked process to handling incoming requests. Specify the before
and after fork behavior in the [`unicorn.conf` configuration
file](http://unicorn.bogomips.org/examples/unicorn.conf.rb).

In a Rails app or an app using `ActiveRecord` add the following
`before_fork` and `after_fork` blocks in `unicorn.conf`:

    :::ruby
    before_fork do |server, worker|

      Signal.trap 'TERM' do
        puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
        Process.kill 'QUIT', Process.pid
      end

      defined?(ActiveRecord::Base) and
        ActiveRecord::Base.connection.disconnect!
    end

    after_fork do |server, worker|

      Signal.trap 'TERM' do
        puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
      end

      defined?(ActiveRecord::Base) and
        ActiveRecord::Base.establish_connection

    end

## Resque ruby queuing

[Resque](https://github.com/defunkt/resque) uses forking to create new
worker processes. The main process connection should be disconnected
before forking (to avoid consuming unnecessary resources) while worker
connections should be established [after the fork
occurs](https://github.com/resque/resque/blob/master/docs/HOOKS.md).

You can specify this behavior by cleaning up and re-establishing
connections in an initializer:

    :::ruby
      Resque.before_fork do
        defined?(ActiveRecord::Base) and
          ActiveRecord::Base.connection.disconnect!
      end

      Resque.after_fork do
        defined?(ActiveRecord::Base) and
          ActiveRecord::Base.establish_connection
      end

## Disabling New Relic EXPLAIN

The current implementation of New Relic auto-`EXPLAIN` can cause one
extra database connection to be used per fork.  For high-volume
applications that cannot tolerate the extra connection, it may be
worthwhile to disable the automatic `EXPLAIN` feature of New Relic.

Staff from New Relic [have
indicated](https://twitter.com/amateurhuman/status/308692401483042816)
that this use of connections may be optimized in the future.

If using Postgres 9.2 or later, investigating
[pg_stat_statements](https://postgres.heroku.com/blog/past/2012/12/6/postgres_92_now_available#visibility)
is recommended.  Useful in its own right, it can also help mitigate
some of the loss in visibility caused by disabling New Relic's
auto-`EXPLAIN`.

        