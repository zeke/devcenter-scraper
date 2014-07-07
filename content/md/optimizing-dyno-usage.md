---
title: Optimizing Dyno Usage
slug: optimizing-dyno-usage
url: https://devcenter.heroku.com/articles/optimizing-dyno-usage
description: A guide to optimizing applications for differently sized dynos on Heroku
---

A fundamental aspect to optimizing any application is to ensure it is [architected appropriately](https://devcenter.heroku.com/articles/architecting-apps). For example, it should use [background jobs](https://devcenter.heroku.com/articles/background-jobs-queueing) for computationally intensive tasks in order to keep request times short, and use a [process model](https://devcenter.heroku.com/articles/runtime-principles#process-model) to ensure that separate parts of the application can be scaled independently.

Beyond this, you may reach a point where you need to scale or optimize by making more efficient use of available resources. For example, if your web requests are short and handled efficiently, you could be able to increase throughput on a dyno by increasing the ability of the web server to handle more requests concurrently, usually at the expense of using more RAM.  

The article provides a bird's-eye view of how to go about optimizing an application for the various dyno sizes.  It provides some rough estimates of capabilities, and pays particular attention to memory usage and concurrency. The techniques suggested in this article are relevant to any environment that runs your application, not just a dyno.

## Considering different dyno sizes

Heroku offers a range of [dyno sizes](https://devcenter.heroku.com/articles/dyno-size) - 1X, 2X and PX. Each size has a different CPU and RAM profile.

Changing the dyno size of an application increases complexity: as a developer you have introduced a new variable, the size of the dyno, in addition to the number of dynos.

However, a well designed app will quite naturally be able to make use of different dyno sizes, and thinking about optimizing your application to make better use of a dyno is a worthwhile endeavor.

Even if your application doesn't need to make use of different dyno sizes, consider applying these optimization techniques to your current dyno size anyway.

The different [dyno sizes](https://devcenter.heroku.com/articles/dyno-size) offer three important axes of optimization: CPU, RAM and the performance profile.

###CPU

Most applications are not CPU-bound on the web server.

If you are processing individual requests slowly due to CPU or other shared resource constraints (such as database), then optimizing concurrency on the dyno may not help your application's throughput at all. Put another way, if your application is slow when there is little traffic, the techniques in this article may not increase performance.

The different dyno sizes do offer different CPU performance characteristics, and will aid a little in a high-CPU situations, but ideally you should consider offloading work to a [background worker](https://devcenter.heroku.com/articles/background-jobs-queueing) as a first step in optimization, as well as optimizing the code.

A final aspect of CPU is the number of cores. The different dyno sizes, PX in particular, offer multiple cores.  With multiple cores, you may be able to execute multiple threads in parallel.  This article points out where you need to take action to make use of these cores.

The rest of this article will assume the application is not CPU-bound.

###RAM

Depending on language and web framework, there is typically a direct correspondence between RAM and concurrency.

For example, web servers like Unicorn for Ruby, or Gunicorn for Python, pre-fork a number of identical copies of your web servers (called workers). Unicorn then has its own connection queue, and as workers finish a web request, they pull a new request off of the queue.

Having more RAM in this scenario means that you can have more workers running concurrently - and there is typically a fairly linear correlation between RAM and concurrency.  Optimizing concurrency for RAM is something this article addresses.

### Performance profile

The performance profile of each dyno size can have an impact.  In particular, 1X and 2X dynos operate on a CPU-share basis, whereas PX dynos have a single tenant 8-core CPU.

Much like the various [Heroku Postgres](https://devcenter.heroku.com/articles/heroku-postgres-production-tier-technical-characterization#multitenancy) tiers, PX dynos therefore offer a higher level of resource isolation.

This can have a significant impact on applications, depending on the amount of traffic that they're receiving and how well they're optimized.  In particular, a more consistent performance profile can lead to reduced tail latencies.

## When to try a different dyno size

There are many factors that come into play when considering different dyno sizes. Some of them are inherent to your application (how much CPU does it use), some are due to optimization factors introduced by increased concurrency (due to having more RAM) and some due to the inherent characteristics of the dyno itself.

This complexity can be difficult to navigate, but the simple techniques suggested in this article for applications that are not CPU bound can be found make it a lot more tractable and easy to optimise for any dyno size.

Once you have optimized for a particular dyno size, say 1X dynos, apply the same techniques on a 2X or PX dyno - taking into account the factors that each dyno size introduce.

Here are some rough rules of thumb:

* For most applications that aren't receiving tremendously high volumes of traffic, consider 1X dynos.
* If the application is particularly memory-hungry, as seen in some Java-based frameworks such as Play and JRuby, consider 2X dynos which doubles the memory.
* For very high volume web apps, running on more than 20 1X dynos, consider PX dynos.

## Basic methodology for optimizing memory

We suggest that you follow these steps, making use of visibility tools listed below, as well as the per-language suggestions.  This will get you to a point where you can easily optimise for a single dyno size, or for moving between dyno sizes.  

1. Using a concurrent web server.
2. Set up instrumentation to measure the impact of load on the app
3. Observing the app performance, and adjusting the concurrency as necessary.

Optimizing is an iterative process - there is no golden path.  Different languages, web frameworks and applications behave quite differently.  

For example, a standard Ruby application may need to use a web server that forks multiple copies of an application to make use of all the RAM that is available.  A standard Java application, on the other hand, may simply need a parameter to the JVM in order to allocate a larger heap.

## Concurrent web servers

Different languages and platforms have different approaches to concurrency. Here's a brief look at how to establish concurrency in apps running on Ruby, Java, Python and Node.js.

### Ruby

Traditional Ruby web servers such as WEBrick and Thin default to only accepting a single request at a time. If you want to optimize for increased concurrency, Heroku recommends that you use Unicorn.

Unicorn works by forking a configurable number of child processes, called workers. Each worker can only process a single request at a time. Concurrency comes about because the master Unicorn process queues new web requests, and these are then delegated to workers if they are free and have completed processing a previous request.

Increasing the concurrency is then configured by increasing the number of workers.

However, as each worker is effectively a forked version of your application, moving from a single worker to two workers will roughly double the memory requirements of your application.

It's this trade off - between increased concurrency and memory available in a dyno, that you will measure and tune.

Read [Deploying Rails Applications With Unicorn](https://devcenter.heroku.com/articles/rails-unicorn) to learn how to set up Unicorn for Ruby on Heroku. This will result in a web server with a config var, `WEB_CONCURRENCY`, which will let you adjust the number of workers the main Unicorn process will fork.

While highly app dependent, the following table lists some rough rules of thumb for how many Unicorn workers can be run on each dyno size:

<table>
<tr><th>Dyno Size</th><th>Number of Unicorn workers</th></tr>
<tr><td>1X</td><td>2-3</td></tr>
<tr><td>2X</td><td>4-6</td></tr>
<tr><td>PX</td><td>20-30</td></tr>
</table>

### Java

Java web servers like Jetty and Tomcat make good use of concurrency out of the box. 

However, you will need to tune the amount of memory allocated to the JVM, depending on dyno size.

Read [Adjusting Environment for a Dyno Size](https://devcenter.heroku.com/articles/java-support#adjusting-environment-for-a-dyno-size) for appropriate `JAVA_OPTS` flags to accomplish this.

### Python

If you want to optimize for increased concurrency, Heroku recommends that you use Gunicorn for Python apps.

Gunicorn works by forking a configurable number of child processes, called workers. Each worker can only process a single request at a time. Concurrency comes about because the master Gunicorn process queues new web requests, and these are then delegated to workers if they are free and have completed processing a previous request.

Increasing the concurrency is then configured by increasing the number of workers.

However, as each worker is effectively a forked version of your application, moving from a single worker to two workers will roughly double the memory requirements of your application.

It's this trade off - between increased concurrency and memory available in a dyno, that you will measure and tune.

Read [Deploying Python Applications with Gunicorn](https://devcenter.heroku.com/articles/python-gunicorn) to learn how to set up Gunicorn for Python on Heroku. This will result in a web server with a config var, `WEB_CONCURRENCY`, which will let you adjust the number of workers the main Unicorn process will fork.

While highly app dependent, the following table lists some rough rules of thumb for how many Unicorn workers can be run on each dyno size:

<table>
<tr><th>Dyno Size</th><th>Number of Gunicorn workers</th></tr>
<tr><td>1X</td><td>2-3</td></tr>
<tr><td>2X</td><td>4-6</td></tr>
<tr><td>PX</td><td>20-30</td></tr>
</table>

>warning
>These are just estimates, and will vary from app to app.  Use something in the lower range, measure, and adjust as necessary.

### Node.js

Node offers a single-threaded non-blocking concurrent web server environment. 

Node will automatically make use of an appropriate amount of memory, so no action is needed if you migrate between 1X and 2X dynos.

The situation is slightly different for PX.  Because Node is single-threaded, a single node instance will never be able to take advantage of the multiple cores offered by PX-sized dynos. To do so, use Node Cluster. In this configuration, node will spawn as many threads as there are cores in the CPU.

Read [Improving Node.js concurrency with node-cluster](https://devcenter.heroku.com/articles/node-cluster) to learn how to configure Node Cluster on Heroku.

## Measuring 

After setting up a concurrent web server, you'll want to tune it for a particular dyno size.   Measuring memory and throughput should provide enough guidance for you to make a judgement as to the impact of a change.

### Measuring memory with log-runtime-metrics

This Heroku Labs [log-runtime-metrics](https://devcenter.heroku.com/articles/log-runtime-metrics) feature adds support for enabling visibility into load and memory usage for running dynos. 

Per-dyno stats on memory use, swap use, and load average are inserted into the app’s log stream.

Here is some example output with this feature enabled:

```
source=web.1 dyno=heroku.2808254.d97d0ea7-cf3d-411b-b453-d2943a50b456 sample#load_avg_1m=2.46 sample#load_avg_5m=1.06 sample#load_avg_15m=0.99
source=web.1 dyno=heroku.2808254.d97d0ea7-cf3d-411b-b453-d2943a50b456 sample#memory_total=21.00MB sample#memory_rss=21.22MB sample#memory_cache=0.00MB sample#memory_swap=0.00MB sample#memory_pgpgin=348836pages sample#memory_pgpgout=343403pages
```

The `memory_rss` is the most significant number here, providing an indication of total resident memory.  Ensure that you don't exceed the memory of your dyno size - and leave some head room too.   Likewise, make sure you keep swap usage at minimum and the swapping activity (`memory_pgpgin`/`memory_pgpgout`) is minimal. Ideally `memory_pgpgin`/`memory_pgpgout` shouldn't change much over time (rate of change is zero).

See [log-runtime-metrics](https://devcenter.heroku.com/articles/log-runtime-metrics#memory-swap) to understand how to interpret these figures.

The output of log-runtime-metrics is particularly useful as it lets you look at per-dyno memory usage.  If you're over-provisioned, you may see a single dyno peaking before any other.

There are other ways of visualising this memory data:

The [Librato add-on](https://addons.heroku.com/librato#nickel), with the Nickel plan and above, provides a way to graph the various output from log-runtime-metrics, averaging the values across all the dynos.  

Here is sample output for a Rails application on 1X dynos using 4 Unicorn workers.  The memory, about 359MB at a peak, fits comfortably into the 1X 512MB of RAM.

![](https://s3.amazonaws.com/f.cl.ly/items/272D0L0N2m0C413l3W0Y/Heroku%20Overview%20%7C%20Librato-1.png)

Another tool that can be used is [log2viz](https://blog.heroku.com/archives/2013/3/19/log2viz), an experimental application that also aggregates the memory (and load) of dynos in an app.

![](https://s3.amazonaws.com/f.cl.ly/items/1S1Q3e2z2i0u3A2V3k3j/log2viz%20%7C%20devcenter-eu.png)

### Measuring throughput and response time

Throughput, the number of requests being handled per minute, as well as response times, are particularly useful indicators of how an optimization has affected the performance of a dyno.

In particular, the 95th and 99th percentile response time values provided by add-ons like [Librato](https://devcenter.heroku.com/articles/librato) or [New Relic](https://devcenter.heroku.com/articles/newrelic) should be monitored closely.
 