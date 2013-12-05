---
title: Rails 4 on Heroku
slug: rails4
url: https://devcenter.heroku.com/articles/rails4
description: How to run a Ruby on Rails 4 application on Heroku.
---

This article covers how to run a Ruby on Rails application on Heroku. It assumes a knowledge of both Heroku and with Rails. If you are new to either please see the [Getting Started with Rails 4.x on Heroku](https://devcenter.heroku.com/articles/rails4-getting-started) instead. This article assumes that you have a copy of the [Heroku toolbelt](https://toolbelt.heroku.com/) installed locally.

Most of Rails works out of the box with Heroku, however there are a few things you can do to get the most out of the platform. To do this you will need to configure your Rails 4 app to connect to Postgres, your logs need to be configured to point to STDOUT, and your application needs to have serving assets enabled in production.

> note
> If you have questions about Ruby on Heroku, consider discussing it in the [Ruby on Heroku forums](https://discussion.heroku.com/category/ruby).

## Logging and assets

Heroku [treats logs as streams](http://12factor.net/logs) and requires your logs to be sent to STDOUT. To enable STDOUT logging in Rails 4 you can add the `rails_12factor` gem. This gem will also configure your app to serve assets in production. To add this gem add this to your Gemfile:

```
gem 'rails_12factor', group: :production
```

This gem allows you to bring your application closer to being a [12factor](http://12factor.net) application. You can get more information about how the gem configures logging and assets read the [rails_12factor README](https://github.com/heroku/rails_12factor). If this gem is not present in your application, you will receive a warning while deploying, and your assets and logs will not be functional.

## Postgres

Your application needs to be configured to use the Postgres database. Newly generated Rails 4 applications are configured to use [sqlite](https://devcenter.heroku.com/articles/sqlite3). To use Postgres instead add the `pg` gem to your Gemfile:

```
gem 'pg'
```

We recommend using the same database in development and production to maintain [dev/prod parity](http://www.12factor.net/dev-prod-parity). You will need to remove the `sqlite` gem from your gemfile or place it in a non production group. You can read more about [why you should not run sqlite on Heroku](https://devcenter.heroku.com/articles/sqlite3), which also contains detailed instructions on setting up Postgres locally.

## Ruby version

Rails 4 Requires a Ruby version of 1.9.3 or higher. Heroku has 2.0.0 installed by default for all new applications, so you don't need to do anything here. However, we recommend setting your Ruby version in your Gemfile:

```
ruby '2.0.0'
```

When you declare your Ruby version, you get parity between production, and between developers.

## Upgrading a Rails 3 app

If you are upgrading an application from Rails 3 you will need to first get your application working with Rails 4 locally. We recommend following this [guide for upgrading to Rails 4](http://railscasts.com/episodes/415-upgrading-to-rails-4). Once complete, follow the previous instructions. Then you need to run a command to generate a `bin` directory in your project. In the root directory of an app upgraded to Rails 4 run:

```
$ rake rails:update:bin
```

This will generate a `bin` directory in the root of your application. Make sure that it is not in your `.gitignore` file, and check this directory and its contents into git. We recommend making large changes in feature branches and testing regularly using staging servers. You can make a new staging server by [forking an existing application](https://devcenter.heroku.com/articles/fork-app) to create a staging application if you do not have a staging server.

## Deploying

Deploying a Rails 4 application is identical to deploying an Rails 3 application. Make sure all of your files are in git:

```
$ git add .
$ git commit -m 'deploying rails 4'
```

Then create a new Heroku app by running `$ heroku create`, or push to an existing one by running:

```
$ git push heroku master
```

If the deploy fails check the build output for warnings and errors. If it succeeds, but your site does not load correctly, check the logs:

```
$ heroku logs --tail
```

## Running

A Rails 4 application will be run the same way as a Rails 3 application. You can manually define how to start your web process by creating a `Procfile` in the root of your directory:

```
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
```

The `PORT` will be assigned to each of your dynos separately through the `PORT` environment variable. Heroku recomends running your Rails 4 app on a [concurrent webserver such as Unicorn](https://devcenter.heroku.com/articles/rails-unicorn). If you do not specify a Procfile, Heroku will run your application using webrick through the `$ rails server` command. While webrick is available through the standard library, we do not recommend using in production. To get the best performance and most consistent experience we recommend you specify how to run your web service in your Procfile.