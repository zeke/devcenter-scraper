---
title: Heroku Node.js Support
slug: nodejs-support
url: https://devcenter.heroku.com/articles/nodejs-support
description: Reference documentation describing the the support for Node.js on Heroku's Cedar stack.
---

This document describes the general behavior of the Cedar stack as it relates
to the recognition and execution of Node.js applications. For a more detailed
explanation of how to deploy an application, see [Getting Started with Node.js
on Heroku](http://devcenter.heroku.com/articles/nodejs).

> note
> If you have questions about Node.js on Heroku, consider discussing it in the [Node.js on Heroku forums](https://discussion.heroku.com/category/node).

## Activation

The Heroku Node.js buildpack is employed only when the application has a
`package.json` file in the root directory.

## Versions

Heroku allows you to run any version of Node.js greater than `0.8.5`, including unstable
pre-release versions like `0.11.8`. Use the `engines` section of your `package.json` to
specify the version of Node.js to use on Heroku.

To see what versions of node are currently available, visit [semver.io/node.json](http://semver.io/node.json) or [what-is-the-latest-version-of-node.com](http://what-is-the-latest-version-of-node.com/).

```json
{
  "name": "myapp",
  "description": "a really cool app",
  "version": "0.0.1",
  "engines": {
    "node": "0.10.x"
  }
}
```

You should always specify a `node` version, but if you don't the latest stable version will be used. There is no need to specify an `npm` version, as `npm` is bundled with `node`.

## Environment

The following environment variables will be set:

```sh
PATH=vendor/node/bin:bin:node_modules/.bin:$PATH
NODE_ENV=production
```

The `NODE_ENV` environment variable defaults to `production`, but you can
override it if you wish:

```sh
heroku config:set NODE_ENV=staging
```

## Build behavior

Heroku maintains a [cache directory](https://devcenter.heroku.com/articles
/buildpack-api#caching) that is persisted between builds. This
cache is used to store resolved dependencies so they don't have to be
downloaded and installed every time you deploy.

If you add `node_modules` to your `.gitignore` file, the build cache is used. If, however, you check your `node_modules` directory into source control, the build cache is **not** used.

`npm install --production` is run on every build, even if the node_modules directory is already present, to ensure execution of any [npm script hooks](https://npmjs.org/doc/misc/npm-scripts.html) defined in your package.json.

`npm prune` is run after restoring cached modules to ensure cleanup of any unused dependencies. You must specify all of your application's dependencies in `package.json`, else they will be removed by `npm prune`.

## Runtime behavior

The buildpack puts `node` and `npm` on the `PATH` so they can be executed with [heroku run](https://devcenter.heroku.com/articles/one-off-dynos#an-example-one-off-dyno) or used directly in a Procfile:

```
web: node web.js
```

## Add-ons

No add-ons are provisioned by default.  If you need a SQL database for your
app, add one explicitly:

```term
$ heroku addons:add heroku-postgresql
```

## Going further

The Heroku Node.js buildpack is open source. For a better technical understand of how the buildpack works, check out the source code at [github.com/heroku/heroku-buildpack-nodejs](https://github.com/heroku/heroku-buildpack-nodejs#readme).        