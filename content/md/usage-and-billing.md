---
title: Usage & Billing
slug: usage-and-billing
url: https://devcenter.heroku.com/articles/usage-and-billing
description: How Heroku calculates billing, based on wall-clock usage, and the impact of dyno sleeping and free dyno-hours.
---

Heroku calculates billing based on wall-clock usage. This article explains the billing calculations, as well as the impact of dyno sleeping, one-off dynos and free dyno-hours on billing.

## Billing cycle & current usage

Heroku charges based on usage, which means that in any given month the bill you receive will be for the previous month of use, not the current one (similar to the way phone services work).

If you wish to see or keep track of your balance for the current month, look for the **Current Usage** item on your [account page](https://dashboard.heroku.com/account). It is updated on a nightly basis, so it will be current to the previous day (up to 00:00:00 UTC time).

## Computing usage

Heroku usage is computed from wall-clock time, **not CPU time**. This means that usage accumulates over time as long as dynos or add-ons are enabled, regardless of traffic or activity.

For example, if you scaled your web dynos to one 1X dyno on 2012-01-01 00:00:00 and then scaled your web dynos to zero on 2012-01-01 **01:15:30** you would have accrued 01:15:30 dyno hours of usage, represented as 1.2583 once converted to a decimal value.

## Cost
 
* **1X dynos**: $0.05 / hour
* **2X dynos**: $0.10 / hour 
* **PX dynos**: $0.80 / hour

All costs are prorated to the second.

An app with *four* 1X dynos is charged $0.20 per hour for each hour that the four dynos are running. The same app with four 2X dynos is charged $0.40 per hour, and the same app with four PX dynos is charged $3.20 per hour.  However, see how [free dynos affect this calculation](https://devcenter.heroku.com/articles/usage-and-billing#750-free-dyno-hours-per-app).

All dynos in your application that are scaled above 0 will accrue usage–regardless of whether they’re actually receiving or processing requests.

Databases and add-ons are prorated to the second based on their applicable monthly fee.
 
## One-off dynos

When executing a [one-off dyno](https://devcenter.heroku.com/articles/one-off-dynos) with `heroku run`, a dyno will be provisioned for your command, and the time spent executing the command will accrue usage.

## Dyno sleeping

A web dyno [that is sleeping](https://devcenter.heroku.com/articles/dynos#dyno-sleeping) continues to accrue usage. To stop accruing usage on an app that is sleeping, you must scale the web dyno to 0.

`$ heroku ps:scale web=0`

To understand the circumstances under which a dyno will sleep, please read about [dyno management](https://devcenter.heroku.com/articles/dynos#dyno-sleeping).

## 750 free dyno-hours per app

Heroku automatically credits each app with 750 free dyno-hours per month, which are clearly identified on your invoice. 

This allotment can be used for any type of dyno (i.e. web, worker, console), of any dyno size. 

Your free dyno-hours will allow you to run one 1X dyno for an entire month free of charge–although you may choose to run two 1X dynos for 1/2 of a month instead.

Note that 2X dynos consume twice as many free dyno-hours per hour as 1X dynos. For example, one 2X dyno app will run for free for 375 hours compared to 750 hours for one 1X dyno app.  

Likewise, PX dynos consume 16 times as many free dyno-hours per hour as 1X dynos. For example, one PX dyno app will run for free for just over 46 hours compared to 750 hours for one 1X dyno app. 