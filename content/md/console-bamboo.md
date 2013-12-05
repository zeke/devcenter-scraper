---
title: Console Sessions on Bamboo
slug: console-bamboo
url: https://devcenter.heroku.com/articles/console-bamboo
description: The Heroku console feature of the Bamboo stack allows you to run remote console and rake commands from the command line.
---

> warning
> This article applies to apps on the [Bamboo](bamboo) stack.  For the most recent stack, [Cedar](cedar), see [one-off admin dynos](oneoff-admin-ps).

You can run console sessions on Bamboo apps using [one-off dynos](oneoff-admin-ps) via `heroku run`. For example:

```term
$ heroku run -a my-app ruby script/rails console
Running `script/rails console` attached to terminal... up, run.1
irb(main):001:0>
```

The appropriate command for your app will depend on what framework you use. Common console commands for Bamboo include `script/rails console` for Rails apps, `script/console` for older Rails versions, and `irb` for general Ruby apps.
