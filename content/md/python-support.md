---
title: Heroku Python Support
slug: python-support
url: https://devcenter.heroku.com/articles/python-support
description: Reference documentation describing the the support for Python on Heroku's Cedar stack.
---

This document describes the general behavior of the [Heroku Cedar stack](cedar) as it relates to the recognition and execution of Python applications. For framework specific tutorials please see:

* [Getting Started with Python on Heroku](getting-started-with-python)
* [Getting Started with Django on Heroku](getting-started-with-django)

## Activation

The Heroku Python Support will be applied to applications only when the application has a `requirements.txt` in the root directory. Even if an application has no module dependencies, it should include an empty `requirements.txt` to document that your app has no dependencies.


## Supported Python Runtimes

Newly created Python applications default to the Python 2.7.8 runtime.

You can specify an arbitrary version of Python to be used to run your application. This functionality is enabled by the presence of a `runtime.txt` file.

```term
$ cat runtime.txt
python-2.7.8
```

### Supported Runtimes

- `python-2.7.8`
- `python-3.4.1`

### Unsupported Runtimes

Unsupported runtimes can also be specified (2.4.4–3.4.1). However, we only endorse and support the use of Python 2.7.8 and 3.4.1.

### Changing runtimes

If you specify a different Python runtime than a previous build, your application's build cache will be purged.  


## Libraries

The following libraries are used by the platform for managing and running Python applications and cannot be specified.

* Setuptools 3.6: Python packaging tools.
* Pip 1.5.6: Application dependency resolution.


## Build behavior

The following command is run on your app to resolve dependencies:

```term
$ pip install -r requirements.txt --allow-all-external
```

The `.heroku` directory is cached between pushes to speed up package installation.

# Python applications

Pure Python applications, such as headless processes and evented web frameworks like Twisted, are fully supported on Cedar.

## Activation

When a deployed application is recognized as a pure Python application, Heroku responds with `-----> Python app detected`.

```term
$ git push heroku master
-----> Python app detected
```

## Add-ons

No add-ons are automatically provisioned if a pure Python application is detected.
If you need a SQL database for your app, add one explicitly:

```term
$ heroku addons:add heroku-postgresql:dev
```

## Process types

No default `web` process types created if a Python application is detected.

# Django applications

All versions of Django are fully supported on Cedar. Django applications are detected by the presence of a `manage.py` file within the repository.

## Add-ons

A dev database add-on is provisioned automatically for Django applications.  This  populates the `DATABASE_URL` environment variable.