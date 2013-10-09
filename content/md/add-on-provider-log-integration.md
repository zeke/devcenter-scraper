---
title: Add-on Provider Log Integration
slug: add-on-provider-log-integration
url: https://devcenter.heroku.com/articles/add-on-provider-log-integration
description: How to send logs to an app's log stream
---

Add-on providers can improve the development experience of their Add-on by inserting data into the app's log stream. This article explains how to connect your service to an app's log stream via [Logplex](https://devcenter.heroku.com/articles/logplex).

## Setup
To gain access to the app’s Logplex token, which will give you the capability to write to an app’s log stream, you will first need to store the log drain token that is submitted in the Add-on provision request. More details of the provision request can be found in the [Add-on Provider API Spec](https://devcenter.heroku.com/articles/add-on-provider-api). If you have not previously stored the logplex_token from the provision request, you can use the [App Info API](https://devcenter.heroku.com/articles/add-on-provider-api#app-info) to query for the token.

## Transport
Data must be delivered to Logplex via HTTP. Using keep-alive connections and dense payloads, you can efficiently deliver all of your customer’s logs to Logplex via HTTP. Here is cURL example demonstrating a simple HTTP request:

```
$ curl "https://east.logplex.io/logs" \
  --user "token:t123" \
  -d "62 <190>1 2013-03-27T20:02:24+00:00 hostname t.123 procid - - foo62 <190>1 2013-03-27T20:02:24+00:00 hostname t.123 procid - - bar" \
  -X "POST" \
  -H "Content-Length: 130" \
  -H "Content-Type: application/logplex-1"
```

Note that basic authentication is required. The username is `token` and the password is the `logplex_token` value returned by the [App Info API](https://devcenter.heroku.com/articles/add-on-provider-api#app-info).

>callout
>Checkout all of the API details in the <a href="https://github.com/heroku/logplex/blob/master/doc/">Logplex API Docs</a>.


## Format
The headers of the request should contain Content-Length & Content-Type. The value of Content-Length should be the integer value of the length of the body. The value of Content-Type should be application/logplex-1.

The body of the HTTP request should contain length delimited syslog packets. Syslog packets are defined in [RFC5424](http://tools.ietf.org/html/rfc5424). The following line summarizes the RFC protocol:

```
<prival>version time hostname appname procid msgid structured-data msg
```

You can use `<190>` (local7.info) for the **prival** and `1` for the version. The **time** field should be set to the time at which the logline was created in [rfc3339](http://tools.ietf.org/html/rfc3339) format. The **hostname** should be set to the name of your service. (e.g. postgresql) The **appname** field is reserved for the app’s Logplex token. The Logplex token is required to write to an app’s log stream. The **procid** is not used by logplex but is a great way to identify the process which is emitting the logs. Similarly, the msgid, and structured-data is not used by logplex and the value `-` should be used. Finally, the msg is the section of the packet where the log message can be stored.

### Message conventions

You should format your log messages in a way that is optimized for both human
readability and machine parsability. With that in mind, log data should:

- Consist of one line of content
- Use key-value pairs of the format `status=delivered`
- Use a `source` key-value pair in log lines for distinguishing machines or
  environments (example: `source=us-east measure#web.latency=4ms`).
- Show hierarchy with dots, from least to most specific, as in
  `measure#queue.backlog=`
- Units must immediately follow the number and must only include `a-zA-Z`
  (example: `10ms`).

#### One-off events

These are log messages that should be written at the time something occurs. For
example: when a process crashes, an SMS is delivered, or when approaching usage
limits.

    event#title=queued source=myworker.4f3595381cf75447be029da5
    event#title=deploy event#start_time=1234567890

These messages can be correlated with quantifiable metrics, like Librato
[Annotations](http://blog.librato.com/posts/2012/09/annotations) or
[Deployments](http://blog.newrelic.com/2010/07/22/what-changed-using-deployment-tracking-in-rpm/)
in NewRelic.

#### High-frequency events

These are log events that would benefit from statistical aggregation by a log
consumer:

    measure#elb.latency.sample_count=67448s source=elb012345.us-east-1d

#### Pre-aggregated statistics

Periodically, your service may inject pre-aggregated metrics into a user's
logstream.  The event could include the total number of database tables, active
connections, cache usage:

    sample#tables=30 sample#active-connections=3
    sample#cache-usage=72.94 sample#cache-keys=1073002

>Our experience logging for Postgres suggests that once a minute is a reasonable
>frequency for reporting aggregate metrics. Any higher frequency is potentially
>too noisy or expensive for storage/analysis. Be mindful of this when choosing
>to periodically log metrics from your add-on.

#### Incremental counters

    count#db.queries=2 count#db.snapshots=10

## Example

A reference implementation is provided at [ryandotsmith/lpxc](https://github.com/ryandotsmith/lpxc). This implementation highlights batching and keep-alive connections.