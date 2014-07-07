---
title: Rails Asset Pipeline on Heroku Cedar
slug: rails-asset-pipeline
url: https://devcenter.heroku.com/articles/rails-asset-pipeline
description: Rails applications running on the Heroku Cedar stack can have the asset pipeline compiled at deploy-time.
---

Rails applications running on the Heroku Cedar stack can have the asset pipeline compiled locally, at deploy-time, or at run time. For new users, we recommend reading [Getting Started with Rails 3.x on Heroku](getting-started-with-rails3) before proceeding further.

>note
>Heroku recommends [using the asset pipeline with a CDN](using-amazon-cloudfront-cdn#adding-cloudfront-to-rails) to increase end user experience and decrease load on your Heroku app. If you have questions about Ruby on Heroku, consider discussing it in the [Ruby on Heroku forums](https://discussion.heroku.com/category/ruby).

## The Rails 4 Asset Pipeline

If you are using Rails 4 and the asset pipeline it is recommended to familiarize yourself with the document below. Much of the behavior between Rails 3 and Rails 4 is similar. Once finished please read the [Rails 4 Asset Pipeline on Heroku](https://devcenter.heroku.com/articles/rails-4-asset-pipeline) which covers the differences between the two experiences. 

## The Rails 3 Asset Pipeline

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

If you have not compiled assets locally, we will attempt to run the `assets:precompile` task during slug compilation. Your push output will show:

```term
-----> Preparing Rails asset pipeline
       Running: rake assets:precompile
```

Please see the Troubleshooting section below on explanations of how the rake task works during our slug compilation process.

### Failed assets:precompile ###

If the `assets:precompile` task fails, the output will be displayed and the build will exit.

## Asset caching

Caching of static assets can be implemented in-application using the [Rack::Cache](rack-cache-memcached-rails31) middleware or in a more distributed fashion with a [CDN](using-amazon-cloudfront-cdn). Serving assets from your application does require dyno-resources so please consider an appropriate asset caching strategy for your needs.

Troubleshooting
---------------

### Failures in the assets:precompile task

In Rails 3.x, you can prevent initializing your application and connecting to the database by ensuring that the following line is in your `config/application.rb`:

```term
config.assets.initialize_on_precompile = false
```

Do not forget to commit to git after changing this setting.

In Rails 4.x this option has been removed and is no longer needed.

When deploying if you see something similar to the following:

```term
could not connect to server: Connection refused
Is the server running on host "127.0.0.1" and accepting
TCP/IP connections on port xxxx?
```

This means that your app is attempting to connect to the database as part of `rake assets:precompile`. Because your database may not be available, the command may fail. You should be able to see the same error by running this command:

    env -i GEM_PATH=$GEM_PATH \
           PATH=$PATH \
           RAILS_ENV=$RAILS_ENV\
           DATABASE_URL=postgres://user:pass@127.0.0.1/does_not_exist_dbname \
           /bin/sh -c 'bundle exec rake --trace  assets:precompile'


The above command uses `env -i` which runs everything following it without any environment variables. We then manually pass in `GEM_PATH`, `PATH` and a nonexistent `DATABASE_URL`. Finally we run the command using `bin/sh -c` this tells our shell to execute `bundle exec rake --trace assets:precompile`.

**Note** If you are using another database you will need to replace `postgres` with the database adapter you are using as detected from your `Gemfile`

If `rake assets:precompile` is still not working, you can debug this locally by configuring a nonexistent database in your local `config/database.yml` and attempting to run `rake assets:precompile`. Ideally you should be able to run this command without connecting to the database.

### therubyracer

If you were previously using `therubyracer` or `therubyracer-heroku`, these gems are no longer required and strongly discouraged as these gems use a very large amount of memory. 

A version of Node is installed by the Ruby buildpack that will be used to compile your assets.

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

## No debug output at all

If you see no debug output and your `asset:precompile` task is not run, ensure that `rake` is in your `Gemfile` and properly committed.  