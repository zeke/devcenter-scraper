---
title: Creating an add-on with Kensa
slug: kensa-create
url: https://devcenter.heroku.com/articles/kensa-create
description: How add-on providers can use the kensa tool to clone a template add-on from GitHub.
---

The `kensa create` command will clone a template add-on from GitHub (or any git url) and create an `addon-manifest.json` file for you and a matching `.env` file you can use to boot up your app with correct credentials via `foreman start`

To clone the sinatra add-on template into the directory `my_addon`.  You would use the following command:
 
    :::term
    $ gem install kensa
    $ kensa create my_addon --template sinatra
    Cloning into my_addon...
    remote: Counting objects: 92, done.
    ...
    Created my_addon from sinatra template
    Initialized new addon manifest in addon-manifest.json
    Initialized new .env file for foreman

The templates are cloned from their GitHub repository at:

    http://github.com/heroku/kensa-create-<template>

Or from a full git url if it is passed in.
We currently have three, fully open sourced templates:

- `sinatra`  (a Ruby sinatra application)
- `node`     (using express)
- `clojure`  (using compojure)

After cloning the template, you can start it with foreman. Heroku uses the credentials provided in your `addon-manifest.json` for API authentication.  Your app also needs to be aware of these credentials.  Because we don't recommend checking the manifest into version control, the template app is designed to read the credentials from the environment.  

`kensa create` writes a `.env` file that matches the credentials in  `addon-manifest.json`.  The `HEROKU_USERNAME` matches the `id`, the `HEROKU_PASSWORD` matches the api `passsword`, and the `SSO_SALT` matches the api `sso_salt`.

 `foreman start` uses the `.env` file to create an environment for its applications.   Refer to `foreman help` for more advanced `.env` file usage.

    :::term
    $ cd my_addon
    $ #npm install or bundle install or lein deps
    $ gem install foreman
    $ foreman start
    17:57:39 web.1     | started with pid 12966

This will start your freshly cloned add-on on port 5000.  You can now test your add-on with the `kensa` gem.  

In a new shell:

    :::term
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

After you've confirmed everything is working, you can rename your add-on by editing the `addon-manifest.json` and `.env` files and concentrate on your application logic.
