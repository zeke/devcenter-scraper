---
title: Recovering an Offline Application
slug: application-offline
url: https://devcenter.heroku.com/articles/application-offline
description: Detailed steps to determine why your application is unavailable and what actions to take to resolve the issue.
---

Your application may be experiencing downtime for a number of reasons.
This article will help you discover why and what you can do to remedy
the problem.

## Check your application logs

The first step is to check your [application's logs][logging]. Many
common application errors as well as Heroku's errors are printed to your
applications logs. To view your logs, run:

    :::term
    $ heroku logs

Note that many frameworks, including Ruby on Rails, will serve a default
error page for your application when there are errors. You can compare
this to [Heroku's error page][errorpage] which is used when one of
[Heroku's error codes][errorcodes] is the cause of the issue.

If your logs show one of Heroku's error codes, you should investigate
the cause of this issue. Our [descriptions of these errors][errorcodes]
is the best place to start.

## Restart your application

If the problem is not immediately present, it can also be helpful to
restart your application, [tail your logs][logging], and then try
viewing your application in a web browser.

    :::term
    $ heroku restart
    $ heroku logs --tail

Some application issues are solved by restart. For example, your
application may need to be restarted after a schema change to your
database, or if [recent Heroku maintenance][status] affected your
application.

## Test using curl

<p class="callout" markdown="1">If you do not have curl on your
computer, you can use [http://hurl.it/](http://hurl.it) to run curl from
your web browser.</p>

A number of issues can be detected using curl:

    :::term
    $ curl -v http://example.herokuapp.com/

<p class="note" markdown="1">Testing your `herokuapp.com` hostname in addition to
your custom domains will help determine if the issue is specific to your
custom domain or your application.</p>

Some common issues you may discover are:

* An HTTP 500 error code indicates an error returned by your
  application. Check your Heroku logs for more details.

* An HTTP 503 error code indicates a Heroku error code. Check your logs for
  the error code you received and reference our [Heroku error code
  documentation][errorcodes] for further information.

* DNS errors (`could not resolve host`) should be resolved by correctly
  [setting up your custom domain][customdomains] for use on Heroku. Note
  that [alternate instructions apply if you are using SSL][ssl].

* Certificate errors, or other errors relating to using SSL, should
  refer to our [SSL documentation][ssl].

## Check application health

Heroku provides several additional tools to check the health of your application.

* Use `heroku ps` to check the current status of your dynos. You can
  adjust your [dyno formation][scale] using `heroku scale`.

* Check `heroku releases` for recent changes made to your application.
  You can [rollback to an older release][releases] if necessary.

* A monitoring add-on like [New Relic][] is an excellent way of keeping
  an eye on your application's health. A large change in requests
  recieved or response time may indicate that you need to [scale
  your application][scale] or [migrate to a larger database][cache size].

## Review advice for production applications

Your application may be affected by an issue that would best be mitigated
by modifying how your Heroku application is running on the
platform. [Production Check][production check] is a great tool for ensuring that
your app is ready to run on the platform in production.

## Check platform status

An active or recent incident could cause your application to be
unavailable or unstable. You should check [Heroku's status site][status]
to see if your application is affected.

## Ask for help

If you are still unable to determine why your application is down,
get in touch with us via our [support channels][].

[status]: https://status.heroku.com/
[errorcodes]: https://devcenter.heroku.com/articles/error-codes
[customdomains]: https://devcenter.heroku.com/articles/custom-domains
[ssl]: https://devcenter.heroku.com/articles/ssl-endpoint
[errorpage]: http://s3.amazonaws.com/heroku_pages/error.html
[support channels]: https://devcenter.heroku.com/articles/support-channels
[logging]: https://devcenter.heroku.com/articles/logging
[scale]: https://devcenter.heroku.com/articles/scaling
[New Relic]: https://devcenter.heroku.com/articles/newrelic
[migrate data]: https://devcenter.heroku.com/articles/migrating-data-between-plans
[cache size]: https://devcenter.heroku.com/articles/cache-size
[production check]: https://devcenter.heroku.com/articles/production-check
[releases]: https://devcenter.heroku.com/articles/releases
