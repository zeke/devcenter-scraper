---
title: Dyno Size
slug: dyno-size
url: https://devcenter.heroku.com/articles/dyno-size
description: Characteristics of the various dyno sizes supported by Heroku.
---

A [dyno](dynos) is a lightweight container running a single user-specified command.  Dynos are the containers in which your application components run.

Heroku offers three different dyno sizes.  Each size has different memory and CPU characteristics, as listed in the table below.  

See [Optimizing Dyno Usage](optimizing-dyno-usage) for guidance on when to consider a different size.

## Available dyno sizes

<table>
  <tr style="width: 100%">
    <th style="text-align: left;">Dyno Size</th>
    <th style="text-align: left;">Memory (RAM)</th>
    <th style="text-align: left;">CPU Share</th>
    <th style="text-align: left;">Multitenant</th>
    <th style="text-align: left;">Compute (<i>2</i>)</th>
    <th style="text-align: left;">Price/dyno-hour</th>
  </tr>
  <tr>
    <td style="text-align: left; ">1X</td>
    <td style="text-align: left; ">512MB</td>
    <td style="text-align: left; ">1x</td>
    <td style="text-align: left; ">yes</td>
    <td style="text-align: left; ">1x-4x</td>
    <td style="text-align: left; ">$0.05</td>
  </tr>
  <tr>
    <td style="text-align: left; ">2X</td>
    <td style="text-align: left; ">1024MB</td>
    <td style="text-align: left; ">2x</td>
    <td style="text-align: left; ">yes</td>
    <td style="text-align: left; ">4x-8x</td>
    <td style="text-align: left; ">$0.10</td>
  </tr>
  <tr>
    <td style="text-align: left; ">PX</td>
    <td style="text-align: left; ">6GB</td>
    <td style="text-align: left; ">100%  (1)</td>
    <td style="text-align: left; ">no</td>
    <td style="text-align: left; ">40x</td>
    <td style="text-align: left; ">$0.80</td>
  </tr>
</table>

1. The PX dyno size (performance dynos) has 8 cores and is highly-isolated.
2. Overall performance will vary heavily based on app implementation, these figures are expected performance based on perc99 of historical system loads.  1X and 2X dyno performance will vary based on available system resources.

PX and 2X dynos consume free dyno-hours at different rates as 1X dynos. See [Usage and Billing](https://devcenter.heroku.com/articles/usage-and-billing#750-free-dyno-hours-per-app) for more details.

> callout
>  If your app has only a single web dyno of any size running, it [will sleep](https://devcenter.heroku.com/articles/dynos#dyno-sleeping).

### Notes on PX dynos

Heroku previously published a AWS account id and security group name to let customers reference it in their own AWS security group settings. This is [no longer recommended](https://devcenter.heroku.com/changelog-items/353) and Heroku is no longer publishing our AWS account id. If you have the legacy AWS account id and security group name, referencing those may still work, but _only_  for 1X and 2X dynos. PX dynos run under a different AWS account, and Heroku will not make the id for that account available to customers.

## Setting dyno size

Resizing dynos changes the dyno size for all dynos of a process type, and restarts the affected dynos.

### CLI

Using the [Heroku Toolbelt][toolbelt], you can resize and scale at the same time.  The following command scales the number of web dynos to 3, and resizes them to PX:

```term
$ heroku ps:scale web=3:PX
```

To just resize:

```term
$ heroku ps:resize worker=2X
```

If you're resizing to a larger size, you may want to scale down the number of dynos as well.  See [Optimizing Dyno Usage](optimizing-dyno-usage) for guidance.

To view the dyno size of a process type, use the `ps` command:

```term
$ heroku ps
=== web (2X): `bundle exec unicorn -p $PORT -c ./config/unicorn.rb`
web.1: up 2013/03/27 14:27:58 (~ 6h ago)
web.2: up 2013/03/27 14:47:04 (~ 6h ago)
web.3: up 2013/03/27 15:08:23 (~ 5h ago)

=== worker (1X): `bundle exec rake worker:job`
worker.1: up 2013/03/27 14:39:04 (~ 6h ago)
worker.2: up 2013/03/27 15:08:24 (~ 5h ago)
worker.3: up 2013/03/27 14:30:55 (~ 6h ago)
```

### Dashboard

Using the app's resources page on [Dashboard][dashboard]:

![dashboard dyno size](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/288-original.jpg 'Optional title')

### One-off dynos

Memory intensive one-off dynos can also be sized:

```term
$ heroku run --size=2X rake heavy:job
```

or

```term
$ heroku run --size=PX rake heavy:job
```

>note
>Without the `--size` flag, one-off dynos will always use the 1X size.

### Scheduler

[Scheduler][scheduler] supports running one-off 1X, 2X, and PX dynos.

## Default scaling limits

By default, a process type can’t be scaled to more than 100 dynos for 1X or 2X sized dynos. A process type can't be scaled to more than 10 dynos for PX-sized dynos.

[Contact sales](https://www.heroku.com/critical) to raise this limit for your application.

### One-off dynos

There are different limits that apply depending on whether the Heroku account [is verified](https://devcenter.heroku.com/articles/account-verification) or not.

If the account is not verified, then it cannot have more than 3 [one-off dynos](https://devcenter.heroku.com/articles/one-off-dynos) of size 1X running concurrently.  Accounts that aren't verified can't create one-off 2X or one-off PX dynos. 

For verified accounts, no more than 5 PX-sized one-off dynos can run concurrently. 

[Contact sales](https://www.heroku.com/critical) to raise this limit for your application.

[dashboard]: https://dashboard.heroku.com/
[heroku-logs]: https://devcenter.heroku.com/articles/logging#log-retrieval
[log-runtime-metrics]: https://devcenter.heroku.com/articles/log-runtime-metrics
[log2viz]: https://blog.heroku.com/archives/2013/3/19/log2viz
[R14]: https://devcenter.heroku.com/articles/error-codes#r14-memory-quota-exceeded
[scheduler]: https://devcenter.heroku.com/articles/scheduler
[toolbelt]: https://toolbelt.heroku.com/
[unicorn]: https://devcenter.heroku.com/articles/rails-unicorn 