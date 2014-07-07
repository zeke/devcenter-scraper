---
title: Forking Applications
slug: fork-app
url: https://devcenter.heroku.com/articles/fork-app
description: Fork an existing app as a new app, including config vars, add-ons and Heroku Postgres data.
---

Use `heroku fork` to copy an existing application, including add-ons, config vars, and Heroku Postgres data.

It is a common practice to maintain [more than one environment](multiple-environments) for each application. For example, a staging and production environment for each app along with any number of ephemeral test environments for features in various stages of development. To ensure parity across applications, create new apps as forks from the production environment.

>warning
>Forked applications are created in the account of the user executing `heroku fork`. The forking user will be the owner of the app and responsible for any application charges. For this reason, your account needs to be verified if the application you're forking contains paid resources.

## Setup

You must have the [Heroku Toolbelt](https://toolbelt.heroku.com/) installed to use the features described here. [Verify your toolbelt installation](https://devcenter.heroku.com/articles/heroku-command#installing-the-heroku-cli) and update it to the latest version with `heroku update`.

## Fork application

>note
>For the purpose of this guide the originating app is called `sourceapp` and the new forked app is `targetapp`.

>callout
Any add-ons with paid plans on the old app will be provisioned with the same paid plans on the new app. Adjust your add-on plans as needed by up- or down-grading after forking.

Invoke `heroku fork` to create the target app, copy all Heroku Postgres data and config vars to the new app, and re-provision all add-ons with the same plan. Depending on the size of your database this process may take some time.

>warning
>Only Heroku Postgres data is automatically copied to the new application. All other add-ons are simply re-provisioned and you will need to manually manage any requisite data export/import for these services.

>callout
>Don't create `targetapp` yourself. `heroku fork` creates the target app as part of the forking process.

```term
$ heroku fork -a sourceapp targetapp
Creating fork targetapp... done
Copying slug... done
Adding pgbackups:plus... done
Adding heroku-postgresql:dev... done
Creating database backup from sourcapp... .. done
Restoring database backup to targetapp... .. done
Copying config vars... done
Fork complete, view it at http://targetapp.herokuapp.com/
```

To fork an app to a non-default [region](regions), use the `--region` flag:

```term
$ heroku fork -a sourceapp targetapp --region eu
```

### Add-on failures

Some add-ons may fail provisioning if they're no longer available.

```term
$ heroku fork -a sourceapp targetapp
Creating fork targetapp... done
Copying slug... ........ done
Adding airbrake:developer... done
Adding bonsai:test... skipped (not found)
...
```

If the add-ons can't be provisioned because the original plan no longer exists, upgrade the plan on the source app and retry the fork.

>callout
>If you've already run `heroku fork` you will need to destroy the target app before retrying: `heroku destroy -a targetapp`.


```term
$ heroku addons:upgrade bonsai:starter -a sourceapp
Upgrading to bonsai:starter on sourceapp... done, v207 (free)
```

## Manual add-on configuration

There are some add-ons that require additional configuration after provisioning. There may be others beyond the add-ons listed so please review your app's add-ons for any that have manually entered configuration.

### Heroku Postgres

All Heroku Postgres databases on your application will be copied from your `sourceapp` to your target app. This is done through pg_backups and does not take advantage fork Heroku Postgres forks. If you have followers this will result in duplicate copies that are not currently following your leader database. 

If the `DATABASE_URL` value was manually set on `sourceapp`, for instance to share a database with another app or to add a parameter like `?pool=10`, its value will copied to `targetapp` verbatim. In other words, `targetapp` will be configured to use the same database as `sourceapp`.

If this is not the desired functionality, use `heroku pg:promote` to use the database provisioned specifically for `targetapp` instead.

### Custom domains

Since custom domains can only belong to a single app at a time, no custom domains are copied as part of the forking process. If you want to use [custom domains](custom-domains) in your new environment you will need to add them yourself as well as make the necessary DNS additions.

### SSL

>warning
>If your forked app doesn't need to use SSL, remove the add-on with `heroku addons:remove ssl` to avoid unnecessary charges.


Although the forking process re-provisions the [SSL Endpoint](ssl-endpoint) on `targetapp` it does not add any certs on your behalf. If your app uses custom domains with SSL you need to add [new certs to your SSL endpoint instance](https://devcenter.heroku.com/articles/ssl-endpoint#provision-the-add-on) on `targetapp`.

```term
$ heroku certs:add server.crt server.key -a targetapp
Resolving trust chain... done
Adding SSL Endpoint to targetapp... done
example now served by tokyo-1234.herokussl.com
```

Add a new DNS CNAME record utilizing this new endpoint URL to serve requests via HTTPS.

<table>
  <tr>
    <th>Type</th>
    <th>Name</th>
    <th>Target</th>
  </tr>
  <tr>
    <td>CNAME</td>
    <td>www</td>
    <td>tokyo-1234.herokussl.com</td>
  </tr>
</table>

### Scheduler

The [Heroku Scheduler](https://addons.heroku.com/scheduler) add-on requires that the job schedule be manually transferred. Open the scheduler dashboard for both `sourceapp` and `targetapp` side-by-side to view the diffs and manually copy the jobs.

```term
$ heroku addons:open scheduler -a sourceapp
$ heroku addons:open scheduler -a targetapp
```

## Deploy

Forking your application doesn't automatically create a new git remote in your current project. To deploy to `targetapp` you will need to establish the git remote yourself. Use `heroku info` to retrieve the Git URL of the new application and the set it manually.

```term
$ heroku info -a targetapp
=== targetapp
...
Git URL:       git@heroku.com:targetapp.git
...
```

Add a git remote named `forked` representing the deploy URL for `targetapp`.

```term
$ git remote add forked git@heroku.com:targetapp.git
```

Deploy to the new environment with:

```term
$ git push forked master
```

If you wish to make the new app the default deployment target you can rename the git remotes.

```term
$ git remote rename heroku old
$ git remote rename forked heroku
```

## Forked app state

Forked apps are as close to the source app as possible. However, there are some differences.

### Git repository

When forking, the slug currently running in the forked app is copied to the new app. The Git repository contents of old app are _not_ copied to the Git repository of the new app.

### Dynos

Forked applications are similar to new apps in that they are scaled to the default [dyno formation](https://devcenter.heroku.com/articles/scaling#dyno-formation) consisting of a single web dyno and no worker or other dynos.

Scale your forked application's dynos to meet your needs:

```term
$ heroku ps:scale web=1 worker=1 -a targetapp
```

### Collaborators

No users from the source app are transferred over to the forked app. You need to add collaborators yourself.

```term
$ heroku sharing:add colleague@example.com -a targetapp
```

### Database followers

The forking process copies all databases present on `sourceapp` but does not retain any [fork](https://devcenter.heroku.com/articles/heroku-postgres-fork)/[follow](https://devcenter.heroku.com/articles/heroku-postgres-follower-databases) relationships between them. Remove extraneous databases yourself and manually re-establish any forks or followers.

### Labs features

Any enabled [Heroku Labs](https://devcenter.heroku.com/categories/labs) features on `sourceapp` are not re-enabled on `targetapp`. 