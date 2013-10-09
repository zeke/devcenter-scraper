---
title: Importing and Exporting Heroku Postgres Databases with PG Backups
slug: heroku-postgres-import-export
url: https://devcenter.heroku.com/articles/heroku-postgres-import-export
description: The PG Backups add-on is a useful tool capable of exporting and importing to/from external PostgreSQL databases.
---

On the surface, [PG Backups add-on](pgbackups) provides a way to capture regular backups of your [Heroku Postgres](heroku-postgresql) database. However, because of its general-purpose architecture and use of standard PostgreSQL utilities, it is also a useful tool capable of exporting and importing to/from external PostgreSQL databases.

<p class="note" markdown="1">
Both use-cases assume you have the [PG Backups add-on](pgbackups) provisioned for the applicable application.
</p>

## Export

PG Backups uses the native `pg_dump` PostgreSQL tool to create its backup files, making it trivial to export to other PostgreSQL installations.

### Download backup

To export the data from your Heroku Postgres database to a local PostgreSQL database, create a new backup and use any number of download tools, such as `curl` or `wget`, to store the backup locally.

    :::term
    $ heroku pgbackups:capture
    $ curl -o latest.dump `heroku pgbackups:url`

### Restore to local database

Load the dump into your local database using the [pg_restore](http://www.postgresql.org/docs/9.1/static/app-pgrestore.html) tool.

<div class="callout" markdown="1">
This will usually generate some warnings, due to differences between your Heroku database and a local database, but they are generally safe to ignore.
</div>

    :::term
    $ pg_restore --verbose --clean --no-acl --no-owner -h localhost -U myuser -d mydb latest.dump

## Import

PG Backups can be used as a convenient tool to import database dumps from other sources to your Heroku Postgres database.

<p class="note" markdown="1">
If you are importing data as part of the initialization of a new application you will need to first [create and configure the app](quickstart) on Heroku before performing the import.
</p>

### Create dump file

Dump your local database in compressed format using the open source [pg_dump](http://www.postgresql.org/docs/9.1/interactive/backup-dump.html) tool:

    :::term
    $ PGPASSWORD=mypassword pg_dump -Fc --no-acl --no-owner -h localhost -U myuser mydb > mydb.dump

### Import to Heroku Postgres

In order for PG Backups to access and import your dump file you will need to upload it somewhere with an HTTP-accessible URL.  We recommend using Amazon S3<!-- or [CloudApp](http://getcloudapp.com/)-->.

Use the raw file URL in the `pgbackups:restore` command:

<div class="callout" markdown="1">
Be sure to use single quotes around the temporary S3 URL, as it contains ampersands and other characters that will confuse your shell otherwise.
</div>

    :::term
    $ heroku pgbackups:restore DATABASE 'https://s3.amazonaws.com/me/items/3H0q/mydb.dump'

<!--heroku pgbackups:restore DATABASE 'http://f.cl.ly/items/1q2o3t1d3g0F1j2g3z18/mydb.dump'-->

Where `DATABASE` represents the `HEROKU_POSTGRESQL_COLOR_URL` of the database you wish to restore to. If no DATABASE is specified, it defaults to the applications current `DATABASE_URL`.

On completion of the import process be sure to delete the dump file from its storage location if it's no longer needed.      