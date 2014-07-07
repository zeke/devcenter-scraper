---
title: Releases
slug: releases
url: https://devcenter.heroku.com/articles/releases
description: The releases functionality of Heroku allows applications to record and rollback to previous versions.
---

Whenever you [deploy code](git), change a [config var](config-vars), or add or remove an [add-on resource](managing-add-ons), Heroku creates a new release and restarts your app.  You can list the history of releases, and use rollbacks to revert to prior releases for backing out of bad deploys or config changes.

## Release creation

Release are named in the format `vNN`, where `NN` is an incrementing sequence number for each release.

Releases are created whenever you deploy code.  In this example, v10 is the release created by the deploy:

```term
$ git push heroku master
...
-----> Compressing... done, 8.3MB
-----> Launching... done, v10
       http://severe-mountain-793.herokuapp.com deployed to Heroku
```

Release are created whenever you change config vars.  In this example, v11 is the release created by the config change:

```term
$ heroku config:set MYVAR=42
Adding config vars:
  MYVAR => 42
Updating vars and restarting app... done, v11
```

And releases are created whenever you add, remove, upgrade, or downgrade add-on resources.  In this example, v12 is the release created by the add-on change:

```term
$ heroku addons:add memcachier
Adding memcachier to myapp... done, v12 (free)
```

## Listing release history

To see the history of releases for an app:

```term
$ heroku releases
Rel   Change                          By                    When
----  ----------------------          ----------            ----------
v52   Config add AWS_S3_KEY           jim@example.com       5 minutes ago            
v51   Deploy de63889                  stephan@example.com   7 minutes ago
v50   Deploy 7c35f77                  stephan@example.com   3 hours ago
v49   Rollback to v46                 joe@example.com       2010-09-12 15:32:17 -0700
```

The number next to the deploy message, for example de63889, corresponds to the commit hash of the repository you deployed to Heroku.  Use this to correlate changes in a release with a changes in your code repository.  For example:

```term
$ git log -n 1 de63889
commit de63889c20a96347679af2c5160c390727fa6749
Author: <stephan@example.com>
Date:   Thu Jul 11 17:16:20 2013 +0200
Fixed listing CSS and localisation of description.
```

To get detailed info on a release:

```term
$ heroku releases:info v24
=== Release v24
Change:      Deploy 575bfa8
By:          jim@example.com
When:        6 hours ago
Addons:      deployhooks:email, releases:advanced
Config:      MY_CONFIG_VAR => 42
             RACK_ENV      => production
```

## Rollback

>callout
>You cannot roll back to a release which would change the state of add-ons, since this affects billing.


Use the `rollback` command to roll back to the last release:

```term
$ heroku rollback
Rolled back to v51
```

You may choose to specify another release to target:

```term
$ heroku rollback v40
Rolled back to v40
```

Rolling back will create a new release which is a copy of the state of the compiled slug and config vars of the release specified in the command.  The state of your `heroku` Git remote, database, and external state held in add-ons (for example, the contents of memcache) will **not** be affected and is your responsibility to reconcile with the rollback.

Running on a rolled-back release is meant as a **temporary fix** to a bad deployment. If you are on a rolled-back release, fix and commit the problem locally, and re-push to Heroku to update the `heroku` Git remote and create a new release. 