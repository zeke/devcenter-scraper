---
title: Heroku Labs: WebSockets
slug: heroku-labs-websockets
url: https://devcenter.heroku.com/articles/heroku-labs-websockets
description: This Heroku Labs feature adds experimental support for WebSocket capable HTTP endpoints
---

## Introduction

The WebSocket protocol is a core technology of modern, real-time web applications.  It provides a bidirectional channel for delivering data between clients and servers.  It gives you the flexibility of a TCP connection with the additional security model and meta data built into the HTTP protocol.  For more details on the WebSocket protocol refer to [RFC 6455](http://tools.ietf.org/html/rfc6455).

This [Heroku Labs](http://devcenter.heroku.com/categories/labs) feature adds experimental WebSocket support to your `herokuapp.com` domain, custom domains and custom SSL endpoints.

>warning
>Features added through Heroku Labs are experimental and are subject to change.

### Enabling WebSockets

```term
$ heroku labs:enable websockets -a myapp
Enabling websockets for myapp... done
WARNING: This feature is experimental and may change or be removed without notice.
```

[Custom SSL Endpoints](https://devcenter.heroku.com/articles/ssl-endpoint) can be provisioned with WebSocket support.  The `websockets` labs feature must be enabled __before__ the endpoint has been provisioned though.

Enabling the `websockets` labs feature on an app with an existing SSL Endpoint will fail with the following error message:

```term
$ heroku labs:enable websockets
Enabling websockets for myapp... failed
!    Can not add websockets feature when ssl-endpoint is in use.
```

Remove the existing endpoint, enable the `websockets` labs feature and add the SSL Endpoint add-on back again to properly provision a WebSocket capable endpoint. Remember to update the DNS records for any custom domains to point to the new hostname presented during the endpoint provisioning process.

### Disabling WebSockets

```term
$ heroku labs:disable websockets -a myapp
Disabling websockets for myapp... done
```
### Domains and DNS configuration

When the `websockets` labs feature is enabled for your app, the DNS record for your `herokuapp.com` domain is updated to point at a WebSocket capable endpoint.  It may take a moment for the DNS change to propagate.  If you have custom domains attached to your app, make sure they are [configured properly](https://devcenter.heroku.com/articles/custom-domains) to ensure WebSocket support on all domains.

## Application architecture

### Process and application state

The WebSocket protocol introduces state into a generally
[stateless application architecture](/articles/runtime-principles#statelessness). 
It provides a mechanism for creating persistent connections to a node in a 
stateless system (e.g. a web browser connecting to a single web process). 
Because of this, each web process is required to maintain the state of 
its own WebSocket connections. If application data is shared across 
processes, global state must also be maintained.

Imagine a chat application that pushes messages from a Redis Pub/Sub 
channel to all of its connected users. Every web process would have a 
collection of persistent WebSocket connections open from active users.
Each user would not, however, have its own subscription to the Redis channel.
The web process would maintain a single connection to Redis, and the state
of each connected user would then be updated as incoming messages arrive.

![Application Diagram](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/225-original.jpg)

In this example, web process state is maintained by your application while global state is maintained by Redis.

> callout
> Visit the <a href="https://addons.heroku.com/?q=redis">Add-ons Marketplace<a/> to find a Redis provider.

### Security considerations

Refer to the [WebSocket Security article](https://devcenter.heroku.com/articles/websocket-security) for information on best practices.

### Timeouts

The normal [Heroku HTTP routing timeout rules](https://devcenter.heroku.com/articles/http-routing#timeouts) apply to the WebSocket labs feature. Either client or server can prevent the connection from idling by sending an occasional ping packet over the connection.

### Example implementations

The following examples demonstrate the minimal code required to establish a WebSocket connection and send/receive data. Refer to the [Further reading](https://devcenter.heroku.com/articles/heroku-labs-websockets#further-reading) section for language specific guides for developing more powerful applications.

* [Ruby faye app](https://github.com/heroku-examples/ruby-ws-test)
* [Node.js ws app](https://github.com/heroku-examples/node-ws-test)

## Further reading

* [Using WebSockets on Heroku with Ruby](https://devcenter.heroku.com/articles/ruby-websockets)
* [Using WebSockets on Heroku with Node.js](https://devcenter.heroku.com/articles/node-websockets)
* [Using WebSockets on Heroku with Python](https://devcenter.heroku.com/articles/python-websockets)
* [Using WebSockets on Heroku in Java with the Play Framework](https://devcenter.heroku.com/articles/play-java-websockets)