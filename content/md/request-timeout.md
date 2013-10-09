---
title: Request Timeout
slug: request-timeout
url: https://devcenter.heroku.com/articles/request-timeout
description: Learn about the behavior of the Heroku routers, connection termination and connection timeouts.
---

<div class="callout" markdown="1">
Additional concurrency usually doesn't help much if you are encountering request timeouts, since the most common causes affect only individual requests. You can crank your dynos to the maximum and you'll still get a request timeout, since it is a single request that is failing to serve in the correct amount of time.  Extra dynos increase your concurrency, not the speed of your requests.
</div>

Web requests processed by Heroku are directed to your dynos via a number of Heroku [routers](http-routing). These requests are intended to be served by your application quickly. Best practice is to get the response time of your web application to be under 500ms, this will free up the application for more requests and deliver a high quality user experience to your visitors. Occasionally a web request may hang or take an excessive amount of time to process by your application. When this happens the router will terminate the request if it takes longer than 30 seconds to complete. The timeout countdown begins when the request leaves the router. The request must then be processed in the dyno by your application, and then a response delivered back to the router within 30 seconds to avoid the timeout.

When a timeout is detected the router will return a [customizable error page](error-pages) to the client and an [H12 error](error-codes) is emitted to your application logs. While the router has returned a response to the client, your application will not know that the request it is processing has reached a time-out, and your application will continue to work on the request. To avoid this situation Heroku recommends setting a timeout within your application and keeping the value well under 30 seconds, such as 10 or 15 seconds. Unlike the routing timeout, these timers will begin when the request begins being processed by your application. You can read more about this below in: Timeout behavior.

The timeout value is not configurable. If your server requires longer than 30 seconds to complete a given request, we recommend moving that work to a background task or worker to periodically ping your server to see if the processing request has been finished. This pattern frees your web processes up to do more work, and decreases overall application response times.


## Long-polling and streaming responses

[Cedar](cedar) supports HTTP 1.1 features such as long-polling and streaming responses. An application has an initial 30 second window to respond with a single byte back to the client.  However, each byte transmitted thereafter (either received from the client or sent by your application) resets a rolling 55 second window.  If no data is sent during the 55 second window, the connection will be terminated.

If you're sending a streaming response, such as with [server-sent events](http://dev.w3.org/html5/eventsource/), you'll need to detect when the client has hung up, and make sure your app server closes the connection promptly. If the server keeps the connection open for 55 seconds without sending any data, you'll see a request timeout.

## Timeout behavior

When a connection is terminated, an error page will be issued to the client. The web dyno that was processing the request is left untouched – it will continue to process the request (even though it won't be able to send any response). Subsequent requests may then be routed to the same process which will be unable to respond (depending on the concurrency behavior of the application's language/framework) causing further degradation.

Depending on your language you may be able to set a timeout on the app server level. One example is Ruby's [Unicorn](rails-unicorn). In Unicorn you can set a timeout in `config/unicorn.rb` like this:

    :::ruby
    timeout 15

The timer will begin once Unicorn starts processing the request, if 15 seconds pass, then the master process will send a SIGKILL to the worker but no exception will be raised.

In addition to server level timeouts you can use other request timeout libraries. One example is using Ruby's [rack-timeout](https://github.com/kch/rack-timeout) gem and setting the timeout value to lower than the router's 30 second timeout, such as 15 seconds. Like the application level timeout this will prevent runaway requests from living on indefinitely in your application dyno, however it will raise an error which makes tracking the source of the slow request considerably easier.

Similar tools exist for other languages.

## Debugging request timeouts

One cause of request timeouts is an infinite loop in the code.  Test locally (perhaps with a copy of the production database pulled down with [pgbackups](pgbackups)) and see if you can replicate the problem and fix the bug.

Another possibility is that you are trying to do some sort of long-running task inside your web process, such as:

* Sending an email
* Accessing a remote API (posting to Twitter, querying Flickr, etc.)
* Web scraping / crawling
* Rendering an image or PDF
* Heavy computation (computing a fibonacci sequence, etc.)
* Heavy database usage (slow or numerous queries, N+1 queries)

If so, you should move this heavy lifting into a background job which can run asynchronously from your web request.  See [background workers](background-jobs-queueing) for details.

Another class of timeouts occur when an external service used by your application is unavailable or overloaded.  In this case, your web app is highly likely to timeout unless you move the work to the background. In some cases where you must process these requests during your web request, you should always plan for the failure case.  Most languages let you specify a timeout on HTTP requests, for example.

## Request queueing efficiency

Request timeouts can also be caused by queueing of TCP connections inside the dyno. Some languages and frameworks process only one connection at a time, but it's possible for the routers to send more than one request to a dyno concurrently. In this case, requests will queue behind the one being processed by the app, causing those subsequent requests to take longer than they would on their own. You can get some visibility into request queue times with the [New Relic addon](https://addons.heroku.com/newrelic). This problem can be ameliorated by the following techniques, in order of typical effectiveness:

- *Run more processes per dyno*, with correspondingly fewer dynos. If you're using a framework that can handle only one request at a time (for example, Ruby on Rails), try a tool like [Unicorn](rails-unicorn) with more worker processes. This keeps your app's total concurrency the same, but dramatically improves request queueing efficiency by sharing each dyno queue among more processes.
- *Make slow requests faster* by optimizing app code. To do this effectively, focus on the 99th percentile and maximum service time for your app. This decreases the amount of time requests will spend waiting behind other, slower requests.
- *Run more dynos*, thus increasing total concurrency. This slightly decreases the probability that any given request will get stuck behind another one.