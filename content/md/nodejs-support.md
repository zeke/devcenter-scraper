---
title: Heroku Node.js Support
slug: nodejs-support
url: https://devcenter.heroku.com/articles/nodejs-support
description: Reference documentation describing the the support for Node.js on Heroku's Cedar stack.
---

This document describes the general behavior of the Cedar stack as it
relates to the recognition and execution of Node.js applications. For
a more detailed explanation of how to deploy an application, see [Getting Started with Node.js on Heroku/Cedar](http://devcenter.heroku.com/articles/nodejs).

<div class="note" markdown="1">
If you have questions about Node.js on Heroku, consider discussing it in the [Node.js on Heroku forums](https://discussion.heroku.com/category/node).
</div>

## Activation

The Heroku Node.js Support is applied only when the application has a `package.json` file in the root directory.

## Versions

You can use the `engines` section of your `package.json` to specify the version of Node.js and npm to use on Heroku.

    :::javascript
	{
	  "name": "myapp",
	  "version": "0.0.1",
	  "engines": {
	    "node": "0.10.x",
	    "npm":  "1.2.x"
	  }
	}


If you do not specify a version, the latest will be used. The available versions of Node.js and npm can be found here:

* [Node.js version manifest](http://heroku-buildpack-nodejs.s3.amazonaws.com/manifest.nodejs)
* [npm version manifest](http://heroku-buildpack-nodejs.s3.amazonaws.com/manifest.npm)

## Environment

The following environment variables will be set:

* `PATH` => `"bin:node_modules/.bin:/usr/local/bin:/usr/bin:/bin"`

## Build behavior

The Node.js buildpack runs the following commands on your app to resolve dependencies:

    $ npm install --production
    $ npm rebuild

## Runtime behavior

The highest available version of Node.js that matches your `engines` specification will be available on the `PATH`. You can use it directly in a Procfile:

    web: node web.js

## Add-ons

No add-ons are provisioned by default.  If you need a SQL database for your app, add one explicitly:

    :::term
    $ heroku addons:add heroku-postgresql:dev
   