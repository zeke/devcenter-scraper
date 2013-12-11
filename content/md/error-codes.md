---
title: Heroku Error Codes
slug: error-codes
url: https://devcenter.heroku.com/articles/error-codes
description: A description of the custom error information written to logs when your app experiences an error.
---

Whenever your app experiences an error, Heroku will return a standard error page with the HTTP status code 503. To help you debug the underlying error, however, the platform will also add custom error information to your logs. Each type of error gets its own error code, with all HTTP errors starting with the letter H and all runtime errors starting with R. Logging errors start with L.

## H10 - App crashed

A crashed web dyno or a boot timeout on the web dyno will present this error.

```
2010-10-06T21:51:04-07:00 heroku[web.1]: State changed from down to starting
2010-10-06T21:51:07-07:00 app[web.1]: Starting process with command: `bundle exec rails server -p 22020`
2010-10-06T21:51:09-07:00 app[web.1]: >> Using rails adapter
2010-10-06T21:51:09-07:00 app[web.1]: Missing the Rails 2.3.5 gem. Please `gem install -v=2.3.5 rails`, update your RAILS_GEM_VERSION setting in config/environment.rb for the Rails version you do have installed, or comment out RAILS_GEM_VERSION to use the latest version installed.
2010-10-06T21:51:10-07:00 heroku[web.1]: Process exited
2010-10-06T21:51:12-07:00 heroku[router]: at=error code=H10 desc="App crashed" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=
```

## H11 - Backlog too deep

When HTTP requests arrive faster than your application can process them, they can form a large backlog on a number of routers. When the backlog on a particular router passes a threshold, the router determines that your application isn't keeping up with its incoming request volume. You'll see an H11 error for each incoming request as long as the backlog is over this size. The exact value of this threshold may change depending on various factors, such as the number of dynos in your app, response time for individual requests, and your app's normal request volume.

```
2010-10-06T21:51:07-07:00 heroku[router]: at=error code=H11 desc="Backlog too deep" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=
```

The solution is to increase your app's throughput by adding more dynos, tuning your database (for example, adding an index), or making the code itself faster. As always, increasing performance is highly application-specific and requires profiling.

## H12 - Request timeout

> callout
> For more information on request timeouts (including recommendations for resolving them), take a look at [our article on the topic](request-timeout).

An HTTP [request took longer than 30 seconds](request-timeout) to complete. In the example below, a Rails app takes 37 seconds to render the page; the HTTP router returns a 503 prior to Rails completing its request cycle, but the Rails process continues and the completion message shows after the router message. 

```
2010-10-06T21:51:07-07:00 app[web.2]: Processing PostController#list (for 75.36.147.245 at 2010-10-06 21:51:07) [GET]
2010-10-06T21:51:08-07:00 app[web.2]: Rendering template within layouts/application
2010-10-06T21:51:19-07:00 app[web.2]: Rendering post/list
2010-10-06T21:51:37-07:00 heroku[router]: at=error code=H12 desc="Request timeout" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno=web.1 connect=6ms service=30001ms status=503 bytes=0
2010-10-06T21:51:42-07:00 app[web.2]: Completed in 37000ms (View: 27, DB: 21) | 200 OK [http://myapp.heroku.com/]
```

This 30-second limit is measured by the router, and includes all time spent in the dyno, including the kernel's incoming connection queue and the app itself.

See [Request Timeout](request-timeout) for more.

## H13 - Connection closed without response

This error is thrown when a process in your web dyno accepts a connection, but then closes the socket without writing anything to it.

```
2010-10-06T21:51:37-07:00 heroku[router]: at=error code=H13 desc="Connection closed without response" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno=web.1 connect=3030ms service=9767ms status=503 bytes=0
```

One example where this might happen is when a [Unicorn web server](rails-unicorn) is configured with a timeout shorter than 30s and a request has not been processed by a worker before the timeout happens. In this case, Unicorn closes the connection before any data is written, resulting in an H13.

## H14 - No web dynos running

This is most likely the result of scaling your web dynos down to 0 dynos. To fix it, scale your web dynos to 1 or more dynos: 

```term
$ heroku ps:scale web=1
```

Use the `heroku ps` command to determine the state of your web dynos.

```
2010-10-06T21:51:37-07:00 heroku[router]: at=error code=H14 desc="No web processes running" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=
```

## H15 - Idle connection

The idle connection error is logged when a request is [terminated due to 55 seconds of inactivity](request-timeout).

