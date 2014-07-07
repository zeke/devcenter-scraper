---
title: Latency Considerations for Add-on Providers
slug: add-on-latency-considerations
url: https://devcenter.heroku.com/articles/add-on-latency-considerations
description: How to tell if you need to provision your cloud service in a specific geographic location
---

Heroku is available in multiple geographic [regions](regions).  As an add-on provider, your service may need to work under low-latency conditions, in which case it should be available in the same region as the app provisioning it.

## Latency

Cloud services intended to be consumed in realtime will need low-latency connections. These include:

* Databases such MySQL, CouchDB, or Casandra
* Cache stores such as Memcache
* Search services such as Websolr or Cloudquery        

On the other hand, many services can tolerate an extra few hundred milliseconds of latency. Usually these are asynchronous services. For example:

* Email sending services such as Sendgrid and Authsmtp
* Outbound message services such as Messagepub or Chatterous
* Monitoring services like New Relic, Exceptional, or Airbrake
* DNS management services such as Zerigo DNS

## Provisioning with latency

If your add-on service requires low latency then you should provision resources for Heroku apps within the same [region](regions) as specified in the provision request `region` attribute. 

If your add-on is latency sensitive and does not support that region, you should not provision the resource and instead [return an error](https://devcenter.heroku.com/articles/add-on-provider-api#exceptions).              

If normal internet latency is acceptable, you can run your service anywhere with a public hostname/IP. 