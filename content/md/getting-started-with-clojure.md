---
title: Getting Started with Clojure on Heroku
slug: getting-started-with-clojure
url: https://devcenter.heroku.com/articles/getting-started-with-clojure
description: Creating, configuring, deploying and scaling Clojure applications on Heroku.
---

This quickstart will get you going with [Clojure](http://clojure.org/)
and the [Ring](https://github.com/ring-clojure/ring#readme) web library,
deployed to Heroku. For general information on how to develop and architect apps for use on Heroku, see [Architecting Applications for Heroku](https://devcenter.heroku.com/articles/architecting-apps).

Prerequisites
-------------

* Basic Clojure knowledge, including an installed version of [Leiningen](https://github.com/technomancy/leiningen#readme) and a JVM.
* Your application must use [Leiningen](http://leiningen.org). This article assumes the use of Leiningen 2.x, but 1.x is [also available](clojure-support).
* Your application must run on the [OpenJDK](http://openjdk.java.net/) [version 6 or 7](customizing-the-jdk).
* A Heroku user account.  [Signup is free and instant](https://api.heroku.com/signup/devcenter).

## Local workstation setup

Install the [Heroku Toolbelt](https://toolbelt.heroku.com/) on your local workstation.  This ensures that you have access to the [Heroku command-line client](/categories/command-line), Foreman, and the Git revision control system.

Once installed, you'll have access to the `heroku` command from your
shell. Log in using the email address and password you used when
creating your Heroku account:

    :::term
    $ heroku login
    Enter your Heroku credentials.
    Email: adam@example.com
    Password (typing will be hidden):
    Could not find an existing public key.
    Would you like to generate one? [Yn] 
    Generating new SSH public key.
    Uploading ssh public key /Users/adam/.ssh/id_rsa.pub

Press enter at the prompt to upload your existing `ssh` key or create
a new one, used for pushing code later on.

Write your app
--------------

You may be starting from an existing app. If not, here's a simple
"hello, world" source file you can use:

### src/hello/world.clj

    :::clojure
    (ns hello.world
      (:require [ring.adapter.jetty :as jetty]))
    
    (defn app [req]
      {:status 200
       :headers {"Content-Type" "text/plain"}
       :body "Hello, world"})
    
    (defn -main [port]
      (jetty/run-jetty app {:port (Integer. port) :join? false}))

You can also run `lein new heroku helloworld` to generate a project
skeleton that has
[some extra convenience features](https://github.com/technomancy/lein-heroku/tree/master/lein-template)
useful for Heroku development.

Declare dependencies in `project.clj`
-------------------------------

Heroku recognizes an app as Clojure by the existence of a `project.clj` file.

Here's an example `project.clj` for the Clojure/Ring app we created above:

### project.clj

    :::clojure
    (defproject helloworld "0.0.1"
      :dependencies [[org.clojure/clojure "1.5.1"]
                     [ring/ring-jetty-adapter "1.1.6"]]
      :uberjar-name "helloworld-standalone.jar"
      :min-lein-version "2.0.0")

Prevent build artifacts from going into revision control by creating this file:

### .gitignore

    :::term
    /target
    /pom.xml
    /.lein-*
    /.env

Projects that depend on dependencies that aren't available in public
repositories can deploy them to private repositories. The easiest way
to do this is using a private S3 bucket with the
[s3-wagon-private](https://github.com/technomancy/s3-wagon-private)
Leiningen plugin.

Declare process types with Procfile
-------------------------------------

Use a [Procfile](procfile), a text file in the root directory of your application, to explicitly declare what command should be executed to start a web [dyno](dynos). In this case, you need to execute the single Clojure namespace. 

Here's a `Procfile` for the sample app we've been working on:

    :::term
    web: java $JVM_OPTS -cp target/helloworld-standalone.jar clojure.main -m hello.world $PORT

This declares a single process type, `web`, and the command needed to run it.  The name "web" is important here.  It declares that this process type will be attached to the [HTTP routing](http-routing) stack of Heroku, and receive web traffic when deployed.

You can run your app locally with `lein run -m hello.world 5000` for a
quick check, or you can launch the server from a repl for interactive
development:

    :::term
    $ lein repl
    [...]
    user=> (require 'hello.world)
    nil
    user=> (hello.world/-main 5000)
    2013-07-01 13:52:49.575:INFO:oejs.Server:jetty-7.6.1.v20120215
    2013-07-01 13:52:49.627:INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:5000
    #<Server org.eclipse.jetty.server.Server@2f26f304>

Your app will come up on port 5000, and you can hit it with `curl` or a web browser.

Store your app in Git
---------------------

We now have the three major components of our app: dependencies in
`project.clj`, process types in `Procfile`, and our application source
in `src/hello/world.clj`. Let's put it into Git:

    :::term
    $ git init
    $ git add .
    $ git commit -m init

Deploy your application to Heroku
---------------

Create the app:

    :::term
    $ heroku apps:create
    Creating glowing-snow-27... done
    Created http://glowing-snow-27.herokuapp.com/ | git@heroku.com:glowing-snow-27.git
    Git remote heroku added

Deploy your code:

    :::term
    $ git push heroku master
    Counting objects: 7, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (4/4), done.
    Writing objects: 100% (7/7), 710 bytes, done.
    Total 7 (delta 0), reused 0 (delta 0)

    -----> Heroku receiving push
    -----> Clojure (Leiningen 2) app detected
    -----> Installing OpenJDK 1.6...done
    -----> Installing Leiningen
           Downloading: leiningen-2.2.0-standalone.jar
           Writing: lein script
    -----> Building with Leiningen
           Running: lein uberjar
           Retrieving org/clojure/clojure/1.5.1/clojure-1.5.1.pom from
               from http://s3pository.herokuapp.com/clojure/
           [...]
           Created /tmp/build_1y7nbplmlxu87/target/helloworld.jar
    -----> Discovering process types
           Procfile declares types -> web
    -----> Compiled slug size: 51.4MB
    -----> Launching... done, v1
           http://glowing-snow-27.herokuapp.com deployed to Heroku

    To git@heroku.com:glowing-snow-27.git
     * [new branch]      master -> master


## Visit your application

You've deployed your code to Heroku, and specified the process types in a `Procfile`.  You can now instruct Heroku to execute a process type.  Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.

Let's ensure we have one dyno running the `web` process type:

    :::term
    $ heroku ps:scale web=1

You can check the state of the app's dynos.  The `heroku ps` command lists the running dynos of your application:

    :::term
    $ heroku ps
    === web: `java $JVM_OPTS -cp target/helloworld-standalone.jar clojure.main -m hello.world $PORT`
    web.1: up for 5s

Here, one dyno is running.

We can now visit the app in our browser with `heroku open`.

    :::term
    $ heroku open
    Opening glowing-snow-27... done


## Dyno sleeping and scaling 

Having only a single web dyno running will result in the dyno [going to sleep](dynos#dyno-sleeping) after one hour of inactivity.  This causes a delay of a few seconds for the first request upon waking. Subsequent requests will perform normally.

To avoid this, you can scale to more than one web dyno.  For example:

    :::term
    $ heroku ps:scale web=2

For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dyno-hours-per-app).  Running your app at 2 dynos would exceed this free, monthly allowance, so let's scale back:

    :::term
    $ heroku ps:scale web=1


## View the logs

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all the dynos running the components of your application.  Heroku’s [Logplex](logplex) provides a single channel for all of these events. 

View information about your running app using one of the [logging commands](logging), `heroku logs`:

    :::term
    $ heroku logs
    2011-03-16T03:28:32-07:00 heroku[web.1]: Running process with command: `java $JVM_OPTS -cp target/helloworld-standalone.jar clojure.main -m hello.world $PORT
    2011-03-16T03:28:37-07:00 app[web.1]: 2011-03-16 10:28:37.181:INFO::Logging to STDERR via org.mortbay.log.StdErrLog
    2011-03-16T03:28:37-07:00 app[web.1]: 2011-03-16 10:28:37.182:INFO::jetty-6.1.26
    2011-03-16T03:28:40-07:00 app[web.1]: 2011-03-16 10:28:40.223:INFO::Started SocketConnector@0.0.0.0:20184
    2011-03-16T03:28:40-07:00 heroku[web.1]: State changed from starting to up


Console
-------

Heroku allows you to run [one-off proceses](oneoff-admin-ps) - scripts and applications that only need to be executed when needed - using the `heroku run` command.   Use this to launch a REPL process attached to your local terminal for experimenting in your app's environment:

<div class="callout" markdown="1">Running `heroku run lein repl` uses
a simplified version of the `repl` task provided by Leiningen.</div>
    
    :::term
    $ heroku run lein repl
    Running lein repl attached to terminal... up, run.1
    Downloading Leiningen to .lein/leiningen-2.2.0-standalone.jar now...
    [...]
    Clojure 1.5.1
    user=> 

Since Leiningen is not included in your slug for size reasons, it's
downloaded on-demand here. The repl has your app's namespaces
available. For example:

    :::term
    user=> (require 'hello.world)
    nil
    user=> (hello.world/app {})
    {:status 200, :headers {"Content-Type" "text/plain"}, :body "Hello, world"}

For more details about using a REPL on Heroku, see the
[live debugging Clojure apps](debugging-clojure) article.

One-off scripts
---------------

You can run a one-off Clojure script attached to the terminal in the
same way, as long as the script exists in your deployed app. Try
making a small script that prints to the console and exits:

### src/hello/hi.clj

    :::clojure
    (ns hello.hi)

    (defn -main [& args]
      (println "Hello there"))

Commit and deploy this new code:

    :::term
    $ git add src/hello/hi.clj
    $ git commit -m hi
    $ git push heroku master

Run the script in a [one-off dyno](oneoff-admin-ps) with `heroku run`:

    :::term
    $ heroku run lein run -m hello.hi
    Running lein run -m hello.hi attached to terminal... up, run.2
    Hello there

Using a SQL database
--------------------

By default, Clojure apps aren't provisioned a database. This is
because you might want to use a NoSQL database like Redis or CouchDB,
or (as in the case of our sample app above) you don't need any
database at all.

If you do need a SQL database for your app, request one explicitly:

    :::term
    $ heroku addons:add heroku-postgresql:dev

Next steps
---------------

* Visit the [Clojure category](/categories/clojure) to learn more about developing and deploying Clojure applications.
* Extend the app by reading [Building a Database-Backed Clojure Web Application](clojure-web-application)
* Read the technical aspects of [Heroku's Clojure support](clojure-support)
* Learn to debug in [Live-Debugging Remote Clojure apps with Drawbridge](debugging-clojure)
* Read [How Heroku Works](how-heroku-works) for a technical overview of the concepts you’ll encounter while writing, configuring, deploying and running applications.