---
title: Heroku Python Support
slug: python-support
url: https://devcenter.heroku.com/articles/python-support
description: Reference documentation describing the the support for Python on Heroku's Cedar stack.
---

This document describes the general behavior of the [Heroku Cedar stack](cedar) as it relates to the recognition and execution of Python applications. For framework specific tutorials please see:

* [Getting Started with Python on Heroku/Cedar](http://devcenter.heroku.com/articles/python)
* [Getting Started with Django on Heroku/Cedar](http://devcenter.heroku.com/articles/django).

<div class="note" markdown="1">
If you have questions about Python on Heroku, consider discussing it in the [Python on Heroku forums](https://discussion.heroku.com/category/python). Both Heroku and community-based Python experts are available.
</div>

## General support

The following support is provided, irrespective of the type of Python application deployed.

### Activation

The Heroku Python Support will be applied to applications only when the application has a `requirements.txt` in the root directory. Even if an application has no module dependencies, it should include an empty `requirements.txt` to document that your app has no dependencies.


### Runtimes

By default, we run 64bit CPython 2.7.4.

Optionally, we support arbitrary versions of Python. This functionality is enabled by the presence of a `runtime.txt` file.

    :::term
    $ cat runtime.txt
    python-2.7.4
 
See [Specifying a Python Runtime](https://devcenter.heroku.com/articles/python-runtimes) for more details.

### Libraries

The following libraries are used by the platform for managing and running Python applications and cannot be specified.

* Distribute 0.6.36: Python packaging tools.
* Pip 1.3.1: Application dependency resolution.


### Build behavior

The following command is run on your app to resolve dependencies:

    :::term
    $ pip install --use-mirrors -r requirements.txt

The `.heroku` directory is cached between pushes to speed up package installation.

## Python applications

Pure Python applications, such as headless processes and evented web frameworks like Twisted, are fully supported on Cedar.

### Activation

When a deployed application is recognized as a pure Python application, Heroku responds with `-----> Python app detected`.

    :::term
    $ git push heroku master
    -----> Python app detected

### Add-ons

No add-ons are automatically provisioned if a pure Python application is detected.
If you need a SQL database for your app, add one explicitly:

    :::term
    $ heroku addons:add heroku-postgresql:dev

### Process types

No default `web` process types created if a Python application is detected.

## Django applications

All versions of Django are fully supported on Cedar. Django applications are detected by the presence of a `manage.py` file within the repository.

### Add-ons

A dev database add-on is provisioned automatically for Django applications.  This  populates the `DATABASE_URL` environment variable.