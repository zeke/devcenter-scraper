---
title: Managing Multiple Environments for an App
slug: multiple-environments
url: https://devcenter.heroku.com/articles/multiple-environments
description: Create a staging environment that is as similar to production as possible, by creating a second Heroku application that hosts your staging application.
---

Every Heroku app runs in at least two environments: on the Heroku platform (we'll call that production) and on your local machine (development). If more than one person is working on the app, then you've got multiple development environments - one per machine, usually. Usually, each developer will also have a test environment for running tests. 

This separation keeps changes from breaking things. You write code and check the site in development, but you run your tests in the test environment to keep them from overwriting your development database. Similarly, you might have broken features in your development environment most of the time, but you only deploy working code to production.

Unfortunately, this approach breaks down as the environments become less similar. Windows and Macs, for instance, both provide different environments than the Linux [stack](stack) on Heroku, so you can’t always be sure that code that works in your local development environment will work the same way when you deploy it to production. 

The solution is to have a staging environment that is as similar to production as is possible. This can be achieved by creating a second Heroku application that hosts your staging application.  With staging, you can check your code in a production-like setting before having it affect your actual users.  As you already [deploy with git](git), setting up and managing these multiple remote environments is easy.

## Starting from scratch

Say you've already got an application on your local machine, and you're ready to push it to Heroku. We’ll need to create both remote environments, staging and production. To get in the habit of pushing to staging first, we’ll start with it:

```term
$ heroku create --remote staging
Creating strong-river-216.... done
http://strong-river-216.heroku.com/ | git@heroku.com:strong-river-216.git
Git remote staging added
```

> callout
> If you forget the `--remote` flag, you can always rename the default `heroku` remote later with `git remote rename <old> <new>`. </div>

By default, the [heroku CLI](heroku-command) creates projects with a `heroku` git remote (thus the normal `git push heroku master`). Here, we're specifying a different name with the `--remote` flag, so pushing code to Heroku and running commands against the app look a little different than the normal `git push heroku master`:

```term
$ git push staging master
...
$ heroku run rake db:migrate --remote staging
...
$ heroku ps --remote staging
=== web: `bundle exec thin start -p $PORT -e production`
web.1: up for 21s
```

Once your staging app is up and running properly, you can create your production app:

```term
$ heroku create --remote production
Creating fierce-ice-327.... done
http://fierce-ice-327.heroku.com/ | git@heroku.com:fierce-ice-327.git
Git remote production added
$ git push production master
...
$ heroku run rake db:migrate --remote production
...
$ heroku ps --remote production
=== web: `bundle exec thin start -p $PORT -e production`
web.1: up for 16s
```

> callout
> You will need to do some work to keep these apps in sync as you continue to develop them. You'll need to add **contributors**, **config vars**, and **add-ons** to each individually, for instance. 

And with that, you've got the same codebase running as two separate Heroku apps -- one staging and one production, set up identically.

In the example `heroku` commands above we've specified the target app using the `--remote` option. In the course of your normal work, however, you may tire of always typing either `--remote staging` or `--remote production` at the end of every command. To make things easier, you can use your git config to specify a default app. For example, if you wanted "staging" do be your default remote, you could set it with the following command:

```term
$ git config heroku.remote staging
```
This will add a section to the project's .git/config file that looks something like this:

```
[heroku]
  remote = staging
```

Once this is set up, all `heroku` commands will default to the staging app. To run a command on the production app, simply use the `--remote production` option.

## Starting from an existing app

An alternative way to create a staging application is to [fork](fork-app) an existing application.

Imagine you want to duplicate the staging application and use it for integration tests.  The following command will do that:

```term
$ heroku fork -a staging integration
$ git remote add integration git@heroku.com:integration.git
```

Forking an application is very powerful: it copies over the config vars, re-provisions all add-ons, and copies all Heroku Postgres data too.  See the [documentation on Fork](fork-app) to learn more. 

## Managing staging and production configurations

Many languages and frameworks support flipping a development/production switch.  For example, when in development mode, you may use a different database, have increased logging levels, and send all emails to yourself instead of to end users.  

You typically want to do this for the staging apps.  For example, in Ruby you can set the `RACK_ENV` and `RAILS_ENV` for your staging app (you'll also need a `config/environments/staging.rb` file to make this work, of course.):

```term
$ heroku config:set RACK_ENV=staging RAILS_ENV=staging --remote staging
```

The services and libraries that your application uses may also need their own configuration variables set, mirroring those on production.  For example, you may use a different S3 bucket in development than you do on production, so you will use different values for the keys:

```term
$ heroku config:set S3_KEY=XXX --remote staging
$ heroku config:set S3_SECRET=YYY --remote staging
```

## Advanced: Linking local branches to remote apps

It’s simple to type `git push staging master` and `git push production master` when you’ve followed the steps above. Many developers like to take advantage of git’s branches to separate in-progress and production-ready code, however. In this sort of setup, you might deploy to production from your `master` branch, merging in changes from a `development` branch once they’ve been reviewed on the staging app. With this setup, pushing is a littler trickier:

```term
$ git push staging development:master
```

This command tells git that you want to push from your local `development` branch to the `master` branch of your `staging` remote. (It might look a little disorderly, but there's a lot more going on - take a look at the [git book for a very in-depth exploration of refspecs](http://progit.org/book/ch9-5.html).)

If you want to simplify your git commands, you can make things easier by forcing your local git branches to track your remote applications. Assuming you’ve got git remotes for `staging` and `production`, you can do the following:

> callout
> If you want to set `push.default` for all git repositories (instead of just this one), add `--global` to the command.


```term
$ git config push.default tracking
$ git checkout -b staging --track staging/master
Branch staging set up to track remote branch master from staging.
Switched to a new branch 'staging'
```

Now, you're in the `staging` branch and you’re set up so that `git pull` and `git push` will work against your staging environment without any further arguments. Change some code, commit it, and push it up:

```term
$ git commit -a -m "changed code"
$ git push
Counting objects: 11, done.
...
```
   
Notice that you said `git push`, not `git push staging staging:master`. The `push.default` setting is what makes this possible; with that set to `tracking`, your local branches will automatically push changes to the remote repositories that they track.

If you'd like your local `master` branch to point to your `production` remote (and you're running git 1.7 or later), you can do the following:

```term
$ git fetch production
$ git branch --set-upstream master production/master
```
   
And with that, `git push` from `master` will update your production app on Heroku.