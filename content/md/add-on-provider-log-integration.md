---
title: Add-on Provider Log Integration
slug: add-on-provider-log-integration
url: https://devcenter.heroku.com/articles/add-on-provider-log-integration
description: How to send logs to an app's log stream
---

Add-on providers can improve the development experience of their Add-on by inserting data into the app's log stream. This article explains how to connect your service to an app's log stream via [Logplex](https://devcenter.heroku.com/articles/logplex).

## Setup
To gain access to the app’s Logplex endpoint, which will give you the capability to write to an app’s log stream, you will first need to store its URL that is submitted in the Add-on provision request. More details of the provision request can be found in the [Add-on Provider API Spec](https://devcenter.heroku.com/articles/add-on-provider-api). If you have not previously stored the `log_input_url` from the provision request, you can use the [App Info API](https://devcenter.heroku.com/articles/add-on-app-info) to query for the endpoint URL.

## Transport
Data must be delivered to Logplex via HTTP. Using keep-alive connections and dense payloads, you can efficiently deliver all of your customer’s logs to Logplex via HTTP. Here is cURL example demonstrating a simple HTTP request:

```
$ URL="https://token:t.01234567-89ab-cdef-0123-456789abcdef@1.us.logplex.io/logs"
$ curl $URL \
  -d "62 <190>1 2013-03-27T20:02:24+00:00 hostname t.01234567-89ab-cdef-0123-456789abcdef procid - - foo62 <190>1 2013-03-27T20:02:24+00:00 hostname t.123 procid - - bar" \
  -X "POST" \
  -H "Content-Length: 130" \
  -H "Content-Type: application/logplex-1" \
  -A 'MyAddonName (https://addons.heroku.com/my-addon-name; Ruby/2.1.2)'
```

>callout
>Please make sure that you set a `User-Agent` header that includes a string that identifies your add-on uniquely.

Note that the URL in the example above is purely illustrative. This URL can vary from app to app and will always have different credentials. You'll need to store these URLs for each installed add-on that requires writing logs or fetching them from the [App Info API](https://devcenter.heroku.com/articles/add-on-app-info) as needed.

The `log_input_url` field for a given app is subject to change, for instance if credentials must be rotated. If your HTTP request gets a `4xx` response code, please see if the `log_input_url` for the app has changed using the [App Info API](https://devcenter.heroku.com/articles/add-on-app-info); if so, update your record for the app and retry.

>callout
>Checkout all of the API details in the <a href="https://github.com/heroku/logplex/blob/master/doc/">Logplex API Docs</a>.

## Format
The headers of the request should contain `Content-Length` & `Content-Type`. The value of `Content-Length` should be the integer value of the byte length of the body. The value of `Content-Type` should be `application/logplex-1`.

The body of the HTTP request should contain length delimited syslog packets. Syslog packets are defined in [RFC5424](http://tools.ietf.org/html/rfc5424). The following line summarizes the RFC protocol:

```
<prival>version time hostname appname procid msgid structured-data msg
```

You can use `<190>` (local7.info) for the **prival** and `1` for the version. The **time** field should be set to the time at which the logline was created in [rfc3339](http://tools.ietf.org/html/rfc3339) format. The **hostname** should be set to the name of your service (e.g. postgresql). The **appname** field is reserved for the app’s Logplex token. The Logplex token is required to write to an app’s log stream. The **procid** is not used by logplex but is a great way to identify the process which is emitting the logs. Similarly, the msgid, and structured-data is not used by logplex and the value `-` should be used. Finally, the msg is the section of the packet where the log message can be stored.

### Message conventions

You should format your log messages in a way that is optimized for both human
readability and machine parsability. With that in mind, log data should:

- Consist of a single message
- Use key-value pairs of the format `status=delivered`
- Use a `source` key-value pair in log lines for distinguishing machines or
  environments (example: `source=us-east measure#web.latency=4ms`).
- Show hierarchy with dots, from least to most specific, as in
  `measure#queue.backlog=`
- Units must immediately follow the number and must only include `a-zA-Z`
  (example: `10ms`).

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