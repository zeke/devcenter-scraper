---
title: Deploying Rails Applications with Unicorn
slug: rails-unicorn
url: https://devcenter.heroku.com/articles/rails-unicorn
description: Configuring Rails applications to use the Unicorn web server, enabling the concurrent processing of requests.
---

Web applications that process requests concurrently make much more efficient use of dyno resources than web applications that only process one request at a time. Therefore it is recommended to use concurrent request processing whenever developing and running production services.

The Rails framework was originally designed to process one request at a time. The framework is gradually moving away from this design towards a thread safe implementation that allows for concurrent processing of requests in a single Ruby process. But most Ruby applications don't support this today.

The Unicorn web server lets you run any Rails application concurrently by running multiple Ruby processes in a single dyno.

This guide will walk you through deploying a new Rails application to Heroku using the Unicorn web server. For basic Rails setup, see [Getting Started with Rails](getting-started-with-rails3).

> warning
> Always test your new deployments in a staging environment before you deploy to your production application.

> note
> If you have questions about Ruby on Heroku, consider discussing it in the [Ruby on Heroku forums](https://discussion.heroku.com/category/ruby).

## The Unicorn server

[Unicorn](http://unicorn.bogomips.org/) is a Rack HTTP server that uses forked processes to handle multiple incoming requests concurrently.

## Adding Unicorn to your application

### Gemfile

First, add Unicorn to your app's Gemfile:

 ```ruby
 gem 'unicorn'
 ```

Run `bundle install` to set up your bundle locally.

### Config

Create a configuration file for Unicorn at `config/unicorn.rb`, or at a path of your choosing. For a simple Rails application, we recommend the following basic configuration:

```ruby
# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end 

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
```

The above assumes a standard Rails app with ActiveRecord and New Relic for monitoring. For information on other available configuration operations, see [Unicorn’s documentation](http://unicorn.bogomips.org/Unicorn/Configurator.html).

### Unicorn worker processes

```ruby
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
```

Unicorn forks multiple OS processes within each dyno to allow a Rails app to support multiple concurrent requests without requiring them to be thread-safe. In Unicorn terminology these are referred to as worker processes not to be confused with Heroku worker processes which run in their own dynos.

Each forked OS process consumes additional memory. This limits how many processes you can run in a single dyno. With a typical Rails memory footprint, you can expect to run 2-4 Unicorn worker processes. Your application may allow for more or less processes depending on your specific memory footprint, and we recommend specifying this number in an config var to allow for faster application tuning. Monitor your application logs for [R14 errors](error-codes#r14-memory-quota-exceeded) (memory quota exceeded) via one of our [logging addons](https://addons.heroku.com/?q=logging) or `heroku logs`.

### Preload app

```ruby
preload_app true
# ...
before_fork do |server, worker|
  # ...
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end 

after_fork do |server, worker|
  # ...
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
```

Preloading your application reduces the startup time of individual Unicorn `worker_processes` and allows you to manage the external connections of each individual worker using the `before_fork` and `after_fork` calls. In the config above, these calls are used to correctly establish postgres connections for each worker process.

New Relic also recommends `preload_app true` for more accurate data collection with Unicorn apps. For information on using New Relic without `preload_app true`, see [their documentation](https://newrelic.com/docs/ruby/no-data-with-unicorn).

### Signal handling

```ruby
before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
  # ...
end 

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end
  # ...
end
```

[POSIX Signals](http://en.wikipedia.org/wiki/Unix_signal) are a form of interprocess communication to indicate a certain event or state change. Traditionally, [`QUIT`](http://en.wikipedia.org/wiki/SIGQUIT#SIGQUIT) is used to signal a process to exit immediately and produce a core dump. [`TERM`](http://en.wikipedia.org/wiki/SIGTERM#SIGTERM) is used to tell a process to terminate, but allows the process to clean up after itself.

Unicorn uses the `QUIT` signal to indicate graceful shutdown. When the master process receives this signal it sends a `QUIT` signal to all workers who will then gracefully shut down after completing any in-flight requests. After the worker processes have shut down, the master process will exit.

[Heroku uses the `TERM`](dynos#graceful-shutdown-with-sigterm) signal to indicate to all processes in a dyno that the dyno is being shut down. The configuration above ensures that this `TERM` signal is translated correctly to the Unicorn model: the workers trap and ignore the signal. The master traps and sends a `QUIT` signal to itself, thereby starting the graceful shutdown process.

Heroku gives processes 10 seconds to shut down gracefully after which a `KILL` signal is sent to all processes to force a shutdown. If an individual request takes longer than 10 seconds, it might be interrupted. Keep an eye out for entries in your application logs that indicate failure to shut down gracefully.

### Timeouts

Heroku's router enforces a 30 second window before there is a [request timeout](https://devcenter.heroku.com/articles/request-timeout). After a request is delivered to a dyno via the router it has 30 seconds to return a response or the router will return a  [customizable error page](error-pages). This is done to prevent hanging requests from tying up resources. While the router will return a response to the client, the unicorn worker will continue to process the request even though a client has received a response. This means that the worker is being tied up, perhaps indefinitely due to a hung request. To ensure your application's requests do not tie up your dyno past the request timeout, we recommend using both [Rack::Timeout](https://github.com/kch/rack-timeout) and Unicorn's timeout configuration setting.


#### Unicorn timeout

Unicorn has a configurable timeout setting. The timeout countdown for unicorn will begin once the request is being processed by your application and end when it returns a response. If the request takes longer than the specified time, the master will be SIGKILL the worker working on the request

```ruby
timeout 15
```

We recommend a timeout of 15 seconds. With a 15 second timeout, the master process will send a `SIGKILL` to the worker process if processing a request takes longer than 15 seconds. This will generate a [H13](https://devcenter.heroku.com/articles/error-codes#h13-connection-closed-without-response) error code and you'll see it in your logs. Note, this will not generate any stacktraces to assist in debugging.

#### Rack::Timeout

When the [Rack::Timeout](https://devcenter.heroku.com/articles/request-timeout#timeout-behavior) limit is hit, it closes the requests and generates a stacktrace in the logs that can be used for future debugging of long running code.

```ruby
# config/initializers/timeout.rb
Rack::Timeout.timeout = 10  # seconds
```

On Ruby 1.9/2.0, `Rack::Timeout` uses Ruby's stdlib `Timeout` library which can be unreliable. Heroku recommends using Rack::Timeout and setting the unicorn timeout. If using both timeout systems, the Rack::Timeout value should be lower than the unicorn timeout if you plan on using the stack trace produced by Rack::Timeout for debugging. 

### Procfile

Set Unicorn as the server for the web process in your `Procfile`, pointing to your config file:

```
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
```

## Sample code

A sample Rails 3 app using Unicorn is available here:

[https://github.com/heroku/ruby-rails-unicorn-sample](https://github.com/heroku/ruby-rails-unicorn-sample)


## Caveats

### Preloading and other external services

Take care with other external connections to make sure they work properly with Unicorn's forking model. As you can see in the sample configuration above, the app drops its ActiveRecord connection in the `before_fork` block, and reconnects in the worker process in `after_fork`. Other services will follow a similar pattern. For example, here’s the configuration block for using Resque with a Unicorn app:

```ruby
before_fork do |server, worker|
  # ...
 
  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end
end
 
after_fork do |server, worker|
  # ...
 
  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis = ENV['<REDIS_URI>']
    Rails.logger.info('Connected to Redis')
  end
end
```

Modify the `REDIS_URI` config var to correspond with that from your Redis provider.

Many popular gems, such as the [dalli memcache client](https://github.com/mperham/dalli#features-and-changes), discuss compatibility with Unicorn’s worker process model in their documentation. If you are experiencing issues, check your gem’s documentation for more information.

### Assets

For optimal performance, host your assets [behind a CDN](https://devcenter.heroku.com/articles/using-amazon-cloudfront-cdn) to free up your web dynos to serve only dynamic content.

     
### Database connections

Running a concurrent web server in production means that each dyno will require more than one database connection. To run a high volume Rails app with a concurrent web server you will need to understand how Active Record creates and manages these connections in the connection pool, and the connection limit on development databases. For an in depth look at these topics please read the devcenter article [Concurrency and Database Connections](https://devcenter.heroku.com/articles/concurrency-and-database-connections).

### Slow clients

While Unicorn is the recommended default web server for Ruby apps
running on Heroku, it may not be the best choice for your particular
combination of application and workload. In particular, if your
application receives requests with large body payloads from slow
clients, you may be better off using a different web server. An
example would be a an app that receives images uploaded by users from
mobile phones that are not on wifi, 4G or other fast networks.

The problem is caused by Unicorn workers becoming tied up receiving
requests that are sent slowly by clients. If all Unicorn workers are
tied up, new requests are queued and your app will likely experience
greater-than-normal request-queue times or even [H12
errors](https://devcenter.heroku.com/articles/error-codes#h12-request-timeout).

Puma, Thin or Rainbows! are alternative web servers that may work
better under load generated by slow clients. To change the web server
running your app on Heroku, simply specify a different command for the
`web` process type in your
[Procfile](https://devcenter.heroku.com/articles/procfile). 