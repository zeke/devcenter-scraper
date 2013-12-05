---
title: Contribute a Dev Center Article
slug: open-topics
url: https://devcenter.heroku.com/articles/open-topics
description: Community contributions for topics central to architecting and developing robust applications on Heroku are welcome.
---

The Dev Center is a widely-referenced source for both Heroku platform as well as modern web application development documentation. External contributions for topics central to architecting and developing robust applications on Heroku are encouraged.

<div class="note" markdown="1">
If you're interested in contributing a topic not listed below, please [let us know](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20Custom%20topic). Well-written articles addressing the tenets of modern web application development are welcome, especially when based on your experiences deploying to Heroku.
</div>

## Ruby application servers

There are many app servers available for Ruby applications including Thin, Unicorn etc… Create an article that details the pros and cons of each in an unbiased fashion and in a context specific to Heroku and demonstrates proper configuration of each.

* *Ruby*: Choosing a Ruby Application Server ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Choosing%20a%20Ruby%20Application%20Server"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

* *JRuby*: Using Puma on JRuby ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Using%20Puma%20on%20JRuby"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

## Uploading files to S3

[Uploading files to S3](s3) (or some other persistent file storage) is a necessity given the ephemeral nature of truly elastic applications. Several articles are needed to extend the [existing article](s3) and clearly demonstrate this process using both the direct and pass-through upload methods.

* *Language-agnostic*: Direct File Uploads to S3<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Direct%20File%20Uploads%20to%20S3"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Ruby*: Uploading Files to S3 in Ruby with Carrierwave<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Uploading%20Files%20to%20S3%20in%20Ruby%20with%20Carrierwave"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Node.js*: Uploading Files to S3 in Node.js ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Uploading%20Files%20to%20S3%20in%20Node"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

## Background jobs and queueing

[Background jobs and queueing](background-jobs-queueing) is an established pattern for deferring long-running work -- moving it from the user's request/response lifecycle to a seperate out-of-process worker. Language/framework specific articles are needed to extend the [existing article](background-jobs-queueing) and clearly demonstrate the implementation of this pattern on Heroku.

* *Scala*: Background Jobs and Queuing in Scala<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Background%20Jobs%20and%20Queuing%20in%20Scala"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Node.js*: Background Jobs and Queuing in Node.js<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Background%20Jobs%20and%20Queuing%20in%20Node.js"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

## Scheduled jobs and custom clock processes

[Custom clock processes](scheduled-jobs-custom-clock-processes) are specialized process types that manage the execution schedule of time and interval-based work. Language/framework specific articles are needed to extend the [existing article](scheduled-jobs-custom-clock-processes) and clearly demonstrate the implementation of this pattern on Heroku.

* *Node.js*: Scheduled Jobs and Custom Clock Processes in Node.js<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Scheduled%20Jobs%20and%20Custom%20Clock%20Processes%20in%20Node.js"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.)) 
* *Scala*: Scheduled Jobs and Custom Clock Processes in Scala<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Scheduled%20Jobs%20and%20Custom%20Clock%20Processes%20in%20Scala"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Clojure*: Scheduled Jobs and Custom Clock Processes in Clojure<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Scheduled%20Jobs%20and%20Custom%20Clock%20Processes%20in%20Clojure"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.)) 

## HTTP cache headers

Properly implementing [HTTP Cache Headers](increasing-application-performance-with-http-cache-headers) is a fundamental aspect of developing responsive web apps. Several articles are needed to extend the existing article and demonstrate appropriate http caching strategies in each primary language and framework.

* *Node.js*: HTTP Caching in Node.js<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"HTTP%20Caching%20in%20Node.js"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Python*: HTTP Caching in Python<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"HTTP%20Caching%20in%20Python"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Scala*: HTTP Caching in Scala<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"HTTP%20Caching%20in%20Scala"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Clojure*: HTTP Caching in Clojure<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"HTTP%20Caching%20in%20Clojure"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

## AWS Cloudfront

