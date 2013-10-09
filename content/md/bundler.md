---
title: Managing Gems with Bundler
slug: bundler
url: https://devcenter.heroku.com/articles/bundler
description: Bundler is the default gem manager for Rails 3, though it can be used with any Ruby project. It's the recommended way to manage your gems on Heroku.
---

Bundler is the default gem manager for Rails 3, though it can be used with any Ruby project as it has no dependency on framework.  Bundler is the way to manage your gems on Heroku.

Using Bundler
-------------

To use, install bundler:

    :::term
    $ gem install bundler

Create a file named `Gemfile` in the root of your app specifying what gems are required to run it:

    :::ruby
    source "https://rubygems.org"
    gem 'sinatra', '1.0'

This file should be added to the git repository since it is part of the app. You should also add the `.bundle` directory to your `.gitignore` file.  Once you have added the `Gemfile`, it makes it easy for other developers to get their environment ready to run the app:

    :::term
    $ bundle install

This ensures that all gems specified in `Gemfile`, together with their dependencies, are available for your application.  Running `bundle install` also generates a `Gemfile.lock` file, which should be added to your git repository. `Gemfile.lock` ensures that your deployed versions of gems on Heroku match the version installed locally on your development machine.

<div class="warning" markdown="1">
If the `platforms` section of your `Gemfile` contains Windows entries, such as `mswin` or `mingw`, then the `Gemfile.lock` file will be ignored.  
</div>

Heroku also uses that file to resolve and install your application dependencies automatically. All you need to do is to push it:

    :::term
    -----> Heroku receiving push
    -----> Sinatra app detected
    -----> Gemfile detected, running Bundler version 1.0.0
           Unresolved dependencies detected; Installing...
           Using rack (1.2.1) 
           Using sinatra (1.0) 
           Using bundler (1.0.0) 
           Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.

           Your bundle was installed to `.bundle/gems`
           Compiled slug size is 10.7MB
    -----> Launching.... done

Specifying gems and groups
------------------------

The recommended use of gem bundler is to bundle absolutely every gem your app depends upon.  This includes your framework (Rails, Sinatra, etc) and your database connectors. 

Bundling Rails and other dependencies does increase your slug size by a few megabytes.  Increased slug size is a worthwhile tradeoff for vastly simplified dependency management, as well as the flexibility of being able to use any version of Rails you wish.

Please note, for the time being, the Cedar stack does not officially support `BUNDLE_WITHOUT`. If you would like to use `BUNDLE_WITHOUT` on cedar, you need to enable the [`user_env_compile` feature flag](https://devcenter.heroku.com/articles/labs-user-env-compile). After enabling the feature flag, you can exclude certain groups from being installed by using the `BUNDLE_WITHOUT` config var.

    :::term
    $ heroku config:set BUNDLE_WITHOUT="development:test"

Frameworks
---------

### Using Bundler with Rails 3

Rails 3 is built on top of Bundler. That means there is no setup needed, all gems specified on the `Gemfile` are ready for use on your app.
    
### Using Bundler with Rails 2.3.X

Follow the instructions [here](http://gembundler.com/rails23.html).  Remember to remove all your `config.gem` lines from your environment configuration file!  Also remember to specify the appropriate database gem for your app.

    :::ruby
    gem "pg", :group => :production
    gem "sqlite3-ruby", :group => :development
    
After you have added the code to your application, run

    :::term
    $ bundle install
    
And your app is running with Bundler.

### Using Bundler from Sinatra (or Other Rack Apps)

Gembundler has a great set of [documentation](http://gembundler.com/sinatra.html) on how to use Bundler with Sinatra and other frameworks as well.


Further reading
---------------

* [Bundler Docs](http://gembundler.com/)
