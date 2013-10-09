---
title: Dyno Size
slug: dyno-size
url: https://devcenter.heroku.com/articles/dyno-size
description: 2X dynos let you double the memory and double the CPU share on a per dyno-type basis.
---

Heroku dynos get 512MB of memory and 1x CPU share in their default configuration ("1X"). If your app [needs more memory][R14] or more CPU share, you can resize dynos to a "2X" configuration for double the memory and double the CPU share on a per process-type basis.

Use cases include running more [concurrency in a Ruby/Unicorn web dyno][unicorn], or doing large image processing or geospacial processing in a worker dyno.

For help determining the right dyno size measure memory usage with the [`log-runtime-metrics` Labs flag][log-runtime-metrics]. The logged metrics can be
viewed with [`heroku logs -t`][heroku-logs], [log2viz][], or any addon that
consumes logs.

## Available dyno sizes

<table>
  <tr>
    <th style="text-align: left;">Dyno Size</th>
    <th style="text-align: left;">Memory (RAM)</th>
    <th style="text-align: left;">CPU Share</th>
    <th style="text-align: left;">Price/dyno-hour</th>
  </tr>
  <tr>
    <td style="text-align: left; width: 25%;">1X</td>
    <td style="text-align: left; width: 25%;">512MB</td>
    <td style="text-align: left; width: 25%;">1x</td>
    <td style="text-align: left; width: 25%;">$0.05</td>
  </tr>
  <tr>
    <td style="text-align: left; width: 25%;">2X</td>
    <td style="text-align: left; width: 25%;">1024MB</td>
    <td style="text-align: left; width: 25%;">2x</td>
    <td style="text-align: left; width: 25%;">$0.10</td>
  </tr>
</table>

<div class="callout" markdown="1">
  **2X dynos consume twice as many free dyno-hours per hour** as 1X dynos. Example: A 2X one dyno app will run for free for 375 hours compared to 750 hours for a 1X one dyno app.

  If your app has only a **single 2X web dyno** running, it **will sleep**.
</div>

## Setting dyno size

<div class="warning" markdown="1">
  **Important:** Resizing dynos restarts the affected dynos.
</div>

### CLI

Using the [Heroku Toolbelt][toolbelt], resize your dynos
with the `resize` command:

    :::term
    $ heroku ps:resize web=2X worker=1X
    Resizing dynos and restarting specified processes... done
    web dynos now 2X ($0.10/dyno-hour)
    worker dynos now 1X ($0.05/dyno-hour)

To view the dyno size of a process type, use the `ps` command:

    :::term
    $ heroku ps
    === web (2X): `bundle exec unicorn -p $PORT -c ./config/unicorn.rb`
    web.1: up 2013/03/27 14:27:58 (~ 6h ago)
    web.2: up 2013/03/27 14:47:04 (~ 6h ago)
    web.3: up 2013/03/27 15:08:23 (~ 5h ago)

    === worker (1X): `bundle exec rake worker:job`
    worker.1: up 2013/03/27 14:39:04 (~ 6h ago)
    worker.2: up 2013/03/27 15:08:24 (~ 5h ago)
    worker.3: up 2013/03/27 14:30:55 (~ 6h ago)

### Dashboard

Using the app's resources page on [Dashboard][dashboard]:

![](https://s3.amazonaws.com/f.cl.ly/items/3S1U0T1z1i0m382g2s3K/2x-dynos-dashboard.png)

### One-off dynos

Memory intensive one-off dynos can also be sized:

    :::term
    $ heroku run --size=2X rake heavy:job

[Scheduler][scheduler] also supports running one-off 2X dynos.

[dashboard]: https://dashboard.heroku.com/
[heroku-logs]: https://devcenter.heroku.com/articles/logging#log-retrieval
[log-runtime-metrics]: https://devcenter.heroku.com/articles/log-runtime-metrics
[log2viz]: https://blog.heroku.com/archives/2013/3/19/log2viz
[R14]: https://devcenter.heroku.com/articles/error-codes#r14-memory-quota-exceeded
[scheduler]: https://devcenter.heroku.com/articles/scheduler
[toolbelt]: https://toolbelt.heroku.com/
[unicorn]: https://devcenter.heroku.com/articles/rails-unicorn