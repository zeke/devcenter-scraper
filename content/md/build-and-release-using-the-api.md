---
title: Building and Releasing using the Platform API
slug: build-and-release-using-the-api
url: https://devcenter.heroku.com/articles/build-and-release-using-the-api
description: How to use the build resource of the Platform API to build source code into slugs that can be run by apps on the Heroku platform.
---

This article describes how to use the [`build`](https://devcenter.heroku.com/articles/platform-api-reference#build) resource of the [Platform API](https://devcenter.heroku.com/articles/platform-api-quickstart) to build source code into slugs that can be run by apps on the Heroku platform.

The build resource complements the interactive [git-based deployment flow](https://devcenter.heroku.com/articles/git) but is optimized for non-interactive continuous integration setups. The outputs of using the Build resource are slugs and releases that can be downloaded, manipulated, reused, and moved around with the [slug and release endpoints](https://devcenter.heroku.com/articles/platform-api-deploying-slugs) of the Platform API.

By combining the Build resource and the slug and release resources, developers can build flows where source code is pushed to a repository (not on Heroku), built into a slug by the Build resource and then deployed to one or more apps on the platform.

The Build resource is available on `api.heroku.com` along with the rest of the [Platform API](https://devcenter.heroku.com/articles/platform-api-reference).

## Creating builds

Creating a build from a source tarball is simple:

```term
$ curl -n -X POST https://api.heroku.com/apps/example-app/builds \
-d '{"source_blob":{"url":"https://github.com/heroku/node-js-sample/archive/master.tar.gz", "version": "cb6999d361a0244753cf89813207ad53ad906a14"}}' \
-H 'Accept: application/vnd.heroku+json; version=3' \
-H "Content-Type: application/json"
{
  "created_at": "2014-04-23T02:47:04+00:00",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "source_blob": {
    "url": "https://github.com/heroku/node-js-sample/archive/cb6999d361a0244753cf89813207ad53ad906a14.tar.gz",
    "version": "cb6999d361a0244753cf89813207ad53ad906a14"
  },
  "slug": {
    "id": null
  },
  "status": "pending",
  "updated_at": "2014-04-23T02:47:11+00:00",
  "user": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```

This will cause Heroku to fetch the source tarball, unpack it and start a build, just as if the source code had been pushed to Heroku using git. If the build completes successfully, the resulting slug will be deployed automatically to the app in a new release.

> callout
> If for some reason you just want to create slugs that are not immediately released to a particular app, we currently recommend creating a separate app to handle builds and then [use the generated slugs to create releases](https://devcenter.heroku.com/articles/platform-api-copying-slugs) on the apps where you want slugs to run.

In the example above, we pass in an optional `version` parameter. This is a piece of metadata that you use to track what version of your source originated this build. If you are creating builds from git-versioned source code, for example, the commit hash would be a good value to use for the `version` parameter. The version parameter is _not_ required and is _not_ used when downloading and building the source code. It's merely a piece of metadata used that you can optionally use to track what source code version went into building what slug.

## Listing builds

You can list builds for a particular app:

```term
$ curl -n https://api.heroku.com/apps/example-app/builds \
-H 'Accept: application/vnd.heroku+json; version=3'
[
  {
    "created_at": "2014-04-23T02:47:04+00:00",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "source_blob": {
      "url": "https://github.com/heroku/node-js-sample/archive/cb6999d361a0244753cf89813207ad53ad906a14.tar.gz",
      "version": "cb6999d361a0244753cf89813207ad53ad906a14"
    },
    "slug": {
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "status": "succeeded",
    "updated_at": "2014-04-23T02:47:11+00:00",
    "user": {
      "email": "username@example.com",
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    }
  },
  ...
]

```

The sample output above show one completed build. Note that the slug id is included in the output. You can use the slug id to create new releases on the same apps or on other apps on Heroku. You can also use the [slug resource](https://devcenter.heroku.com/articles/platform-api-copying-slugs) to download slugs to debug builds, for example.

All builds are available in the build list, including ones created by git-pushing to the Heroku repository for the app. Builds that fail for any reason are also tracked.  To get the status of a build, check the `status` property. Possible values are `pending`, `successful` and `failed`.

## Build output

You can also get the output of a particular build:

```term
$ curl -n https://api.heroku.com/apps/example-app/builds/01234567-89ab-cdef-0123-456789abcdef/result \
-H 'Accept: application/vnd.heroku+json; version=3'
{
"build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "succeeded"
  },
  "exit_code": 0,
  "lines": [
    {
      "stream": "STDOUT",
      "line": "\n"
    },
    {
      "stream": "STDOUT",
      "line": "-----> Fetching custom git buildpack... done\n"
    },
    ...
   ]
}
```

The output includes both `STDOUT` and `STDERR` and is provided in the order it was output by the build. If you combine with values of all the `line` elements, you will will get the same output as you would have seen when doing an interactive `git push` to Heroku.