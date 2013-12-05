---
title: Process Types and the Procfile
slug: procfile
url: https://devcenter.heroku.com/articles/procfile
description: A Procfile is a list of process types in an app. Each process type declares a command that is executed when a dyno of that process type is started.
---

Procfile is a mechanism for declaring what commands are run by your application's dynos on the Heroku platform.  It follows the [process model](process-model).  You can use a Procfile to declare various process types, such as multiple types of workers, a singleton process like a [clock](scheduled-jobs-custom-clock-processes), or a consumer of the Twitter streaming API.

## Process types as templates

A Procfile is a text file named `Procfile` placed in the root of your application, that lists the process types in an application.  Each process type is a declaration of a command that is executed when a dyno of that process type is started.

All the language and frameworks on the [Cedar](cedar) stack declare a `web` process type, which starts the application server.  [Rails 3](rails3) has the following process type:

```
web: bundle exec rails server -p $PORT
```

[Clojure](clojure)'s `web` process type looks something like this:

```
web: lein run -m demo.web $PORT
```

> callout
> You can reference other environment variables populated by Heroku, most usefully the $PORT variable, in the command.

A Maven-generated batch file executing the [Tomcat](create-a-java-web-application-using-embedded-tomcat) Java application server:

```
web: sh target/bin/webapp
```

For many apps, these defaults will be sufficient.  For more sophisticated apps, and to adhere to the recommended approach of more explicitly declaring of your application's required runtime processes, you may wish to define your process types.  For example, Rails applications are supplied with an additional process type of this sort:

```
worker:  bundle exec rake jobs:work
```

## Declaring process types

Process types are declared via a file named `Procfile` placed in the root of your app.  Its format is one process type per line, with each line containing:

```
<process type>: <command>
```

The syntax is defined as:

* *&lt;process type&gt;* -- an alphanumeric string, is a name for your command, such as `web`, `worker`, `urgentworker`, `clock`, etc. 
* *&lt;command&gt;* -- a command line to launch the process, such as `rake jobs:work`.

> note
> The `web` process type is special as it's the only process type that will receive HTTP traffic from Heroku's routers.  Other process types can be named arbitrarily.

## Developing locally with Foreman

It's important when developing and debugging an application that the local development environment is executed in the same manner as the remote environments. This ensures that incompatibilities and hard to find bugs are caught before deploying to production and treats the application as a holistic unit instead of a series of individual commands working independently.

[Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html) is a command-line tool for running `Procfile`-backed apps.  It's installed automatically by the [Heroku Toolbelt](https://toolbelt.heroku.com).

If you had a Procfile with both `web` and `worker` process types, Foreman will start one of each process type, with the output interleaved on your terminal:

Run your app locally with Foreman:

```term
$ foreman start
18:06:23 web.1     | started with pid 47219
18:06:23 worker.1  | started with pid 47220
18:06:25 worker.1  | (in /Users/adam/myapp)
18:06:27 web.1     | => Awesome web application server output
```

> callout
> Your web process loads on port 5000 because this is what Foreman provides as a default in the `$PORT` env var.  It's important that your web process respect this value, since it's used by the Heroku platform when you deploy.

You can now test the app locally.  Press Ctrl-C when done to shut it down.

## Setting local environment variables

[Config vars](config-vars) saved in the `.env` file of a project directory will be added to the environment when run by Foreman. For example we can set the `RACK_ENV` to development in your environment. 

```term
$ echo "RACK_ENV=development" >>.env
$ foreman run irb
> puts ENV["RACK_ENV"]
> development
```

Do not commit the `.env` file to source control--it should only be used for local configuration.


## Deploying to Heroku

A `Procfile` is not necessary to deploy apps written in most languages supported by Heroku.  The platform automatically detects the language, and creates a default `web` process type to boot the application server.  

Creating an explicit `Procfile` is recommended for greater control and flexibility over your app.

For Heroku to use your Procfile, add the `Procfile` to the root of your application, then push to Heroku:

