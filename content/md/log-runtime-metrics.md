---
title: Heroku Labs: log-runtime-metrics
slug: log-runtime-metrics
url: https://devcenter.heroku.com/articles/log-runtime-metrics
description: Log runtime metrics is a labs feature that logs load and memory usage on a per-dyno basis to an app's log stream.
---

This [Heroku Labs](http://devcenter.heroku.com/categories/labs) `log-runtime-metrics` feature adds experimental support for enabling visibility into load and memory usage for running dynos. Per-dyno stats on memory use, swap use, and load average are inserted into the app's log stream where they can be seen via `heroku logs --tail`, used for graphs or alerting via an [add-on which consumes app logs](https://addons.heroku.com/#logging), or sent to a [log drain](logging#syslog-drains). There is no cost incurred by enabling this feature.

> warning
> Features added through Heroku Labs are experimental and subject to change.

## Enabling

```term
$ heroku labs:enable log-runtime-metrics
Enabling log-runtime-metrics for myapp... done
$ heroku restart
```

## How it works

The load and memory usage metrics are surfaced as [system logs](logging#types-of-logs) in the Logplex log stream. Metrics are emitted for each running dyno, at an approximate frequency of once every 20 seconds.

## Log format

Runtime metrics logs have the following format:

```term
source=web.1 dyno=heroku.2808254.d97d0ea7-cf3d-411b-b453-d2943a50b456 sample#load_avg_1m=2.46 sample#load_avg_5m=1.06 sample#load_avg_15m=0.99
source=web.1 dyno=heroku.2808254.d97d0ea7-cf3d-411b-b453-d2943a50b456 sample#memory_total=21.00MB sample#memory_rss=21.22MB sample#memory_cache=0.00MB sample#memory_swap=0.00MB sample#memory_pgpgin=348836pages sample#memory_pgpgout=343403pages
```

The `source` field identifies a dyno in your [dyno formation](scaling#dyno-formation) and is intended to be used by systems draining application logs. The `dyno` field includes the app id and a UUID that unique identifies every distinct dyno run on the platform. Over the life of your app metrics, you will see the same `source` value have many different `dyno` values, related to when you deploy or restart dynos.

## CPU load averages

The following fields are reported for CPU load average:

* **Load Average 1m** (`load_avg_1m`): The load average for the dyno in the last 1 minute. This reflects the number of CPU tasks that are in the [ready queue](http://en.wikipedia.org/wiki/Process_state#Ready_or_waiting) (i.e. waiting to be processed). More details about how load averages are calculated can be found [below](#understanding-load-averages).
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
 
## Understanding load averages

Load average represents the number of tasks (e.g., processes, system
threads) currently running or waiting to run on CPU. Load averages are
typically depicted with programs like `uptime` or `top` on Linux
systems with three values: 1-minute, 5-minute, and 15-minute. These
values do not represent averages across the preceding 1-, 5-, or
15-minutes and are calculated from values beyond those periods. Load
averages are exponentially damped moving averages.  Taken as a set,
these values demonstrate the trend of CPU utilization.

The dyno manager takes the count of runnable tasks from
`/cgroup/<uuid>/tasks` about every 20 seconds. The load average is
computed with the count of runnable tasks from the previous 30
minutes in the following iterative algorithm:

```ruby
expterm = Math.exp(-(count_of_runnable_tasks.time - avg.time) / (period))
newavg = (1 - expterm) * count_of_runnable_tasks.value + expterm * avg.value
```

where `period` is either 1-, 5-, or 15-minutes (in seconds), the
`count_of_runnable_tasks` is an entry of the number of tasks in the
queue at a given point in time, and the `avg` is the previous
calculated exponential load average from the last iteration.

This load average calculation differs from the algorithm in Linux,
which includes tasks in an uninterruptible state (e.g., tasks
performing disk I/O). The choice to present load average values that
include only runnable tasks enables Heroku users to evaluate their
application's CPU saturation without confounding these statistics 
with long-running uninterruptible tasks. 