---
title: Heroku Node.js Support
slug: nodejs-support
url: https://devcenter.heroku.com/articles/nodejs-support
description: Reference documentation describing the the support for Node.js on Heroku's Cedar stack.
---

This document describes the general behavior of the Cedar stack as it relates
to the recognition and execution of Node.js applications. For a more detailed
explanation of how to deploy an application, see [Getting Started with Node.js
on Heroku](getting-started-with-nodejs).

> note
> If you have questions about Node.js on Heroku, consider discussing it in the [Node.js on Heroku forums](https://discussion.heroku.com/category/node).

## Activation

The Heroku Node.js buildpack is employed only when the application has a
`package.json` file in the root directory.

## Node.js runtimes

Node versions adhere to [SemVer](http://semver.org/), the semantic versioning convention popularized by GitHub. SemVer uses a version scheme in the form `MAJOR.MINOR.PATCH`.

- `MAJOR` denotes incompatible API changes
- `MINOR` denotes added functionality in a backwards-compatible manner
- `PATCH` denotes backwards-compatible bug fixes

Node's versioning strategy is [borrowed from Linux](http://en.wikipedia.org/wiki/Software_versioning#Odd-numbered_versions_for_development_releases), where odd `MINOR` version numbers denote unstable development releases, and even `MINOR` version numbers denote stable releases. Here are some examples for node:

- `0.8.x`: stable
- `0.9.x`: unstable
- `0.10.x`: stable
- `0.11.x`: unstable

### Supported runtimes

Heroku's node support extends to the latest stable `MINOR` version and the previous `MINOR` stable version that still receives security updates. 

Currently, those versions are `0.10.x` and `0.8.x`.

Version `0.12` is expected to be the [last stable minor version before `1.0`](http://venturebeat.com/2014/03/12/nodes-new-leader-tj-fontaine-explains-why-version-0-12-will-blow-developers-minds/). When `0.12` is released, Heroku support for `0.8` will be dropped. When `1.0` is released, Heroku support for `0.10` will be dropped, and so on.

### Other available runtimes

While there are limits to the Node versions officially Heroku supports, it is technically possible to run any available version of Node beyond `0.8.5`, including unstable pre-release versions like `0.11.13`. To see what versions of node are currently available for use on Heroku, visit [semver.io/node.json](http://semver.io/node.json) or [what-is-the-latest-version-of-node.com](http://what-is-the-latest-version-of-node.com/).

## Specifying a Node.js Version

Use the `engines` section of your `package.json` to specify the version of Node.js to use on Heroku:

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

To run a newer (unsupported) version of node with support for generators, promises, and other new features, use the `0.11.x` SemVer range:

```json
{
  "engines": {
    "node": "0.11.x"
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

## Build Behavior

Heroku maintains a [cache directory](https://devcenter.heroku.com/articles/buildpack-api#caching) that is persisted between builds. This
cache is used to store resolved dependencies so they don't have to be
downloaded and installed every time you deploy.

If you add `node_modules` to your `.gitignore` file, the build cache is used. If you check your `node_modules` directory into source control, the build cache is **not** used.

`npm install --production` is run on every build, even if the node_modules directory is already present, to ensure execution of any [npm script hooks](https://npmjs.org/doc/misc/npm-scripts.html) defined in your package.json.

`npm prune` is run after restoring cached modules to ensure cleanup of any unused dependencies. You must specify all of your application's dependencies in `package.json`, else they will be removed by `npm prune`.

On each build, the node runtime version is checked against the version in the previous build. If the version has changed, `npm rebuild` is run automatically to recompile any binary dependencies. This ensures your app’s dependencies are compatible with the installed node version.

## Customizing the Build Process

If your app has a build step that you'd like to run when you deploy, you can use
an npm `postinstall` script, which will be executed automatically after the
buildpack runs `npm install --production`. Here's an example:

```json
"scripts": {
  "start": "node index.js",
  "test": "mocha",
  "postinstall": "bower install && grunt build"
}
```

Your app's [environment is
available](https://devcenter.heroku.com/changelog-items/416) during the build,
allowing you to adjust build behavior based on the values of
environment variables such as `NODE_ENV`.

By default, the Heroku node buildpack runs `npm install --production`, which doesn't install `devDependencies` in
your package.json file. If you wish to install development dependencies when deploying to Heroku, there are two ways to do so:

- Move your build dependencies (such as grunt plugins) from `devDependencies` to `dependencies` in package.json.
- Configure npm to install all dependencies by setting a config var:

```term
$ heroku config:set npm_config_production=false
```

## Runtime Behavior

The buildpack puts `node` and `npm` on the `PATH` so they can be executed with [heroku run](https://devcenter.heroku.com/articles/one-off-dynos#an-example-one-off-dyno) or used directly in a Procfile:

```term
$ cat Procfile
web: npm start
```

## Default Web Process Type

A `Procfile` is not required to run a Node.js app on Heroku. If no `Procfile` is present in the root directory of your app during the build process, we will check for a `scripts.start` entry in your `package.json` file. If a start script entry is present, a default Procfile is generated automatically:

```term
$ cat Procfile
web: npm start
```

Read more about npm script behavior at [npmjs.org](https://npmjs.org/doc/misc/npm-scripts.html).

## Add-ons

No add-ons are provisioned by default.  If you need a SQL database for your
app, add one explicitly:

```term
$ heroku addons:add heroku-postgresql
```

## Going further

The Heroku Node.js buildpack is open source. For a better technical understand of how the buildpack works, check out the source code at [github.com/heroku/heroku-buildpack-nodejs](https://github.com/heroku/heroku-buildpack-nodejs#readme).