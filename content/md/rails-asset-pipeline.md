---
title: Rails Asset Pipeline on Heroku Cedar
slug: rails-asset-pipeline
url: https://devcenter.heroku.com/articles/rails-asset-pipeline
description: Rails applications running on the Heroku Cedar stack can have the asset pipeline compiled at deploy-time.
---

Rails applications running on the Heroku Cedar stack can have the asset pipeline compiled locally, at deploy-time, or at run time. For new users, we recommend reading [our tutorial for creating a Rails 3.x app on Cedar](/articles/rails3) before proceeding further.

>note
>Heroku recommends [using the asset pipeline with a CDN](https://devcenter.heroku.com/articles/using-amazon-cloudfront-cdn-with-rails) to increase end user experience and decrease load on your Heroku app. If you have questions about Ruby on Heroku, consider discussing it in the [Ruby on Heroku forums](https://discussion.heroku.com/category/ruby).

>callout
>Environment variables are not available to your app at compile time. This means if you need them for your asset compilation, the task may not run properly. Best practice is to re-write your application to not require environment variables at compile time. If you cannot do this, you can use the <a href='https://devcenter.heroku.com/articles/labs-user-env-compile'>user-env-compile</a> labs feature, though its use should be avoided.

## The Rails 3 Asset pipeline

The Rails 3 asset pipeline is supported on Heroku's Cedar stack. The new pipeline makes assets a first class citizen in the Rails stack. By default, Rails uses [CoffeeScript](http://jashkenas.github.com/coffee-script/) for JavaScript and [SCSS](http://sass-lang.com/) for CSS. DHH has a great introduction during his [keynote for RailsConf](http://www.youtube.com/watch?v=cGdCI2HhfAU).

The Rails asset pipeline provides an `assets:precompile` rake task to allow assets to be compiled and cached up front rather than compiled every time the app boots.

There are two ways you can use the asset pipeline on Heroku. 

1. Compiling assets locally.
2. Compiling assets during slug compilation.

### Compiling assets locally ###

>callout
>If a `public/assets/manifest.yml` is detected in your app, Heroku will assume you are handling asset compilation yourself and will not attempt to compile your assets. In Rails 4 the there should be a `public/assets/manifest-<md5 hash>.json` instead. On both versions you can generate this file by running `$ rake assets:precompile` locally and checking the resultant files into Git.

To compile your assets locally, run the `assets:precompile` task locally on your app. Make sure to use the `production` environment so that the production version of your assets are generated.

```term
RAILS_ENV=production bundle exec rake assets:precompile
```

A `public/assets` directory will be created. Inside this directory you'll find a `manifest.yml` which includes the md5sums of the compiled assets in Rails 3. In Rails 4 the file will be  `manifest-<md5 hash>.json`. Adding `public/assets` to your git repository will make it available to Heroku.

```term
git add public/assets
git commit -m "vendor compiled assets"
```

Now when pushing, the output should show that your locally compiled assets were detected:

```term
-----> Preparing Rails asset pipeline
       Detected manifest.yml, assuming assets were compiled locally
```       

### Compiling assets during slug compilation ###

>callout
>The app's config vars are not available in the environment during the slug compilation process. Because the app must be loaded to run the `assets:precompile` task, any initialization code that requires existence of config vars should gracefully handle the `nil` case.

If you have not compiled assets locally, we will attempt to run the `assets:precompile` task during slug compilation. Your push output will show:

```term
-----> Preparing Rails asset pipeline
       Running: rake assets:precompile
```

Please see the Troubleshooting section below on explanations of how the rake task works during our slug compilation process.

### Failed assets:precompile ###

If the `assets:precompile` task fails, the output will be displayed and the build will exit.

## Asset caching

Caching of static assets can be implemented in-application using the [Rack::Cache](rack-cache-memcached-static-assets-rails31) middleware or in a more distributed fashion with a [CDN](cdn-asset-host-rails31). Serving assets from your application does require dyno-resources so please consider an appropriate asset caching strategy for your needs.

Troubleshooting
---------------

### assets:precompile failures

There's no fix or workaround at this time if assets:precompile is failing during slug compilation. Below we describe common issues you might run into and the reasons why it isn't working.

The most common cause of failures in `assets:precompile` is an app that relies on having its environment present to boot. Your app's config vars are not present in the environment during slug compilation, so you should take steps to handle the `nil` case for config vars (and add-on resources) in your initializers.

If you see something similar to the following:

```term
could not connect to server: Connection refused
Is the server running on host "127.0.0.1" and accepting
TCP/IP connections on port xxxx?
```

This means that your app is attempting to connect to the database as part of `rake assets:precompile`. Because the config vars are not present in the environment, we use a placeholder `DATABASE_URL` to satisfy Rails. The full command run during slug compilation is:

     env RAILS_ENV=production DATABASE_URL=scheme://user:pass@127.0.0.1/dbname bundle exec rake assets:precompile 2>&1

* `scheme` will be replaced with an appropriate database adapter as detected from your `Gemfile`

While precompiling assets, in Rails 3.x, you can prevent initializing your application and connecting to the database by ensuring that the following line is in your `config/application.rb`:

```term
config.assets.initialize_on_precompile = false
```

Do not forget to commit to git after changing this setting.

In Rails 4.x this option has been removed and is no longer needed.

If `rake assets:precompile` is still not working, you can debug this locally by configuring a nonexistent database in your local `config/database.yml` and attempting to run `rake assets:precompile`. Ideally you should be able to run this command without connecting to the database.

### therubyracer

If you were previously using `therubyracer` or `therubyracer-heroku`, these gems are no longer required and strongly discouraged as these gems use a very large amount of memory.

### Updating PATH

If you need to compile assets at runtime, you must add `bin` to your PATH to access the JavaScript runtime. Check your current configuration using `heroku config`:

```term
$ heroku config
PATH => vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin
```

If your PATH variable does not include `bin` on its own, update it by running:

```term
$ heroku config:set PATH=bin:vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin
Adding config vars:
  PATH => vendor/bundle/ru...usr/bin:/bin:bin
Restarting app... done, v7.
```