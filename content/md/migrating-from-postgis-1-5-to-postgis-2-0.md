---
title: Migrating From PostGIS 1.5 to PostGIS 2.0
slug: migrating-from-postgis-1-5-to-postgis-2-0
url: https://devcenter.heroku.com/articles/migrating-from-postgis-1-5-to-postgis-2-0
description: A guide to migrating to PostGIS 2.0, now available as a Postgres extension, on Heroku Postgres.
---

PostGIS 2.0 is now available in public beta to Heroku Postgres customers on
production tier plans (Crane and up).  It brings improved stability and features to spatial applications.

## Installation

Unlike PostGIS 1.5, it is available as a Postgres extension on Postgres 9.2 databases. 
To install PostGIS in your database, run the following from a `psql` console:

    CREATE EXTENSION postgis;

## PostGIS 1.5 to 2.0 Migration

To migrate an old Heroku Postgres database running PostGIS 1.5 to the new
architecture, please follow these steps:

### Create a target database

```term
$ heroku addons:add heroku-postgresql:ronin --version=9.2 --app your-app
Adding heroku-postgresql:ronin on hgmnz... done, v29 ($200/mo)
Attached as HEROKU_POSTGRESQL_LAVANDA_URL
The database should be available in 3-5 minutes.
 ! The database will be empty. If upgrading, you can transfer
 ! data from another database with pgbackups:restore.
Use `heroku pg:wait` to track status..
Use `heroku addons:docs heroku-postgresql:ronin` to view documentation.
```

### Create the postgis extension on the new database

```term
$ heroku pg:psql LAVANDA --app your-app
> CREATE EXTENSION postgis;
```

### Transfer your data to a new Postgres database

The fastest way to do this is to use the pgbackups:transfer command available
from the [heroku pg-extras](https://github.com/heroku/heroku-pg-extras) plugin.

Install the plugin via

```term
$ heroku plugins:install git://github.com/heroku/heroku-pg-extras.git
```

This command requires the pgbackups addon. If you don't already have it installed
on your app, install it now:

```term
$ heroku addons:add pgbackups --app your-app
Adding pgbackups on hgmnz... done, v32 (free)
You can now use "pgbackups" to backup your databases or import an external backup.
Use `heroku addons:docs pgbackups` to view documentation.
```

Place your application in maintenance mode, and scale down any workers:

```term
$ heroku maintenance:on --app your-app
$ heroku ps:scale worker=0 another_worker=0 --app your-app
```

Finally, transfer data from your old database to your new one:

```term
$ heroku pgbackups:transfer <OLD_DATABASE_COLOR> LAVANDA --app your-app
```

Depending on your data size, the transfer may take a while. You can track
progress of the transfer by tailing your application logs from another shell
window:

```term
$ heroku logs --tail -p pbackups --app your-app
```

### Verify data and promote your new database

You can now gain a connection to your new database and run queries verifying
that your data looks as expected. You can also point a staging application to
it to verify that your it works well with Postgis 2.0.

After you're ready to use the Postgis 2.0 database as the primary for your
application, simply promote it:

```term
$ heroku pg:promote HEROKU_POSTGRESQL_LAVANDA --app your-app
Promoting HEROKU_POSTGRESQL_LAVANDA_URL to DATABASE_URL... done
```

Now that the new database is up and running, scale it back up:

```term
$ heroku maintenance:off --app your-app
$ heroku ps:scale worker=4 another_worker=2 --app your-app
```

### Remove old database

Once your new database has been migrated and promoted, you can safely remove
your old one:

```term
$ heroku addons:remove HEROKU_POSTGRESQL_<OLD_DATABASE_COLOR> --app your-app
```
