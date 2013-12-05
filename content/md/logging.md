---
title: Logging
slug: logging
url: https://devcenter.heroku.com/articles/logging
description: Logs are a stream of time-ordered events aggregated from the output streams of all your app’s running processes. Retrieve, filter, or use syslog drains.
---

Logs are a stream of time-ordered events aggregated from the output streams of all your app's running processes, system components, and backing services.  Heroku's [Logplex](logplex) routes log streams from all of these diverse sources into a single channel, providing the foundation for truly comprehensive logging.

## Types of logs

Heroku aggregates three categories of logs for your app:

* App logs - Output from your application.  This will include logs generated from within your application, application server and libraries.  (Filter: `--source app`)
* System logs - Messages about actions taken by the Heroku platform infrastructure on behalf of your app, such as: restarting a crashed process, sleeping or waking a web dyno, or serving an error page due to a problem in your app.  (Filter: `--source heroku`)
* API logs - Messages about administrative actions taken by you and other developers working on your app, such as: deploying new code, scaling the process formation, or toggling maintenance mode.  (Filter: `--source heroku --ps api`)

Logplex is designed for collating and routing log messages, not for storage. It keeps the last 1,500 lines of consolidated logs. We recommend using a separate service for long-term log storage; see [Syslog drains](#syslog-drains) for more information.

## Writing to your log

Anything written to standard out (`stdout`) or standard error (`stderr`) is captured into your logs.  This means that you can log from anywhere in your application code with a simple output statement.  

In Ruby, you could use something like:

```ruby
puts "Hello, logs!"
```

In Java:

```java
System.err.println("Hello, logs!");
System.out.println("Hello, logs!");
```

The same holds true for all other languages supported by Heroku.

To take advantage of the realtime logging, you may need to disable any log buffering your application may be carrying out.  For example, in Ruby add this to your `config.ru`:

```ruby
$stdout.sync = true
```

Some frameworks send log output somewhere other than `stdout` by default. These might require extra configuration. For example, when using the Ruby on Rails TaggedLogger by ActiveSupport, you should add the following into your app's configuration to get `stdout` logging:

```ruby
config.logger = Logger.new(STDOUT)
```

## Log retrieval

To fetch your logs:

```term
$ heroku logs
2010-09-16T15:13:46.677020+00:00 app[web.1]: Processing PostController#list (for 208.39.138.12 at 2010-09-16 15:13:46) [GET]
2010-09-16T15:13:46.677023+00:00 app[web.1]: Rendering template within layouts/application
2010-09-16T15:13:46.677902+00:00 app[web.1]: Rendering post/list
2010-09-16T15:13:46.678990+00:00 app[web.1]: Rendered includes/_header (0.1ms)
2010-09-16T15:13:46.698234+00:00 app[web.1]: Completed in 74ms (View: 31, DB: 40) | 200 OK [http://myapp.heroku.com/]
2010-09-16T15:13:46.723498+00:00 heroku[router]: at=info method=GET path=/posts host=myapp.herokuapp.com fwd="204.204.204.204" dyno=web.1 connect=1ms service=18ms status=200 bytes=975
2010-09-16T15:13:47.893472+00:00 app[worker.1]: 2 jobs processed at 16.6761 j/s, 0 failed ...
```

In this example, the output includes log lines from one of the app's web dynos, the Heroku HTTP router, and one of the app's workers. 

The logs command retrieves 100 log lines by default.  

## Log message ordering

When retrieving logs, you may notice that the logs are not always in order, especially when multiple components are involved. This is likely an artifact of distributed computing.  Logs originate from many sources (router nodes, dynos, etc) and are assembled into a single log stream by logplex.  It is up to the logplex user to sort the logs and provide the ordering required by their application, if any.

## Log history limits

You can fetch up to 1500 lines using the `--num` (or `-n`) option:

```term
$ heroku logs -n 200
```

[Heroku only stores the last 1500 lines of log history](limits#log-history-limits).  If you'd like to persist more than 1500 lines, use a [logging add-on](https://addons.heroku.com/#logging).

## Log format

Each line is formatted as follows:

```
timestamp source[dyno]: message
```

* **Timestamp** - The date and time recorded at the time the log line was produced by the dyno or component. The timestamp is in the format specified by [RFC5424](https://tools.ietf.org/html/rfc5424#section-6.2.3), and includes microsecond precision.
* **Source** - All of your app's dynos (web dynos, background workers, cron) have a source of `app`.  All of Heroku's system components (HTTP router, dyno manager) have a source of `heroku`.
* **Dyno** - The name of the dyno or component that wrote this log line.  For example, worker #3 appears as `worker.3`, and the Heroku HTTP router appears as `router`.
* **Message** - The content of the log line. Dynos can generate messages up to approximately 1024 bytes in length and longer messages will be truncated. We're working to increase this limit.

## Realtime tail

Similar to `tail -f`, realtime tail displays recent logs and leaves the session open for realtime logs to stream in. By viewing a live stream of logs from your app, you can gain insight into the behavior of your live application and debug current problems. 

You may tail your logs using `--tail` (or `-t`).

```term
$ heroku logs --tail
```

When you are done, press Ctrl-C to close the session.

## Filtering

If you only want to fetch logs with a certain source, a certain dyno, or both, you can use the `--source` (or `-s`) and `--ps` (or `-p`) filtering arguments:

```term
$ heroku logs --ps router
2012-02-07T09:43:06.123456+00:00 heroku[router]: at=info method=GET path=/stylesheets/dev-center/library.css host=devcenter.heroku.com fwd="204.204.204.204" dyno=web.5 connect=1ms service=18ms status=200 bytes=13
2012-02-07T09:43:06.123456+00:00 heroku[router]: at=info method=GET path=/articles/bundler host=devcenter.heroku.com fwd="204.204.204.204" dyno=web.6 connect=1ms service=18ms status=200 bytes=20375

$ heroku logs --source app
2012-02-07T09:45:47.123456+00:00 app[web.1]: Rendered shared/_search.html.erb (1.0ms)
2012-02-07T09:45:47.123456+00:00 app[web.1]: Completed 200 OK in 83ms (Views: 48.7ms | ActiveRecord: 32.2ms)
2012-02-07T09:45:47.123456+00:00 app[worker.1]: [Worker(host:465cf64e-61c8-46d3-b480-362bfd4ecff9 pid:1)] 1 jobs processed at 23.0330 j/s, 0 failed ...
2012-02-07T09:46:01.123456+00:00 app[web.6]: Started GET "/articles/buildpacks" for 4.1.81.209 at 2012-02-07 09:46:01 +0000

$ heroku logs --source app --ps worker
2012-02-07T09:47:59.123456+00:00 app[worker.1]: [Worker(host:260cf64e-61c8-46d3-b480-362bfd4ecff9 pid:1)] Article#record_view_without_delay completed after 0.0221
2012-02-07T09:47:59.123456+00:00 app[worker.1]: [Worker(host:260cf64e-61c8-46d3-b480-362bfd4ecff9 pid:1)] 5 jobs processed at 31.6842 j/s, 0 failed ...
```

When filtering by dyno, either the base name, `--ps web`, or the full name, `--ps web.1`, may be used.

You can also combine the filtering switches with `--tail` to get a realtime stream of filtered output.

```term
$ heroku logs --source app --tail
```

## Syslog drains

Logplex drains allow you to forward your Heroku logs to an external syslog server for long-term archiving.  You must configure the service or your server to be able to receive syslog packets from Heroku, and then add its syslog URL (which contains the host and port) as a syslog drain.

Drain log messages are formatted according to [RFC5424](https://tools.ietf.org/html/rfc5424). They are delivered over TCP as described in [RFC6587](https://tools.ietf.org/html/rfc6587), using the [octet counting framing method](https://tools.ietf.org/html/rfc6587#section-3.4.1).

Visit [Heroku Add-ons](http://addons.heroku.com/) to find log management services.

> warning
> Previously, Heroku published its AWS account ID and security group name as a way to grant Heroku access to an AWS EC2 instance running a self-hosted Syslog server. This is [no longer recommended](https://devcenter.heroku.com/changelog-items/353).

### Drain IDs

When you create a drain, it is assigned a unique Drain ID that will look something like `d.9173ea1f-6f14-4976-9cf0-7cd0dafdcdbc`. You can discover the drain IDs for your application by running `heroku drains -x`.

```term
$ heroku drains -x
syslog://logs.example.com (d.9173ea1f-6f14-4976-9cf0-7cd0dafdcdbc)
```

This identifier will be written into all log messages from that drain. E.g.

```
2013-01-01T01:01:01.000000+00:00 d.9173ea1f-6f14-4976-9cf0-7cd0dafdcdbc app[web.1] Your message here.
```

The ID can be used to separate log messages sent by different drains to the same drain URL. Drains to the same URL on different apps will have different IDs. The Drain ID will remain the same for the lifetime of the drain, but will change if you delete and re-add the same drain.

### Security Access

When you use EC2 security groups, the hostname used when you add the drain must resolve to the [10/8 private IP address](http://en.wikipedia.org/wiki/CIDR_notation) of your instance (which must be in the us-east Amazon region). If you use the EC2 public IP address, or a name that resolves to the public IP address, then logplex will not be able to connect to your drain.
        
