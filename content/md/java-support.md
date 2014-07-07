---
title: Heroku Java Support
slug: java-support
url: https://devcenter.heroku.com/articles/java-support
description: Reference documentation describing the support for Java on Heroku's Cedar stack.
---

The Heroku Cedar stack is capable of running a variety of types of Java applications.

This document describes the general behavior of the [Heroku Cedar stack](cedar) as it relates to the recognition and execution of Java applications. General Java support on Heroku refers to the support for all frameworks except for Play. You can read about Play framework support in the [Play framework support reference](play-support).

For framework specific tutorials visit: 

* [Getting Started with Java on Heroku](getting-started-with-java)
* [Java Tutorials](/categories/java)

You can also find template applications that can be cloned directly into your Heroku account at [java.heroku.com](http://java.heroku.com)

> note
> If you have questions about Java on Heroku, consider discussing them in the [Java on Heroku forums](https://discussion.heroku.com/category/java).

## Activation

The default build system for Java application on Heroku is Maven. Heroku Java support for Maven will be applied to applications that contain a pom.xml.

When a deployed application is recognized as a Java application, Heroku responds with `-----> Java app detected`.

```term
$ git push heroku master
-----> Java app detected
```

## Build behavior

The following command is run to build your app:

```term
$ mvn -B -DskipTests=true clean install
```

The maven repo is cached between builds to improve performance.

## Environment

The following [config vars](config-vars) will be set at first push:

* `PATH`: /usr/local/bin:/usr/bin:/bin
* `JAVA_OPTS`: -Xmx384m -Xss512k -XX:+UseCompressedOops
* `MAVEN_OPTS`: -Xmx384m -Xss512k -XX:+UseCompressedOops 
* `PORT`: HTTP port to which the web process should bind
* `DATABASE_URL`: URL of the database connection

> note
> [Resizing dynos](dyno-size) does not automatically change Java memory settings. The `JAVA_OPTS` and `MAVEN_OPTS` [config vars](config-vars) should be manually adjusted for the JVM.

### Adjusting Environment for a Dyno Size

When a new dyno size is selected, the following `JAVA_OPTS` updates are recommended:

* `1X`: -Xmx384m -Xss512k
* `2X`: -Xms768m -Xmx768m -Xmn192m
* `PX`: -Xmx4g -Xms4g -Xmn2g

### Monitoring Resource Usage

Additional JVM flags can be used to monitor resource usage in a dyno. The following flags are recommended for monitoring resource usage:

```
-XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+UseConcMarkSweepGC
```

See the [troubleshooting](java-memory-issues) article for more information about tuning a JVM process.

### Supported Java versions

Heroku currently uses OpenJDK to run your application. OpenJDK versions 6 and 7 are available.

You're able to select Java 6 or 7. Depending on which you select the latest available version of that Java runtime will be used each time you deploy your app.

Current versions are:

* Java 6 - `1.6.0_27`
* Java 7 - `1.7.0_45`

The JDK that your app uses will be included in the slug, which will affect your slug size.

### Specifying a Java version

You can specify a Java version by adding a file called `system.properties` to your application. 

Set a property `java.runtime.version` in the file:

    java.runtime.version=1.7
 
1.6 is the default so if you'd like to use Java 6 you don't need this file at all.

### Default web process type

No default `web` process type is defined for Java applications. See one of the [Java tutorials](/categories/java) for information on setting up your `Procfile`.

## Add-ons

A Postgres database is automatically provisioned for Java applications. This populates the DATABASE_URL environment variable.