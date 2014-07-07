---
title: Maintenance Mode
slug: maintenance-mode
url: https://devcenter.heroku.com/articles/maintenance-mode
description: Heroku’s maintenance mode feature serves a static page to all visitors allowing developers to perform maintenance tasks requiring no incoming traffic.
---

>callout
>By default, the maintenance mode page is unstyled; if you need a custom design, take a look at [Custom Error Pages](/articles/error-pages).

If you're deploying a large migration or need to disable access to your application for some length of time, you can use Heroku's built in maintenance mode. It will serve a static page to all visitors, while still allowing you to run [one-off dynos](one-off-dynos).

## Usage

Enable it like so:

```term
$ heroku maintenance:on
Enabling maintenance mode for myapp... done
```

Once your application is ready, you can disable maintenance mode with:

```term
$ heroku maintenance:off
Disabling maintenance mode for myapp... done
```

At any time you can also check the maintenance status of an app:

```term
$ heroku maintenance
off
```

## Customization

You can also create your own content to display when your application goes into maintenance mode using [Error Pages](error-pages).

To use, set your `MAINTENANCE_PAGE_URL`:

```term
$ heroku config:set MAINTENANCE_PAGE_URL=//s3.amazonaws.com/your_bucket/your_maintenance_page.html
```

See the [Error Pages docs](error-pages) for full details.

## Running Dynos

Enabling or disabling maintenance mode generally doesn't alter running dynos. Web dynos continue to run as before, but won't receive HTTP requests because the requests are blocked by the [routers](http-routing). Dynos of other types, such as worker dynos, will also continue to run.

In some cases you may want to scale down dynos when maintenance mode is enabled, for example if you are running a database migration that requires background jobs not be processed while the migration is running. You can scale down dynos using `heroku scale`:

```term
$ heroku maintenance:on
Enabling maintenance mode for myapp... done
$ heroku scale worker=0
Scaling worker processes... done, now running 0
```

If you do scale down dynos after enabling maintenance mode, be sure to scale them back up before returning traffic to the app.

You can run [one-off dynos](one-off-dynos) as usual while maintenance mode is enabled using `heroku run`. 