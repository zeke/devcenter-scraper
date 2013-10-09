---
title: Erosion-resistance
slug: erosion-resistance
url: https://devcenter.heroku.com/articles/erosion-resistance
description: Heroku is built to be erosion-resistant. The dyno manager keeps dynos running, and ops teams keep the underlying operating system kernel up-to-date.
---

Software-as-a-service apps deployed in traditional server-based environments require ongoing maintenance to keep them running, whether or not the app is under active development.  The Heroku platform is erosion-resistant.

Erosion is a problem for apps
-------------------------

Anyone who has built an application, set it up to run on a server somewhere, and come back months later to discover it down is familiar with this problem.  Forces of entropy that affect every running application include:

* Operating system upgrades, kernel patches, and infrastructure software (e.g. Apache, MySQL, ssh, OpenSSL) updates to fix security vulnerabilities.
* The server's disk filling up with logfiles.
* One or more of the app's processes crashing or getting stuck, requiring someone to log in and restart them.
* Failure of the underlying hardware causing one or more entire servers to go down, taking the application with it.

The effect of these and other such forces is often known as "bit rot" or "[software erosion](http://en.wikipedia.org/wiki/Software_erosion)".

Heroku is erosion-resistant
---------------------------

In contrast to traditional server-based environments, the Heroku platform is built to be **erosion-resistant**.

The [dyno manager](dynos#the-dyno-manager) keeps your app's [dyno formation](scaling#dyno-formation) running without any manual intervention.  It restarts crashed dynos automatically, and moves your dynos to new locations automatically and instantly whenever a failure in the underlying hardware occurs.

Heroku's ops team keeps the underlying operating system kernel and other components up-to-date with the latest security patches.  This is handled without any impact to running dynos except for a restart, which happens automatically and silently behind the scenes.

Databases running on [Heroku's PostgreSQL service](http://devcenter.heroku.com/articles/heroku-postgresql) are fully managed and monitored.  Hardware failures are handled completely by the Heroku PostgreSQL team and require no intervention from the app owner.