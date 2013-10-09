---
title: Configuration and Config Vars
slug: config-vars
url: https://devcenter.heroku.com/articles/config-vars
description: How to store configuration of a Heroku app in the environment, keeping config out of code, making it easy to maintain app or deployment specific configs.
---

<!-- #HOME: http://devcenter.heroku.com/articles/config-vars -->
A given codebase may have numerous deployments: a production site, a staging site, and any number of local environments maintained by each developer.  An open source app may have hundreds or thousands of deployments.

Although all running the same code, each of these deploys have environment-specific configurations.  One example would be credentials for an external service, such as Amazon S3.  Developers may share one S3 account, while the staging site and production sites each have their own keys.

The traditional approach for handling such config vars is to put them under source - in a properties file of some sort.  This is an error-prone process, and is especially complicated for open source apps which often have to maintain separate (and private) branches with app-specific configurations.

A better solution is to use environment variables, and keep the keys out of the code.  On a traditional host or working locally you can set environment vars in your `bashrc`.  On Heroku, you use config vars.

Setting up config vars for a deployed application
------------------------------------

Use the Heroku CLI's  `config`, `config:set`, `config:get` and `config:unset` to manage your config vars:
<div class="callout" markdown="1">Previous versions of the Heroku Toolbelt used `config:add` and `config:remove`</div>

    :::term
    $ heroku config:set GITHUB_USERNAME=joesmith
    Adding config vars and restarting myapp... done, v12
    GITHUB_USERNAME: joesmith
    
    $ heroku config
    GITHUB_USERNAME: joesmith
    OTHER_VAR:       production

    $ heroku config:get GITHUB_USERNAME
    joesmith

    $ heroku config:unset GITHUB_USERNAME
    Unsetting GITHUB_USERNAME and restarting myapp... done, v13

Heroku manifests these config vars as environment variables to the application. These 
environment variables are persistent – they will remain in place across deploys and app restarts – so unless you need to change values, you only need to set them once.  

Whenever you set or remove a config var, your app will be restarted.

Limits
-------

Config var data (the collection of all keys and values) is limited to 16kb for each app.

Example
--------------------------

Add some config vars for your S3 account keys:

    :::term
    $ cd myapp
    $ heroku config:set S3_KEY=8N029N81 S3_SECRET=9s83109d3+583493190
    Adding config vars and restarting myapp... done, v14
    S3_KEY:     8N029N81
    S3_SECRET:  9s83109d3+583493190

Set up your code to read the vars at runtime.  For example, in Ruby you access the environment variables using the `ENV['KEY']` pattern - so now you can write an initializer like so:

    :::ruby
    AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    )

In Java, you can access it through calls to `System.getenv('key')`, like so:

	:::java
	S3Handler = new S3Handler(System.getenv("S3_KEY"), System.getenv("S3_SECRET"))

Python:

	:::python
	s3 = S3Client(os.environ['S3_KEY'], os.environ['S3_SECRET'])
	
Now, upon deploying to Heroku, the app will use the keys set in the config.  

Local setup
-----------

### Using Foreman

In the example shown above, the app would run with the S3 keys set to `nil` on a developer workstation or any host other than Heroku.  However, you may more typically use a different service locally.

For example, your deployed app may have `DATABASE_URL` referencing a Heroku Postgres database, but your local app may have `DATABASE_URL` referencing your local installation of Postgres.

{.callout}
Foreman has the advantage of letting you select a different environment file, or even multiple files, at launch: `foreman -e alternate_env start`

Where should you put your local environment variables?  One solution is to place them in a `.env` file and use [Foreman](procfile#developing-locally-with-foreman) (installed with the [Heroku Toolbelt](http://toolbelt.heroku.com/)) to start your application.  Foreman will then ensure the variables are set, before starting up the processes specified in your `Procfile`.  Here's a `.env`:

	S3_KEY=mykey
	S3_SECRET=mysecret
	
Now start the application:

{.callout}
Foreman also lets you easily run a single one-off command locally. For example: `foreman run rails console`. This is analogous to Heroku's [one-off dynos](/articles/oneoff-admin-ps).

	:::term
	$ foreman start

When using this approach, add your environment files to `.gitignore`.

### Using Foreman and heroku-config

[heroku-config](https://github.com/ddollar/heroku-config) is a plugin for the Heroku CLI that makes it easy to grab your application's config vars, and place them in your local `.env`, and vice versa.

Install it:

	:::term
	$ heroku plugins:install git://github.com/ddollar/heroku-config.git
	heroku-config installed
	
Interactively pull your config vars, prompting for each value to be overwritten in your local file:

	:::term
	$ heroku config:pull --overwrite --interactive	

Push a local environment file to Heroku:

<p class="warning">
Pushing a local environment will overwrite the environment in your Heroku application. Take care when performing this command.
</p>

	:::term
	$ heroku config:push
	
### Other local options

A less useful alternative to using Foreman's `.env` file is to set these values in the `~/.bashrc` for the user:

    export S3_KEY=mykey
    export S3_SECRET=mysecret

Or, specify them when running the application (or any other command) by prepending the shell command:

    :::term
    $ S3_KEY=mykey S3_SECRET=mysecret application

   
## Production and development modes

Many languages and frameworks support a development mode.  This typically enables more debugging, as well as dynamic reloading or recompilation of changed source files.  

For example, in a Ruby environment you could set a `RACK_ENV` config var to `development` to enable such a mode.

It's important to understand and keep track of these config vars on a production Heroku app.  While a development mode is typically great for development, it's not so great for production - leading to a degradation of performance.