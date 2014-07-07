---
title: Deploying Rails Applications with the Puma Web Server
slug: deploying-rails-applications-with-the-puma-web-server
url: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
description: A guide to using Puma on Heroku. Puma uses threads, in addition to worker processes, to make more use of a systems available CPU.
---

<!--

Please send edits to https://draftin.com/documents/265218?token=bhHu5yxJW7NJ3AUAsNYBl6nT6UQ9AAHlB9bKF-l4wNl64bh4uDoF9Gw2cf9JBN302u1FOa5IZQ-W8j7jepVCMEY

-->

Web applications that process concurrent requests make more efficient use of dyno resources than those that only process one request at a time. Puma is a webserver that competes with [Unicorn](https://devcenter.heroku.com/articles/rails-unicorn) and allows you to process concurrent requests.

Puma uses threads, in addition to worker processes, to make more use of available CPU. You can only utilize threads in Puma if your entire code-base is thread safe. Otherwise, you can still use Puma, but must only scale out through worker processes.

This guide will walk you through deploying a new Rails application to Heroku using the Puma web server. For basic Rails setup, see [Getting Started with Rails](rails4).

> warning
> Always test your new deployments in a staging environment before you deploy to your production environment.


## Adding Puma to your application

### Gemfile

First, add Puma to your app's Gemfile:

```ruby
gem 'puma'
```

### Procfile

Set Puma as the server for your web process in the `Procfile` of your application:

```
web: bundle exec puma -C config/puma.rb
```

Make sure the `Procfile` is properly capitalized and checked into git.


## Config

Create a configuration file for Puma at `config/puma.rb` or at a path of your choosing. For a simple Rails application, we recommend the following basic configuration:

```ruby
workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['MAX_THREADS'] || 16
    ActiveRecord::Base.establish_connection(config)
  end
end
```

You must also ensure that your Rails application has enough database connections available in the pool for all threads and workers. (This will be covered later).

If your app is not thread safe, you will only be able to use workers. Set your min and max threads to 1:

```ruby
$ heroku config:set MIN_THREADS=1 MAX_THREADS=1
```

See the section below on thread safety for more information.


## Workers

```ruby
workers Integer(ENV['PUMA_WORKERS'] || 3)
```

Puma forks multiple OS processes within each dyno to allow a Rails app to support multiple concurrent requests. In Puma terminology these are referred to as worker processes (not to be confused with Heroku worker processes which run in their own dynos). Worker processes are isolated from one another at the OS level, therefore not needing to be thread safe.

Each worker process used consumes additional memory. This limits how many processes you can run in a single dyno. With a typical Rails memory footprint, you can expect to run 2-4 Puma worker processes on a 1x dyno. Your application may allow for more or less depending on your specific memory footprint. We recommend specifying this number in a config var to allow for faster application tuning. Monitor your application logs for R14 errors (memory quota exceeded) via one of our [logging addons](https://addons.heroku.com/#logging) or heroku logs.


### Threads

```ruby
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)
```

Puma can serve each request in a thread from an internal thread pool. This allows Puma to provide additional concurrency for your web application. Loosely speaking, workers consume more RAM and threads consume more CPU, and both provide more concurrency.

On MRI, there is a Global Interpreter Lock (GIL) that ensures only one thread can be run at any time. IO operations such as database calls, interacting with the file system, or making external http calls will not lock the GIL. Most Rails applications heavily use IO, so adding additional threads will allow Puma to process multiple threads, gaining you more throughput. JRuby and Rubinius also benefit from using Puma. These Ruby implementations do not have a GIL and will run all threads in parallel regardless of what is happening in them.

Puma allows you to configure your thread pool with a `min` and `max` setting, controlling the number of threads each Puma instance uses. The min threads allows your application to spin down resources when not under load. This feature is not needed on Heroku as your application can consume all of the resources on a given dyno. We recommend setting `MIN_THREADS` to equal `MAX_THREADS`.

Each Puma worker will be able to spawn up to the maximum number of threads you specify.


## Preload app

```ruby
preload_app!
```

Preloading your application reduces the startup time of individual Puma worker processes and allows you to manage the external connections of each individual worker using the `on_worker_boot` calls. In the config above, these calls are used to correctly establish Postgres connections for each worker process.


## On worker boot

The `on_worker_boot` block is run after a worker is spawned, but before it begins to accept requests. This block is especially useful for connecting to different services as connections cannot be shared between multiple processes. This is similar to Unicorn's `after_fork` block.

```ruby
on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['MAX_THREADS'] || 16
    ActiveRecord::Base.establish_connection(config)
  end
end
```

In the default configuration we are setting the database pool size. For more information please read [Concurrency and Database Connections in Ruby with ActiveRecord](https://devcenter.heroku.com/articles/concurrency-and-database-connections#threaded-servers). We also make sure to create a new connection to the database here.

You will need to re-connect to any datastore such as Postgres, Redis, or memcache. In the pre-load section we show how to reconnect Active Record. If you are using Resque, which connects to Redis you would need to reconnect:

```ruby
on_worker_boot do
  # ...
  if defined?(Resque)
     Resque.redis = ENV["<redis-uri>"] || "redis://127.0.0.1:6379"
  end
end
```

If you get connection errors while booting up your application, consult the gem documentation for the service you are attempting to communicate with to see how you can re-connect in this block.


## Rackup

```ruby
rackup      DefaultRackup
```

Use the `rackup` command to tell Puma how to start your rack app. This should point at your applications `config.ru`, which is automatically generated by Rails when you create a new project.

This line may not be needed on newer versions of Puma.


## Port

```ruby
port        ENV['PORT']     || 3000
```

The port that Puma will bind to. Heroku will set `ENV['PORT']` when the web process boots up. Locally, default this to `3000` to match the normal Rails default.


## Environment

```
environment ENV['RACK_ENV'] || 'development'
```

Set the environment of Puma. On Heroku `ENV['RACK_ENV']` will be set to `'production'` by default.


## Timeout

There is no request timeout mechanism inside of Puma. The Heroku router will [timeout all requests that exceed 30 seconds](https://devcenter.heroku.com/articles/request-timeout). Although the an error will be returned back to the client, Puma will continue to work on the request as there is no way for the router to notify Puma that the request terminated early. To avoid clogging your processing ability we recommend using `Rack::Timeout` to terminate long running requests and locate their source.

Add the [Rack Timeout](https://github.com/kch/rack-timeout) gem to your project then in an initializer set the value to something lower than 30:

```ruby
# config/initializers/timeout.rb
Rack::Timeout.timeout = 20  # seconds
```

Now any requests that continue for 20 seconds will be terminated and a stack trace output to your logs. The stack trace should help you determine what part of your application is causing the timeout so you can fix it.


## Sample code

The open source [codetriage.com](http://codetriage.com) project uses Puma and you can see the [Puma config file in the repo](https://github.com/codetriage/codetriage/blob/master/config/puma.rb)

## Thread safety

Thread safe code can be run across multiple threads without error. Not all Ruby code is [threadsafe](http://en.wikipedia.org/wiki/Thread_safety) and it can be difficult to determine if your code and all of the libraries you are using can be run across multiple threads.

Until Rails 4, there was a [thread safe compatibility mode](http://tenderlovemaking.com/2012/06/18/removing-config-threadsafe.html) that could be toggled. Though just because Rails is thread safe it doesn't guarantee your code will be. If you haven't run your application in a threaded environment we recommend deploying and setting `MIN_THREADS` and `MAX_THREADS` both to 1:

```
$ heroku config:set MIN_THREADS=1 MAX_THREADS=1
```

You can still gain concurrency by adding workers. Since a worker runs in a different process and does not share memory, code that is not thread safe can be run across multiple worker processes.

Once you have your application running on workers, you can try increasing the number of threads on staging and in development to 2:

```
$ heroku config:set MIN_THREADS=2 MAX_THREADS=2
```

You need to monitor exceptions and look for errors such as **deadlock detected (fatal)*, [race conditions](http://en.wikipedia.org/wiki/Race_condition#Software), and locations where you're modifying global or shared variables.

Concurrency bugs can be difficult to detect and fix, so make sure to test your application thoroughly before deploying to production. If you can make your application thread safe, the benefit is greatly worth it, as scaling out with Puma threads and workers provide significantly more throughput than using workers alone.

Once you are confident that your application behaves as expected, you can increase your thread count.

To optimize thread count, we recommend looking at request latency. If your application is under load additional threads will decrease request latency, up to a point. Once adding new threads no longer gives your application measurable request time improvements there is no need to add additional threads


## Database connections

As you add more concurrency to your application it will need more connections to your database. A good formula for determining the number of connections each application will require is to multiply the `MAX_THREADS` by the `PUMA_WORKERS`. This will determine the number of connections each dyno will consume.

Rails maintains its own database connection pool, with a new pool created for each worker process. Threads within a worker will operate on the same pool. Make sure there are enough connections inside of your Rails database connection pool so that `MAX_THREADS` number of connections can be used. If you see this error:

```
ActiveRecord::ConnectionTimeoutError - could not obtain a database connection within 5 seconds
```

This is an indication that your Rails connection pool is too low. For an in depth look at these topics please read the devcenter article [Concurrency and Database Connections](https://devcenter.heroku.com/articles/concurrency-and-database-connections).


## Slow clients

A slow client is one that sends and receives data slowly. For example, an app that receives images uploaded by users from mobile phones that are not on WiFi, 4G or other fast networks. This type of a connection can cause a denial of service for some servers, such as Unicorn, as workers must sit idle as they wait for the request to finish.

Puma can allow multiple slow clients to connect without requiring a worker to be blocked on the request transaction. Because of this, Puma handles slow clients gracefully. Heroku recommends Puma for use in scenarios where you expect slow clients.