```term
$ git add .
$ git commit -m "Procfile"
$ git push heroku
...
-----> Procfile declares process types: web, worker
       Compiled slug size is 10.4MB
-----> Launching... done
       http://strong-stone-297.herokuapp.com deployed to Heroku

To git@heroku.com:strong-stone-297.git
 * [new branch]      master -> master
```

Use `heroku ps` to determine the number of dynos that are executing.  The list indicates the process type in the left column, and the command corresponding to that process type in the right column:

```term
$ heroku ps
=== web: `bundle exec rails server -p $PORT`
web.1: up for 2m
```

Use `heroku logs` to view an aggregated list of log messages from all dynos across all process types.

```term
$ heroku logs
2011-04-26T01:24:20-07:00 heroku[slugc]: Slug compilation finished
2011-04-26T01:24:22+00:00 heroku[web.1]: Running process with command: `bundle exec rails server mongrel -p 46999`
2011-04-25T18:24:22-07:00 heroku[web.1]: State changed from created to starting
2011-04-25T18:24:29-07:00 heroku[web.1]: State changed from starting to up
2011-04-26T01:24:29+00:00 app[web.1]: => Booting Mongrel
2011-04-26T01:24:29+00:00 app[web.1]: => Rails 3.0.5 application starting in production on http://0.0.0.0:46999
2011-04-26T01:24:29+00:00 app[web.1]: => Call with -d to detach
2011-04-26T01:24:29+00:00 app[web.1]: => Ctrl-C to shutdown server
```

## Scaling a process type

Heroku runs one `web` dyno for you automatically, but other process types don't start by default.  To launch a worker, you need to scale it up to one dyno:

```term
$ heroku ps:scale worker=1
Scaling worker processes... done, now running 1
```

You can also scale the [size of a dyno](https://devcenter.heroku.com/articles/dyno-size):

```term
$ heroku ps:resize worker=2X
Resizing dynos and restarting specified processes... done
worker dynos now 2X ($0.10/dyno-hour)
```

Check `ps` to see the new process type running, for example:

```term
$ heroku ps
=== web: `bundle exec rails server -p $PORT`
web.1: up for 2m

=== worker: `env QUEUE=* bundle exec rake resque:work`
worker.1: up for 5s
```

Use `heroku logs --ps worker` to view just the messages from the worker process type:

```term
$ heroku logs --ps worker
2011-04-25T18:33:25-07:00 heroku[worker.1]: State changed from created to starting
2011-04-26T01:33:26+00:00 heroku[worker.1]: Running process with command: `env QUEUE=* bundle exec rake resque:work`
2011-04-25T18:33:29-07:00 heroku[worker.1]: State changed from starting to up
2011-04-26T01:33:29+00:00 app[worker.1]: (in /app)
```

The output we see here matches our local output from Foreman, interleaved with system messages from Heroku's system components such as the router and dyno manager.

You can scale up higher with the same command.  For example, two web dynos and four worker dynos:

```term
$ heroku ps:scale web=2 worker=4
Scaling web processes... done, now running 2
Scaling worker processes... done, now running 4

$ heroku ps
=== web: `bundle exec rails server -p $PORT`
web.1: up for 7m
web.2: up for 2s

=== worker: `env QUEUE=* bundle exec rake resque:work`
worker.1: up for 7m
worker.2: up for 3s
worker.3: up for 2s
worker.4: up for 3s
```

[Read more about scaling.](scaling)

## More process type examples

The `Procfile` model of running processes types is extremely flexible.  You can run any number of dynos with whatever arbitrary commands you want, and scale each independently.

For example, using Ruby you could run two types of queue workers, each consuming different queues:

```
worker:        env QUEUE=* bundle exec rake resque:work
urgentworker:  env QUEUE=urgent bundle exec rake resque:work
```

These can then be scaled independently.

```term
$ heroku ps:scale worker=1 urgentworker=5
```

## Further reading

* [Applying the Unix Process Model to Web Apps](http://adam.heroku.com/past/2011/5/9/applying_the_unix_process_model_to_web_apps/)
* [Introducing Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html)
* [Foreman man page](http://ddollar.github.com/foreman/)