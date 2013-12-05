---
title: Heroku Labs: http-request-id
slug: http-request-id
url: https://devcenter.heroku.com/articles/http-request-id
description: Correlate router logs for a given web request against the web dyno logs for that same request.
---

This [Heroku Labs](http://devcenter.heroku.com/categories/labs) feature that allows you to correlate router logs for a given web request against the web dyno logs for that same request.

> warning
> Features added through Heroku Labs are experimental and subject to change.

## How it works

The Heroku router generates a unique request ID for every HTTP request that it receives. It logs this ID as `request_id`, and inserts it into the HTTP headers going to the web dyno as `Heroku-Request-ID`.

Your app code can read the request ID from the header, and log it or use it for other purposes.

## Using it

```term
$ heroku labs:enable http-request-id
Enabling http-request-id for myapp... done
```

## Router log

The router log request ID parameter is `request_id`. Example:

```
2013-03-10T19:53:10+00:00 heroku[router]: at=info method=GET path=/ host=myapp.herokuapp.com request_id=f9ed4675f1c53513c61a3b3b4e25b4c0 fwd="215.90.1.17" dyno=web.4 connect=0ms service=61ms status=200 bytes=1382
```

## HTTP header

The HTTP header is named `Heroku-Request-ID`. Sample code for reading and logging this from Rack middleware:

```ruby
module Rack::LogRequestID
  def initialize(app); @app = app; end

  def call(env)
    puts "request_id=#{env['HTTP_HEROKU_REQUEST_ID']}"
    @app.call(env)
  end
end
```

## Example: correlate H13 error against app backtrace

Scenario: your app is reporting occasional [H13](https://devcenter.heroku.com/articles/error-codes#h13-connection-closed-without-response) errors. The router reports the dyno closed the connection; how do we find the web dyno logs associated with one of these requests? Request IDs can help here, especially on a busy app with lots of data in the logs.

Find the router log line for the H13:

```
2010-10-06T21:51:37-07:00 heroku[router]: at=error code=H13 desc="Connection closed without response" method=GET path=/ host=myapp.herokuapp.com request_id=30f14c6c1fc85cba12bfd093aa8f90e3 fwd="215.90.1.17" dyno=web.15 connect=3030ms service=9767ms status=503 bytes=0
```

Note the request ID, which is `30f14c6c1fc85cba12bfd093aa8f90e3` in this example. Now you can search your logs (using [Papertrail](papertrail) or other log search method) for that ID and find the request, logged by the middleware shown in the previous section:

```
2010-10-06T21:51:37-07:00 heroku[web.15]: request_id=30f14c6c1fc85cba12bfd093aa8f90e3
2010-10-06T21:51:37-07:00 heroku[web.15]: /usr/local/heroku/vendor/gems/excon-0.14.0/lib/excon/ssl_socket.rb:74: [BUG] Segmentation fault
```

Here we see that this request is causing the dyno to crash due to a bug in the SSL library and/or the Ruby interpreter. Upgrading to a newer version of Ruby might help, or if not, you now have the backtrace that you can use to file a bug with.