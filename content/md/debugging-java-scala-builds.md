---
title: Debugging Java, Scala, and Play Framework builds on Heroku
slug: debugging-java-scala-builds
url: https://devcenter.heroku.com/articles/debugging-java-scala-builds
description: A guide to better matching Heroku build functionality locally, so as to increase dev/prod parity and decrease the likelihood of builds not working remotely when they work locally.
---

When you push your source code to Heroku a build will be performed by the buildpack for your specific language. On occasion you may find that code which builds locally has issues when you push to Heroku. In these situations the best way to debug the problem is to understand how builds work on Heroku and drive towards the closest dev/prod parity you can get between your local development environment and Heroku.

## Builds on Heroku

The exact steps that are run to build your code can be found in the buildpack for your language. An overview of the build can also be found in the article describing Heroku's support for each language/framework:

* [Java](https://devcenter.heroku.com/articles/java-support#build-behavior)
* [Scala](https://devcenter.heroku.com/articles/scala-support#build-behavior)
* [Play Framework](https://devcenter.heroku.com/articles/play-support#build-behavior)

## Matching Heroku build functionality locally

Each buildpack attempts to use the most common command for building your code. This is why you can expect something that builds locally using your usual process to also build on Heroku most of the time. However when you run into an issue the best approach is to try to reproduce the failure locally by attempting to make your local build match how Heroku is going to build your code as closely as possible. There are some common areas where differences are found.

### Build command

As mentioned above. Be sure to look at our support article for your chosen language or the buildpack to see what command and which options are used to build your code. Matching this locally is an important first step.

### Local build cache

Most build systems will take advantage of a local build cache to speed up builds by holding on to dependencies once they've been retrieved. If you've built a certain version of a dependency locally it may be present in your build cache, but not in any public repository that Heroku can access. In order to reproduce a build locally that is like what will happen on Heroku you should try building with a clean local build cache. This will differ based on your build tool.

__Maven__

You can point maven to a different local repository by adding this flag to your build command:

    mvn -Dmaven.repo.local=/path/to/repo

Just point your local repo at an empty temporary directory.

__SBT or Play 2.x__

You can point maven to a different local repository by adding this flag to your build command:

    sbt -Dsbt.ivy.home=/path/to/repo clean compile stage

Just point your local repo at an empty temporary directory.

### Dependency caching proxy

In order to speed up the build process some default buildpacks use a proxy called s3pository that caches common dependencies in a file store that is low latency to the datacenter where the builds take place.

s3pository is a proxy for Maven style repositories. When a dependency is retrieved from s3pository configured target repositories are checked for the dependency. When the dependency is found it is copied to the low latency store and returned. Future requests will be returned from the file store rather than sending a request to the source repository. Requests to target repositories are also made concurrently with the fastest returned result being accepted for further speed improvement. To learn more about s3pository have a look at the [source repo](https://github.com/heroku/s3pository).

#### Using s3pository locally

You can set up your local builds to use s3pository the same way that builds on Heroku do. In addition to providing better dev/prod parity this is likely to speed up your local builds. The steps to do this depend on which build tool you're using.

__Maven__

The Java buildpack uses a default [settings.xml](http://s3.amazonaws.com/heroku-jvm-langpack-java/settings.xml) that points the most common Java dependency repositories to s3pository. You can use this [settings.xml](http://s3.amazonaws.com/heroku-jvm-langpack-java/settings.xml) to use s3pository in your local builds. All you have to do is copy the settings.xml to your local maven repository directory (usually ~/.m2)

__SBT or Play 2.x__

The Scala buildpack uses a plugin that adds the necessary resolvers to point to s3pository. To use this plugin locally simply copy [the Scala file](https://raw.github.com/heroku/heroku-buildpack-scala/master/opt/HerokuPlugin.scala) to the project directory in your app or to ~/.sbt/plugins to affect all builds.

## Omitting s3pository on Heroku

If you find that s3pository is causing an issue with your build you can run your Heroku build without using s3pository. Each buildpack that makes use of s3pository has a branch that excludes it.

#### Java Buildpack

    $ heroku config:set BUILDPACK_URL='http://github.com/heroku/heroku-buildpack-java.git#no-s3pository'

#### Scala/Play 2.0 Buildpack

    $ heroku config:set BUILDPACK_URL='http://github.com/heroku/heroku-buildpack-scala.git#no-s3pository'
 