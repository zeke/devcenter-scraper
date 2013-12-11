---
title: Getting Started with Node.js on Heroku
slug: getting-started-with-nodejs
url: https://devcenter.heroku.com/articles/getting-started-with-nodejs
description: Creating, configuring, deploying and scaling Node.js applications on Heroku using npm dependency management as well as a database and add-ons.
---

This quickstart will get you going with [Node.js](http://nodejs.org/) and the [Express](http://expressjs.com/) web framework, deployed to Heroku. For general information on how to develop and architect apps for use on Heroku, see [Architecting Applications for Heroku](https://devcenter.heroku.com/articles/architecting-apps).

> note
> If you have questions about Node.js on Heroku, consider discussing it in the [Node.js on Heroku forums](https://discussion.heroku.com/category/node).

## Prerequisites

If you're new to Heroku or Node.js development, you'll need to set up a few things first:

- A Heroku user account. [Signup is free and instant](https://api.heroku.com/signup/devcenter).
- Install the [Heroku Toolbelt](https://toolbelt.heroku.com), which gives you git, Foreman, and the Heroku command-line interface.
- [Node.js](http://nodejs.org/), easily installed on Mac, Windows, and Linux with packages from [nodejs.org](http://nodejs.org/).

## Local workstation setup

Once installed, you can use the `heroku` command from your command shell.  Log in using the email address and password you used when creating your Heroku account:

```term
$ heroku login
Enter your Heroku credentials.
Email: zeke@example.com
Password:
Could not find an existing public key.
Would you like to generate one? [Yn]
Generating new SSH public key.
Uploading ssh public key /Users/adam/.ssh/id_rsa.pub
```

Press enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on.

## Write your app

You may be starting from an existing app.  If not, here's a simple "hello, world" sourcefile you can use:

```js
// web.js
var express = require("express");
var logfmt = require("logfmt");
var app = express();

app.use(logfmt.requestLogger());

app.get('/', function(req, res) {
  res.send('Hello World!');
});

var port = process.env.PORT || 5000;
app.listen(port, function() {
  console.log("Listening on " + port);
});
```


Declare dependencies with npm
-----------------------------

Heroku recognizes an app as Node.js by the existence of a `package.json` file. To create one, run `npm init` in the root directory of your app. The `npm init` utility will walk you through creating a `package.json` file. It only covers the most common items, and tries to guess sane defaults.

```term
$ cd node-example
$ npm init

name: (node-example)
version: (0.0.0)
description: This example app is so cool.
entry point: (index.js) web.js
test command:
git repository: https://github.com/jane-doe/node-example.git
keywords: example heroku
author: jane-doe
license: (BSD-2-Clause) MIT
...
```

Here's what our generated package.json file looks like:

```json
{
  "name": "node-example",
  "version": "0.0.0",
  "description": "This example app is so cool.",
  "main": "web.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/jane-doe/node-example.git"
  },
  "keywords": [
    "example",
    "heroku"
  ],
  "author": "jane-doe",
  "license": "MIT",
  "bugs": {
    "url": "https://github.com/jane-doe/node-example/issues"
  }
}
```

Now it's time to install some dependencies like [express](https://npmjs.org/package/express) and [logfmt](https://npmjs.org/package/logfmt). Use `npm install <pkg> --save` to install a package and
save it as a dependency in the package.json file.

``` term
$ npm install express logfmt --save
npm WARN package.json node-example@0.0.0 No README data
npm http GET https://registry.npmjs.org/express
npm http GET https://registry.npmjs.org/logfmt
npm http 304 https://registry.npmjs.org/logfmt
npm http 200 https://registry.npmjs.org/express
npm http GET https://registry.npmjs.org/express/-/express-3.4.6.tgz
npm http 200 https://registry.npmjs.org/express/-/express-3.4.6.tgz
npm http GET https://registry.npmjs.org/connect/2.11.2
npm http GET https://registry.npmjs.org/range-parser/0.0.4
...
```

> note
> Make sure that all of your app's dependencies are declared in `package.json` and that you are not relying on any system-level packages.

Lastly, you should specify the version(s) of node that are compatible with your application by adding an [engines](https://npmjs.org/doc/json.html#engines) field to your `package.json`. If you choose not to set this value, the default stable version of node will always be used when you deploy.

```json
{
  "engines": {
    "node": "0.10.x"
  }
}
```


Declare process types with Procfile
-----------------------------------

Use a [Procfile](procfile), a text file in the root directory of your application, to explicitly declare what command should be executed to start a web [dyno](dynos). In this case, you simply need to execute the Node script using `node`.

Here's a `Procfile` for the sample app we've been working on:

```term
web: node web.js
```

This declares a single process type, `web`, and the command needed to run it.  The name "web" is important here.  It declares that this process type will be attached to the [HTTP routing](http-routing) stack of Heroku, and receive web traffic when deployed.

You can now start your application locally using [Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html) (installed as part of the Toolbelt):

```term
$ foreman start
14:39:04 web.1     | started with pid 24384
14:39:04 web.1     | Listening on 5000
```

Your app will now be running at [localhost:5000](http://localhost:5000). Test that it's working with `curl` or a web browser, then Ctrl-C to exit.


Store your app in Git
---------------------

We now have the three major components of our app: dependencies in `package.json`, process types in `Procfile`, and our application source in `web.js`.  Let's put it into Git:

```term
$ git init
$ git add .
$ git commit -m "init"
```


Deploy your application to Heroku
---------------------------------

Create the app:

```term
$ heroku create
Creating sharp-rain-871... done, stack is cedar
http://sharp-rain-871.herokuapp.com/ | git@heroku.com:sharp-rain-871.git
Git remote heroku added
```

Deploy your code:

```term
$ git push heroku master
Counting objects: 343, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (224/224), done.
Writing objects: 100% (250/250), 238.01 KiB, done.
Total 250 (delta 63), reused 0 (delta 0)

-----> Node.js app detected
-----> Resolving engine versions
       Using Node.js version: 0.10.3
       Using npm version: 1.2.18
-----> Fetching Node.js binaries
-----> Vendoring node into slug
-----> Installing dependencies with npm
       ....
       Dependencies installed
-----> Building runtime environment
-----> Discovering process types
       Procfile declares types -> web

-----> Compiled slug size: 4.1MB
-----> Launching... done, v9
       http://sharp-rain-871.herokuapp.com deployed to Heroku

To git@heroku.com:sharp-rain-871.git
 * [new branch]      master -> master
```

## Visit your application

You've deployed your code to Heroku, and specified the process types in a `Procfile`.  You can now instruct Heroku to execute a process type.  Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.

Let's ensure we have one dyno running the `web` process type:

```term
$ heroku ps:scale web=1
```

You can check the state of the app's dynos.  The `heroku ps` command lists the running dynos of your application:

```term
$ heroku ps
=== web: `node web.js`
web.1: up for 10s
```

Here, one dyno is running.

We can now visit the app in our browser with `heroku open`.

```term
$ heroku open
Opening sharp-rain-871... done
```

## Dyno sleeping and scaling

Having only a single web dyno running will result in the dyno [going to sleep](dynos#dyno-sleeping) after one hour of inactivity.  This causes a delay of a few seconds for the first request upon waking. Subsequent requests will perform normally.

To avoid this, you can scale to more than one web dyno.  For example:

```term
$ heroku ps:scale web=2
```

For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dyno-hours-per-app).  Running your app at 2 dynos would exceed this free, monthly allowance, so let's scale back:

```term
$ heroku ps:scale web=1
```

## View the logs

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all the dynos running the components of your application.  Heroku’s [Logplex](logplex) provides a single channel for all of these events.

View information about your running app using one of the [logging commands](logging), `heroku logs`:

```term
$ heroku logs
2011-03-10T10:22:30-08:00 heroku[web.1]: State changed from created to starting
2011-03-10T10:22:32-08:00 heroku[web.1]: Running process with command: `node web.js`
2011-03-10T10:22:33-08:00 heroku[web.1]: Listening on 18320
2011-03-10T10:22:34-08:00 heroku[web.1]: State changed from starting to up
```


Console
-------

Heroku allows you to run commands in a [one-off dyno](oneoff-admin-ps) - scripts and applications that only need to be executed when needed - using the `heroku run` command.   Use this to launch a REPL process attached to your local terminal for experimenting in your app's environment:

```term
$ heroku run node
Running `node` attached to terminal... up, ps.1
>
```

This console has nothing loaded other than the Node.js standard library.  From here you can `require` some of your application files.

Advanced HTTP features
----------------------

> callout
> The WebSocket protocol is now supported as a [beta labs feature](https://devcenter.heroku.com/articles/heroku-labs-websockets) for apps running on the Cedar stack.

The HTTP stack available to Cedar apps on the `herokuapp.com` subdomain supports HTTP 1.1, long polling, and chunked responses.

Running a worker
----------------

The `Procfile` format lets you run any number of different [process types](procfile).  For example, let's say you wanted a worker process to complement your web process:

```term
$ cat Procfile
web: node web.js
worker: node worker.js
```

> note
> Running more than one dyno for an extended period may incur charges to your account. Read more about [dyno-hour costs](usage-and-billing).

Push this change to Heroku, then launch a worker:

```term
$ heroku ps:scale worker=1
Scaling worker processes... done, now running 1
```

Using a PostgreSQL database
----------------------------

To add the free Heroku Postgres Starter Tier dev database to your app, run this command:

```term
$ heroku addons:add heroku-postgresql:dev
Adding heroku-postgresql:dev... done, v3 (free)
```

This sets the `DATABASE_URL` environment variable. Add the [pg npm module](https://npmjs.org/package/pg) to your dependencies:

```json
"dependencies": {
  "pg": "2.x",
  "express": "3.x"
}
```

And use the module to connect to `DATABASE_URL` from somewhere in your code:

```js
var pg = require('pg');

pg.connect(process.env.DATABASE_URL, function(err, client, done) {
  client.query('SELECT * FROM your_table', function(err, result) {
    done();
    if(err) return console.error(err);
    console.log(result.rows);
  });
});
```

Read more about [Heroku PostgreSQL](heroku-postgresql).

Using MongoDB
-------------

To add a MongoDB database to your app, provision one of the [MongoDB add-ons](https://addons.heroku.com/marketplace/#data-stores):

```term
$ heroku addons:add mongolab
Adding redistogo on sharp-rain-871... done, v3 (free)
Use `heroku addons:docs mongolab` to view documentation.
```

Add the `mongodb` NPM module to your dependencies:

```term
$ npm install mongodb --save
npm http GET https://registry.npmjs.org/mongodb
npm http 200 https://registry.npmjs.org/mongodb
npm http GET https://registry.npmjs.org/bson/0.2.2
npm http GET https://registry.npmjs.org/kerberos/0.0.3
npm http 304 https://registry.npmjs.org/bson/0.2.2
npm http 304 https://registry.npmjs.org/kerberos/0.0.3
...
```

Use the module to connect using the provisioned MongoDB URL located in the environment.

```js
var mongo = require('mongodb');

var mongoUri = process.env.MONGOLAB_URI ||
  process.env.MONGOHQ_URL ||
  'mongodb://localhost/mydb';

mongo.Db.connect(mongoUri, function (err, db) {
  db.collection('mydocs', function(er, collection) {
    collection.insert({'mykey': 'myvalue'}, {safe: true}, function(er,rs) {
    });
  });
});
```

Using Redis
-----------

To add a Redis database to your app, run this command:

```term
$ heroku addons:add redistogo
Adding redistogo on sharp-rain-871... done, v3 (free)
Use `heroku addons:docs redistogo` to view documentation.
```

This sets the `REDISTOGO_URL` environment variable.  Add the `redis-url` NPM module to your dependencies:

```term
$ npm install redis-url --save
npm http GET https://registry.npmjs.org/redis-url
npm http 200 https://registry.npmjs.org/redis-url
npm http GET https://registry.npmjs.org/redis-url/-/redis-url-0.2.0.tgz
npm http 200 https://registry.npmjs.org/redis-url/-/redis-url-0.2.0.tgz
npm http GET https://registry.npmjs.org/redis
npm http 200 https://registry.npmjs.org/redis
npm http GET https://registry.npmjs.org/redis/-/redis-0.9.1.tgz
npm http 200 https://registry.npmjs.org/redis/-/redis-0.9.1.tgz
redis-url@0.2.0 node_modules/redis-url
└── redis@0.9.1
```

And use the module to connect to `REDISTOGO_URL` from somewhere in your code:

```js
var redis = require('redis-url').connect(process.env.REDISTOGO_URL);

redis.set('foo', 'bar');

redis.get('foo', function(err, value) {
  console.log('foo is: ' + value);
});
```

## Next steps

* Visit the [Node.js category](/categories/nodejs) to learn more about developing and deploying Node.js applications.
* Read [How Heroku Works](how-heroku-works) for a technical overview of the concepts you’ll encounter while writing, configuring, deploying and running applications.        