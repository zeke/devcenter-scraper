---
title: Maintenance Windows
slug: heroku-postgres-maintenance
url: https://devcenter.heroku.com/articles/heroku-postgres-maintenance
description: How to set a maintenance window for Heroku Postgres plans.
---

From time to time, Heroku must take your database offline to perform maintenance tasks. Typical tasks include upgrading the underlying infrastructure of the database (i.e. patching the operating system or required libraries) or upgrading Postgres itself. This maintenance is handled automatically by Heroku. 

## Checking if maintenance is required for your database

You can check if maintenance is required on a database by using `pg:info`.

```term
$ heroku pg:info
Plan:           Ika
Status:         Available
Data Size:      26.1 MB
...
Maintenance:    required by 2014-02-01 00:00:00 +0000
```

## Setting a Maintenance window

(Heroku [pg:extras](https://github.com/heroku/heroku-pg-extras) plugin is required)

Some database plans support set-able maintenance windows. Users can specify the day-of-week and time (UTC) at which the maintenance will occur:

```term
$ heroku pg:maintenance window="Sunday 14:30"
```

Setting a maintenance window allows you to minimize the impact on your application and users. We recommend selecting a time during which maintenance would have the least-impact on your business. 

Maintenance windows are 4 hours long - two hours before and two hours after the time that you set.

## Limitations

User settable maintenance windows and manual maintenance runs are only available on Ronin, Fugu, Ika, Zilla, Baku, Mecha, and Ryu plans. 

Heroku will make best efforts to honor your maintenance window request; however it is not guaranteed. If there is an emergency where the security or integrity of your data is threatened, we may perform the maintenance outside of your regular window at our discretion.
