---
title: Limits
slug: limits
url: https://devcenter.heroku.com/articles/limits
description: A convenient aggregation of limits imposed on various components of the Heroku platform, as documented elsewhere on Dev Center.
---

This is an aggregation of the limits imposed on various components of the Heroku platform.  It lists only the limits (number of connections, for example) not the features (this database plan has that capability). 

Limits exist for several reasons.  Sometimes limits are present because of how the underlying platform is constructed: for example, Heroku stores only 1500 lines of log history (the rest being available via a logging add-on). Sometimes limits are present because they enforce good citizenship: for example, you can't make more than 1200 API requests an hour. 

Each limit here is documented with a link to the source document that documents the limit, and which provides a lot more context to the limit.  

## Logplex

### Log history limits

Heroku only stores the last 1500 lines of log history. If you’d like to persist more than 1500 lines, use a logging add-on or create your own syslog drain.

[Source](logging#log-history-limits)

## Router

### HTTP timeouts

HTTP requests have an initial 30 second window in which the web process must return response data (either the completed response or some amount of response data to indicate that the process is active). Processes that do not send response data within the initial 30-second window will see an H12 error in their logs.

After the initial response, each byte sent (either from the client or from your app process) resets a rolling 55 second window. If no data is sent during this 55 second window then the connection is terminated and a H15 error is logged.

[Source](http-routing#timeouts)

### HTTP response buffering

The router maintains a 1MB buffer for responses from the dyno per connection.

[Source](http-routing#response-buffering)

### HTTP request buffering

When processing an incoming request, a router sets up an 8KB receive buffer and begins reading the HTTP request line and request headers. Each of these can be at most 8KB in length, but together can be more than 8KB in total. Requests containing a request line or header line longer than 8KB will be dropped by the router without being dispatched.

[Source](http-routing#request-buffering)

## Dynos

### Dyno memory

Dynos are available in 1X or 2X sizes and are allocated 512MB or 1024MB respectively.

If the memory size of your dyno keeps growing until it reaches three times its quota (for a 1X dyno, 512MB x 3 = 1.5GB), the dyno manager will restart your dyno with an R15 error.

[Source](dynos#memory-behavior)

### Attached one-off dyno timeout

Connections to one-off dynos will be closed after one hour of inactivity (in both input and output). When the connection is closed, the dyno will be sent SIGHUP. This idle timeout helps prevent unintended charges from leaving interactive console sessions open and unused.

[Source](one-off-dynos#one-off-dyno-timeout)

### Concurrent one-off dynos

Heroku accounts [that aren’t verified](https://devcenter.heroku.com/articles/account-verification) cannot have more than 3 one-off dynos running concurrently.

[Source](https://devcenter.heroku.com/articles/one-off-dynos#limits)

### Config vars

Config var data (the collection of all keys and values) is limited to 16kb for each app.

[Source](config-vars#limits)

### Boot timeout

The web process in a dyno may not take more than 60 seconds to bind to its assigned $PORT. 

> note
> Contact support to increase this limit to 120 seconds on a per-application basis. In general, slow boot times will make it harder to deploy your application and will make recovery from dyno failures slower, so this should be considered a temporary solution.

[Source](error-codes#r10-boot-timeout)

### Exit timeout

When a dyno is killed or restarted, the processes within the dyno have 10 seconds in which to exit on receiving a SIGTERM. The process is sent SIGKILL to force an exit after this 10 seconds.

[Source](error-codes#r12-exit-timeout)

### Dyno restart limits

Heroku’s dyno restart policy is to try to restart crashed dynos by spawning new dynos once every ten minutes. This means that if you push bad code that prevents your app from booting, your app dynos will be started once, then restarted, then get a cool-off of ten minutes. In the normal case of a long-running web or worker process getting an occasional crash, the dyno will be restarted instantly without any intervention on your part. If your dyno crashes twice in a row, it will stay down for ten minutes before the system retries.

[Source](dynos#automatic-dyno-restarts)

### Dyno scale

By default, a process type can't be scaled to more than 100 dynos.  Contact support to raise this limit for your application.

[Source](scaling#limits)

### Processes / threads

1X Dynos are limited a combined sum of 256 processes and threads. 2X Dynos are limited to 512. This limit applies whether they are executing, sleeping, or in any other state. 

[Source](dynos)

## Build

### Git requests

Users are [limited](git#other-limits) to a rolling window of 75 requests to [Heroku Git repos](git) per hour, per app.

[Source](git#other-limits)

### Slug size

Your slug size is displayed at the end of a successful compile. The maximum slug size is 300MB; most apps should be far below this limit.

[Source](slug-compiler#slug-size)

### Slug compilation

Slug compilation is limited to 15 minutes.

[Source](/articles/slug-compiler#time-limit)

## Heroku Postgres

### Dataclips row limits

Dataclips may return up to 29,999 rows.

[Source](dataclips#limits)

### Dataclips query limit timeout

Dataclips will cancel queries after 10 minutes.

[Source](dataclips#limits)

### Standard, Premium, and Enterprise tier

* 1 TB of storage
* Maximum of 500 connections
* In-memory cache ([size dependent on plan](https://www.heroku.com/pricing#postgres))

[Source](heroku-postgres-plans#standard-tier)

### Hobby tier

* Enforced row limits of 10,000 rows for `dev` and 10,000,000 for `basic` plans
* Maximum of 20 connections
* No in-memory cache

[Source](heroku-postgres-plans#hobby-tier)

## API

### Heroku API limits

The rate limit on calls to the Heroku API is 1200 calls per hour.

[Source](https://devcenter.heroku.com/articles/platform-api-reference#rate-limits)

## Bamboo

The Bamboo `heroku.com` stack has a 30 megabyte request body size limit.

[Source](https://devcenter.heroku.com/articles/http-routing-bamboo#request-body-size-limit)

## Other

### Maximum number of applications

Unverified accounts can create at most 5 apps. Verified accounts can create no more than 100 applications.

[Source](https://devcenter.heroku.com/articles/account-management#application-limit)