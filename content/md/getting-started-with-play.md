---
title: Getting Started with Play! 1.x on Heroku
slug: getting-started-with-play
url: https://devcenter.heroku.com/articles/getting-started-with-play
description: Creating, configuring and deploying a Play applications on Heroku.
---

This quickstart will get you going with the [Play! 1.x Framework](http://playframework.org/), deployed to Heroku. For general information on how to develop and architect apps for use on Heroku, see [Architecting Applications for Heroku](https://devcenter.heroku.com/articles/architecting-apps).

> note
> If you have questions about Java on Heroku, consider discussing them in the [Java on Heroku forums](https://discussion.heroku.com/category/java).

## Prerequisites

* Basic Java knowledge, including an installed version of the JVM.
* An installation of [Play Framework](http://www.playframework.org/download) version 1.2.3 or later (make sure you have the `play` command on your path).
* Your application must run on the [OpenJDK](http://openjdk.java.net/) version 6.
* A Heroku user account.  [Signup is free and instant.](https://signup.heroku.com/signup/dc)

## Local workstation setup

First, install the Heroku Toolbelt on your local workstation.  

<a class="toolbelt" href="https://toolbelt.heroku.com/">Install the Heroku Toolbelt</a>

This ensures that you have access to the [Heroku command-line client](/categories/command-line), Foreman, and the Git revision control system.

Once installed, you can use the `heroku` command from your command shell.  Log in using the email address and password you used when creating your Heroku account:

```term
$ heroku login
Enter your Heroku credentials.
Email: adam@example.com
Password: 
Could not find an existing public key.
Would you like to generate one? [Yn] 
Generating new SSH public key.
Uploading ssh public key /Users/adam/.ssh/id_rsa.pub
```

Press enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on.

## Write your app
    
You can run any Play! application on Heroku. If you don't already have one, you can create a basic Play! application with:

```term
$ play new helloworld
~        _            _ 
~  _ __ | | __ _ _  _| |
~ | '_ \| |/ _' | || |_|
~ |  __/|_|\____|\__ (_)
~ |_|            |__/   
~
~ play! 1.2.4, http://www.playframework.org
~
~ The new application will be created in /Users/jjoergensen/dev/tmp/helloworld
~ What is the application name? [helloworld] 
~
~ OK, the application is created.
~ Start it with : play run helloworld
~ Have fun!
~
```

This creates a project called helloworld with a simple controller class `Application.java`:

### app/controllers/Application.java

```
package controllers;

import play.*;
import play.mvc.*;

import java.util.*;

import models.*;

public class Application extends Controller {

    public static void index() {
        render();
    }

}
```

## Declare dependencies

> callout
> Previous versions of the Play! framework allowed module dependency declaration in application.conf. This functionality has been deprecated. dependencies.yml should now be used.

Play dependencies are declared in `conf/dependencies.yml`. The first dependency is the framework itself. When the app is generated it will depend on any version of the framework: `- play`. It's a best practice to include the optional framework version after this: `- play 1.2.4`. This is also how Heroku will know which version of the framework you want instead of using the default.

Edit your `dependencies.yml` to look like this. Substitute `1.2.4` with the version of the framework you are using:

### dependencies.yml

```
# Application dependencies

require:
    - play 1.2.4
```

Prevent build artifacts from going into revision control by creating this file:

### .gitignore

```term
bin/
data/
db/
dist/
logs/
test-result/
lib/
tmp/
modules/
```

## Test locally

Simply type `play run` at your terminal and your application will start.

## Declare process types with Procfile

> callout
> Note: you can use your Procfile locally with Foreman, but it is not required. [Read more about Foreman and procfiles](procfile).

Use a [Procfile](procfile), a text file in the root directory of your application, to explicitly declare what command should be executed to start a web [dyno](dynos). In this case, you was to execute `play run`, ensuring it listens on a particular port.

Here's a `Procfile` for the sample app we've been working on:

```term
web:    play run --http.port=$PORT $PLAY_OPTS
```

This declares a single process type, `web`, and the command needed to run it.  The name "web" is important here.  It declares that this process type will be attached to the [HTTP routing](http-routing) stack of Heroku, and receive web traffic when deployed.

The `PLAY_OPTS` variable is used to set options that change from one environment to another.

## Optionally Choose a JDK
By default, OpenJDK 1.6 is installed with your app. However, you can choose to use a newer JDK by specifying `java.runtime.version=1.7` in the `system.properties` file.

Here's what a `system.properties` file looks like:

```term
java.runtime.version=1.7
```

You can specify 1.6, 1.7, or 1.8 (1.8 is in beta) for Java 6, 7, or 8 (with lambdas), respectively.

## Store your app in Git

We now have the three major components of our app: dependencies in `dependencies.yml`, process types in `Procfile`, and our application source in `app/controllers/Application.java`.  Let's put it into Git:

```term
$ git init
$ git add .
$ git commit -m "init"
```

## Deploy your application to Heroku

Create the app:

```term
$ heroku create
Creating afternoon-frost-273... done, stack is cedar
http://afternoon-frost-273.herokuapp.com/ | git@heroku.com:afternoon-frost-273.git
Git remote heroku added
```

Deploy your code:

```term
$ git push heroku master
Counting objects: 33, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (24/24), done.
Writing objects: 100% (33/33), 36.17 KiB, done.
Total 33 (delta 3), reused 0 (delta 0)

-----> Heroku receiving push
-----> play app detected
-----> Installing Play!..... done
-----> Building Play! application...
       ~        _            _ 
       ~  _ __ | | __ _ _  _| |
       ~ | '_ \| |/ _' | || |_|
       ~ |  __/|_|\____|\__ (_)
       ~ |_|            |__/   
       ~
       ~ play! 1.2.x-bfb715e, http://www.playframework.org
       ~
       1.2.x-bfb715e
       Resolving dependencies: .play/play dependencies ./ --forceCopy --sync --silent -Duser.home=/tmp/build_19mcxvj20b6cu 2>&1
       ~ Resolving dependencies using /tmp/build_19mcxvj20b6cu/conf/dependencies.yml,
       ~
       ~
       ~ No dependencies to install
       ~
       ~ Done!
       ~
       Precompiling: .play/play precompile ./ --silent 2>&1
       Listening for transport dt_socket at address: 8000
       22:50:04,601 INFO  ~ Starting /tmp/build_19mcxvj20b6cu
       22:50:05,265 INFO  ~ Precompiling ...
       22:50:08,635 INFO  ~ Done.

-----> Built 1 Play! configuration(s).
-----> Discovering process types
       Procfile declares types -> web
-----> Compiled slug size is 26.2MB
-----> Launching... done, v5
       http://afternoon-frost-273.herokuapp.com deployed to Heroku
```

## Visit your application

You've deployed your code to Heroku, and specified the process types in a `Procfile`.  You can now instruct Heroku to execute a process type.  Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.

Let's ensure we have one dyno running the `web` process type:

```term
$ heroku ps:scale web=1
```

You can check the state of the app's dynos.  The `heroku ps` command lists the running dynos of your application:

```term
$ heroku ps
=== web: `play run --http.port=$PORT $PLAY_O..`
web.1: up for 5s
```

Here, one dyno is running.

We can now visit the app in our browser with `heroku open`.

```term
$ heroku open
Opening afternoon-frost-273... done
```

Note that the web page rendered on Heroku is slightly different from what you saw on your local build. That's because Heroku executes play in production mode by default. Use the `$PLAY_OPTS` environment variable to control the mode for your local build. You can also change the mode used on Heroku by modifying the `PLAY_OPTS` config var for your application.

## Dyno sleeping and scaling 

Having only a single web dyno running will result in the dyno [going to sleep](dynos#dyno-sleeping) after one hour of inactivity.  This causes a delay of a few seconds for the first request upon waking. Subsequent requests will perform normally.

To avoid this, you can scale to more than one web dyno.  For example:

```term
$ heroku ps:scale web=2
```

For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dyno-hours-per-app).  Running your app at 2 dynos would exceed this free, monthly allowance, so let's scale back:

```term
$ heroku ps:scale web=1
```

## View the logs

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all the dynos running the components of your application.  Heroku’s [Logplex](logplex) provides a single channel for all of these events. 

View information about your running app using one of the [logging commands](logging), `heroku logs`:

```term
$ heroku logs
2011-08-20T22:50:14+00:00 heroku[web.1]: State changed from created to starting
2011-08-20T22:50:14+00:00 heroku[slugc]: Slug compilation finished
2011-08-20T22:50:16+00:00 heroku[web.1]: Starting process with command `play run --http.port=10800 --%prod -DusePrecompiled=true`
2011-08-20T22:50:16+00:00 app[web.1]: 22:50:16,953 INFO  ~ Starting /app
2011-08-20T22:50:17+00:00 app[web.1]: 22:50:17,011 INFO  ~ Precompiling ...
2011-08-20T22:50:21+00:00 app[web.1]: 22:50:21,448 WARN  ~ Defaults messsages file missing
2011-08-20T22:50:21+00:00 app[web.1]: 22:50:21,481 INFO  ~ Application 'helloworld' is now started !
2011-08-20T22:50:21+00:00 app[web.1]: 22:50:21,538 INFO  ~ Listening for HTTP on port 10800 ...
2011-08-20T22:50:22+00:00 heroku[web.1]: State changed from starting to up
```

## Next steps

* Extend the app by reading [Building a Database-backed Play! application for Heroku](database-driven-play-apps)
* Check out the technical aspects of [Heroku's Play support](play-support)
* See the [Play! Framework documentation and tutorials](http://www.playframework.org/documentation)
* Read [How Heroku Works](how-heroku-works) for a technical overview of the concepts you’ll encounter while writing, configuring, deploying and running applications. 