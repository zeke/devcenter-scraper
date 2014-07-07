---
title: Scaling Your Dyno Formation
slug: scaling
url: https://devcenter.heroku.com/articles/scaling
description: Each app on Heroku has a set of running dynos, its dyno formation, which can be scaled up or down instantly from the command line or dashboard.
---

All apps on Heroku use a [process model](process-model) (via [Procfile](procfile)) that lets them scale up or down instantly from the command line or Dashboard.  Each app has a set of running dynos, managed by the [dyno manager](dynos#the-dyno-manager), which are known as its dyno formation.

## Scaling

> callout
> Dynos are [prorated to the second](usage-and-billing), so if you want to experiment with different configurations, you can do so and only be billed for actual seconds set. Remember, it's your responsibility to set the correct number of dynos and workers for your app.


A web app typically has at least web and worker process types.  You can set the concurrency level for either one by adjusting the number of [dynos](dynos) running each process type with the `ps:scale` command:

```term
$ heroku ps:scale web=2
Scaling web processes... done, now running 2
```

Or both at once:

```term
$ heroku ps:scale web=2 worker=1
Scaling web processes... done, now running 2
Scaling worker processes... done, now running 1
```

Scaling dynos quantities can be specified as an absolute number or an increment from the current number of dynos.

```term
$ heroku ps:scale web+2
Scaling web processes... done, now running 4
```

If you want to stop running a particular process type entirely, simply scale it to&nbsp;`0`:

```term
$ heroku ps:scale worker=0
Scaling worker processes... done, now running 0
```

Dynos can also be scaled vertically, providing them with more memory and CPU share. See [the documentation on dyno size](https://devcenter.heroku.com/articles/dyno-size) for more information.

## Dyno formation

The term *dyno formation* refers to the layout of your app's dynos at a given time.  The default formation for simple apps will be a single web dyno, whereas more demanding applications may consiste of web, worker, clock etc... process types.  In the examples above, the formation was first changed to two web dynos, then two web dynos and a worker.

> callout
> The scale command affects only process types named in the command.  For example, if the app already has a dyno formation of two web dynos, and you run `heroku ps:scale worker=2`, you will now have a total of four dynos (two web, two worker).

## Listing dynos

The current dyno formation can always been seen via the ` heroku ps` command:

```term
$ heroku ps
=== web: `bundle exec unicorn -p $PORT -c ./config/unicorn.rb`
web.1: up for 8h
web.2: up for 3m

=== worker: `bundle exec stalk worker.rb`
worker.1: up for 1m
```

The unix [watch utility](http://www.thegeekstuff.com/2010/05/watch-command-examples/) can be very handy in combination with the `ps` command.  Run `watch heroku ps` in one terminal while you add or remove dynos, deploy, or restart your app.

## Introspection

Any changes to the dyno formation are logged:

```term
$ heroku logs | grep Scale
2011-05-30T22:19:43+00:00 heroku[api]: Scale to web=2, worker=1 by adam@example.com
```

Note that the logged message includes the full dyno formation, not just dynos mentioned in the scale command.

## Understanding concurrency

> callout 
> Singleton process types, such as [clock/scheduler process](scheduled-jobs-custom-clock-processes) type or a process type to consume the Twitter streaming API, should never be scaled beyond a single dyno.  They can't benefit from additional concurrency and in fact they will create duplicate records or events in your system as each tries to do the same work at the same time.

Scaling up a given process type gives you more concurrency for the type of work handled by that process type.  For example, adding more web dynos allows you to handle more concurrent HTTP requests, and therefore higher volumes of traffic.  Adding more worker dynos will let you process more jobs in parallel, and therefore higher volumes of jobs.

There are circumstances where creating more dynos to run your web, worker, or other process types won't help.  One of these is bottlenecks on backing services, most commonly the database.  If your database is a bottleneck, adding more dynos may actually make the problem worse.  Instead, optimize your database queries, upgrade to a larger database, use caching to reduce load on the database, or switch to a sharded or read-slave database configuration.

Another circumstance where increased concurrency won't help is long requests or jobs.  For example, a slow HTTP request such as a report with a database query that takes 30 seconds, or a job to email out your newsletter to 20k subscribers.  Concurrency gives you horizontal scale, which means it applies to work that can be subdivided - not large, monolithic work blocks.

The solution to the slow report might be to move the report calculation into the [background](background-jobs-queueing) and cache the results in memcache for later display.  For the long job, the answer is to subdivide the work - create a single job which fans out by putting 20k jobs (one for each newsletter to be sent) onto the queue.  A single worker can consume all these jobs in sequence, or you can scale up to multiple workers to consume these jobs more quickly.  The more workers you add, the more quickly the entire batch will finish.

The [Request Timeout](request-timeout) article has more information on the effects of concurrency on [request queueing efficiency](request-timeout#request-queueing-efficiency). 