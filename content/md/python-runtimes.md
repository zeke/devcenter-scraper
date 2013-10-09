---
title: Specifying a Python Runtime
slug: python-runtimes
url: https://devcenter.heroku.com/articles/python-runtimes
description: Specifying a particular version of Python via your app's runtime.txt.
---

<div class="note" markdown="1">
If you have questions about Python on Heroku, consider discussing it in the [Python on Heroku forums](https://discussion.heroku.com/category/python). Both Heroku and community-based Python experts are available.
</div>

When you push a Python application to Heroku, Python 2.7.4 will be used by default:

    -----> No runtime.txt provided; assuming python-2.7.4.
    -----> Preparing Python runtime (python-2.7.4)
    -----> Installing Distribute (0.6.36)
    -----> Installing Pip (1.3.1)
    -----> Installing dependencies using Pip (1.3.1)


## Specifying a specific runtime

You can specify an arbitrary version of Python to be used to run your application. This functionality is enabled by the presence of a `runtime.txt` file.

    :::term
    $ cat runtime.txt
    python-3.3.2

When you commit and push to Heroku you'll see that Python 3.3.2 is detected:

    -----> Heroku receiving push
    -----> Python app detected
    -----> Preparing Python runtime (python-3.3.2)
    -----> Installing Distribute (0.6.36)
    -----> Installing Pip (1.3.1)
    -----> Installing dependencies using Pip (1.3.1)
    ...

## Supported runtimes

Supported runtimes include:

- python-2.7.4
- python-3.3.2
- pypy-1.9 (experimental)

Unsupported runtimes can also be specified (2.4.4–3.3.2). However, we only endorse and support the use of Python 2.7.4 and 3.3.2.



## Changing runtimes

If you specify a different Python runtime than a previous build, your application's build cache will be purged. 