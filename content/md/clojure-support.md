---
title: Heroku Clojure Support
slug: clojure-support
url: https://devcenter.heroku.com/articles/clojure-support
description: Reference documentation describing the the support for Clojure on Heroku's Cedar stack.
---

The [Heroku Cedar stack](cedar) is capable of running a variety of
types of Clojure applications.

This document describes the general behavior of the Cedar stack as it
relates to the recognition and execution of Clojure applications. For
a more detailed explanation of how to deploy an application, see:

* [Getting Started with Clojure on Heroku/Cedar](http://devcenter.heroku.com/articles/clojure)
* [Building a Database-Backed Clojure Web Application](http://devcenter.heroku.com/articles/clojure-web-application).

## Activation

Heroku's Clojure support is applied only when the application has a
`project.clj` file in the root directory.

Clojure applications that use Maven can be deployed as well, but they
will be treated as Java applications, so
[different documentation](http://devcenter.heroku.com/articles/java)
will apply.

## Configuration

Leiningen 1.7.1 will be used by default, but if you have
`:min-lein-version "2.0.0"` in project.clj (highly recommended) then
the latest Leiningen 2.x release will be used instead.

Your `Procfile` should declare what process types which make up your
app. Often in development Leiningen projects are launched using `lein
run -m my.project.namespace`, but this is not recommended in
production because it leaves Leiningen running in addition to your
project's process. It also uses profiles that are intended for
development, which can let test libraries and test configuration sneak
into production.

### Uberjar

If your `project.clj` contains an `:uberjar-name` setting, then
`lein uberjar` will run during deploys. If you do this, your `Procfile`
entries should consist of just `java` invocations.

If your main namespace doesn't have a `:gen-class` then you can use
`clojure.main` as your entry point and indicate your app's main
namespace using the `-m` argument in your `Procfile`:

```
web: java $JVM_OPTS -cp target/myproject-standalone.jar clojure.main -m myproject.web
```

If you have custom settings you would like to only apply during build,
you can place them in an `:uberjar` profile. This can be useful to use
AOT-compiled classes in production but not during development where
they can cause reloading issues:

```clojure
:profiles {:uberjar {:main myproject.web, :aot :all}}
```

If you need Leiningen in a `heroku run` session, it will be downloaded
on-demand.

Note that if you use Leiningen features which affect runtime like
`:jvm-opts`, extraction of native dependencies, or `:java-agents`,
then you'll need to do a little extra work to ensure your Procfile's
`java` invocation includes these things. In these cases it might be
simpler to use Leiningen at runtime instead.

### Leiningen at Runtime

Instead of putting a direct `java` invocation into your Procfile, you
can have Leiningen handle launching your app. If you do this, be sure
to use the `trampoline` and `with-profile` tasks. Trampolining will
cause Leiningen to calculate the classpath and code to run for your
project, then exit and execute your project's JVM, while
`with-profile` will omit development profiles:

```
web: lein with-profile production trampoline run -m myapp.web
```

Including Leiningen in your slug will add about ten megabytes to its
size and will add a second or two of overhead to your app's boot time.

### Overriding build behavior

If neither of these options get you quite what you need, you can check
in your own executable `bin/build` script into your app's repo and it
will be run instead of `compile` or `uberjar` after setting up Leiningen.

## JDK Version

By default you will get OpenJDK 1.6. To use a different version, you
can commit a `system.properties` file to your app.

```term
$ echo "java.runtime.version=1.7" > system.properties
$ git add system.properties
$ git commit -m "JDK 7"
```

## Add-ons

No add-ons are provisioned by default. If you need a SQL database for
your app, add one explicitly:

```term
$ heroku addons:add heroku-postgresql:crane
```
