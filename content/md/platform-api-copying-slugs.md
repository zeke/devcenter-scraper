---
title: Copying Slugs with the Platform API
slug: platform-api-copying-slugs
url: https://devcenter.heroku.com/articles/platform-api-copying-slugs
description: Copying slugs on Heroku via the Heroku Platform API's release API endpoint.
---

This article describes how a slug from one app can be used to create a release on another app. Imagine that you have pushed code to a staging app, the code has been tested and you are now ready to release to production. Instead of pushing to the production app and waiting for the code to build again, you can simply copy the slug from the staging app to the production app.

First, [list releases](https://devcenter.heroku.com/articles/platform-api-reference#release-list) on the staging app to get the id of the slug to release on the production app:

```term
$ curl -H "Accept: application/vnd.heroku+json; version=3" -n \
https://api.heroku.com/apps/example-app-staging/releases
...
"slug":{ "id":"ff40c84f-a538-4b65-a838-88fdd5245f4b" }
```

Now, create a new release on the production app using the slug from the staging app:

```term
$ curl -X POST -H "Accept: application/vnd.heroku+json; version=3" -n \
-H "Content-Type: application/json" \
-d '{"slug": "ff40c84f-a538-4b65-a838-88fdd5245f4b"}' \
https://api.heroku.com/apps/example-app-production/releases
```

That’s it! The new code is now running on the `example-app-production` app.

Note that copying slugs between apps is already possible using the beta [Pipelines plugin](https://blog.heroku.com/archives/2013/7/10/heroku-pipelines-beta), and [Heroku Fork](https://blog.heroku.com/archives/2013/6/27/heroku-fork). The release endpoint exposes the primitives necessary for third-party API developers to build services offering similar functionality. 