---
title: Accessing Application Logs from an Add-on
slug: accessing-app-logs
url: https://devcenter.heroku.com/articles/accessing-app-logs
description: How to get access to application logs as an Add-on Provider
---

Add-on services can access an app's log data.  If you're building an add-on service that requires this access, you can create a [log drain](https://devcenter.heroku.com/articles/logging) on behalf of the app and receive the log data.

To set it up, you first need to request it through the manifest.

## Add-on manifest

The manifest will need to tell Heroku that your add-on requires permission to set up the syslog drain. This is done by adding `syslog_drain` to the list if permissions in the `requires` property:

``` json
{ "id": "myaddon",
  "api": { ... }
  "requires" : ["syslog_drain"]
}
```

## Provisioning call

When the add-on is provisioned, Heroku's systems will generate a unique log token for that app/add-on instance combo. Add-on Providers should use this to identify logs sent to the drain.

The provisioning call will contain the log token. Storing the token is recommended for providers, but not necessary as it's possible use another mechanism to separate traffic such as unique port+IP combinations per Heroku user/app. The content of our POST to the /heroku/resources endpoint looks like:

``` json
{ "heroku_id": "app123@heroku.com", 
  "plan": "basic", 
  "callback_url":"https://api.heroku.com/vendor/resources/123",
  "syslog_token": "XXYYZZ1234fff" }
```

and the response would be:

``` json
{ "id": 456, 
  "config": { ... },
  "syslog_drain_url": "syslog://1.1.1.1:67890/",
  "message": "your message here"
}
```

Heroku will then create the drain.

## IP Whitelist API

The final piece of configuration is to whitelist Heroku's Logplex IPs for incoming syslog traffic. Simply send HTTP GET request to `https://api.heroku.com/vendor/logplex/whitelist` using basic auth with your provider API credentials. The call returns a JSON array of IP addresses to whitelist:

``` json
 [
   "184.73.5.216",
   "50.16.41.187",
   "50.19.0.98",
   "50.19.146.67",
   "184.72.174.202",
   "50.16.56.45",
   "50.16.160.94",
   "50.17.56.172"
  ]
```

When an app provisions an add-on successfully, the user will be able to see the drain created on behalf of the add-on in the log drain list.

``` term
$ heroku drains
syslog://two.example.org:584
-----------------------------
[Dummy Addon]
```
