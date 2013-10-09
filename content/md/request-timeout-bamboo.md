---
title: Request Timeouts on Bamboo
slug: request-timeout-bamboo
url: https://devcenter.heroku.com/articles/request-timeout-bamboo
description: On the Heroku Bamboo stack web dynos have 30 seconds to respond before an error page is served to the user and an error logged.
---

<div class="deprecated" markdown="1">This article applies to apps on the [Bamboo](bamboo) stacks.  For the most recent stack, [Cedar](cedar), see [Request Timeout](request-timeout).</div>

<div class="callout"><p>
Additional concurrency usually doesn't help much if you are encountering request timeouts, since the most common causes affect only individual requests. You can crank your dynos to the maximum and you'll still get a request timeout, since it is a single request that is failing to serve in the correct amount of time.  Extra dynos increase your concurrency, not the speed of your requests.
</p></div>

Heroku's routers can detect long-running requests.  If your dyno takes more than 30 seconds to respond to a request, a router will serve an error page to the user and record an [H12 error](error-codes) in your application logs.

Web requests should be typically processed in no more than 500ms, and ideally under 200ms.  So a request which runs 30 seconds is two orders of magnitude slower than a best-practice response!

We suggest using the [rack-timeout](https://github.com/kch/rack-timeout/) gem for all Bamboo apps.  The gem will automatically terminate your request after 15 seconds (or a user specified time).  This will ensure that you have logs for which requests are taking a long time.

Timeouts
--------------

The entire request cycle must be completed in 30 seconds or less.  Bamboo does not support long-polling or chunked responses.  After 30 seconds your request will be terminated an an  [error](error-codes) served to your users. 

When a connection is terminated, an error page will be issued to the client. The web dyno that was processing the request is left untouched – it will continue to process the request (even though it won't be able to send any response). Subsequent requests may then be routed to the same process which will be unable to respond (depending on the concurrency behavior of the application's language/framework) causing further degradation.

Debugging request timeouts
--------------

One possibility may be that you have an infinite loop in your code.  Test locally (perhaps with a copy of the production database pulled down with [pgbackups](pgbackups)) and see if you can replicate the problem and fix the bug.

Another possibility is that you are trying to do some sort of long-running task inside your web request, such as:

* Sending an email
* Accessing a remote API (posting to Twitter, querying Flickr, etc)
* Web scraping / crawling
* Rendering an image or PDF
* Heavy computation (generating a fractal, computing a fibonacci sequence, etc)
* Heavy database usage (slow or numerous queries)

If so, you should move this heavy lifting into a background job which can run asynchronously from your web request.  See [Queueing](background-jobs-queueing) for details.

Note that if an external service is unavailable or overloaded, your web app is highly likely to timeout unless you move the work to the background. In some cases where you must process these requests during your web request, you should always plan for the failure case.

Request timeouts can also be caused by queueing of TCP connections inside the dyno. Each Rails worker process in Unicorn handles only one connection at a time, so each dyno can handle a fixed number of requests at a time corresponding to the number of workers. It's possible for the routers to send more than one request to a dyno concurrently, and in this case, requests will queue behind the ones being processed by the app, causing those subsequent requests to take longer than they would on their own. You can get some visibility into request queue times with the [New Relic addon](https://addons.heroku.com/newrelic). This can be ameliorated by the following techniques, in order of typical effectiveness:

- *Run more workers per dyno*, with correspondingly fewer dynos. This keeps your total concurrency the same, but dramatically improves request queueing efficiency by sharing each dyno queue among more processes.
- *Make slow requests faster* by optimizing app code. To do this effectively, focus on the 99th percentile and maximum service time for your app. This decreases the amount of time requests will spend waiting behind other, slower requests.
- *Run more dynos*, thus increasing total concurrency. This slightly decreases the probability that any given request will get stuck behind another one.

You can also use [rack-timeout](https://github.com/kch/rack-timeout) to abort requests that take more than a certain time. This should be used as a fallback measure so that abnormal requests do not hang forever, causing your app performance to degrade for all users.