---
title: Getting Started with Python on Heroku
slug: getting-started-with-python
url: https://devcenter.heroku.com/articles/getting-started-with-python
description: Create, configure, deploy and scale a Python application on Heroku, using Pip to manage dependencies.
---

This quickstart will get you going with a [Python](http://python.org/) application that uses the
[Flask](http://flask.pocoo.org/) web framework, deployed to Heroku. For Django apps, please see the [Getting Started with Django on Heroku](django).  For general information on how to develop and architect apps for use on Heroku, see [Architecting Applications for Heroku](https://devcenter.heroku.com/articles/architecting-apps).

<div class="note" markdown="1">
If you have questions about Python on Heroku, consider discussing it in the [Python on Heroku forums](https://discussion.heroku.com/category/python). Both Heroku and community-based Python experts are available.
</div>

## Prerequisites


* Basic Python knowledge.
* Installed [Python](http://python.org/) and [Virtualenv](http://pypi.python.org/pypi/virtualenv). See [this guide](http://install.python-guide.org/) for guidance.
* Your application must use Pip to resolve dependencies.
* A Heroku user account.  [Signup is free and instant.](https://api.heroku.com/signup/devcenter)

## Local workstation setup

First, install the [Heroku Toolbelt](https://toolbelt.heroku.com/) on your local workstation.  This ensures that you have access to the [Heroku command-line client](/categories/command-line), Foreman, and the Git revision control system.

Once installed, you can use the `heroku` command from your command shell.  Log in using the email address and password you used when creating your Heroku account:

    :::term
    $ heroku login
    Enter your Heroku credentials.
    Email: kenneth@example.com
    Password:
    Could not find an existing public key.
    Would you like to generate one? [Yn]
    Generating new SSH public key.
    Uploading ssh public key /Users/kenneth/.ssh/id_rsa.pub

Press enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on.

## Start Flask app inside a Virtualenv

First, we'll create an empty top-level directory for our project:

    :::term
    $ mkdir helloflask
    $ cd helloflask

Next, we'll create a Python [Virtualenv](http://pypi.python.org/pypi/virtualenv) (v0.7):

<div class="callout" markdown="1">Make sure you're using the latest virtualenv release. If you're using a version that comes with Ubuntu, you may need to add the `--no-site-packages` flag.</div>

    :::term
    $ virtualenv venv --distribute
    New python executable in venv/bin/python
    Installing distribute...............done.
    Installing pip...............done.

To use our new virtualenv, we need to activate it. (You must source the virtualenv environment for each terminal session where you wish to run your app.)

<div class="callout" markdown="1">Windows users can run `venv\Scripts\activate.bat` for the same effect.</div>

    :::term
    $ source venv/bin/activate

Next, install our application's dependencies with [pip](http://pypi.python.org/pypi/pip). In this case, we will be installing Flask, the web framework, and Gunicorn, the web server.

    :::term
    $ pip install Flask gunicorn
    Downloading/unpacking Flask
      Downloading Flask-0.9.tar.gz (481kB): 481kB downloaded
    Downloading/unpacking gunicorn
      Downloading gunicorn-0.17.2.tar.gz (360kB): 360kB downloaded
      Running setup.py egg_info for package gunicorn
    
    Downloading/unpacking Werkzeug>=0.7 (from Flask)
      Downloading Werkzeug-0.8.3.tar.gz (1.1MB): 1.1MB downloaded
    Downloading/unpacking Jinja2>=2.4 (from Flask)
      Downloading Jinja2-2.6.tar.gz (389kB): 389kB downloaded

    Installing collected packages: Flask, gunicorn, Werkzeug, Jinja2
      Running setup.py install for Flask
      Running setup.py install for gunicorn
      Running setup.py install for Werkzeug
      Running setup.py install for Jinja2
    
    Successfully installed Flask gunicorn Werkzeug Jinja2
    
### Hello World

Now that we have a clean Flask environment to work in, we'll create our simple application, `hello.py`:

#### hello.py

    :::python
    import os
    from flask import Flask

    app = Flask(__name__)

    @app.route('/')
    def hello():
        return 'Hello World!'


## Declare process types with Procfile

Use a [Procfile](procfile), a text file in the root directory of your application, to explicitly declare what command should be executed to start a web [dyno](dynos). In this case, you need to execute Gunicorn with a few arguments. 

Here's a `Procfile` for our new app. It should be called `Procfile` and live at the root directory of our project:

#### Procfile

    :::term
    web: gunicorn hello:app

You can now start the processes in your Procfile locally using [Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html) (installed as part of the Toolbelt):

    :::term
    $ foreman start
    2013-04-03 16:11:22 [8469] [INFO] Starting gunicorn 0.14.6
    2013-04-03 16:11:22 [8469] [INFO] Listening at: http://127.0.0.1:8000 (8469)

Make sure things are working properly `curl` or a web browser, then Ctrl-C to exit.

## Specify dependencies with Pip

Heroku recognizes Python applications by the existence of a `requirements.txt` file in the root of a repository. This simple format is used by most Python projects to specify the external Python modules the application requires.

Pip has a nice command (`pip freeze`) that will generate this file for us:

    :::term
    $ pip freeze > requirements.txt


#### requirements.txt

    Flask==0.9
    Jinja2==2.6
    Werkzeug==0.8.3
    gunicorn==0.17.2

Pip can also be used for advanced dependency management. See [Python Dependencies via Pip](/articles/python-pip) to learn more.


## Store your app in Git

Now that we've written and tested our application, we need to store the project in a [Git](http://git-scm.org/) repository.

Since our current directory contains a lof of extra files, we'll want to configure our repository to ignore these files with a `.gitignore` file:

<div class="callout" markdown="1">
    GitHub provides an excellent
    [Python gitignore file](https://github.com/github/gitignore/blob/master/Python.gitignore)
    that can be
    [installed system-wide](https://github.com/github/gitignore#readme).
</div>

### .gitignore

    venv
    *.pyc

Next, we'll create a new git repository and save our changes.

    :::term
    $ git init
    $ git add .
    $ git commit -m "init"

## Deploy your application to Heroku

The next step is to push the application's repository to Heroku. First, we have to get a place to push to from Heroku. We can do this with the `heroku create` command:

    :::term
    $ heroku create
    Creating stark-window-524... done, stack is cedar
    http://stark-window-524.herokuapp.com/ | git@heroku.com:stark-window-524.git
    Git remote heroku added

This automatically added the Heroku remote for our app (`git@heroku.com:stark-window-524.git`) to our repository. Now we can do a simple `git push` to deploy our application:

    :::term
    $ git push heroku master
    Counting objects: 10, done.
    Delta compression using up to 8 threads.
    Compressing objects: 100% (8/8), done.
    Writing objects: 100% (10/10), 3.59 KiB, done.
    Total 10 (delta 0), reused 0 (delta 0)

    -----> Heroku receiving push
    -----> Python app detected
    -----> No runtime.txt provided; assuming python-2.7.4.
    -----> Preparing Python runtime (python-2.7.4)
    -----> Installing Distribute (0.6.36)
    -----> Installing Pip (1.3.1)
    -----> Installing dependencies using Pip (1.3.1)
           ...
           Successfully installed Flask Werkzeug Jinja2 gunicorn
           Cleaning up...
    -----> Discovering process types
           Procfile declares types -> web
    -----> Compiled slug size is 3.5MB
    -----> Launching... done, v2
           http://stark-window-524.herokuapp.com deployed to Heroku

    To git@heroku.com:stark-window-524.git
     * [new branch]      master -> master

### Visit your application

You've deployed your code to Heroku, and specified the process types in a `Procfile`.  You can now instruct Heroku to execute a process type.  Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.

Let's ensure we have one dyno running the `web` process type:

    :::term
    $ heroku ps:scale web=1
    Scaling web processes... done, now running 1

You can check the state of the app's dynos.  The `heroku ps` command lists the running dynos of your application:

    :::term
    $ heroku ps
    === web: `gunicorn hello:app`
    web.1: up for 5s

Here, one dyno is running.

We can now visit the app in our browser with `heroku open`.

    :::term
    $ heroku open
    Opening stark-window-524... done

### Dyno sleeping and scaling 

Having only a single web dyno running will result in the dyno [going to sleep](dynos#dyno-sleeping) after one hour of inactivity.  This causes a delay of a few seconds for the first request upon waking. Subsequent requests will perform normally.

To avoid this, you can scale to more than one web dyno.  For example:

    :::term
    $ heroku ps:scale web=2

For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dyno-hours-per-app).  Running your app at 2 dynos would exceed this free monthly allowance, so let's scale back:

    :::term
    $ heroku ps:scale web=1

### View the logs

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all the dynos running the components of your application.  Heroku’s [Logplex](logplex) provides a single channel for all of these events. 

View information about your running app using one of the [logging commands](logging), `heroku logs`:

    :::term
    $ heroku logs
    2011-08-20T16:33:39+00:00 heroku[slugc]: Slug compilation started
    2011-08-20T16:34:07+00:00 heroku[api]: Config add PYTHONUNBUFFERED by kenneth@heroku.com
    2011-08-20T16:34:07+00:00 heroku[api]: Release v1 created by kenneth@heroku.com
    2011-08-20T16:34:07+00:00 heroku[api]: Deploy 67b7e54 by kenneth@heroku.com
    2011-08-20T16:34:07+00:00 heroku[api]: Release v2 created by kenneth@heroku.com
    2011-08-20T16:34:08+00:00 heroku[web.1]: State changed from created to starting
    2011-08-20T16:34:08+00:00 heroku[slugc]: Slug compilation finished
    2011-08-20T16:34:10+00:00 heroku[web.1]: Starting process with command `gunicorn hello:app`
    2011-08-20T16:34:10+00:00 app[web.1]:  * Running on http://0.0.0.0:17658/
    2011-08-20T16:34:11+00:00 heroku[web.1]: State changed from starting to up


### Interactive shell

Heroku allows you to run commands in a [one-off dyno](oneoff-admin-ps) - scripts and applications that only need to be executed when needed - using the `heroku run` command.   Use this to launch a Python shell attached to your local terminal for experimenting in your app's environment:

    :::term
    $ heroku run python
    Running python attached to terminal... up, run.1
    Python 2.7.4 (default, Apr  6 2013, 22:14:13)
    [GCC 4.4.3] on linux2
    Type "help", "copyright", "credits" or "license" for more information.
    >>> 

From here you can `import` some of your application modules.


### Running a worker

The `Procfile` format lets you run any number of different [process types](procfile).  For example, let's say you wanted a worker process to complement your web process:

#### Procfile

    web: gunicorn hello:app
    worker: python worker.py

<div class="callout" markdown="1">Running more than one dyno for an extended period may incur charges to your account.  Read more about [dyno-hour costs](usage-and-billing).</div>

Push this change to Heroku, then launch a worker:

    :::term
    $ heroku ps:scale worker=1
    Scaling worker processes... done, now running 1

Check `heroku ps` to see that your worker comes up, and `heroku logs` to see your worker doing its work.

## Next steps

- Visit the [Python category](/categories/python) to learn more about developing and deploying Python applications.
- Learn about [Python Dependencies via Pip](https://devcenter.heroku.com/articles/python-pip) and  [Specifying a Python Runtime](https://devcenter.heroku.com/articles/python-runtimes)
- Extend your app architecture with [Background Tasks in Python with RQ](https://devcenter.heroku.com/articles/python-rq)
- Learn how to [Get Started with Django on Heroku](https://devcenter.heroku.com/articles/django)
- Read [How Heroku Works](how-heroku-works) for a technical overview of the concepts you’ll encounter while writing, configuring, deploying and running applications.