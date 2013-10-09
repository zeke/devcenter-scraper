---
title: Production Check
slug: production-check
url: https://devcenter.heroku.com/articles/production-check
description: Use Production Check to achieve maximum availability for your Heroku application.
---

Production Check tests your app’s configuration against a set of optional—but highly recommended—criteria. It makes it easy to ensure that your app’s configuration lends itself to maximum uptime. Moreover, it ensures that you have tools available for understanding and monitoring the factors that contribute to uptime.

## How to Check Your App

To run Production Check, click the “Run Production Check” link in the header for any app in the Heroku Dashboard.

![Heroku Production Check](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/166-original.jpg?1366938447 'Heroku Production Check')

Production Check will run a series of tests on your app recommended for maintaining and monitoring availability. Each check includes useful links to related resources.

## Cedar

[Cedar](cedar) is recommended for all applications and is Heroku's most performant and robust stack. Cedar is the focus of the majority of the platform engineering and availability efforts.

To determine what stack your application is currently deployed to, use the `heroku stack` command.

    :::term
    $ heroku stack -a ha-app
    === ha-app Available Stacks
      bamboo-mri-1.9.2
      bamboo-ree-1.8.7
    * cedar

If you are not yet on Cedar, consider [migrating your application](cedar-migration).

## Dyno redundancy

Running at least 2 web [dynos](dynos) for any mission-critical app increases the probability that the app will remain available during a catastrophic event. Multiple dynos are also more likely to run on different physical infrastructure (for example, separate AWS Availability Zones), further increasing redundancy.

Use the `heroku ps` command to determine how many dynos of each type your app is currently running and `heroku ps:scale` to increase dyno redundancy.

    :::term
    $ heroku ps -a ha-app
    === web:
    web.1: up for 17m

    $ heroku ps:scale web+2
    Scaling web processes... done, now running 3

This applies to `web` dynos but also any [background or worker](background-jobs-queueing) dynos as well.

## DNS & SSL

Apps on the Cedar stack should have [CNAME records](custom-domains#custom-subdomains) pointing to `app-name.herokuapp.com`. When SSL is required, provision an [SSL Endpoint](https://devcenter.heroku.com/articles/ssl-endpoint) and point your CNAME records to `endpoint-name.herokussl.com`. Any other configuration will result in reduced availability.

<div class="warning" markdown="1">
Apex domains (otherwise known as bare, root and naked domains) should not be configured using A-records. [Properly configure the root domain DNS](apex-domains) using CNAME-like functionality or subdomain redirection.
</div>

You can quickly determine if your DNS records are properly configured using the `host` command-line utility.

    :::term
    $ host www.example.com
    www.example.com is an alias for nara-1234.herokussl.com.
    nara-1234.herokussl.com is an alias for elb002776-242519199.us-east-1.elb.amazonaws.com.
    elb002776-242519199.us-east-1.elb.amazonaws.com has address 107.21.240.226
    …

You should see an alias mapping from `www.example.com` to either `app-name.herokuapp.com` or `endpoint-name.herokussl.com`.

## Production database

If you run your business on Heroku, you should use a production-grade [Heroku Postgres database](https://addons.heroku.com/heroku-postgresql).

<div class="note" markdown="1">
The Heroku Postgres production tier starts with Crane and extends through to the Mecha plan. *Dev and Starter plans are not production databases*.
</div>

The production tier of service achieves the highest expected uptime and includes automated health checks, data snapshots and advanced features such as fork and follow.

    :::term
    $ heroku pg:info -a ha-app
    === HEROKU_POSTGRESQL_RED
    Plan:        Ronin
    Status:      available
    Data Size:   5.9 MB
    Tables:      0
    PG Version:  9.1.4
    Fork/Follow: Available
    Created:     2012-07-13 16:59 UTC
    Maintenance: not required

If your application requires a non-relational data store, [Amazon DynamoDB](http://aws.amazon.com/dynamodb/) is another great candidate for highly available data storage.

## Visibility & monitoring

Before improving the availability of your app, you should have excellent awareness of, and reactivity to, the state of your app. This can be accomplished with a variety of tools.

### App Monitoring

[New Relic](newrelic) allows you to monitor, and drill into, the performance of your app over time. There are many cases in which a loss in availability is preceded by a degradation in service.

![New Relic](https://dl.dropbox.com/u/674401/devcenter/newrelic.png)

Over a reasonable period of observation, establish normal operating boundaries for your application and set up alerts to notify you when your system is beginning to deviate.

Use New Relic's rich graphing and performance analysis capabilities to better understand how your application behaves in certain circumstances and where it is most brittle. These observations can help you diagnose and work around degradations in periods of instability.

### Log Monitoring

The Heroku [add-on marketplace](https://addons.heroku.com/) includes many services that consume, store and provide instrumention against your application's [log stream](logging). By logging interesting events, like successful credit card signups, you can use these log services to alert you of unusual activity. When problems do arise they also simplify debugging by allowing you to search the history of your log events.

[Papertrail](https://papertrailapp.com/) is an example of such a service that provides alerting based on patterns in your log data. Setup a search alert for errors & events within your app and integrate with Librato, PagerDuty, and Campfire. The search alert can be for Heroku error codes or interesting events in your app.

![Papertrail](https://dl.dropbox.com/u/674401/devcenter/Screen%2520Shot%25202012-07-12%2520at%25209.16.png)