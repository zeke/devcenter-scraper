---
title: Erosion-resistance
slug: erosion-resistance
url: https://devcenter.heroku.com/articles/erosion-resistance
description: Heroku is built to be erosion-resistant. The dyno manager keeps dynos running, and ops teams keep the underlying operating system kernel up-to-date.
---

Software-as-a-service apps deployed in traditional server-based environments require ongoing maintenance to keep them running, whether or not the app is under active development.  The Heroku platform is erosion-resistant.

## Erosion is a problem for apps

Anyone who has built an application, set it up to run on a server somewhere, and come back months later to discover it down is familiar with this problem.  Forces of entropy that affect every running application include:

* Operating system upgrades, kernel patches, and infrastructure software (e.g. Apache, MySQL, ssh, OpenSSL) updates to fix security vulnerabilities.
* The server's disk filling up with logfiles.
* One or more of the app's processes crashing or getting stuck, requiring someone to log in and restart them.
* Failure of the underlying hardware causing one or more entire servers to go down, taking the application with it.

The effect of these and other such forces is often known as "bit rot" or "[software erosion](http://en.wikipedia.org/wiki/Software_erosion)".

## Heroku is erosion-resistant

In contrast to traditional server-based environments, the Heroku platform is built to be **erosion-resistant**.

The [dyno manager](dynos#the-dyno-manager) keeps your app's [dyno formation](scaling#dyno-formation) running without any manual intervention.  It restarts crashed dynos automatically, and moves your dynos to new locations automatically and instantly whenever a failure in the underlying hardware occurs.

Heroku's ops team keeps the underlying operating system kernel and other components up-to-date with the latest security patches.  This is handled without any impact to running dynos except for a restart, which happens automatically and silently behind the scenes.

Databases running on [Heroku's PostgreSQL service](http://devcenter.heroku.com/articles/heroku-postgresql) are fully managed and monitored.  Hardware failures are handled completely by the Heroku PostgreSQL team and require no intervention from the app owner. 

## Resistance, not elimination

Heroku's erosion resistance does not mean that your app will run forever. The forces of technology evolution will eventually require manual intervention by you if you want your app to continue running in a safe and stable manner. There are two main sources of change that will lead to manual intervention.

### Software stack lifecycle

The software stack that your app runs on will have its own lifecycle. The underlying operating system and language binaries are generally only supported for a limited time period by their respective governing bodies. 

For example, once a language runtime version becomes deprecated by the governing body, it typically will no longer receive security patches.  Applications will have to be  migrated to a newer version of the component to remain safe and stable.

Heroku keeps track of the software lifecycle for our supported stacks and language buildpacks, and we will notify you in advance of any changes you need to make. We will ensure that you have optimal migration options to the best of our abilities.

### Heroku service changes

Heroku's own services evolve [on a regular basis](https://devcenter.heroku.com/changelog). Sometimes Heroku introduces new services that will over time replace old services. In some cases, it will require customer intervention to move an application from an old to a new service. When Heroku makes these changes we notify customers well in advance, and do our best to make migration as seamless as possible.
 
