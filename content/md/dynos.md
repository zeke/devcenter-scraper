---
title: Dynos and the Dyno Manager
slug: dynos
url: https://devcenter.heroku.com/articles/dynos
description: A dyno is a lightweight container running a single user-specified command managed the dyno manager.
---

<div class="callout" markdown="1">
Read [How it Works](how-heroku-works) for a technical introduction to the concepts behind the Heroku platform.
</div>

A dyno is a lightweight container running a single user-specified command. You can think of it as a virtualized Unix container---it can run any command available in its default environment (what we supply in the [Cedar stack](cedar)) combined with your app's [slug](slug-compiler) (which will be based on your code and its dependencies).

The commands run within dynos include web processes, worker processes (such as timed jobs and queuing systems), and any process types declared in the app’s [Procfile](procfile).  Admin and maintenance commands can also be run in [one-off dynos](oneoff-admin-ps).

## Features

* **Elasticity & scale:** The number of dynos allocated for your app can be increased or decreased at any time. [Read more about scaling your dynos](scaling).

* **Routing:** The [routers](http-routing) tracks the location of all running dynos with the web process type (web dynos) and routes HTTP traffic to them accordingly.

* **Dyno management:** Running dynos are monitored to make sure they continue running. Dynos that crash are removed and new dynos are launched to replace them.

* **Distribution and redundancy:** Dynos are distributed across an elastic execution environment. An app configured with two web dynos, for example, may end up with each web dyno running in a separate physical location. If infrastructure underlying one of those two dynos fails, the other stays up — and so does your site.

* **Isolation:** Every dyno is isolated in its own subvirtualized container with many benefits for security, resource guarantees, and overall robustness.

## Memory behavior

