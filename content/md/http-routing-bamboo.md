---
title: HTTP Routing on Bamboo
slug: http-routing-bamboo
url: https://devcenter.heroku.com/articles/http-routing-bamboo
description: A description of how Heroku routes requests on the Bamboo stack, including the HTTP stack and timeouts
---

> warning
> This article applies to apps using the deprecated Bamboo routing stack. You need to [migrate your app's routing to the current routing stack](moving-to-the-current-routing-stack) by September 22, 2014.

The Heroku platform automatically routes HTTP requests sent to your app's hostname(s) through to all of your web dynos.

Applications running on the [Bamboo](bamboo) stack use the `heroku.com` HTTP stack. Apps on the [Cedar](cedar) stack use the newer `herokuapp.com` HTTP stack, which offers [more direct routing](http-routing) to your dyno to allow more advanced uses of HTTP.

> callout
> [Bamboo](bamboo) apps use the heroku.com stack.  Any request sent to `*.heroku.com` is using the `heroku.com` stack.  The new [Cedar](cedar) stack uses `*.herokuapp.com`.

### Request distribution

A request sent to Bamboo app `myapp.heroku.com` passes through an [nginx](http://nginx.org/) proxy, into a Heroku router, and finally to one of the app's dynos, chosen at random.

### Request queueing

Each router node maintains an internal per-app request queue. For Bamboo apps, router nodes limit the number of active requests per dyno to 1 and queue additional requests. There is no coordination between routing nodes however, so this request limit is per routing node. The request queue on each router has a maximum backlog size of 50n (n = the number of web dynos your app has running). If the request queue on a particular router fills up, subsequent requests to that router will immediately return an [H11 (Backlog too deep)](error-codes#h11-backlog-too-deep) response.

### Request body size limit

The `heroku.com` stack has a 30 megabyte request body size limit.

### 30 second timeout

All requests on the `heroku.com` stack are limited to 30 seconds total time. Any request that takes more than 30 seconds will be [returned to the user as an error page](http://devcenter.heroku.com/articles/request-timeout). This 30-second limit is measured by the router processing the request, and includes all time spent in the dyno, including the kernel’s incoming connection queue and the app itself.

### HTTP 1.0

The `heroku.com` stack is HTTP 1.0 compliant only.  HTTP 1.1 features such as long-polling and chunked response are not supported. 