---
title: Scaling Dynos and Workers on Bamboo
slug: scaling-aspen-bamboo
url: https://devcenter.heroku.com/articles/scaling-aspen-bamboo
description: Scale web dynos and background worker dynos on Heroku Bamboo with `heroku ps:scale`.
---

<div class="deprecated" markdown="1">
This article applies to apps on the [Bamboo](bamboo) stack.  For the most recent stack, [Cedar](cedar), see [Scaling Your Dyno Formation on Heroku Cedar](scaling).</div>

<div class="callout" markdown="1">
The [Cedar](cedar) stack is not limited to hard-coded process types and allows for a fully customizable [process model](process-model).
</div>

On the Bamboo stack there are two types of dynos available. Web dynos are responsible for running the web application processes that receive and respond to HTTP traffic whereas worker dynos run [background jobs with Delayed Job](delayed-job).

## Scaling web dynos

Use the `heroku ps:scale` command to scale web dynos on Bamboo.

    :::term
    $ heroku ps:scale dynos=1
    my-app now running 1 dynos

The CLI accepts either an absolute quantity or an increment from the current number of dynos.

    :::term
    $ heroku ps:scale dynos+2
    my-app now running 3 dynos

Decrements are also recognized.

    :::term
    $ heroku ps:scale dynos-1
    my-app now running 2 dynos

## Scaling worker dynos

`heroku ps:scale` command also scales background workers in the same fashion as dynos, accepting either absolute quantities or increment/decrements.

    :::term
    $ heroku ps:scale workers=2
    my-app now running 2 workers

    $ heroku ps:scale workers-1
    my-app now running 1 workers

## Introspection

The current number, types and state of dynos running is always available with the `heroku ps` command.

    :::term
    $ heroku ps
    === web: `bundle exec thin start -p $PORT -e production`
    web.1: idle for 1628h
    web.2: up for 4m

    === worker: `bundle exec rake jobs:work`
    worker.1: crashed for 1m

## Scaling via the web UI

Though scaling via the CLI is preferred it is also possible to scale dynos and workers on the web interface. [Login to Heroku](http://www.heroku.com/login) and view the resources for the application in question. The URL will look something like: `https://api.heroku.com/myapps/my-app/resources`.

<div class="callout" markdown="1">
Applications can scale beyond 24 dynos by using the CLI.
</div>

Use the two vertical sliders to adjust the web and worker dynos up to the UI-limit of 24.

![Heroku scaling sliders](https://dl.dropbox.com/u/674401/devcenter/Screen%20shot%202012-03-13%20at%202.38.42%20PM.png)