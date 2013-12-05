---
title: Heroku Postgres Legacy Plans
slug: heroku-postgres-legacy-plans
url: https://devcenter.heroku.com/articles/heroku-postgres-legacy-plans
description: Heroku Postgres is Heroku’s database-as-a-service running an unmodified PostgreSQL installation. If you’re looking for Heroku Postgres' current plans please visit the pricing page. The below pertains to the legacy plans for Heroku Postgres. These legacy plans are still available and
---

[Heroku Postgres](heroku-postgresql) is Heroku's database-as-a-service running an unmodified PostgreSQL installation. If you're looking for Heroku Postgres' current plans please visit the pricing page. The below pertains to the legacy plans for Heroku Postgres. These legacy plans are still available and provisionable, but not listed in `heroku addons:list` or within dashboard provisioning.

The legacy plans consist of two tiers, starter and production, across a variety of plans.

<table>
<tr>
  <th>Tier</th>
  <th style="width: 26em;">Plans</th>
  <th>Description</th>
</tr>
<tr>
  <td><b><a href="heroku-postgres-legacy-plans#starter-tier">Starter</a></b></td>
  <td><code>dev</code>, <code>basic</code></td>
  <td>Free and low-cost database plans for evaluation, application development, and testing.</td>
</tr>
<tr>
  <td><b><a href="heroku-postgres-legacy-plans#production-tier">Production</a></b></td>
  <td><code>crane</code>, <code>kappa</code>, <code>ronin</code>, <code>fugu</code>,<br/><br/> <code>ika</code>,<code>zilla</code>, <code>baku</code>, <code>mecha</code></td>
  <td>Production-grade monitoring, operations, and support.</td>
</tr>
</table>

### Starter Tier

<p class="warning" markdown="1">
The starter tier database plans are not intended for
production-caliber applications or applications with high-uptime
requirements.
</p>

The starter tier, which includes the [`dev` and `basic`
plans](https://addons.heroku.com/heroku-postgresql), has the following
limitations:

* Enforced row limits of 10,000 rows for `dev` and 10,000,000 for `basic` plans
* Max of 20 connections
* No in-memory cache: The lack of an in-memory cache limits the
  performance capabilities since the data can't be accessed on
  low-latency storage.
* No [fork/follow](heroku-postgres-follower-databases) support: Fork
  and follow, used to create replica databases and master-slave
  setups, are not supported.
* Expected uptime of 99.5% each month
* No postgres logs

### Production Tier

As the name implies, the production tier of Heroku Postgres is
intended for production applications and includes the following
feature additions to the starter tier:

* No row limitations
* Increasing amounts of in-memory cache
* [Fork and follow](heroku-postgres-follower-databases) support
* Max of 500 connections
* 1 TB of storage (if you need beyond 1 TB please contact us)
* Expected uptime of 99.95% each month
* [Database metrics published](https://devcenter.heroku.com/articles/heroku-postgres-metrics-logs) to application log stream for further analysis

Management of production tier database plans is also much more robust including:

* Eligible for automatic daily snapshots with 1-month retention (see
  the [PGBackups add-on](https://devcenter.heroku.com/articles/pgbackups)
  for more details)
* Priority service restoration on disruptions

Non-production applications, or applications with minimal data
storage, performance or availability requirements can choose between
one of the two starter tier plans, `dev` and `basic`, depending on row
requirements. However, production applications, or apps that require
the features of a production tier database plan, have a variety of
plans to choose from. These plans vary primarily by the size of their
in-memory data cache.

The cache and price for each legacy production plan is:

<table>
<tr>
<td>Plan Name</td>
<td>Provisioning name</td>
<td>Memory</td>
<td>Price per month</td>
</tr>
<tr>
<td>Crane</td>
<td>heroku-postgresql:crane</td>
<td>400 MB</td>
<td>$50</td>
</tr>
<tr>
<td>Kappa</td>
<td>heroku-postgresql:kappa</td>
<td>800 MB</td>
<td>$100</td>
</tr>
<tr>
<td>Ronin</td>
<td>heroku-postgresql:ronin</td>
<td>1.7GB</td>
<td>$200</td>
</tr>
<tr>
<td>Fugu</td>
<td>heroku-postgresql:fugu</td>
<td>3.75 GB</td>
<td>$400</td>
</tr>
<tr>
<td>Ika</td>
<td>heroku-postgresql:ika</td>
<td>7.5 GB</td>
<td>$800</td>
</tr>
<tr>
<td>Zilla</td>
<td>heroku-postgresql:zilla</td>
<td>17 GB</td>
<td>$1600</td>
</tr>
<tr>
<td>Baku</td>
<td>heroku-postgresql:baku</td>
<td>34 GB</td>
<td>$3200</td>
</tr>
<tr>
<td>Mecha</td>
<td>heroku-postgresql:mecha</td>
<td>64 GB</td>
<td>$6400</td>
</tr>
</table>