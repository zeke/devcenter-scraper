---
title: WAR Deployment
slug: war-deployment
url: https://devcenter.heroku.com/articles/war-deployment
description: Deploying Java web applications to Heroku as WAR files from Eclipse or the command-line.
---

> warning
> This article only applies to applications in Heroku Enterprise for Java packages.

In addition to [deploying with Git](git), Heroku also supports deploying Java web applications via the [command line](#command-line). When deploying with this method, the WAR file is automatically placed in a [Tomcat 7 web application container](http://tomcat.apache.org/) and deployed as a Heroku application. WAR deployments are subject to the same [slug size limits](https://devcenter.heroku.com/articles/limits#slug-size) as Git-based deployments.

> note
> If you have questions about Java on Heroku, consider discussing them in the [Java on Heroku forums](https://discussion.heroku.com/category/java).

## Command Line

###Setup
1. Install the [Heroku Toolbelt](https://toolbelt.heroku.com/)
2. Install the `heroku-deploy` command line plugin:

```term
$ heroku plugins:install https://github.com/heroku/heroku-deploy
```

###Usage
1. Create a WAR file to deploy. Any method can be used to generate a WAR file. You can use Maven, Ant, or simply export your application from your IDE as a WAR file. The only requirement is that the WAR file is a standard Java web application and adheres to the standard web application structure and conventions. For example, if the application is a Maven project with `war` packaging, running `mvn package` will generate a WAR file in the project's `target` directory.

2. Deploy the WAR file: 

```term
$ heroku deploy:war --war <path_to_war_file> --app <app_name> 
```

If you are in an application directory, the `--app` parameter can be omitted:

```term
$ heroku deploy:war --war <path_to_war_file>
```

##JDK Version
WAR deployment is limited to JDK 6. To use a different JDK version with WAR deployment, please use [deploy using git and Webapp Runner](https://devcenter.heroku.com/articles/java-webapp-runner).

##Advanced Options
WAR files are deployed to your application with Tomcat 7 using [Webapp Runner](https://github.com/jsimone/webapp-runner). Webapp Runner allows advanced options, such as session management and custom Tomcat config files, to be configured. To configure Webapp Runner for deployed WAR files, set the value of the `WEBAPP_RUNNER_OPTS` [config var](config-vars) on your app, and it will be passed to Webapp Runner on start up. For example, to configure a Memcached session store, set `WEBAPP_RUNNER_OPTS` to `--session-store memcache`.

In Eclipse, config vars can be set by right-clicking on the app name in the **My Heroku Application** | **App Info** | **Environment Variables**.

On the command line, run the following:

```term
$ heroku config:set WEBAPP_RUNNER_OPTS="--session-store memcache"
```

See the [Webapp Runner documentation](https://github.com/jsimone/webapp-runner#readme) and [parameter names](https://github.com/jsimone/webapp-runner/blob/master/src/main/java/webapp/runner/launch/CommandLineParams.java) for details about what options are available. 