```
2010-10-06T21:51:37-07:00 heroku[router]: at=error code=H15 desc="Idle connection" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno=web.1 connect=1ms service=55449ms status=503 bytes=18
```

## H16 - Redirect to herokuapp.com

Apps on Cedar's [HTTP routing stack](http-routing) use the herokuapp.com domain. Requests made to a Cedar app at its deprecated heroku.com domain will be redirected to the correct herokuapp.com address and this redirect message will be inserted into the app's logs.

```
2010-10-06T21:51:37-07:00 heroku[router]: at=info code=H16 desc="herokuapp redirect" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=301 bytes=
```

## H17 - Poorly formatted HTTP response

This error message is logged when a router detects a malformed HTTP response coming from a dyno.

```
2010-10-06T21:51:37-07:00 heroku[router]: at=info code=H17 desc="Poorly formatted HTTP response" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno=web.1 connect=1ms service=1ms status=503 bytes=0
```

## H18 - Request Interrupted

Either the client socket or backend (your app's web process) socket was closed before the backend returned an HTTP response. The `sock` field in the log has the value `client` or `backend` depending on which socket was closed.

```
2010-10-06T21:51:37-07:00 heroku[router]: at=error code=H18 desc="Request Interrupted" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno=web.1 connect=1ms service=0ms status=503 bytes=0 sock=client
```

## H19 - Backend connection timeout

A router received a connection timeout error after 5 seconds attempting to open a socket to a web dyno. This is usually a symptom of your app being overwhelmed and failing to accept new connections in a timely manner. If you have multiple dynos, the router will retry multiple dynos before logging H19 and serving a standard error page.

If your app has a single web dyno, it is possible to see H19 errors if the runtime instance running your web dyno fails and is replaced.  Once the failure is detected and the instance is terminated your web dyno will be restarted somewhere else, but in the meantime, H19s may be served as the router fails to establish a connection to your dyno.  This can be mitigated by running more than one web dyno.

```
2010-10-06T21:51:07-07:00 heroku[router]: at=error code=H19 desc="Backend connection timeout" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno=web.1 connect=5001ms service= status=503 bytes=
```

## H20 - App boot timeout

The router will enqueue requests for 75 seconds while waiting for starting processes to reach an "up" state. If after 75 seconds, no web dynos have reached an "up" state, the router logs H20 and serves a standard error page.

```
2010-10-06T21:51:07-07:00 heroku[router]: at=error code=H20 desc="App boot timeout" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=
```

> note 
> The Ruby on Rails [asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html) can sometimes fail to run during [git push](git), and will instead attempt to run when your app’s [dynos](dynos) boot. Since the Rails asset pipeline is a slow process, this can cause H20 boot timeout errors.

This error differs from [R10](#r10-boot-timeout) in that the H20 75-second timeout includes platform tasks such as internal state propagation, requests between internal components, slug download, unpacking, container preparation, etc... The R10 60-second timeout applies solely to application startup tasks.

> note 
> Contact support to increase this limit to 120 seconds on a per-application basis. In general, slow boot times will make it harder to deploy your application and will make recovery from dyno failures slower, so this should be considered a temporary solution.

## H21 - Backend connection refused

A router received a connection refused error when attempting to open a socket to your web process. This is usually a symptom of your app being overwhelmed and failing to accept new connections. If you have multiple dynos, the router will retry multiple dynos before logging H21 and serving a standard error page.

```
2010-10-06T21:51:07-07:00 heroku[router]: at=error code=H21 desc="Backend connection refused" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno=web.1 connect=1ms service= status=503 bytes=
```

## H22 - Connection limit reached

A routing node has detected an elevated number of HTTP client connections attempting to reach your app. Reaching this threshold most likely means your app is under heavy load and is not responding quickly enough to keep up. The exact value of this threshold may change depending on various factors, such as the number of dynos in your app, response time for individual requests, and your app's normal request volume.

```
2010-10-06T21:51:07-07:00 heroku[router]: at=error code=H22 desc="Connection limit reached" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=
```

## H23 - Endpoint misconfigured

A routing node has detected a [websocket handshake](https://tools.ietf.org/html/rfc6455#section-1.3), specifically the 'Sec-Websocket-Version' header in the request, that came from an endpoint (upstream proxy) that does not support websockets.

```
2010-10-06T21:51:07-07:00 heroku[router]: at=error code=H23 desc="Endpoint misconfigured" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=
```

## H70 - Access to Bamboo HTTP endpoint denied

HTTP traffic for [Cedar](cedar) apps is not allowed to route through the legacy [Bamboo](bamboo) routing stack.  If your Cedar app is producing this error then you need to follow the instructions documented in the [custom domains article](custom-domains#custom-subdomains) to properly configure the DNS records for your custom domains.

Specifically, your DNS configuration should not use the deprecated `proxy.heroku.com` target and instead point to `yourappname.herokuapp.com`.

```
2010-10-06T21:51:07-07:00 heroku[router]: at=error code=H70 desc="Access to bamboo HTTP endpoint denied" method=GET path=/ host=foo.myapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=
```

## H80 - Maintenance mode

This is not an error, but we give it a code for the sake of completeness. Note the log formatting is the same but without the word "Error".

```
2010-10-06T21:51:07-07:00 heroku[router]: at=info code=H80 desc="Maintenance mode" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=
```

## H99 - Platform error

>callout
> H99 and R99 are the only error codes that represent errors in the Heroku platform.

This indicates an internal error in the Heroku platform. Unlike all of the other errors which will require action from you to correct, this one does not require action from you. Try again in a minute, or check [the status site](http://status.heroku.com/).

```
2010-10-06T21:51:07-07:00 heroku[router]: at=error code=H99 desc="Platform error" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=
```

## R10 - Boot timeout

A web process took longer than 60 seconds to bind to its assigned `$PORT`. When this happens, the dyno's process is killed and the dyno is considered crashed. Crashed dynos are restarted according to the dyno manager's [restart policy](dynos#automatic-dyno-restarts).

```
2011-05-03T17:31:38+00:00 heroku[web.1]: State changed from created to starting
2011-05-03T17:31:40+00:00 heroku[web.1]: Starting process with command: `bundle exec rails server -p 22020 -e production`
2011-05-03T17:32:40+00:00 heroku[web.1]: Error R10 (Boot timeout) -> Web process failed to bind to $PORT within 60 seconds of launch
2011-05-03T17:32:40+00:00 heroku[web.1]: Stopping process with SIGKILL
2011-05-03T17:32:40+00:00 heroku[web.1]: Process exited
2011-05-03T17:32:41+00:00 heroku[web.1]: State changed from starting to crashed
```

This error is often caused by a process being unable to reach an external resource, such as a database, or the application doing too much work, such as parsing and evaluating numerous, large code dependencies, during startup.

Common solutions are to access external resources asynchronously, so they don't block startup, and to reduce the amount of application code or its dependencies.

> note 
> Contact support to increase this limit to 120 seconds on a per-application basis. In general, slow boot times will make it harder to deploy your application and will make recovery from dyno failures slower, so this should be considered a temporary solution.

## R12 - Exit timeout

A process failed to exit within 10 seconds of being sent a SIGTERM indicating that it should stop. The process is sent SIGKILL to force an exit.

```
2011-05-03T17:40:10+00:00 app[worker.1]: Working
2011-05-03T17:40:11+00:00 heroku[worker.1]: Stopping process with SIGTERM
2011-05-03T17:40:11+00:00 app[worker.1]: Ignoring SIGTERM
2011-05-03T17:40:14+00:00 app[worker.1]: Working
2011-05-03T17:40:18+00:00 app[worker.1]: Working
2011-05-03T17:40:21+00:00 heroku[worker.1]: Error R12 (Exit timeout) -> Process failed to exit within 10 seconds of SIGTERM
2011-05-03T17:40:21+00:00 heroku[worker.1]: Stopping process with SIGKILL
2011-05-03T17:40:21+00:00 heroku[worker.1]: Process exited
```

## R13 - Attach error

A dyno started with `heroku run` failed to attach to the invoking client.

```
2011-06-29T02:13:29+00:00 app[run.3]: Awaiting client
2011-06-29T02:13:30+00:00 heroku[run.3]: State changed from starting to up
2011-06-29T02:13:59+00:00 app[run.3]: Error R13 (Attach error) -> Failed to attach to process
2011-06-29T02:13:59+00:00 heroku[run.3]: Process exited
```

## R14 - Memory quota exceeded

A dyno requires memory in excess of its [quota](dynos#memory-behavior) (512 MB on 1X dynos, 1024 MB on 2X dynos) . If this error occurs, the dyno will [page to swap space](http://en.wikipedia.org/wiki/Paging) to continue running, which may cause degraded process performance.

```
2011-05-03T17:40:10+00:00 app[worker.1]: Working
2011-05-03T17:40:10+00:00 heroku[worker.1]: Process running mem=528MB(103.3%)
2011-05-03T17:40:11+00:00 heroku[worker.1]: Error R14 (Memory quota exceeded)
2011-05-03T17:41:52+00:00 app[worker.1]: Working
```

## R15 - Memory quota vastly exceeded

A dyno requires vastly more memory than its [quota](dynos#memory-behavior) and is consuming excessive swap space. If this error occurs, the dyno will be killed by the platform.

```
2011-05-03T17:40:10+00:00 app[worker.1]: Working
2011-05-03T17:40:10+00:00 heroku[worker.1]: Process running mem=2565MB(501.0%)
2011-05-03T17:40:11+00:00 heroku[worker.1]: Error R15 (Memory quota vastly exceeded)
2011-05-03T17:40:11+00:00 heroku[worker.1]: Stopping process with SIGKILL
2011-05-03T17:40:12+00:00 heroku[worker.1]: Process exited
```

## R16 – Detached

An attached dyno is continuing to run after being sent `SIGHUP` when its external connection was closed. This is usually a mistake, though some apps might want to do this intentionally.

```
2011-05-03T17:32:03+00:00 heroku[run.1]: Awaiting client
2011-05-03T17:32:03+00:00 heroku[run.1]: Starting process with command `bash`
2011-05-03T17:40:11+00:00 heroku[run.1]: Client connection closed. Sending SIGHUP to all processes
2011-05-03T17:40:16+00:00 heroku[run.1]: Client connection closed. Sending SIGHUP to all processes
2011-05-03T17:40:21+00:00 heroku[run.1]: Client connection closed. Sending SIGHUP to all processes
2011-05-03T17:40:26+00:00 heroku[run.1]: Error R16 (Detached) -> An attached process is not responding to SIGHUP after its external connection was closed.
```

## R99 - Platform error

> callout
> R99 and H99 are the only error codes that represent errors in the Heroku platform.

This indicates an internal error in the Heroku platform. Unlike all of the other errors which will require action from you to correct, this one does not require action from you. Try again in a minute, or check [the status site](http://status.heroku.com/).

## L10 - Drain buffer overflow

```
2013-04-17T19:04:46+00:00 d.1234-drain-identifier-567 heroku logplex - - Error L10 (output buffer overflow): 500 messages dropped since 2013-04-17T19:04:46+00:00.
```

The number of log messages being generated has temporarily exceeded the rate at which they can be delivered and Logplex, [Heroku's logging system](logging), has discarded some messages in order to catch up.

A common cause of L10 error messages is a sudden burst of log messages from a dyno. As each line of dyno output (e.g. a line of a stack trace) is a single log message, and Logplex limits the total number of un-transmitted log messages it will keep in memory to 1024 messages, a burst of lines from a dyno can overflow buffers in Logplex. In order to allow the log stream to catch up, Logplex will discard messages where necessary, keeping newer messages in favour of older ones.

You may need to investigate reducing the volume of log lines output by your application (e.g. condense multiple logs lines into a smaller, single-line entry). You can also use the `heroku logs -t` command to get a live feed of logs and find out where your problem might be. A single dyno stuck in a loop that generates log messages can force an L10 error, as can a problematic code path that causes all dynos to generate a multi-line stack trace for some code paths.


## L11 - Tail buffer overflow

A heroku logs --tail session cannot keep up with the volume of logs generated by the application or log channel, and Logplex has discarded some log lines necessary to catch up. To avoid this error you will need run the command on a faster internet connection (increase the rate at which you can receive logs) or you will need to modify your application to reduce the logging volume (decrease the rate at which logs are generated).

```
2011-05-03T17:40:10+00:00 heroku[logplex]: L11 (Tail buffer overflow) -> This tail session dropped 1101 messages since 2011-05-03T17:35:00+00:00
```

## L12 - Local buffer overflow

The application is producing logs faster than the local delivery process (log-shuttle) can deliver them to Logplex and has discarded some log lines in order to keep up. If this error is sustained you will need to reduce the logging volume of your application.

```        
2013-11-04T21:31:32.125756+00:00 app[log-shuttle]: Error L12: 222 messages dropped since 2013-11-04T21:31:32.125756+00:00.
```