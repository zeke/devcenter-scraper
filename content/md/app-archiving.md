---
title: App Archiving
slug: app-archiving
url: https://devcenter.heroku.com/articles/app-archiving
description: App archiving
---

Some apps on Heroku may be automatically archived.

When archived, an app won't be accessible via any web domain.  In particular, accessing the app on its `.herokuapp.com` domain will yield a "No such app" response. 

Currently apps are archived only if they have never had a [user-initiated deploy](git), i.e. they are empty apps or apps created from templates and never changed.

Use the [Heroku CLI](/articles/heroku-command) to determine whether an app has been archived:

```term
$ heroku apps:info -a example-app
=== example-app
Archived At:   2013-07-24 01:10 UTC
...
```

You can also inspect archived state in [Heroku Dashboard](https://dashboard.heroku.com/).

![screenshot showing archived app](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/205-original.jpg)

Apps can be un-archived by deploying any change to the application. See the [getting started guide](articles/quickstart) for details.