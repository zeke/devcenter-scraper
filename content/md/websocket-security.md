---
title: WebSocket Security
slug: websocket-security
url: https://devcenter.heroku.com/articles/websocket-security
description: Security Concerns when developing a WebSockets application
---

The WebSocket protocol is a young technology, and brings with it some risks. Decades of experience have taught the web community some best practices around HTTP security, but the security best practices in the WebSocket world aren't firmly established, and continue to evolve.

Nevertheless, some themes have emerged:

## WSS

You should strongly prefer the secure `wss://` protocol over the insecure `ws://` transport. Like HTTPS, WSS (WebSockets over SSL/TLS) is encrypted, thus protecting against Man-in-the-Middle attacks. A variety of attacks against WebSockets become impossible if the transport is secured.

Heroku's [SSL Endpoints](https://devcenter.heroku.com/articles/ssl-endpoint) support WSS, and we strongly recommend that you use it.

## Avoid tunneling

It's relatively easy to tunnel arbitrary TCP services through a WebSocket. So you could, for example, tunnel a database connection directly through to the browser.

This is very dangerous, however. Doing so would enable access to these services to an in-browser attacker in the case of a [Cross-site Scripting](https://www.owasp.org/index.php/Cross-site_Scripting_%28XSS%29) attack, thus allowing an escalation of a XSS attack into a complete remote breach.

We recommend avoiding tunneling if at all possible, instead developing more secured and checked protocols on top of WebSockets.

## Validate client input

WebSocket connections are easily established outside of a browser, so you should assume that you need to deal with arbitrary data. Just as with any data coming from a client, you should carefully validate input before processing it. [SQL Injection](https://www.owasp.org/index.php/SQL_Injection) attacks are just as possible over WebSockets as they are over HTTP.

## Validate server data

You should apply equal suspicion to data returned from the server, as well. Always process messages received on the client side as data. Don't try to assign them directly to the DOM, nor evaluate as code. If the response is JSON, always use `JSON.parse()` to safely parse the data.

## Authentication/authorization

The WebSocket protocol doesn't handle authorization or authentication. Practically, this means that a WebSocket opened from a page behind auth doesn't "automatically" receive any sort of auth; you need to take steps to *also* secure the WebSocket connection.

This can be done in a variety of ways, as WebSockets will pass through standard HTTP headers commonly used for authentication. This means you could use the same authentication mechanism you're using for your web views on WebSocket connections as well.

Since you cannot customize WebSocket headers from JavaScript, you're limited to the "implicit" auth (i.e. Basic or cookies) that's sent from the browser. Further, it's common to have the server that handles WebSockets be completely separate from the one handling "normal" HTTP requests. This can make shared authorization headers difficult or impossible.

So, one pattern we've seen that seems to solve the WebSocket authentication problem well is a "ticket"-based authentication system. Broadly speaking, it works like this:

* When the client-side code decides to open a WebSocket, it contacts the HTTP server to obtain an authorization "ticket".

* The server generates this ticket. It typically contains some sort of user/account ID, the IP of the client requesting the ticket, a timestamp, and any other sort of internal record-keeping you might need.

* The server stores this ticket (i.e. in a database or cache), and also returns it to the client.

* The client opens the WebSocket connection, and sends along this "ticket" as part of an initial handshake.

* The server can then compare this ticket, check source IPs, verify that the ticket hasn't been re-used and hasn't expired, and do any other sort of permission checking. If all goes well, the WebSocket connection is now verified.

[Thanks to [Armin Ronacher](http://lucumr.pocoo.org/2012/9/24/websockets-101/) for first bringing this pattern to our attention.]

## Origin header

The WebSocket standard defines an `Origin` header field which web browsers set to the URL that originates a WebSocket request. This can be used to differentiate between WebSocket connections from different hosts, or between those made from a browser and some other kind of network client. However, remember that the `Origin` header is essentially advisory: non-browser clients can easily set the `Origin` header to any value, and thus "pretend" to be a browser.

You can think of the `Origin` header as roughly analogous to the `X-Requested-With` header used by AJAX requests. Web browsers send a header of `X-Requested-With: XMLHttpRequest` which can be used to distinguish between AJAX requests made by a browser and those made directly. However, this header is easily set by non-browser clients, and thus isn't trusted as a source of authentication.

In the same way, you can use the `Origin` header as an advisory mechanism, one that helps differentiate WebSocket requests from different locations and hosts, but you shouldn't rely on it as a source of authentication. 