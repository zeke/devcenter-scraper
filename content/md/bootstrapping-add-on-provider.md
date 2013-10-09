---
title: Bootstrapping an Add-on Provider
slug: bootstrapping-add-on-provider
url: https://devcenter.heroku.com/articles/bootstrapping-add-on-provider
description: A quick way to get started the Heroku Add-ons API
---

This is a short guide showing how to get started building your own add-on.  It assumes you've [read the docs on building an Add-on](/articles/building-a-heroku-add-on).

## Cloning a template add-on

The `kensa create` command will clone a template add-on from GitHub (or any git URL) so you can immediately get started with a working application that implements the cloud services API.  It will also create an `addon-manifest.json` file for you and a matching `.env` file you can use to boot up your app locally with correct credentials via `foreman start`.

Say you wanted to clone the sinatra add-on template into the directory `my_addon`.  You would use the following command:

``` term
$ kensa create my_addon --template sinatra
Cloning into my_addon...
remote: Counting objects: 92, done.
...
Created my_addon from sinatra template
Initialized new addon manifest in addon-manifest.json
Initialized new .env file for foreman
```

The templates are simply cloned from the github repository at [http://github.com/heroku/kensa-create-sinatra](http://github.com/heroku/kensa-create-sinatra). Alternatively you can provide a full git URL of a different template to use.

## Starting the template add-on

After cloning the template, you can start it with foreman. Heroku and kensa use the credentials provided in your `addon-manifest.json` for API authentication.  Your app also needs to be aware of these credentials.  Because we don't recommend checking the manifest into version control, the template app is designed to read the credentials from the environment.


>callout
>**Credentials**  
>`kensa create` writes a `.env` file that matches the credentials in  `addon-manifest.json`.
>The `HEROKU_USERNAME` matches the id, the `HEROKU_PASSWORD` matches the API passsword, and the `SSO_SALT` matches the API sso_salt.

 `foreman start` uses the `.env` file to create an environment for its applications.   Refer to `foreman help` for more advanced `.env` file usage.

``` term
$ cd my_addon
$ bundle install
$ gem install foreman
$ foreman start
17:57:39 web.1     | started with pid 12966
```

This will start your freshly cloned add-on on port 5000.  You can now test your add-on with the `kensa` gem.

## Testing the template add-on

In a new shell:

``` term
$ cd path/to/my_addon
$ kensa test provision  #look at the output for the id of the provisioned resource

Testing POST /heroku/resources
    Check response [PASS]
    Check valid JSON [PASS]
    Check authentication [PASS]

Testing response
  Check contains an id [PASS] (id 1)

$ kensa test planchange <id> <newplan>
$ kensa test sso <id>
$ kensa sso <id>
$ kensa test deprovision <id>
$ kensa test all
```

After you've confirmed everything is working, you can rename your add-on by editing the `addon-manifest.json` and `.env` files and concentrate on your application logic.