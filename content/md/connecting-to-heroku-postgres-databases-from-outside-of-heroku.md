---
title: Connecting to Heroku Postgres databases from outside of Heroku
slug: connecting-to-heroku-postgres-databases-from-outside-of-heroku
url: https://devcenter.heroku.com/articles/connecting-to-heroku-postgres-databases-from-outside-of-heroku
description: Considerations for connecting to a Heroku Postgres database from outside of Heroku, including SSL and credential details.
---

Heroku Postgres databases are designed to be used with a Heroku app. However, they are accessible from anywhere and may be used from any application using standard Postgres clients.

To make effective use of Heroku Postgres databases outside of a Heroku application, keep in mind the following:

### Heroku app

All Heroku Postgres databases have a corresponding Heroku application. You can find the application name on the database page from [postgres.heroku.com/databases](https://postgres.heroku.com/databases). You do not have to use the Heroku app for application code, but your database is attached to it and holds an environment variable containing the database URL. This variable is managed by Heroku, and is the primary way we tell you about your database's network location and credentials.

### Credentials

Do not copy and paste database credentials to a separate environment or into your application's code. The database URL is managed by Heroku and _will_ change under special circumstances such as:

* User initiated database credential rotations using `heroku pg:credentials --reset`.
* Catastrophic hardware failure leading to Heroku Postgres staff recovering your database on new hardware.
* Automated failover events on [HA](https://devcenter.heroku.com/articles/heroku-postgres-ha) enabled plans.

It is best practice to always fetch the database URL configuration variable from the corresponding Heroku app when your application starts. For example, you may follow [12Factor application configuration principles](https://devcenter.heroku.com/articles/development-configuration#configuration) by using the [Heroku Toolbelt](https://toolbelt.heroku.com) and invoke your process like so:

```bash
DATABASE_URL=$(heroku config:get DATABASE_URL -a your-app) your_process
```

This way, you ensure your process or application always has correct database credentials.

### SSL

Connecting to a Heroku Postgres database from outside of the Heroku network requires SSL. Your client or application must support and enable SSL to reliably connect to a Heroku Postgres database. Most clients will connect over SSL by default, but on occasion it is necessary to set the `sslmode=require` parameter on a Postgres connection.

### Backups

You can set up any of our [pgbackups plans](https://addons.heroku.com/pgbackups) to the enclosing Heroku app in order to get automated backups on your database. Pgbackups takes backups of the database pointed at by `DATABASE_URL` in the Heroku app, so make sure you promote your database:

```
heroku pg:promote HEROKU_POSTGRESQL_VIOLET --app your-app
```

 