[AWS Cloudfront](http://aws.amazon.com/cloudfront/) has the ability to front dynamic content, making it an accessible and language-agnostic asset cache and CDN. Detail how to setup Cloudfront and the proper DNS settings for origin apps on Heroku.

* *High-level*: AWS Cloudfront as an Asset Host and Content Delivery Network ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"AWS%20Cloudfront%20as%20an%20Asset%20Host%20and%20Host0Content%20Delivery%20Network"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

## Benefits

Contributing an article to the Dev Center is a rewarding experience that puts the author’s ideas and work in front of a large and diverse group of technologists. New articles are broadcast via the [@HerokuDevCenter](https://twitter.com/#!/herokudevcenter) Twitter account and the monthly Heroku newsletter.

All externally contributed articles are attributed in a way that highlights both the author and their organization.

![Attributed article banner](https://s3.amazonaws.com/assets.heroku.com/devcenter/contribution-guide/attribution-header.png)

The Heroku Dev Center is the resource for Heroku’s massive developer audience across the most popular languages and frameworks. High-quality articles often become the canonical resource for their subject matter due to the wide reach and social nature of the Heroku community.

Authors retain full visibility and ownership of their articles after publishing. Regular automated updates are sent detailing the reach and popularity of their articles along with realtime user feedback.

![Article updates](https://dl.dropbox.com/u/674401/devcenter/Screen%20Shot%202012-07-02%20at%2011.29.02%20AM.png)

Any questions about the contribution process can be directed to the [Dev Center team](mailto:devcenter-feedback@heroku.com).

<!--
## Process

Upon indicating your interest in a particular topic a Dev Center editor will send you more detailed information around the vision for the article, an article outline and other supporting material, and what you can expect when authoring Dev Center content.

Indicate your interest in contributing one of the [open topics](#open_topics) by clicking on the associated `let us know if you'd like to contribute this article` link.


* Debugging
  * *Ruby*: Debugging Ruby Applications with ???<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com))
  * *Java*: Debugging Java Applications with ???<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com))


Additionally, language/framework specific articles are needed for each officially supported language on Heroku showing how to properly set the relevant HTTP headers in a way consistent with the idioms of the language/framework.

* *Ruby*: Setting HTTP Cache Headers in Ruby on Rails<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Setting%20HTTP%20Cache%20Headers%20in%20Ruby%20on%20Rails"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Java*: Setting HTTP Cache Headers in Java with SpringMVC<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Setting%20HTTP%20Cache%20Headers%20in%20Java%20with%20SpringMVC"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Scala*: Setting HTTP Cache Headers in Scala<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Setting%20HTTP%20Cache%20Headers%20in%20Scala"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Clojure*: Setting HTTP Cache Headers in Clojure<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Setting%20HTTP%20Cache%20Headers%20in%20Clojure"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Python*: Setting HTTP Cache Headers in Python with Django<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Setting%20HTTP%20Cache%20Headers%20in%20Python"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))
* *Node.js*: Setting HTTP Cache Headers in Node.js<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Setting%20HTTP%20Cache%20Headers%20in%20Node.js"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Background%20Jobs%20and%20Queuing%20in%20Ruby%20with%20Resque"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

 ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Increasing%20Application%20Performance%20with%20HTTP%20Cache%20Headers"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

<br/> ([let us know if you'd like to contribute this article](mailto:devcenter-feedback@heroku.com?subject=Contribution%20interest:%20"Uploading%20Files%20to%20S3%20in%20Node.js"&body=Please%20indicate%20your%20interest,%20and%20competence,%20in%20the%20topic%20along%20with%20a%20links%20to%20examples%20of%20your%20writing.))

* SSL

## Notes

* How represent parent-child relationship
* How represent predicate articles (HTTP Cache Headers b/f Cloudfront)
* Need to flesh out article outline better, TOC etc...
* When set expectations (ref apps, ownership, feedback)
* Add contribute links in high-level parent articles

-->