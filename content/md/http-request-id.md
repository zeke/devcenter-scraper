---
title: HTTP Request IDs
slug: http-request-id
url: https://devcenter.heroku.com/articles/http-request-id
description: Correlate router logs for a given web request against the web dyno logs for that same request.
---

HTTP Request IDs let you correlate router logs for a given web request against the web dyno [logs](https://devcenter.heroku.com/articles/logging) for that same request.

## How it works

The Heroku router generates a unique Request ID for every incoming HTTP request that it receives. This unique ID is then passed to your application as an HTTP header called `X-Request-ID`.

Alternately, you can specify the `X-Request-ID` header when making a request. The value must be between 20 and 200 characters, and consist of ASCII letters, digits, or the characters `+`, `/`, `=`, and `-`. Invalid ids will be ignored and replaced with generated ones.

Your app code can then read this ID and simply log it or use it for other purposes.

## Router logs

These Request IDs will also also be visible in the Heroku router logs as `request_id`.  Here's an example:

```term
$ heroku logs --ps router
2013-03-10T19:53:10+00:00 heroku[router]: at=info method=GET path=/ host=myapp.herokuapp.com request_id=f9ed4675f1c53513c61a3b3b4e25b4c0 fwd="215.90.1.17" dyno=web.4 connect=0ms service=61ms status=200 bytes=1382
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

## Usage with Rails

By default Rails will pick up the `X-Request-ID` and set it as the requests UUID. To tie this request ID in with your application logs, add this line to your `config/environments/production.rb`


```ruby
config.log_tags = [ :uuid ]
```

The values in your logs will then be tagged with the Request ID:

```
2014-02-07T00:58:00.978819+00:00 app[web.1]: [6a7f7b2f-889b-4ae8-b849-db1f635c971c] Started GET "/" for 99.61.71.11 at 2014-02-07 00:58:00 +0000
```

Here `6a7f7b2f-889b-4ae8-b849-db1f635c971c` is the Request ID. You can get more information on [tagged logging with UUID in Rails here](http://arun.im/2011/x-request-id-tracking-taggedlogging-rails). Note that if there is not an available `X-Request-ID`, then Rails will generate a UUID for you, so if you enable this in development you will see a "request ID" even though one may not be available.


## Usage with Ruby Rack middleware

Here is a sample Rack module for logging the Request ID.

```ruby
module Rack::LogRequestID
  def initialize(app); @app = app; end

  def call(env)
    puts "request_id=#{env['HTTP_X_REQUEST_ID']}"
    @app.call(env)
  end
end
```

For a more comprehensive rack middleware we recommend the [Heroku Request ID](https://github.com/Octo-Labs/heroku-request-id) gem, which can also provide timing information if you have `Rack::Runtime` enabled:

```ruby
use Rack::Runtime
```

## Usage with Node.js

If you're using the [logfmt](https://www.npmjs.org/package/logfmt) node module `>=0.21.0` as outlined in the [Getting started with Node.js](https://devcenter.heroku.com/articles/getting-started-with-nodejs#write-your-app) article, the `X-Request-Id` header will automatically be output to your logs on every web request as `request_id`.

If you prefer not to use `logfmt` in your node app, be aware that [node's core http module](http://nodejs.org/api/http.html#http_http) downcases header keys, so the header will be named `req.headers['x-request-id']`.


## Usage with Django

You can easily utilize all of the power of Request IDs in Django with the excellent `django-log-request-id` library. First, you'll need to install it by adding it to your `requirements.txt` file:

#### requirements.txt

    django-log-request-id==1.0.0

Next, you need to install the newly available Django middleware into your application's `settings.py`. Make sure that it's the first specified middleware, or it may not function properly:

#### settings.py

```python
MIDDLEWARE_CLASSES = (
    'log_request_id.middleware.RequestIDMiddleware',
    ...
```

Finally, you need to configure Django to properly log outcoming requests to `stdout`.  The code below should work perfectly:

#### settings.py

```python

# Support for X-Request-ID
# https://devcenter.heroku.com/articles/http-request-id-staging

LOG_REQUEST_ID_HEADER = 'HTTP_X_REQUEST_ID'
LOG_REQUESTS = True

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'request_id': {
            '()': 'log_request_id.filters.RequestIDFilter'
        }
    },
    'formatters': {
        'standard': {
            'format': '%(levelname)-8s [%(asctime)s] [%(request_id)s] %(name)s: %(message)s'
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'filters': ['request_id'],
            'formatter': 'standard',
        },
    },
    'loggers': {
        'log_request_id.middleware': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
    }
```

## Usage with Java

Depending on the framework your application is using, the method of accessing and logging the Request ID in Java can vary. This is a simplified example using a Java Servlet filter to access the header and print it to `System.out`.

#### RequestIdLoggingFilter.java

```java
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

public class RequestIdLoggingFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        if (servletRequest instanceof HttpServletRequest) {
            final String requestId = ((HttpServletRequest) servletRequest).getHeader("X-Request-ID");
            if (requestId != null) {
                System.out.println("request_id=" + requestId);
            }
        }
        filterChain.doFilter(servletRequest, servletResponse);
    }

    @Override
    public void destroy() {}
}
```

#### web.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://java.sun.com/xml/ns/javaee"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
         version="2.5">
    <filter>
      <filter-name>RequestIdLoggingFilter</filter-name>
      <filter-class>com.example.config.RequestIdLoggingFilter</filter-class>
    </filter>
    <filter-mapping>
      <filter-name>RequestIdLoggingFilter</filter-name>
      <url-pattern>/*</url-pattern>
    </filter-mapping>
</web-app>
``` 