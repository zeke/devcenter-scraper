---
title: Getting Started with Rails 4.x on Heroku
slug: getting-started-with-rails4
url: https://devcenter.heroku.com/articles/getting-started-with-rails4
description: Creating, configuring, deploying and scaling Rails 4.x applications on Heroku, using Bundler dependency management.
---

Ruby on Rails is a popular web framework written in [Ruby](http://www.ruby-lang.org/). For running previous versions of Rails on Heroku see [Getting Started with Rails 3.x on Heroku](https://devcenter.heroku.com/articles/rails3).

This article provides an in-depth getting started guide for Rails 4. If you are already familiar with Heroku and Rails, reference the [simplifed Rails 4 on Heroku guide](https://devcenter.heroku.com/articles/rails4) instead. For general information on how to develop and architect apps for use on Heroku, see [Architecting Applications for Heroku](https://devcenter.heroku.com/articles/architecting-apps).

For this guide you will need:

* Basic Ruby/Rails knowledge, including an installed version of Ruby 2.0.0, Rubygems, Bundler, and Rails 4.

* Basic Git knowledge

* Your application must run on Ruby (MRI) 2.0.0.

* A Heroku user account. [Signup is free and instant](https://api.heroku.com/signup/devcenter).

## Local workstation setup

Install the [Heroku Toolbelt](https://toolbelt.heroku.com/) on your local workstation. This ensures that you have access to the [Heroku command-line client](/categories/command-line), Foreman, and the Git revision control system. You will also need [Ruby and Rails installed](http://guides.railsgirls.com/install/).

Once installed, you'll have access to the `heroku` command from your command shell. Log in using the email address and password you used when creating your Heroku account:

<div class="callout" markdown="1">

Note that `$` before commands indicates they should be run on the command line, prompt, or terminal with appropriate permissions.

</div>

    :::term
    $ heroku login
    Enter your Heroku credentials.
    Email: adam@example.com
    Password:
    Could not find an existing public key.
    Would you like to generate one? [Yn]
    Generating new SSH public key.
    Uploading ssh public key /Users/adam/.ssh/id_rsa.pub



Press enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on.

Write your app
--------------

You may be starting from an existing app, if so [upgrade to Rails 4](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0) before continuing. If not, a vanilla Rails 4 app will serve as a suitable sample app. To build a new app make sure that you're using the Rails 4.x using `$ rails -v`. You can get the new version of rails by running,

    :::term
    $ gem install rails --version 4.0.0

Then create a new app:

    :::term
    $ rails new myapp --database=postgresql
    $ cd myapp

Rails 4 no longer has a static index page in production. When you're using a new app, there won't be a root page in production. We'll create one then.

In `app/controllers/application_controller.rb` add the index method in the `ApplicationController` class:

    :::ruby
    def index
      render text: "Hello World"
    end

It should look something like this:

    :::ruby
    class ApplicationController < ActionController::Base
      # Prevent CSRF attacks by raising an exception.
      # For APIs, you may want to use :null_session instead.
      protect_from_forgery with: :exception
    
      def index
        render text: "Hello World"
      end
    end

Now we need to have Rails route to this action. We'll edit `config/routes.rb` to set the index page to our new method:

    :::ruby
    Myapp::Application.routes.draw do
      root 'application#index'
    end

Heroku gems
-----------

Heroku integration has previously relied on using the Rails plugin system, which has been removed from Rails 4. To enable features such as static asset serving and logging on Heroku please add the following gems to your `Gemfile`:

    :::ruby
    gem 'rails_12factor', group: :production

Then run:

    :::term
    $ bundle install

That should be the minimum you need to do to integrate with Heroku. We talk more about Rails integration on our [Ruby Support page](https://devcenter.heroku.com/articles/ruby-support#injected-plugins).

Use Postgres
------------

<div class="callout" markdown="1">
We highly recommend using PostgreSQL during development. Maintaining [parity between your development](http://www.12factor.net/dev-prod-parity) and deployment environments prevents subtle bugs from being introduced because of differences between your environments.
</div>

If you did not specify `postgresql` while creating your app (using `--database=postgresql`) you will need to add the `pg` gem to your Rails project. Edit your `Gemfile` and change this line:

    :::ruby
    gem 'sqlite3'

To this:

    :::ruby
    gem 'pg'

In addition to using the `pg` gem, you'll also need to ensure the `config/database.yml` is using the `postgresql` adapter and not `sqlite3`. You're `config/database.yml` file should look something like this:

    :::ruby
    development:
      adapter: postgresql
      encoding: unicode
      database: myapp_development
      pool: 5
      username: myapp
      password:
    test:
      adapter: postgresql
      encoding: unicode
      database: myapp_test
      pool: 5
      username: myapp
      password:
    production:
      adapter: postgresql
      encoding: unicode
      database: myapp_production
      pool: 5
      username: myapp
      password:

Make sure to update the username and password for your database.

And re-install your dependencies (to generate a new `Gemfile.lock`):

    :::term
    $ bundle install

You can get more information on why this change is needed and how to configure your app to run postgres locally see [why you cannot use Sqlite3 on Heroku](https://devcenter.heroku.com/articles/sqlite3).


Specify Ruby version in app
---------------------------

Rails 4 requires Ruby 1.9.3 or above. Heroku has a recent version of Ruby installed, however you can specify an exact version by using the `ruby` DSL in your `Gemfile`. For this guide we'll be using Ruby 2.0.0 so add this to your `Gemfile`:

    :::ruby
    ruby "2.0.0"

You should also be running the same version of Ruby locally. You can verify by running `$ ruby -v`. You can get more information on [specifying your Ruby version on Heroku here](https://devcenter.heroku.com/articles/ruby-versions).

Store your app in git
---------------------

Heroku relies on [git](http://git-scm.com/), a distributed source control managment tool, for deploying your project. If your project is not already in git first verify that `git` is on your system:

    :::term
    $ git --help
    usage: git [--version] [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
               [-p|--paginate|--no-pager] [--no-replace-objects] [--bare]
               [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
               [-c name=value] [--help]
               <command> [<args>]
    # ...

If you don't see any output or get `command not found` you will need to install it on your system, verify that the Heroku toolbelt is installed.

Once you've verified that git works, first make sure you are in your Rails app directory. Now run these three commands in your Rails app directory to initialize and commit your code to git:

    :::term
    $ git init
    $ git add .
    $ git commit -m "init"


Now that your application is committed to git you can deploy to Heroku.

Deploy your application to Heroku
----------------------

Make sure you are in the directory that contains your Rails app, then create the app on Heroku:

    :::term
    $ heroku create
    Creating calm-brook-1268... done, stack is cedar
    http://calm-brook-1268.herokuapp.com/ | git@heroku.com:calm-brook-1268.git
    Git remote heroku added

Verify that the remote was added to your project by running

    :::term
    $ git config -e

If you do not see `fatal: not in a git directory` then you are safe to deploy to Heroku. After you deploy you will need to migrate your database, make sure it is properly scaled and use logs to debug any issues that come up.


Deploy your code:

    :::term
    $ git push heroku master
    Counting objects: 112, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (77/77), done.
    Writing objects: 100% (112/112), 27.01 KiB, done.
    Total 112 (delta 20), reused 112 (delta 20)
    -----> Ruby/Rails app detected
    -----> Using Ruby version: ruby-2.0.0
    -----> Installing dependencies using Bundler version 1.3.2
           Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin --deployment
           Fetching gem metadata from https://rubygems.org/..........
           Fetching gem metadata from https://rubygems.org/..
           Installing rake (10.1.0)
           ...
           Installing uglifier (2.2.1)
           Your bundle is complete! It was installed into ./vendor/bundle
           Post-install message from rdoc:
           Depending on your version of ruby, you may need to install ruby rdoc/ri data:
           <= 1.8.6 : unsupported
           = 1.8.7 : gem install rdoc-data; rdoc-data --install
           = 1.9.1 : gem install rdoc-data; rdoc-data --install
           >= 1.9.2 : nothing to do! Yay!
           Cleaning up the bundler cache.
    -----> Writing config/database.yml to read from DATABASE_URL
    -----> Preparing app for Rails asset pipeline
           Running: rake assets:precompile
           I, [2013-09-11T01:22:58.078536 #1186]  INFO -- : Writing /tmp/build_1013n2ur0ve97/public/assets/application-268d763ee3d9fa5a009263184a8d78b2.js
           I, [2013-09-11T01:22:58.101084 #1186]  INFO -- : Writing /tmp/build_1013n2ur0ve97/public/assets/application-58c7c0e35a67f189e19b8c485930e614.css
           Asset precompilation completed (5.86s)
           Cleaning assets
    -----> Discovering process types
           Procfile declares types      -> (none)
           Default types for Ruby/Rails -> console, rake, web, worker

    -----> Compiled slug size: 34.8MB
    -----> Launching... done, v6
           http://calm-brook-1268.herokuapp.com deployed to Heroku

    To git@heroku.com:calm-brook-1268.git
     * [new branch]      master -> master


## Migrate your database

If you are using the database in your application you need to manually migrate the database by running:

    :::term
    $ heroku run rake db:migrate

Any commands after the `heroku run` will be executed on a Heroku [dyno](dynos).


## Visit your application


You've deployed your code to Heroku. You can now instruct Heroku to execute a process type. Heroku does this by running the associated command in a [dyno](dynos) - a lightweight container which is the basic unit of composition on Heroku.


Let's ensure we have one dyno running the `web` process type:


    :::term
    $ heroku ps:scale web=1


You can check the state of the app's dynos. The `heroku ps` command lists the running dynos of your application:

    :::term
    $ heroku ps
    === web: `bin/rails server -p $PORT -e $RAILS_ENV`
    web.1: up for 5s

Here, one dyno is running.

We can now visit the app in our browser with `heroku open`.

    :::term
    $ heroku open
    Opening calm-brook-1268... done

You should now see the "Hello World" text we inserted above.

Heroku gives you a default web app name for simplicty while you are developing. When you are ready to scale up and use Heroku for production you can add your own [Custom Domain](https://devcenter.heroku.com/articles/custom-domains).


## View the logs

If you run into any problems getting your app to perform properly, you will first need to check the logs.

Heroku treats logs as streams of time-ordered events aggregated from the output streams of all the dynos running the components of your application. Heroku’s [Logplex](logplex) provides a single channel for all of these events.

You can view information about your running app using one of the [logging commands](logging), `heroku logs`:

    :::term
    $ heroku logs
    2013-02-26T01:47:32+00:00 heroku[web.1]: State changed from created to starting
    2013-02-26T01:47:33+00:00 heroku[web.1]: Starting process with command `rails server -p 16142 -e $RAILS_ENV`
    2013-02-26T01:47:35+00:00 app[web.1]: [2013-02-26 01:47:35] INFO  WEBrick 1.3.1
    2013-02-26T01:47:35+00:00 app[web.1]: [2013-02-26 01:47:35] INFO  WEBrick::HTTPServer#start: pid=2 port=16142
    2013-02-26T01:47:35+00:00 app[web.1]: [2013-02-26 01:47:35] INFO  ruby 2.0.0 (2013-02-24) [x86_64-linux]
    2013-02-26T01:47:36+00:00 heroku[web.1]: State changed from starting to up


You can also get the full stream of logs by running the logs command with the `--tail` flag like this:

    :::term
    $ heroku logs --tail


## Dyno sleeping and scaling

Having only a single web dyno running will result in the dyno [going to sleep](dynos#dyno-sleeping) after one hour of inactivity.  This causes a delay of a few seconds for the first request upon waking. Subsequent requests will perform normally.

To avoid this, you can scale to more than one web dyno. For example:

    :::term
    $ heroku ps:scale web=2

For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dyno-hours-per-app).  Running your app at 2 dynos would exceed this free, monthly allowance, so let's scale back:

    :::term
    $ heroku ps:scale web=1

Console
-------

Heroku allows you to run commands in a [one-off dyno](oneoff-admin-ps) - scripts and applications that only need to be executed when needed - using the `heroku run` command. Use this to launch a Rails console process attached to your local terminal for experimenting in your app's environment:

    :::term
    $ heroku run rails console
    Running `rails console` attached to terminal... up, run.2591
    Loading production environment (Rails 4.0.0)
    irb(main):001:0>

Rake
----

Rake can be run as an attached process exactly like the console:

    :::term
    $ heroku run rake db:migrate


Webserver
---------

By default, your app's web process runs `rails server`, which uses Webrick. This is fine for testing, but for production apps you'll want to switch to a more robust webserver. On Cedar, [we recommend Unicorn as the webserver](ruby-production-web-server). Regardless of the webserver you choose, production apps should always specify the webserver explicitly in the `Procfile`.

First, add Unicorn to your application `Gemfile`:

    gem 'unicorn'

Run `$ bundle install`, now you are ready to configure your app to use Unicorn.

Create a configuration file for Unicorn at `config/unicorn.rb`:

    $ touch config/unicorn.rb

Now we're going to add Unicorn specific configuration options, that we explain in detail in [Heroku's Unicorn documentation](https://devcenter.heroku.com/articles/rails-unicorn):

    # config/unicorn.rb
    worker_processes 3
    timeout 30
    preload_app true

    before_fork do |server, worker|

      Signal.trap 'TERM' do
        puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
        Process.kill 'QUIT', Process.pid
      end

      defined?(ActiveRecord::Base) and
        ActiveRecord::Base.connection.disconnect!
    end

    after_fork do |server, worker|

      Signal.trap 'TERM' do
        puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
      end

      defined?(ActiveRecord::Base) and
        ActiveRecord::Base.establish_connection
    end

This default configuration assumes a standard Rails app with Active Record. You should get acquainted with the different options in [the official Unicorn documentation](http://unicorn.bogomips.org/Unicorn/Configurator.html).

Finally you will need to tell Heroku how to run your Rails app by creating a `Procfile` in the root of your application directory.

### Procfile

Change the command used to launch your web process by creating a file called [Procfile](procfile) and entering this:

    web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb

Note: The case of `Procfile` is sensitive, the first letter must be uppercase.

Set the `RACK_ENV` to development in your environment and a `PORT` to connect to. Before pushing to Heroku you'll want to test with the `RACK_ENV` set to production since this is the enviroment your Heroku app will run in.

    :::term
    $ echo "RACK_ENV=development" >>.env
    $ echo "PORT=5000" >> .env

You'll also want to add `.env` to your `.gitignore` since this is for local enviroment setup.

    :::term
    $ echo ".env" >> .gitignore
    $ git add .gitignore
    $ git commit -m "add .env to .gitignore"


Test your Procfile locally using Foreman:

    :::term
    $ foreman start
    18:24:56 web.1  | I, [2013-03-13T18:24:56.885046 #18793]  INFO -- : listening on addr=0.0.0.0:5000 fd=7
    18:24:56 web.1  | I, [2013-03-13T18:24:56.885140 #18793]  INFO -- : worker=0 spawning...
    18:24:56 web.1  | I, [2013-03-13T18:24:56.885680 #18793]  INFO -- : master process ready
    18:24:56 web.1  | I, [2013-03-13T18:24:56.886145 #18795]  INFO -- : worker=0 spawned pid=18795
    18:24:56 web.1  | I, [2013-03-13T18:24:56.886272 #18795]  INFO -- : Refreshing Gem list
    18:24:57 web.1  | I, [2013-03-13T18:24:57.647574 #18795]  INFO -- : worker=0 ready

Looks good, so press Ctrl-C to exit. Deploy your changes to Heroku:

    :::term
    $ git add .
    $ git commit -m "use unicorn via procfile"
    $ git push heroku

Check `ps`, you'll see the web process uses your new command specifying Unicorn as the web server

    :::term
    $ heroku ps
    Process State Command
    ------------ ------------------ ------------------------------
    web.1 starting for 3s unicorn -p $..

The logs also reflect that we are now using Unicorn:

    :::term
    $ heroku logs
    2013-03-14T01:57:55+00:00 heroku[web.1]: State changed from up to starting
    2013-03-14T01:57:59+00:00 heroku[web.1]: Starting process with command `unicorn -p 26253 -E $RACK_ENV`
    2013-03-14T01:58:00+00:00 app[web.1]: => Rails 4.0.0 application starting in production on http://0.0.0.0:27993
    2013-03-14T01:58:00+00:00 app[web.1]: I, [2013-03-14T01:58:00.253906 #2]  INFO -- : listening on addr=0.0.0.0:26253 fd=7
    2013-03-14T01:58:00+00:00 app[web.1]: I, [2013-03-14T01:58:00.254256 #2]  INFO -- : worker=0 spawning...
    2013-03-14T01:58:00+00:00 app[web.1]: I, [2013-03-14T01:58:00.257455 #2]  INFO -- : master process ready
    2013-03-14T01:58:00+00:00 app[web.1]: I, [2013-03-14T01:58:00.258541 #4]  INFO -- : Refreshing Gem list
    2013-03-14T01:58:00+00:00 app[web.1]: I, [2013-03-14T01:58:00.258293 #4]  INFO -- : worker=0 spawned pid=4
    2013-03-14T01:58:01+00:00 app[web.1]: I, [2013-03-14T01:58:01.347337 #4]  INFO -- : worker=0 ready
    2013-03-14T01:58:01+00:00 heroku[web.1]: State changed from starting to up

## Rails Asset Pipeline

There are several options for invoking the [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html) when deploying to Heroku. For generalinformation on the asset pipeline please see the [Rails 3.1+ Asset Pipeline on Heroku Cedar](rails3x-asset-pipeline-cedar) article.

The `config.assets.initialize_on_precompile` option has been removed and not needed for Rails 4. Also, any failure in asset compilation will now cause the push to fail. For Rails 4 asset pipeline support see the [Ruby Support](https://devcenter.heroku.com/articles/ruby-support#rails-4-x-applications) page.

Troubleshooting
---------------

If you push up your app and it crashes (`heroku ps` shows state `crashed`), check your logs to find out what went wrong. Here are some common problems.

### Runtime dependencies on development/test gems

If you're missing a gem when you deploy, check your Bundler groups. Heroku builds your app without the `development` or `test` groups, and if you app depends on a gem from one of these groups to run, you should move it out of the group.

One common example using the RSpec tasks in your `Rakefile`. If you see this in your Heroku deploy:

    :::term
    $ heroku run rake -T
    Running `bundle exec rake -T` attached to terminal... up, ps.3
    rake aborted!
    no such file to load -- rspec/core/rake_task

Then you've hit this problem. First, duplicate the problem locally:

    :::term
    $ bundle install --without development:test
    …
    $ bundle exec rake -T
    rake aborted!
    no such file to load -- rspec/core/rake_task

Now you can fix it by making these Rake tasks conditional on the gem load. For example:

### Rakefile

    :::ruby
    begin
      require "rspec/core/rake_task"

      desc "Run all examples"

      RSpec::Core::RakeTask.new(:spec) do |t|
        t.rspec_opts = %w[--color]
        t.pattern = 'spec/**/*_spec.rb'
      end
    rescue LoadError
    end

Confirm it works locally, then push to Heroku.
