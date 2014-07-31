---
title: HTTP Routing
slug: http-routing
url: https://devcenter.heroku.com/articles/http-routing
description: HTTP routing on Heroku's Cedar stack has an HTTP stack supporting HTTP 1.1, a rolling timeout mechanism, and multiple simultaneous connections.
---

The Heroku platform automatically routes HTTP requests sent to your app's hostname(s) to your web dynos. The entry point for all applications on the [Cedar](cedar) stack is the `herokuapp.com` domain which offers a direct routing path to your web dynos.

## Routing

Inbound requests are received by a load balancer that offers HTTP and SSL termination. From here they are passed directly to a set of routers.

The routers are responsible for determining the location of your application's web [dynos](dynos) and forwarding the HTTP request to one of these dynos.

A request's unobfuscated path from the end-client through the Heroku infrastructure to your application allows for full support of [HTTP 1.1][rfc2616] features such as chunked responses, long polling, and using an async webserver to handle multiple responses from a single web process.

## Request distribution

Routers use a random selection algorithm for HTTP request load balancing across web dynos.

## Request queueing

Each router maintains an internal per-app request queue. For Cedar apps, routers limit the number of active requests per dyno to 50 and queue additional requests. There is no coordination between routers however, so this request limit is per router. The request queue on each router has a maximum backlog size of 50n (n = the number of web dynos your app has running). If the request queue on a particular router fills up, subsequent requests to that router will immediately return an [H11 (Backlog too deep)](error-codes#h11-backlog-too-deep) response.

## Dyno connection behavior

When Heroku receives an HTTP request, a router establishes a new upstream TCP connection to a randomly selected web dyno. If the connection is refused or has not been successfully established after 5 seconds, the dyno will be quarantined and no other connections will be forwarded from that router to the dyno for up to 5 seconds. The quarantine only applies to a single router. Because each router keep its own list of quarantined dynos, other routers may continue to forward connections to the dyno.

When a connection to a dyno is refused or times out, the router processing the request will retry the request on another dyno. A maximum of 10 attempts (or fewer if you don't have 10 running web dynos) will be made before returning an [H19](error-codes#h19-backend-connection-timeout) or [H21](error-codes#h21-backend-connection-refused) error.

If all dynos are quarantined, the router will retry for up to 75 seconds (with an incremental back off), before serving an [H99](error-codes#h99-platform-error) error.

## Timeouts

After a dyno connection has been established, HTTP requests have an initial 30 second window in which the web process must return response data (either the completed response or some amount of response data to indicate that the process is active). Processes that do not send response data within the initial 30-second window will see an [H12](error-codes#h12-request-timeout) error in their [logs](logging).

After the initial response, each byte sent (either from the client or from your app process) resets a rolling 55 second window. If no data is sent during this 55 second window then the connection is terminated and a [H15](error-codes#h15-idle-connection) error is logged.

Additional details can be found in the [Request Timeout article](https://devcenter.heroku.com/articles/request-timeout).

## Simultaneous connections

The `herokuapp.com` routing stack allows many concurrent connections to web dynos. For production apps, you should always choose an embedded webserver that allows multiple concurrent connections to maximize the responsiveness of your app. You can also take advantage of concurrent connections for long-polling requests.

Almost all modern web frameworks and embeddable webservers support multiple concurrent connections. Examples of webservers that allow concurrent request processing in the dyno include [Unicorn](https://devcenter.heroku.com/articles/rails-unicorn) (Ruby), Goliath (Ruby), Puma (JRuby), [Gunicorn](https://devcenter.heroku.com/articles/python-gunicorn) (Python), and Jetty (Java).

## Request buffering

When processing an incoming request, a router sets up an 8KB receive buffer and begins reading the HTTP request line and request headers. Each of these can be at most 8KB in length, but together can be more than 8KB in total. Requests containing a request line or header line longer than 8KB will be dropped by the router without being dispatched. The body of a request can be of any size. Once the entire set of HTTP headers has been received, the router starts the process of dispatching the request to a dyno.

As a result, each router buffers the header section of all requests, and will deliver this to your dyno as fast as our internal network will run. The dyno is protected from slow clients until the request body needs to be read. If you need protection from clients transmitting the body of a request slowly, you'll have the request headers available to you in order to make a decision as to when you want to drop the request by closing the connection at the dyno.

## Response buffering

The router maintains a 1MB buffer for responses from the dyno per connection. This means that you can send a response up to 1MB in size before the rate at which the client receives the response will affect the dyno - even if the dyno closes the connection, the router will keep sending the response buffer to the client. The transfer rate for responses larger than the 1MB buffer size will be limited by how fast the client can receive data.

## Heroku headers

* `X-Forwarded-For`: the originating IP address of the client connecting to the Heroku router
* `X-Forwarded-Proto`: the originating protocol of the HTTP request (example: https)
* `X-Forwarded-Port`: the originating port of the HTTP request (example: 443)
* `X-Request-Start`: unix timestamp (milliseconds) when the request was received by the router

## Heroku router log format

#### info logs

```
2012-10-11T03:47:20+00:00 heroku[router]: at=info method=GET path=/ host=myapp.herokuapp.com fwd="204.204.204.204" dyno=web.1 connect=1ms service=18ms status=200 bytes=13
```

* `method`: HTTP request method
* `path`: HTTP request path
* `host`: HTTP request `Host` header value
* `fwd`: HTTP request `X-Forwarded-For` header value
* `dyno`: name of the dyno that serviced the request
* `connect`: amount of time spent establishing a connection to the backend web process
* `service`: amount of time spent proxying data between the backend web process and the client
* `status`: HTTP response code
* `bytes`: Number of bytes transferred from the backend web process to the client

#### Error logs

```
2012-10-11T03:47:20+00:00 heroku[router]: at=error code=H12 desc="Request timeout" method=GET path=/ host=myapp.herokuapp.com fwd="204.204.204.204" dyno=web.1 connect= service=30000ms status=503 bytes=0
```

* `code`: [Heroku error code](https://devcenter.heroku.com/articles/error-codes)
* `desc`: description of error

## Caching

Apps serving large amounts of static assets can take advantage of [HTTP caching](http-caching) to improve performance and reduce load.

## WebSockets

WebSocket functionality is [also available](https://devcenter.heroku.com/articles/websockets).

## Gzipped responses

Since requests to Cedar apps are made directly to the application server -- not proxied through an HTTP server like nginx -- any compression of responses must be done within your application.

## Supported HTTP Methods

The Heroku HTTP stack supports any [HTTP method][method] (sometimes called a "verb"), even those not defined in an RFC, except the following: [CONNECT][method-connect].

Commonly used methods include [GET][method-get], [POST][method-post], [PUT][method-put], [DELETE][method-delete], [HEAD][method-head], [OPTIONS][method-options], and [PATCH][method-patch]. Methods are limited to 127 characters in length.

[method]: https://tools.ietf.org/html/rfc2616#section-5.1.1 "HTTP/1.1 Method token"
[method-options]: https://tools.ietf.org/html/rfc2616#section-9.2 "HTTP/1.1 - OPTIONS"
[method-get]: https://tools.ietf.org/html/rfc2616#section-9.3 "HTTP/1.1 - GET"
[method-head]: https://tools.ietf.org/html/rfc2616#section-9.4 "HTTP/1.1 - HEAD"
[method-post]: https://tools.ietf.org/html/rfc2616#section-9.5 "HTTP/1.1 - POST"
[method-put]: https://tools.ietf.org/html/rfc2616#section-9.6 "HTTP/1.1 - PUT"
[method-delete]: https://tools.ietf.org/html/rfc2616#section-9.7 "HTTP/1.1 - DELETE"
[method-patch]: http://tools.ietf.org/html/rfc5789 "PATCH Method for HTTP"
[method-connect]: https://tools.ietf.org/html/rfc2616#section-9.9 "CONNECT method"
[rfc2616]: https://tools.ietf.org/html/rfc2616 "RFC2616: Hypertext Transfer Protocol -- HTTP/1.1" 