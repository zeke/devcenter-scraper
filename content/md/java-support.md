---
title: Heroku Java Support
slug: java-support
url: https://devcenter.heroku.com/articles/java-support
description: Reference documentation describing the support for Java on Heroku's Cedar stack.
---

The Heroku Cedar stack is capable of running a variety of types of Java applications.

This document describes the general behavior of the [Heroku Cedar stack](cedar) as it relates to the recognition and execution of Java applications. General Java support on Heroku refers to the support for all frameworks except for Play. You can read about Play framework support in the [Play framework support reference](play-support).

For framework specific tutorials visit: 

* [Getting Started with Java on Heroku/Cedar](java)
* [Java Tutorials](/categories/java)

You can also find template applications that can be cloned directly into your Heroku account at [java.heroku.com](http://java.heroku.com)

### Activation

The default build system for Java application on Heroku is Maven. Heroku Java support for Maven will be applied to applications that contain a pom.xml.

When a deployed application is recognized as a Java application, Heroku responds with `-----> Java app detected`.

    :::term
    $ git push heroku master
    -----> Java app detected

### Build behavior

The following command is run to build your app:

    :::term
    $ mvn -B -DskipTests=true clean install

The local repo is cached between builds to improve performance.

### Environment

The following environment variables will be set at first push:

* `PATH`: /usr/local/bin:/usr/bin:/bin
* `JAVA_OPTS`: -Xmx384m -Xss512k -XX:+UseCompressedOops
* `MAVEN_OPTS`: -Xmx384m -Xss512k -XX:+UseCompressedOops 
* `PORT`: HTTP port to which the web process should bind
* `DATABASE_URL`: URL of the database connection

### Runtime behavior

Heroku currently uses OpenJDK to run your application. OpenJDK versions 6 and 7 are available using a `system.properties` file. OpenJDK 8 with Lambdas is also available as an early preview. See the [Java Tutorials](/categories/java) for more information.

No default `web` process type is defined for Java applications. See one of the [Java tutorials](/categories/java) for information on setting up your `Procfile`.

The JDK that your app uses will be included in the slug, which will affect your slug size.

### Add-ons

A Postgres database is automatically provisioned for Java applications. This populates the DATABASE_URL environment variable.