---
title: Getting Started with Django on Heroku
slug: getting-started-with-django
url: https://devcenter.heroku.com/articles/getting-started-with-django
description: Developing and deploying a Python/Django application to Heroku.
---

This quickstart will get you going with a Python/Django application that uses a Postgres database, deployed to Heroku.  For other Python apps, see [Getting Started with Python on Heroku](python). For general information on how to develop and architect apps for use on Heroku, see [Architecting Applications for Heroku](https://devcenter.heroku.com/articles/architecting-apps).

<div class="note" markdown="1">
If you have questions about Python on Heroku, consider discussing it in the [Python on Heroku forums](https://discussion.heroku.com/category/python). Both Heroku and community-based Python experts are available.
</div>

## Prerequisites

* The Heroku toolbelt, as described in [Getting Started with Python](https://devcenter.heroku.com/articles/getting-started-with-python#local-workstation-setup).
* Installed [Python](http://python.org/) and [Virtualenv](http://pypi.python.org/pypi/virtualenv). See [this guide](http://install.python-guide.org/) for guidance.
* An installed version of [Postgres](http://www.postgresql.org/) to test locally.
* A Heroku user account.  [Signup is free and instant](https://api.heroku.com/signup/devcenter).

## Start a Django app inside a Virtualenv

First, we'll create an empty top-level directory for our project:

    :::term
    $ mkdir hellodjango && cd hellodjango

<div class="callout" markdown="1">Make sure you're using the latest virtualenv release. If you're using a version that comes with Ubuntu, you may need to add the `--no-site-packages` flag.</div>

Next, we'll create a Python [Virtualenv](http://pypi.python.org/pypi/virtualenv) (v0.7):

    :::term
    $ virtualenv venv --distribute
    New python executable in venv/bin/python
    Installing distribute...............done.
    Installing pip...............done.

To use the new virtualenv, we need to activate it. (You must source the virtualenv environment for each terminal session where you wish to run your app.)

<div class="callout" markdown="1">Windows users can run `venv\Scripts\activate.bat` for the same effect.</div>

    :::term
    $ source venv/bin/activate


Next, install our application's dependencies with [pip](http://pypi.python.org/pypi/pip). In this case, we will be installing **django-toolbelt**, which includes all of the packages we need:

 * Django (the web framework)
 * Gunicorn (WSGI server)
 * dj-database-url (a Django configuration helper)
 * dj-static (a Django static file server)

From your virtualenv:

    :::term
    $ pip install django-toolbelt
    Installing collected packages: Django, psycopg2, gunicorn, dj-database-url, dj-static, static
      ...
    Successfully installed Django psycopg2 gunicorn dj-database-url dj-static static
    Cleaning up...


Now that we have a clean Python environment to work in, we'll create our simple Django application.

<div class="callout" markdown="1">Don't forget the `.` at the end. This tells Django to put the extract the into the current directory, instead of putting it in a new subdirectory.</div>

    :::term
    $ django-admin.py startproject hellodjango .

## Declare process types with Procfile

Use a [Procfile](procfile), a text file in the root directory of your application, to explicitly declare what command should be executed to start a web [dyno](dynos). In this case, you need to execute Gunicorn with a few arguments. 

Here's a `Procfile` for our new app. It should be called `Procfile` and live at the root directory of our project:

#### Procfile

    :::term
    web: gunicorn hellodjango.wsgi

You can now start the processes in your Procfile locally using [Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html) (installed as part of the Toolbelt):

    :::term
    $ foreman start
    2013-04-03 16:11:22 [8469] [INFO] Starting gunicorn 0.17.2
    2013-04-03 16:11:22 [8469] [INFO] Listening at: http://127.0.0.1:8000 (8469)

Make sure things are working properly `curl` or a web browser, then Ctrl-C to exit.


## Specify dependencies with Pip

Heroku recognizes Python applications by the existence of a `requirements.txt` file in the root of a repository. This simple format is used by most Python projects to specify the external Python modules the application requires.

Pip has a nice command (`pip freeze`) that will generate this file for us:

    :::term
    $ pip freeze > requirements.txt

#### requirements.txt

    Django==1.5.1
    dj-database-url==0.2.1
    dj-static==0.0.5
    gunicorn==17.5
    psycopg2==2.5.1
    static==0.4

Pip can also be used for advanced dependency management. See [Python Dependencies via Pip](/articles/python-pip) to learn more.


## Django settings

Next, configure the application for the Heroku environment, including [Heroku's Postgres](heroku-postgresql) database. The [dj-database-url](https://crate.io/packages/dj-database-url/) module will parse the values of the `DATABASE_URL` [environment variable](/articles/config-vars) and convert them to something Django can understand.

Make sure 'dj-database-url' is in your requirements file, then add the following to the bottom of your `settings.py` file:

#### settings.py

    :::python
    # Parse database configuration from $DATABASE_URL
    import dj_database_url
    DATABASES['default'] =  dj_database_url.config()

    # Honor the 'X-Forwarded-Proto' header for request.is_secure()
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

    # Allow all host headers
    ALLOWED_HOSTS = ['*']

    # Static asset configuration
    import os
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    STATIC_ROOT = 'staticfiles'
    STATIC_URL = '/static/'

    STATICFILES_DIRS = (
        os.path.join(BASE_DIR, 'static'),
    )

With these settings available, you can add the following code to `wsgi.py` to serve static files in production:

#### wsgi.py

    :::python
    from django.core.wsgi import get_wsgi_application
    from dj_static import Cling
 
    application = Cling(get_wsgi_application())

## Store your app in Git

Now that we've written and tested our application, we need to store the project in a [Git](http://git-scm.org/) repository.

Since our current directory contains a lof of extra files, we'll want to configure our repository to ignore these files with a `.gitignore` file:

<div class="callout" markdown="1">
    GitHub provides an excellent
    [Python gitignore file](https://github.com/github/gitignore/blob/master/Python.gitignore)
    that can be
    [installed system-wide](https://github.com/github/gitignore#readme).
</div>

#### .gitignore

    venv
    *.pyc
    staticfiles

Next, we'll create a new git repository and save our changes.

    :::term
    $ git init
    Initialized empty Git repository in /Users/kreitz/hellodjango/.git/
    $ git add .
    $ git commit -m "my django app"
    [master (root-commit) 2943412] my django app
     7 files changed, 230 insertions(+)
     create mode 100644 .gitignore
     create mode 100644 Procfile
     create mode 100644 hellodjango/__init__.py
     create mode 100644 hellodjango/settings.py
     create mode 100644 hellodjango/urls.py
     create mode 100644 hellodjango/wsgi.py
     create mode 100644 manage.py
     create mode 100644 requirements.txt

## Deploy to Heroku

The next step is to push the application's repository to Heroku. First, we have to get a place to push to from Heroku. We can do this with the `heroku create` command:

    :::term
    $ heroku create
    Creating simple-spring-9999... done, stack is cedar
    http://simple-spring-9999.herokuapp.com/ | git@heroku.com:simple-spring-9999.git
    Git remote heroku added


This automatically added the Heroku remote for our app (`git@heroku.com:simple-spring-9999.git`) to our repository. Now we can do a simple `git push` to deploy our application:

    :::term
    $ git push heroku master
    Counting objects: 11, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (9/9), done.
    Writing objects: 100% (11/11), 4.01 KiB, done.
    Total 11 (delta 0), reused 0 (delta 0)
    -----> Python app detected
    -----> No runtime.txt provided; assuming python-2.7.4.
    -----> Preparing Python runtime (python-2.7.4)
    -----> Installing Distribute (0.6.36)
    -----> Installing Pip (1.3.1)
    -----> Installing dependencies using Pip (1.3.1)
           Downloading/unpacking Django==1.5 (from -r requirements.txt (line 1))
           ...
           Successfully installed Django psycopg2 gunicorn dj-database-url dj-static static
           Cleaning up...
    -----> Collecting static files
           0 static files copied.
    
    -----> Discovering process types
           Procfile declares types -> web

    -----> Compiled slug size is 29.5MB
    -----> Launching... done, v6
           http://simple-spring-9999.herokuapp.com deployed to Heroku

    To git@heroku.com:simple-spring-9999.git
    * [new branch]      master -> master


### Visit your application

You've deployed your code to Heroku, and specified the process types in a `Procfile`.  You can now instruct Heroku to execute a process type.  Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.

Let's ensure we have one dyno running the `web` process type:

    :::term
    $ heroku ps:scale web=1

You can check the state of the app's dynos.  The `heroku ps` command lists the running dynos of your application:

    :::term
    $ heroku ps
    === web: `gunicorn hellodjango.wsgi`
    web.1: up for 10s

Here, one dyno is running.

We can now visit the app in our browser with `heroku open`.

    :::term
    $ heroku open
    Opening simple-spring-9999.herokuapp.com... done

You should see the satisfying "It worked!" Django welcome page.

## Dyno sleeping and scaling 

Having only a single web dyno running will result in the dyno [going to sleep](dynos#dyno-sleeping) after one hour of inactivity.  This causes a delay of a few seconds for the first request upon waking. Subsequent requests will perform normally.

To avoid this, you can scale to more than one web dyno.  For example:

    :::term
    $ heroku ps:scale web=2

For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dyno-hours-per-app).  Running your app at 2 dynos would exceed this free, monthly allowance, so let's scale back:

    :::term
    $ heroku ps:scale web=1

### View the logs

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all the dynos running the components of your application.  Heroku’s [Logplex](logplex) provides a single channel for all of these events. 

View information about your running app using one of the [logging commands](logging), `heroku logs`:

    :::term
    $ heroku logs
    2012-04-06T19:38:25+00:00 heroku[web.1]: State changed from created to starting
    2012-04-06T19:38:29+00:00 heroku[web.1]: Starting process with command `gunicorn hellodjango.wsgi`
    2012-04-06T19:38:29+00:00 app[web.1]: Validating models...
    2012-04-06T19:38:29+00:00 app[web.1]:
    2012-04-06T19:38:29+00:00 app[web.1]: 0 errors found
    2012-04-06T19:38:29+00:00 app[web.1]: Django version 1.5, using settings 'hellodjango.settings'
    2012-04-06T19:38:29+00:00 app[web.1]: Development server is running at http://0.0.0.0:6566/
    2012-04-06T19:38:29+00:00 app[web.1]: Quit the server with CONTROL-C.
    2012-04-06T19:38:30+00:00 heroku[web.1]: State changed from starting to up
    2012-04-06T19:38:32+00:00 heroku[slugc]: Slug compilation finished


### Syncing the database

The `heroku run` command lets you run [one-off admin dynos](oneoff-admin-ps).  You can use this to sync the Django models with the database schema:

    :::term
    $ heroku run python manage.py syncdb
    Running python manage.py syncdb attached to terminal... up, run.1
    Creating tables ...
    Creating table auth_permission
    Creating table auth_group_permissions
    Creating table auth_group
    Creating table auth_user_groups
    Creating table auth_user_user_permissions
    Creating table auth_user
    Creating table django_content_type
    Creating table django_session
    Creating table django_site

    You just installed Django's auth system, which means you don't have any superusers defined.
    Would you like to create one now? (yes/no): yes
    Username (leave blank to use 'u53976'): kenneth
    Email address: kenneth@heroku.com
    Password: 
    Password (again): 
    Superuser created successfully.
    Installing custom SQL ...
    Installing indexes ...
    Installed 0 object(s) from 0 fixture(s)

### Using the Django shell

Similarly, you can use `heroku run` to get a Django shell for executing arbitrary code against your deployed app:

    :::term
    $ heroku run python manage.py shell
    Running python manage.py shell attached to terminal... up, run.1
    Python 2.7.4 (default, Apr  6 2013, 22:14:13)
    [GCC 4.4.3] on linux2
    Type "help", "copyright", "credits" or "license" for more information.
    (InteractiveConsole)
    >>> from django.contrib.auth.models import User
    >>> User.objects.all()
    [<User: kenneth>]


## Next steps

- Learn about [Django and Static Assets](/articles/django-assets) and automatic collectstatic running.
- Visit the [Python category](/categories/python) to learn more about developing and deploying Python applications.
- Learn about [Python Dependencies via Pip](https://devcenter.heroku.com/articles/python-pip) and  [Specifying a Python Runtime](https://devcenter.heroku.com/articles/python-runtimes)
- Extend your app architecture with [Background Tasks in Python with RQ](https://devcenter.heroku.com/articles/python-rq)
- Read [How Heroku Works](how-heroku-works) for a technical overview of the concepts you’ll encounter while writing, configuring, deploying and running applications.