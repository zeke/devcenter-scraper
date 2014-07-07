---
title: Getting Started with Scala on Heroku
slug: getting-started-with-scala
url: https://devcenter.heroku.com/articles/getting-started-with-scala
description: Creating, configuring and deploying Scala applications on Heroku, using sbt dependency management.
---

This quickstart will get you going with Scala and the [Finagle](http://github.com/twitter/finagle) web library, deployed to Heroku.

## Prerequisites

* Basic knowledge of [Scala](http://scala-lang.org) and [sbt](http://www.scala-sbt.org/). 
* Your application must be compatible with a [supported SBT version](scala-support#build-behavior).
* Your application must run on the [OpenJDK](http://openjdk.java.net/) version 6.
* A Heroku user account.  [Signup is free and instant.](https://signup.heroku.com/signup/dc)

## Local workstation setup

First, install the Heroku Toolbelt on your local workstation.  

<a class="toolbelt" href="https://toolbelt.heroku.com/">Install the Heroku Toolbelt</a>

This ensures that you have access to the [Heroku command-line client](/categories/command-line), Foreman, and the Git revision control system.

Once installed, you can use the `heroku` command from your command shell.  Log in using the email address and password you used when creating your Heroku account:

    :::term
    $ heroku login
    Enter your Heroku credentials.
    Email: adam@example.com
    Password: 
    Could not find an existing public key.
    Would you like to generate one? [Yn] 
    Generating new SSH public key.
    Uploading ssh public key /Users/adam/.ssh/id_rsa.pub

Press enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on. For more information about keys, see [Managing Your SSH Keys](keys). 

## Write your app

You may be starting from an existing app. If not, here’s a simple “hello, world” sourcefile you can use:

### src/main/scala/Web.scala

    :::scala
    import org.jboss.netty.handler.codec.http.{HttpRequest, HttpResponse}
    import com.twitter.finagle.builder.ServerBuilder
    import com.twitter.finagle.http.{Http, Response}
    import com.twitter.finagle.Service
    import com.twitter.util.Future
    import java.net.InetSocketAddress
    import util.Properties

    object Web {
      def main(args: Array[String]) {
        val port = Properties.envOrElse("PORT", "8080").toInt
        println("Starting on port:"+port)
        ServerBuilder()
          .codec(Http())
          .name("hello-server")
          .bindTo(new InetSocketAddress(port))
          .build(new Hello)
        println("Started.")
      }
    }

    class Hello extends Service[HttpRequest, HttpResponse] {
      def apply(req: HttpRequest): Future[HttpResponse] = {
        val response = Response()
        response.setStatusCode(200)
        response.setContentString("Hello World")
        Future(response)
      }
    }

## Declare dependencies with sbt

Heroku recognizes an app as Scala by the existence of `project/build.properties`.

### project/build.properties

    :::scala
    sbt.version=0.12.0

You can use [light](https://github.com/harrah/xsbt/wiki/Basic-Configuration) or [full](https://github.com/harrah/xsbt/wiki/Full-Configuration) build configurations with sbt.  We'll use a light configuration, declaring dependencies `build.sbt` in the root directory:

### build.sbt

    :::scala
    import com.typesafe.sbt.SbtStartScript
    
    seq(StartScriptPlugin.startScriptForClassesSettings: _*)

    name := "hello"
    
    version := "1.0"
    
    scalaVersion := "2.9.2"
    
    resolvers += "twitter-repo" at "http://maven.twttr.com"
    
    libraryDependencies ++= Seq("com.twitter" % "finagle-core" % "1.9.0", "com.twitter" % "finagle-http" % "1.9.0")

## Add the start script plugin

At deploy time, Heroku runs `sbt compile stage` to build your Scala app.  [Typesafe](http://typesafe.com/)'s [`sbt-start-script`](https://github.com/sbt/sbt-start-script) adds a `stage` task to sbt that generates start scripts for your application.

To use the plugin, create this file:

#### project/build.sbt

    :::scala
    resolvers += Classpaths.typesafeResolver

    addSbtPlugin("com.typesafe.sbt" %% "sbt-start-script" % "0.10.0")

The `stage` task, by convention, performs any tasks needed to prepare an app to be run in-place. Other plugins that use a different approach to prepare an app to run could define `stage` as well.

## Optionally Choose a JDK
By default, OpenJDK 1.6 is installed with your app. However, you can choose to use a newer JDK by specifying `java.runtime.version=1.7` in the [`system.properties`](add-java-version-to-an-existing-maven-app) file in the root of your project.

Here's what a `system.properties` file looks like:

    :::term
    java.runtime.version=1.7

You can specify 1.6, 1.7, or 1.8 (1.8 is in beta) for Java 6, 7, or 8 (with lambdas), respectively.

## Build your app

Build your app locally:

    :::term
    $ sbt compile stage
    ...
    [info] Compiling 1 Scala source to .../target/scala-2.9.2/classes...
    [success] Total time: 5 s, completed Sep 5, 2012 12:42:56 PM
    [info] Wrote start script for mainClass := Some(Web) to .../target/start
    [success] Total time: 0 s, completed Sep 5, 2012 12:42:56 PM

## Declare process types with Procfile

Use a [Procfile](procfile), a text file in the root directory of your application, to explicitly declare what command should be executed to start a web [dyno](dynos). In this case, you need to execute the `Web` main method.

The `sbt-start-script` we added above generates a start script in `target/start`.  This simple shell script sets the `CLASSPATH` and executes the main method for the object you specify.  Invoke it from your Procfile:

### Procfile

    web: target/start Web

This declares a single process type, `web`, and the command needed to run it.  The name "web" is important here.  It declares that this process type will be attached to the [HTTP routing](http-routing) stack of Heroku, and receive web traffic when deployed.

You can now start your application locally using [Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html) (installed as part of the Toolbelt):

    :::term
    $ foreman start
    11:53:15 web.1     | started with pid 2281
    11:53:15 web.1     | Starting on port:5000
    11:53:15 web.1     | Started.

Your app will come up on port 5000. Test that it’s working with `curl` or a web browser, then Ctrl-C to exit.

## Store your app in Git

Prevent build artifacts from going into revision control by creating a `.gitignore` file:

### .gitignore

    target
    project/boot
    project/target
    project/plugins/target


We now have the three major components of our app: dependencies in `build.sbt`, process types in `Procfile`, and our application source in `src/main/Web.scala`. Let’s put it into Git:

    :::term
    $ git init
    $ git add .
    $ git commit -m "init"

## Deploy your application to Heroku

Create the app:

    :::term
    $ heroku create
    Creating warm-frost-1289... done, stack is cedar
    http://warm-frost-1289.herokuapp.com/ | git@heroku.com:warm-frost-1289.git
    Git remote heroku added

Deploy your code:

    :::term
    $ git push heroku master
    Counting objects: 14, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (9/9), done.
    Writing objects: 100% (14/14), 1.51 KiB, done.
    Total 14 (delta 1), reused 0 (delta 0)

    -----> Heroku receiving push
    -----> Scala app detected
    -----> Building app with sbt
    -----> Running: sbt compile stage
           Getting net.java.dev.jna jna 3.2.3 ...
           ...
           [info] Compiling 1 Scala source to /tmp/build_1otpp7ujqznr3/target/scala-2.9.2/classes...
           [success] Total time: 1 s, completed Sep 5, 2012 7:26:27 PM
           [info] Wrote start script for mainClass := Some(Web) to /tmp/build_1otpp7ujqznr3/target/start
           [success] Total time: 0 s, completed Sep 5, 2012 7:26:27 PM
    -----> Discovering process types
           Procfile declares types -> web
    -----> Compiled slug size is 43.1MB
    -----> Launching... done, v3
           http://warm-frost-1289.herokuapp.com deployed to Heroku

    To git@heroku.com:warm-frost-1289.git
     * [new branch]      master -> master

## Visit your application

You've deployed your code to Heroku, and specified the process types in a `Procfile`.  You can now instruct Heroku to execute a process type.  Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.

Let's ensure we have one dyno running the `web` process type:

    :::term
    $ heroku ps:scale web=1

You can check the state of the app's dynos.  The `heroku ps` command lists the running dynos of your application:

    :::term
    $ heroku ps
    === web: `target/start Web`
    web.1: up for 5s

Here, one dyno is running.

We can now visit the app in our browser with `heroku open`.

    :::term
    $ heroku open
    Opening warm-frost-1289... done

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
    2011-08-18T00:13:41+00:00 heroku[web.1]: Starting process with command `target/start Web `
    2011-08-18T00:14:18+00:00 app[web.1]: Starting on port:28328
    2011-08-18T00:14:18+00:00 app[web.1]: Started.
    2011-08-18T00:14:19+00:00 heroku[web.1]: State changed from starting to up


## Console

Heroku allows you to run [one-off dynos](one-off-dynos) - scripts and applications that only need to be executed when needed - using the `heroku run` command.   Use this to launch a REPL process attached to your local terminal for experimenting in your app's environment:

    :::term
    $ heroku run sbt console
    Running sbt console attached to terminal... up, run.1
    [info] Loading global plugins from /app/.sbt_home/.sbt/plugins
    [info] Updating {file:/app/.sbt_home/.sbt/plugins/}default-0f55ac...
    ...
    [info] Done updating.
    [info] Compiling 1 Scala source to /app/.sbt_home/.sbt/plugins/target/scala-2.9.2/sbt-0.12/classes...
    [info] Loading project definition from /app/project
    [info] Updating {file:/app/project/}default-525df6...
    ...
    [info] Done updating.
    [info] Set current project to hello (in build file:/app/)
    [info] Updating {file:/app/}default-0c35ee...
    [info] Done updating.
    [info] Compiling 1 Scala source to /app/target/scala-2.9.2/classes...
    [info] Starting scala interpreter...
    [info] 
    Welcome to Scala version 2.9.2 (OpenJDK 64-Bit Server VM, Java 1.6.0_20)
    Type in expressions to have them evaluated.
    Type :help for more information.

    scala> 

The console has your application code available. For example:

    scala> Web.main(Array())
    Starting on port:33418
    Started.

## One-off dynos

You can run any of your app's objects in a one-off dyno attached to a terminal, as long as the `main` method exists on that object.  For example:

### src/main/scala/Demo.scala

    :::scala
    object Demo {
      def main(args:Array[String]){
        println("Hello From Demo")
      }
    }

Commit and deploy:

    :::term
    $ git add src/main/scala/Demo.scala
    $ git commit -m "demo class"
    $ git push heroku master

And run the one-off process:

    :::term
    $ heroku run 'target/start Demo'
    Running target/start Demo attached to terminal... up, run.1
    Hello From Demo

## Troubleshooting

sbt has been under rapid development during the past year, and major releases are not compatible with each other.  Most issues will be related to mismatched versions of sbt.

* If you already have sbt 0.7.x or sbt 0.10.x installed as a script on your path called `sbt`, you should rename that script to something like `sbt7` or `sbt10`.
* If you attempt to build this project with sbt 0.7.x you will see project creation prompts. If you see these prompts, quit sbt, and make sure your `sbt` script launches sbt 0.11.0 or later.
* If you attempt to build this project with sbt 0.10.x you will get an error due to unresolved dependencies, `org.scala-tools.sbt#sbt_2.9.2;0.11.0: not found`. If you see this error, make sure your `sbt` script launches sbt 0.11.0 or later. 

## Next steps

- Visit the [Scala category](/categories/scala) to learn more about developing and deploying Scala applications.
* [Scaling Out with Scala and Akka on Heroku](scaling-out-with-scala-and-akka) looks at using Akka with Scala.
* [Heroku Scala Support](scala-support) provides the reference documentation for Heroku's Scala support.
* Read [How Heroku Works](how-heroku-works) for a technical overview of the concepts you’ll encounter while writing, configuring, deploying and running applications. 