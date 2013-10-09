---
title: Heroku Labs: log-runtime-metrics
slug: log-runtime-metrics
url: https://devcenter.heroku.com/articles/log-runtime-metrics
description: Log runtime metrics is a labs feature that logs load and memory usage on a per-dyno basis to an app's log stream.
---

This [Heroku Labs](http://devcenter.heroku.com/categories/labs) `log-runtime-metrics` feature adds experimental support for enabling visibility into load and memory usage for running dynos. Per-dyno stats on memory use, swap use, and load average are inserted into the app's log stream where they can be seen via `heroku logs --tail`, used for graphs or alerting via an [add-on which consumes app logs](https://addons.heroku.com/#logging), or sent to a [log drain](logging#syslog-drains). There is no cost incurred by enabling this feature.

<p class="warning">
The features added through labs are experimental and may change or be removed without notice.
</p>

## Enabling

    :::term
    $ heroku labs:enable log-runtime-metrics
    Enabling log-runtime-metrics for myapp... done
    $ heroku restart

## How it works

The load and memory usage metrics are surfaced as [system logs](logging#types-of-logs) in the Logplex log stream. Metrics are emitted for each running dyno, at an approximate frequency of once every 20 seconds.

## Log format

Runtime metrics logs have the following format:

    :::term
    source=web.1 dyno=heroku.2808254.d97d0ea7-cf3d-411b-b453-d2943a50b456 sample#load_avg_1m=2.46 sample#load_avg_5m=1.06 sample#load_avg_15m=0.99
    source=web.1 dyno=heroku.2808254.d97d0ea7-cf3d-411b-b453-d2943a50b456 sample#memory_total=21.00MB sample#memory_rss=21.22MB sample#memory_cache=0.00MB sample#memory_swap=0.00MB sample#memory_pgpgin=348836pages sample#memory_pgpgout=343403pages

The `source` field identifies a dyno in your [dyno formation](scaling#dyno-formation) and is intended to be used by systems draining application logs. The `dyno` field includes the app id and a UUID that unique identifies every distinct dyno run on the platform. Over the life of your app metrics, you will see the same `source` value have many different `dyno` values, related to when you deploy or restart dynos.

## CPU load averages

The following fields are reported for CPU load average:

* **Load Average 1m** (`load_avg_1m`): The load average for the dyno in the last 1 minute. This reflects the number of CPU tasks that are in the [ready queue](http://en.wikipedia.org/wiki/Process_state#Ready_or_waiting) (i.e. waiting to be processed). More details about how load averages are calculated can be found [below](#load-averages).
* **Load Average 5m** (`load_avg_5m`): The load average for the dyno in the last 5 minutes. Computed in the same manner as 1m load average.
* **Load Average 15m** (`load_avg_15m`): The load average for the dyno in the last 15 minutes. Computed in the same manner as 1m load average.

## Memory & swap

The following fields are reported for memory consumption and swap:

* **Resident Memory** (`memory_rss`): The portion of the dyno’s memory (megabytes) held in RAM.
* **Disk Cache Memory** (`memory_cache`): The portion of the dyno’s memory (megabytes) used as disk cache.
* **Swap Memory** (`memory_swap`): The portion of the dyno's memory (megabytes) stored on disk. Swapping is **extremely slow and should be avoided**. 
* **Total Memory** (`memory_total`): The total memory (megabytes) being used by the dyno, equal to the sum of resident, cache, and swap memory. 
* **Pages Written to Disk** (`memory_pgpgout`): The cumulative total of the pages written to disk. Sudden high variations on this number can indicate short duration spikes in swap usage. The other memory related metrics are point in time snapshots and can miss short spikes.
* **Pages Read from Disk** (`memory_pgpgin`): The cumulative total of the pages read from disk. As with the previous metric, watch out for sudden variations.
 
## Understand load averages

Load averages represent the number of tasks (processes or system threads) waiting to run at a given time. See [this blog post by Scout](http://blog.scoutapp.com/articles/2009/07/31/understanding-load-averages) for an explanation and diagrams.

The load averages exposed by the [dyno manager](dynos#the-dyno-manager) account only for tasks (processes and/or system threads) in the CPU run queue (or [ready queue](http://en.wikipedia.org/wiki/Process_state#Ready_or_waiting)), waiting for their opportunity to consume CPU time. This is different from how some [Unix-like OSes calculate it](http://en.wikipedia.org/wiki/Load_%28computing%29#Unix-style_load_calculation). In the Linux case, for example, tasks in the [uninterruptible sleep state](http://en.wikipedia.org/wiki/Uninterruptible_sleep) (usually blocked on I/O operations) are also included in load averages. Dynos **do not consider tasks blocked on I/O operations** for load averages.

Periodically, the number of tasks in the ready queue are collected. Load averages are then calculated as [exponentially weighted moving averages](http://en.wikipedia.org/wiki/Moving_average#Application_to_measuring_computer_performance) of these values, with different average periods (`W`): 1m, 5m and 15m.