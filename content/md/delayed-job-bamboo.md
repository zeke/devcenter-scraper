---
title: Running Delayed Job Workers on Bamboo
slug: delayed-job-bamboo
url: https://devcenter.heroku.com/articles/delayed-job-bamboo
description: How to run Delayed Job workers in applications running on the Bamboo Heroku stack.
---

>warning
>This article applies to apps on the [Bamboo](bamboo) stack.  For the most recent stack, [Cedar](cedar), see [Delayed Job](delayed-job).

Delayed Job, also known as DJ, is a queueing system for Rails.    Please reference the [Delayed Job](delayed-job) documentation on Dev Center to learn how to configure Delayed Job, enqueue jobs, and build workers.

Running Workers
-----------------

These instructions apply to the [Bamboo](bamboo) stack only.

Once your app uses DJ, you can start workers locally, or on a traditional host,
using `rake jobs:work`.  On Heroku's Bamboo stack, start your worker process via the `heroku
workers` command:

```term
$ cd myapp
$ heroku scale workers=1
myapp is now running 1 worker
```

You can verify that the DJ process started without error by inspecting the
logs:

```term
$ heroku logs
2011-05-31T15:58:43+00:00 app[dj.1]: (in /app)
2011-05-31T15:58:43+00:00 app[dj.1]: *** Starting job worker host:runtime.51985 pid:2476
```

Managing Workers
-----------------

>callout
>To shut down all worker processes, set workers to zero: `heroku scale workers=0`

Heroku will run and manage the number of worker processes you specify, and
you'll be billed to a prorated second, exactly like dynos.  You can increase or decrease
your workers as needed:

```term
$ heroku scale workers=3
myapp is now running 3 workers
$ heroku scale workers=2
myapp is now running 2 workers
```    
   
