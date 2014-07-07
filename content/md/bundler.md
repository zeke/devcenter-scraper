---
title: Managing Gems with Bundler
slug: bundler
url: https://devcenter.heroku.com/articles/bundler
description: Bundler is the default gem manager for Rails 3, though it can be used with any Ruby project. It's the recommended way to manage your gems on Heroku.
---

Bundler is the default gem manager for Rails 3, though it can be used with any Ruby project as it has no dependency on framework.  Bundler is the way to manage your gems on Heroku.

>note
>If you have questions about Ruby on Heroku, consider discussing it in the [Ruby on Heroku forums](https://discussion.heroku.com/category/ruby).

Using Bundler
-------------

To use, install bundler:

```term
$ gem install bundler
```

Create a file named `Gemfile` in the root of your app specifying what gems are required to run it:

```ruby
source "https://rubygems.org"
gem 'sinatra', '1.0'
```

This file should be added to the git repository since it is part of the app. You should also add the `.bundle` directory to your `.gitignore` file.  Once you have added the `Gemfile`, it makes it easy for other developers to get their environment ready to run the app:

```term
$ bundle install -j4
```

This ensures that all gems specified in `Gemfile`, together with their dependencies, are available for your application.  Running `bundle install` also generates a `Gemfile.lock` file, which should be added to your git repository. `Gemfile.lock` ensures that your deployed versions of gems on Heroku match the version installed locally on your development machine. The flag `-j4` will use 4 parallel jobs to install all of your dependencies. This feature was introduced in bundler 1.5.0

>warning
>If the `platforms` section of your `Gemfile` contains Windows entries, such as `mswin` or `mingw`, then the `Gemfile.lock` file will be ignored.  

Heroku also uses that file to resolve and install your application dependencies automatically. All you need to do is to push it:

```term
-----> Heroku receiving push
-----> Sinatra app detected
-----> Gemfile detected, running Bundler version 1.5.2
       Unresolved dependencies detected; Installing...
       Using rack (1.2.1) 
       Using sinatra (1.0) 
       Using bundler (1.0.0) 
       Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.

       Your bundle was installed to `.bundle/gems`
       Compiled slug size is 10.7MB
-----> Launching.... done
```

Specifying gems and groups
------------------------

The recommended use of gem bundler is to bundle absolutely every gem your app depends upon.  This includes your framework (Rails, Sinatra, etc) and your database connectors. 

Bundling Rails and other dependencies does increase your slug size by a few megabytes.  Increased slug size is a worthwhile tradeoff for vastly simplified dependency management, as well as the flexibility of being able to use any version of Rails you wish.

To specify groups of gems to not to be installed, you can use the `BUNDLE_WITHOUT` config var.

```term
$ heroku config:set BUNDLE_WITHOUT="development:test"
```

Frameworks
---------

### Using Bundler with Rails 3

Rails 3 is built on top of Bundler. That means there is no setup needed, all gems specified on the `Gemfile` are ready for use on your app.
    
### Using Bundler with Rails 2.3.X

Follow the instructions [here](http://gembundler.com/rails23.html).  Remember to remove all your `config.gem` lines from your environment configuration file!  Also remember to specify the appropriate database gem for your app.

```ruby
gem "pg", :group => :production
gem "sqlite3-ruby", :group => :development
```
    
After you have added the code to your application, run

```term
$ bundle install
```
    
And your app is running with Bundler.

### Using Bundler from Sinatra (or Other Rack Apps)

Gembundler has a great set of [documentation](http://gembundler.com/sinatra.html) on how to use Bundler with Sinatra and other frameworks as well.

Further reading
---------------

* [Bundler Docs](http://gembundler.com/) 
