---
title: Specifying a Python Runtime
slug: python-runtimes
url: https://devcenter.heroku.com/articles/python-runtimes
description: Specifying a particular version of Python via your app's runtime.txt.
---

This document describes the general behavior of the [Heroku Cedar stack](cedar) as it relates to the recognition and execution of Python applications. For framework specific tutorials please see:

* [Getting Started with Python on Heroku](getting-started-with-python)
* [Getting Started with Django on Heroku](getting-started-with-django)

## Activation

The Heroku Python Support will be applied to applications only when the application has a `requirements.txt` in the root directory. Even if an application has no module dependencies, it should include an empty `requirements.txt` to document that your app has no dependencies.


## Supported Python runtimes

Heroku's Python support extends to the latest stable release from the Python 2.x and Python 3.x series.

Today, this is support extends to these specific runtimes:

- `python-2.7.8`
- `python-3.4.1`

### Selecting a runtime

Newly created Python applications default to the Python 2.7.8 runtime.

You can specify an arbitrary version of Python to be used to run your application. This functionality is enabled by the presence of a `runtime.txt` file.

```term
$ cat runtime.txt
python-3.4.1
```

If you specify a different Python runtime than a previous build, your application's build cache will be purged.  

### Available runtimes

A number of additional, unsupported runtimes are available. However, we only endorse and support the use of Python 2.7.8 and 3.4.1.

- `pypy-1.9`
- `python-2.4.6`
- `python-2.5.5`
- `python-2.6.9`
- `python-3.1.5`
- `python-3.2.5`
- `python-3.3.3`


## Libraries

The following libraries are used by the platform for managing and running Python applications and cannot be specified.

* Setuptools 3.6: Python packaging tools.
* Pip 1.5.6: Application dependency resolution.

If your application does declare these dependencies in `requirements.txt`, unexpected behavior may occur. 


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