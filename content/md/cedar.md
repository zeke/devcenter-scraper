---
title: The Celadon Cedar Stack
slug: cedar
url: https://devcenter.heroku.com/articles/cedar
description: Celadon Cedar is a polyglot Heroku runtime stack, letting you run Java, Ruby, Node.js, Python, Clojure and Scala apps in the cloud.
---

Celadon Cedar is Heroku's default [runtime stack](stack) and is a flexible, polyglot environment with robust introspection and erosion-resistance capabilities. It embodies [modern principles of building, deploying and managing web applications](https://devcenter.heroku.com/articles/architecting-apps) and  is recommended for all apps.

## Using Cedar

To create an app on the Cedar stack use the `heroku create` command from the [Heroku command line](using-the-cli):

```term
$ heroku create
Creating quiet-sky-6888... done, stack is cedar
http://quiet-sky-6888.herokuapp.com/ | git@heroku.com:quiet-sky-6888.git
```

Make sure you're running version 2.1.0 or higher of the command-line tool which can be installed via the [Heroku toolbelt](https://toolbelt.heroku.com/).

```term
$ heroku --version
2.0.1
$ heroku update
-----> Updating to latest client... done
$ heroku --version
2.21.2
```

## Polyglot platform

Cedar is a [polyglot platform](http://blog.heroku.com/archives/2011/8/3/polyglot_platform/) with native support for many of today's most popular and productive languages and frameworks including:

<table>
  <tr>
    <th colspan="2">Get started with...</th>
  </tr>
  <tr>
    <td style="text-align: left; width: 50%;">
<a href="https://devcenter.heroku.com/articles/getting-started-with-ruby">Ruby</a> or <a href="https://devcenter.heroku.com/articles/getting-started-with-rails4">Rails</a>
</td>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-nodejs">Node.js</a>
</td>   
  </tr>
  <tr>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-java">Java</a>, <a href="https://devcenter.heroku.com/articles/getting-started-with-spring-mvc-hibernate">Spring</a> or <a href="https://devcenter.heroku.com/articles/getting-started-with-play">Play</a>
</td>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-python">Python</a> or <a href="https://devcenter.heroku.com/articles/getting-started-with-django">Django</a>
</td>
  </tr>
  <tr>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-clojure">Clojure</a>
</td>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-scala">Scala</a>
</td>
  </tr>
</table>

Polyglot support at the platform level lets development teams effectively utilize many languages across - and within - projects and ensures the right tool for the job. On Cedar, language choice and deployment infrastructure are orthogonal.

The foundation of Cedar's unified multi-language support is the new process model which provides a consistent interface for running and managing apps.

## Process model

Cedar introduces a new way to think about scaling your app: [the process model](process-model). The process model is a generalized approach to managing processes across a distributed environment. It allows you to specify a custom list of process types in a [Procfile](procfile) and provides for very granular management of an application's components.

```ruby
web:     node web.js
worker:  node worker.js
reports: node report.js
```

The process model enables the thousands of unique [dyno formations](scaling) to be coordinated by the [dyno manager](dynos#the-dyno-manager) while giving application developers the flexibility to use the frameworks and libraries of their choice.

### Management granularity

The process model also allows applications with logical components to manage and [scale at a very granular level](scaling). For instance, to dial-down HTTP processing while increasing background job concurrency, apply the `heroku ps:scale` command against your application's unique process model.

```term
$ heroku ps:scale web-1 worker+2 reports=1
Scaling web processes... done, now running 3
Scaling worker processes... done, now running 5
Scaling reports processes... done, now running 1
```

## One-off dynos

Cedar's flexibility is most evident with the `heroku run` command which lets you execute any command against your application. Many languages support a [REPL](http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) which gives you a console with which to interact with your application. Use `heroku run` to establish an interactive session with a remote REPL for a Clojure app.

```term
$ heroku run "lein repl"
Running lein repl attached to terminal... up, run.1
Clojure 1.3.0
user=>
```

[One-off dynos](oneoff-admin-ps), such as rake tasks for Ruby applications, can also be executed against their remote environment on Heroku.

```term
$ heroku run rake db:migrate
Running `rake db:migrate` attached to terminal... up, ps.1
(in /app)
Migrating to CreateWidgets (20110204210157)
==  CreateWidgets: migrating ==================================================
-- create_table(:widgets)
   -> 0.0120s
==  CreateWidgets: migrated (0.0121s) =========================================
```

## Visibility

Deployment platforms can appear to be black-boxes in their management and automation of application runtimes. Heroku Cedar provides several tools to give application developers [complete insight](http://blog.heroku.com/archives/2011/6/24/the_new_heroku_3_visibility_introspection/) into their applications.

### Dyno formation

The [`heroku ps` command](scaling) lists all dynos running for an application and clearly identifies the state of each individual dyno.

```term
$ heroku ps
=== web: `bundle exec unicorn -p $PORT -c ./config/unicorn.rb`
web.1: up for 8h
web.2: up for 3m

=== worker: `bundle exec stalk worker.rb`
worker.1: up for 1m
```

### Logging

[Aggregated logs](logging) for all components in the application stack, including components managed by Heroku such as the HTTP router, are available in a single stream with `heroku logs`.

> callout
> The `-t` flag keeps the log stream open so new entries are automatically displayed, much like the Unix `tail -f` command.

```term
$ heroku logs -t
2012-03-16T14:02:57+00:00 heroku[router]: GET devcenter.heroku.com/articles/git dyno=web.3  service=44ms status=200 bytes=32839
2012-03-16T14:02:57+00:00 app[worker.1]: [Worker(host:278fa1bc-d6aa-4409-bffd-0032dd0093b5 pid:1)] Article#reindex_without_delay completed after 0.1200
2012-03-16T14:02:57+00:00 app[worker.1]: [Worker(host:278fa1bc-d6aa-4409-bffd-0032dd0093b5 pid:1)] 1 job processed at 11.3892 j/s, 0 failed ...
2012-03-16T14:03:00+00:00 heroku[router]: GET devcenter.heroku.com/images/dev-center/aside_accordion_indicator_open.png dyno=web.1 service=2ms status=200 bytes=369
2012-03-16T14:03:05+00:00 app[web.3]: Started GET "/articles/git" for 213.144.5.2 at 2012-03-16 14:03:05 +0000
2012-03-16T14:03:05+00:00 app[web.3]:   Processing by ArticlesController#show as HTML
2012-03-16T14:03:05+00:00 app[web.3]:   Parameters: {"id"=>"git"}
2012-03-16T14:03:05+00:00 app[web.3]: Read fragment views/devcenter.heroku.com/articles/git (3.6ms)
```

> callout
> Additionally, [several add-on providers](https://addons.heroku.com/#logging) provide retention, indexing and visualization capabilities of log data.

Here we see the router receiving a request and passing it to the `web.3` dyno while the `worker.1` dyno indexes an article for search. Router logs, database queries and application output is all coalesced into a singled event stream for full visibility into your application's execution.

Component and dyno-level introspection is also available to quickly zero-in on problematic dynos and filter out irrelevant activity.

```term
$ heroku logs --ps worker.1 -t
2012-03-16T14:16:58+00:00 app[worker.1]: [Worker(host:278fa1bc-d6aa-4409-bffd-0032dd0093b5 pid:1)] Article#reindex_without_delay completed after 0.0645
2012-03-16T14:16:58+00:00 app[worker.1]: [Worker(host:278fa1bc-d6aa-4409-bffd-0032dd0093b5 pid:1)] Article#record_view_without_delay completed after 0.0388
2012-03-16T14:16:58+00:00 app[worker.1]: [Worker(host:278fa1bc-d6aa-4409-bffd-0032dd0093b5 pid:1)] 10 jobs processed at 11.6378 j/s, 0 failed ...
```

### Release management

All application deployments and configuration changes are captured and logged by Heroku and are [made available with `heroku releases`](releases).

```term
$ heroku releases
Rel   Change                          By                    When
----  ----------------------          ----------            ----------
v52   Config add AWS_S3_KEY           jim@example.com       5 minutes ago            
v51   Deploy de63889                  stephan@example.com   7 minutes ago
v50   Deploy 7c35f77                  stephan@example.com   3 hours ago
```

[Releases](releases) ensures that an application's lifecycle is captured in an accountable and actionable format with the ability to undo errant modifications with `heroku releases:rollback`.

## Advanced HTTP capabilities

On Cedar, an app named `foo` will have the default hostname of `foo.herokuapp.com`.

The `herokuapp.com` domain routes to a modern [HTTP stack](http-routing) which offers a direct routing path to your web processes.  This allows for advanced HTTP uses such as [chunked responses](http://en.wikipedia.org/wiki/Chunked_transfer_encoding), [long polling](http://en.wikipedia.org/wiki/Push_technology#Long_polling), and using an async webserver to handle multiple responses from a single web process.

Cedar does not include a reverse proxy cache such as Varnish, preferring to empower developers to choose the CDN solution that best serves their needs.

## Migrating to Cedar

Migrating from Bamboo to Cedar allows an application to take advantage of a much more flexible and powerful stack. Because the significant architectural differences, migrating to Cedar is a largely manual process.

Instructions for migrating to Cedar can be [found here](cedar-migration).