---
title: The Process Model
slug: process-model
url: https://devcenter.heroku.com/articles/process-model
description: The Heroku Cedar stack uses a Unix-style process model for web, worker and all other types of processes.
---

The unix process model is a simple and powerful abstraction for running server-side programs.  Applied to web apps, the process model gives us a unique way to think about dividing our workloads and scaling up over time.  The Heroku [Cedar](cedar) stack uses the process model for web, worker and all other types of dynos.

## Basics

Let's begin with a simple illustration of the basics of the process model, using a well-known unix daemon: memcached.

Download and compile it:

```term
$ wget http://memcached.googlecode.com/files/memcached-1.4.5.tar.gz
$ tar xzf memcached-1.4.5.tar.gz 
$ cd memcached-1.4.5
$ ./configure
$ make
```

Run the program:

```term
$ ./memcached -vv
...
<17 server listening (auto-negotiate)
<18 send buffer was 9216, now 3728270
```

This running program is called a **process**.

Running manually in a terminal is fine for local development, but in a production deployment we want memcached to be a **managed** process.  A managed process should run automatically when the operating system starts up, and should be restarted if the system crashes or dies for any reason.

In traditional server-based deployments, the OS provides a **process manager**.  On OS X, [launchd](http://launchd.macosforge.org/) is the built-in process manager; on Ubuntu, [Upstart](http://upstart.ubuntu.com/) the built-in process manager.  On Heroku, the [dyno manager](dynos#the-dyno-manager) provides an analogous mechanism.

Now that we've established a baseline for the process model, we can put its principles to work in more novel way: running a web app.

## Mapping the Unix process model to web apps

A server daemon like memcached has a single entry point, meaning there's only one command you run to invoke it.  Web apps, on the other hand, typically have two or more entry points.  Each of these entry points can be called a [process type](procfile#declaring-process-types).

A basic Rails app will typically have two process types: a Rack-compatible web process type (such as Webrick or Unicorn), and a worker process type using a queueing library (such as Delayed Job or Resque).  For example:

<table>
  <tr><th>Process type</th><th>Command</th></tr>
  <tr><td>web</td><td>bundle exec rails server</td></tr>
  <tr><td>worker</td><td>bundle exec rake jobs:work</td></tr>
</table>

A basic Django app looks strikingly similar: a web process type can be run with the `manage.py` admin tool; and background jobs via Celery.

<table>
  <tr><th>Process type</th><th>Command</th></tr>
  <tr><td>web</td><td>python manage.py runserver</td></tr>
  <tr><td>worker</td><td>celeryd --loglevel=INFO</td></tr>
</table>

For Java, your process types might look like this:

<table>
  <tr><th>Process type</th><th>Command</th></tr>
  <tr><td>web</td><td>java $JAVA_OPTS -jar web/target/dependency/webapp-runner.jar --port $PORT web/target/*.war</td></tr>
  <tr><td>worker</td><td>sh worker/target/bin/worker</td></tr>
</table>

Process types differ for each app.  For example, some Rails apps use Resque instead of Delayed Job, or have multiple types of workers.  Every app needs to declare its own process types.

`Procfile` offers a format for declaring your process types, and Foreman is a tool that makes it easy to run the commands defined in the process types in your development environment.  Read [the Procfile documentation](procfile) for details.

## Process types vs dynos

To scale up, we'll want a full grasp of the relationship between process types and dynos.

A **process type** is the prototype from which one or more **dynos** are instantiated.  This is similar to the way a **class** is the prototype from which one or more **objects** are instantiated in object-oriented programming.

Here's a visual aid showing the relationship between dynos (on the vertical axis) and process types (on the horizontal axis):

![](https://s3-eu-west-1.amazonaws.com/jon-assettest/dynos.jpg)

Dynos, on the vertical axis, are **scale**.  You increase this direction when you need to scale up your concurrency for the type of work handled by that process type.  On Heroku, you do this with the `scale` command:

```term
$ heroku ps:scale web=2 worker=4 clock=1
Scaling web processes... done, now running 2
Scaling worker processes... done, now running 4
Scaling clock processes... done, now running 1
```

Process types, on the horizontal axis, are **workload diversity**.  Each process type specializes in a certain type of work.

For example, some apps have two types of workers, one for urgent jobs and another for long-running jobs.  By subdividing into more specialized workers, you can get better responsiveness on your urgent jobs and more granular control over how to spend your compute resources.  A [queueing](background-jobs-queueing) system can be used to distribute jobs to the worker dynos.

## Scheduling processes

Scheduling work at a certain time of day, or time intervals, much like `cron` does, can be achieved with a tool like the [Heroku Scheduler](scheduler) add-on or by using a [specialized job-scheduling process type](scheduled-jobs-custom-clock-processes).

## One-off admin dynos

The set of dynos run by the [dyno manager](dynos#the-dyno-manager) via `heroku ps:scale` are known as the [dyno formation](scaling) - for example, web=2 worker=4 clock=1.  In addition to these dynos, which run continually, the process model also allows for one-off dynos to handle administrative tasks, such as database migrations and console sessions.

[Read more about one-off dynos.](one-off-dynos)

## Output streams as logs

All code running on dynos under the process model should send their logs to `STDOUT`.  Locally, output streams from your processes are displayed by Foreman in your terminal.  On Heroku, output streams from processes executing on all your dynos are collected together by [Logplex](logging) for easy viewing with the `heroku logs` command. 