Dynos are available in [1X or 2X sizes](https://devcenter.heroku.com/articles/dyno-size) and are allocated 512MB or 1024MB respectively.

Dynos whose processes exceed their memory quota are identified by an [R14 error](https://devcenter.heroku.com/articles/error-codes#r14-memory-quota-exceeded) in the [logs](logging). This doesn't terminate the process, but it does warn of deteriorating application conditions: memory used above quota will [swap out to disk](http://en.wikipedia.org/wiki/Virtual_memory), which **substantially degrades** dyno performance.

If the memory size keeps growing until it reaches three times its quota, the dyno manager will restart your dyno with an [R15 error](https://devcenter.heroku.com/articles/error-codes#r15-memory-quota-vastly-exceeded).

If you suspect a [memory leak](http://www.ibm.com/developerworks/java/library/j-leaks/) in your application, memory profiling tools such as [Oink](https://github.com/noahd1/oink) for Ruby or [Heapy](http://guppy-pe.sourceforge.net/#Heapy) for Python can be helpful.

## The dyno manager

Your application's dynos run in a distributed, fault-tolerant, and horizontally scalable execution environment. The dyno manager manages many different applications via the [the process model](process-model) and keeps dynos running automatically; so operating your app is generally hands-off and maintenance free.

### Automatic dyno restarts

The dyno manager restarts all your app's dynos whenever you create a new [release](releases) by deploying new code, changing your [config vars](config-vars), changing your [add-ons](managing-add-ons), or when you run `heroku restart`.  You can watch this happen in realtime using the Unix <a href="http://en.wikipedia.org/wiki/Watch_(Unix)">watch</a> command: run `watch heroku ps` in one terminal while pushing code or changing a config var in another.

Dynos are also cycled at least once per day, in addition to being restarted as needed for the overall health of the system and your app. For example, the dyno manager occasionally detects a fault in the underlying hardware and needs to move your dyno to a new physical location. These things happen transparently and automatically on a regular basis and are logged to your [application logs](logging).

Dynos are also restarted if the processes running in the dyno exit.
The cases when the processes running in a dyno can exit are as follows:

* Defect in startup code - If your app is missing a critical dependency, or has any other problem during startup, it will exit immediately with a stack trace.
* Transient error on a resource used during startup - If your app accesses a resource during startup, and that resource is offline, it may exit.  For example, if you're using Amazon RDS as your database and didn't create a security group ingress for your Heroku app, your app will generate an error or time out trying to boot.
* Segfault in a binary library - If your app uses a binary library (for example, an XML parser), and that library crashes, then it may take your entire application with it.  Exception handling can't trap it, so your process will die.
* Interpreter or compiler bug - The rare case of a bug in an interpreter (Ruby, Python) or in the results of compilation (Java, Scala) can take down your process.

As app developers, we tend to see the first two errors as "boot crashes" and the second two as "runtime crashes."  However, Heroku has [no way](http://en.wikipedia.org/wiki/Halting_problem) to distinguish these.  From the platform's perspective, all process crashes are alike.  These scenarios result in crashed dynos.

### Dyno crash restart policy

If a dyno crashes during boot, Heroku will immediately attempt to restart it again. If a dyno crashes during subsequent attempts, Heroku will continue to attempt to restart it again, but the attempts will be spaced apart by increasing intervals. If the second restart attempt fails, there will be a 10 minute cool-off period before the third attempt. If the third restart attempt fails, there will be a 20 minute cool-off period, followed by a 40 minute cool-off period and so forth up to a maximum 24 hour cool-off period between restart attempts.

### Dyno sleeping

<p class="callout" markdown="1">If your app has only a single web dyno running, that web dyno will sleep - irrespective of the number of worker dynos. You have to have more than one **web** dyno to prevent web dynos from sleeping.  Worker dynos do not sleep.</p>

Apps that have scaled the number of web dynos (dynos running the `web` [process type](process-model#process-types-vs-dynos)) so that only a single web dyno is running, will have that web dyno sleep after one hour of inactivity.  When this happens, you'll see the following in your [logs](logging):

    2011-05-30T19:11:09+00:00 heroku[web.1]: Idling
    2011-05-30T19:11:17+00:00 heroku[web.1]: Stopping process with SIGTERM

When you access the app in your web browser or by some other means of sending an HTTP request, the [router](http-routing) processing your request will signal the dyno manager to unidle (or "wake up") your dyno to run the `web` process type:

    2011-05-30T22:17:43+00:00 heroku[web.1]: Unidling
    2011-05-30T22:17:43+00:00 heroku[web.1]: State changed from created to starting

This causes a few second delay for this first request.  Subsequent requests will perform normally.

Apps that have more than 1 web dyno running never sleep. Workers dynos never sleep.

### Startup

During startup, the container starts a `bash` shell that runs any code in `$HOME/.profile` before executing the dyno's command. You can put `bash` code in this file to manipulate the initial environment, at runtime, for all dyno types in your app.

#### Example `.profile`

<div class="callout" markdown="1">
The `.profile` script will be sourced *after* the app's config vars. To have the config vars take precedence, use a technique like that shown here with `LANG`.
</div>


    # add vendor binaries to the path
    PATH=$PATH:$HOME/vendor/bin

    # set a default LANG if it does not exist in the environment
    LANG=${LANG:-en_US.UTF-8}

<div class="warning" markdown="1">
For most purposes, [config vars](config-vars) are more convenient and flexible. You need not push new code to edit config vars, whereas `.profile` is part of your source tree and must be edited and deployed like any code change.
</div>

#### Local environment variables

The Dyno Manager sets up a number of default environment variables that you can access in your application. 

* If the dyno is a web dyno, the `$PORT` variable will be set.  The dyno must bind to this port number to receive incoming requests.
<div class="callout" markdown="1">
The `$DYNO` variable is experimental and subject to change or removal.
Also, `$DYNO` is not guaranteed to be unique within an app. For example, during a deploy or restart, the same dyno identifier could be used for two running dynos. It will be eventually consistent, however.
</div>
* The `$DYNO` variable will be set to the dyno identifier. e.g. `web.1`, `worker.2`, `run.9157`.

#### Processes

After the `.profile` script is executed, the dyno executes the command associated with the [process type](procfile) of the dyno.  For example, if the dyno is a web dyno, then the command in the Procfile associated with the web process type will be executed.

Any command that's executed may spawn additional processes. 

No more than 256 created processes/threads can exist at any one time in a dyno - whether they're executing, sleeping or in any other state.  Note that the dyno counts threads and processes towards this limit.  For example, a dyno with 255 threads and one process is at the limit, as is a dyno with 256 processes.

#### Web dynos

A web dyno must bind to its assigned `$PORT` within 60 seconds of startup. If it doesn't, it is terminated by the dyno manager and a [R10 Boot Timeout](https://devcenter.heroku.com/articles/error-codes#r10-boot-timeout) error is logged. Processes can bind to other ports before and after binding to `$PORT`.

<div class="callout" markdown="1">
Contact support to increase this limit to 120 seconds on a per-application basis. In general, slow boot times will make it harder to deploy your application and will make recovery from dyno failures slower, so this should be considered a temporary solution.
</div>

### Graceful shutdown with SIGTERM

When the dyno manager restarts a dyno, the dyno manager will request that your processes shut down gracefully by sending them [`SIGTERM`](http://en.wikipedia.org/wiki/SIGTERM). This signal is sent to all processes in the dyno, not just the process type.

<div class="callout" markdown="1">Please note that it is currently possible that processes in a dyno that is being shut down may receive multiple SIGTERMs</div>

The application processes have ten seconds to shut down cleanly (ideally, they will do so more quickly than that).  During this time they should stop accepting new requests or jobs and attempt to finish their current requests, or put jobs back on the queue for other worker processes to handle.  If any processes remain after ten seconds, the dyno manager will terminate them forcefully with `SIGKILL`.

When performing controlled or periodic restarts, new dynos are spun up as soon as shutdown signals are sent to processes in the old dynos.

We can see how this works in practice with a sample worker process.  We'll use Ruby here as an illustrative language - the mechanism is identical in other languages.  Imagine a process that does nothing but loop and print out a message periodically:

    :::ruby
    STDOUT.sync = true
    puts "Starting up"

    trap('TERM') do
      puts "Graceful shutdown"
      exit
    end

    loop do
      puts "Pretending to do work"
      sleep 3
    end

If we deploy this (along with [the appropriate `Gemfile` and `Procfile`](https://github.com/adamwiggins/sigterm)) and `heroku ps:scale worker=1`, we'll see the process in its loop running on dyno `worker.1`:

    :::term
    $ heroku logs
    2011-05-31T23:31:16+00:00 heroku[worker.1]: Starting process with command: `bundle exec ruby worker.rb`
    2011-05-31T23:31:17+00:00 heroku[worker.1]: State changed from starting to up
    2011-05-31T23:31:17+00:00 app[worker.1]: Starting up
    2011-05-31T23:31:17+00:00 app[worker.1]: Pretending to do work
    2011-05-31T23:31:20+00:00 app[worker.1]: Pretending to do work
    2011-05-31T23:31:23+00:00 app[worker.1]: Pretending to do work

Restart the dyno, which causes the dyno to receive `SIGTERM`:

    :::term
    $ heroku restart worker.1
    Restarting worker.1 process... done

    $ heroku logs
    2011-05-31T23:31:26+00:00 app[worker.1]: Pretending to do work
    2011-05-31T23:31:28+00:00 heroku[worker.1]: State changed from up to starting
    2011-05-31T23:31:29+00:00 heroku[worker.1]: Stopping all processes with SIGTERM
    2011-05-31T23:31:29+00:00 app[worker.1]: Graceful shutdown
    2011-05-31T23:31:29+00:00 heroku[worker.1]: Process exited

Note that `app[worker.1]` logged "Graceful shutdown" (as we expect from our code); all the dyno manager messages log as `heroku[worker.1]`.

If we modify `worker.rb` to ignore the `TERM` signal, like so:

    :::ruby
    STDOUT.sync = true
    puts "Starting up"

    trap('TERM') do
      puts "Ignoring TERM signal - not a good idea"
    end

    loop do
      puts "Pretending to do work"
      sleep 3
    end

Now we see the behavior is changed:

    :::term
    $ heroku restart worker.1
    Restarting worker.1 process... done

    $ heroku logs
    2011-05-31T23:40:57+00:00 heroku[worker.1]: Stopping all processes with SIGTERM
    2011-05-31T23:40:57+00:00 app[worker.1]: Ignoring TERM signal - not a good idea
    2011-05-31T23:40:58+00:00 app[worker.1]: Pretending to do work
    2011-05-31T23:41:01+00:00 app[worker.1]: Pretending to do work
    2011-05-31T23:41:04+00:00 app[worker.1]: Pretending to do work
    2011-05-31T23:41:07+00:00 heroku[worker.1]: Error R12 (Exit timeout) -> Process failed to exit within 10 seconds of SIGTERM
    2011-05-31T23:41:07+00:00 heroku[worker.1]: Stopping all processes with SIGKILL
    2011-05-31T23:41:08+00:00 heroku[worker.1]: Process exited

Our process ignores `SIGTERM` and blindly continues on processing.  After ten seconds, the dyno manager gives up on waiting for the process to shut down gracefully, and kills it with `SIGKILL`.  It logs [Error R12](error-codes) to indicate that the process is not behaving correctly.

## Redundancy

Applications with multiple running dynos will be more redundant against failure. If some dynos are lost, the application can continue to process requests while the missing dynos are replaced. Typically, lost dynos restart promptly, but in the case of a catastrophic failure, it can take more time.  Multiple dynos are also more likely to run on different physical infrastructure (for example, separate AWS Availability Zones), further increasing redundancy.

## Isolation and security

Dynos execute in complete isolation from one another, even when on the same physical infrastructure. This includes both dynos in the [dyno formation](scaling#dyno-formation) and dynos run as [one-off dynos](process-model#one-off-admin-dynos) with `heroku run`. This provides protection from other application processes and system-level processes consuming all available resources.

### Technologies

The dyno manager uses a variety of technologies to enforce this isolation, most notably [LXC](http://lxc.sourceforge.net/) for subvirtualized resource and process table isolation, independent filesystem namespaces, and the `pivot_root` syscall for filesystem isolation.  These technologies provide security and evenly allocate resources such as CPU and memory in Heroku's multi-tenant environment.

### Ephemeral filesystem

Each dyno gets its own ephemeral filesystem, with a fresh copy of the most recently deployed code. During the dyno's lifetime its running processes can use the filesystem as a temporary scratchpad, but no files that are written are visible to processes in any other dyno and any files written will be discarded the moment the dyno is stopped or restarted.

### IP addresses

When running multiple dynos, apps are distributed across several nodes by the dyno manager.  Access to your app always goes through the [routers](http-routing).

As a result, dynos don't have static IP addresses.  While you can never connect to a dyno directly, it is possible to originate outgoing requests from a dyno. However, you can count on the dyno's IP address changing as it gets restarted in different places.

### Network interfaces

The dyno manager allocates each dyno a separate network interface. Dynos are only reachable from outside Heroku via the routers at their assigned $PORT. Individual processes within a dyno can bind to any address or port they want and communicate among them using e.g. standard TCP.

The external networking interface (i.e.: eth0) for each dyno will be part of a /30 private subnet in the range 172.16.0.0/12, such as 172.16.83.252/30 or 172.30.239.96/30. Processes within one dyno don’t share IPs or subnets with other dynos, nor can they observe TCP session state of other dynos.

## Connecting to external services

Applications running on dynos can connect to external services. Heroku can run apps in [multiple regions](https://devcenter.heroku.com/articles/regions), so for optimal latency run your services in the same [region](https://devcenter.heroku.com/articles/regions#data-center-locations) as the app.

## Dynos and requests

A single dyno can serve thousands of requests per second, but performance depends greatly on the language and framework you use.

A single-threaded, non-concurrent web framework (like Rails 3 in its default configuration) can process one request at a time. For an app that takes 100ms on average to process each request, this translates to about 10 requests per second per dyno, which is not optimal.

<p class="warning" markdown="1">
Single threaded backends are not recommended for production applications for their inefficient handling of concurrent requests. Choose a concurrent backend whenever developing and running a production service.
</p>

Multi-threaded or event-driven environments like Java, Unicorn, EventMachine, and Node.js can handle many concurrent requests. Load testing your app is the only realistic way to determine request throughput.