---
title: Setting Up Apps using the Platform API
slug: setting-up-apps-using-the-heroku-platform-api
url: https://devcenter.heroku.com/articles/setting-up-apps-using-the-heroku-platform-api
description: How to use the app-setups resource of the Platform API to setup up a fully configured app on the Heroku platform.
---

This article describes how to use the [`app-setups`](platform-api-reference#app-setup) resource of the [Platform API](https://devcenter.heroku.com/articles/platform-api-quickstart). The resource, together with an [`app.json` manifest file](https://devcenter.heroku.com/articles/app-json-schema) embedded in the source code, can be used to programmatically setup an app.

Here are some scenarios were `app.json` and `app-setups` might come in handy for source code that you maintain:

 * You want to make it easy for collaborators to setup and deploy your source code to Heroku for testing in staging apps
 * You maintain a ready-to-deploy app or framework and you want to let others quickly deploy and try it out on Heroku

The `app-setups` resource accepts a tar archive of an application’s source code, looks for the `app.json` manifest file, and uses it to orchestrate the first time setup of the application on Heroku, streamlining the deployment and release of the application. 

## Preparing for the setup

Imagine that you want to deploy a simple application using the `app-setups` resource. This may be your own application or, a sample or template you are interested in.

The [ruby-rails-sample](https://github.com/balansubr/ruby-rails-sample/) sample application is such an example. Note that this API applies to apps written in any language, and we're just using Ruby here as an example. 

The first step is to add an `app.json` configuration file to the app. This app's configuration includes:

* a config var in the runtime environment to customize the template
* a couple of add-ons: 
  * Papertrail for logging 
  * Heroku Postgres for the database. 
* a command to be run after deployment to prepare the database. 

To call the API, you need the URL of its source tarball.For this example, use [this URL](https://github.com/balansubr/ruby-rails-sample/tarball/master/). The API expects the `app.json` file, that contains this configuration information, to be present at the root of the source bundle’s directory structure. 

>note
>If you are using a public GitHub repo for your source code, GitHub provides a specific URL for each repo that resolves to a tarball of the repo’s contents. This URL typically looks like: ```https://github.com/<username>/<repo name>/tarball/master/```

## Creating an app setup

With a source tarball, which contains an `app.json`, call the `https://api.heroku.com/app-setups` endpoint to setup the `app.json` enabled application on Heroku. The request body must contain a source URL that points to the tarball of your application’s source code. 

Let's use cURL to call the `app-setups` endpoint:

```term
$ curl -n -X POST https://api.heroku.com/app-setups \
-H "Content-Type:application/json" \
-H "Accept:application/vnd.heroku+json; version=3" \
-d '{"source_blob": { "url":"https://github.com/balansubr/ruby-rails-sample/tarball/master/"} }' 
```

Optionally, the request can include an `overrides` section to provide values for environment variables specified in the `app.json`, override default values, or to provide additional environment variables. The only portion of the `app.json` that you can override is the `env` section. 

```term
$ curl -n -X POST https://api.heroku.com/app-setups \
-H "Content-Type:application/json" \
-H "Accept:application/vnd.heroku+json; version=3" \
-d '{"source_blob": { "url":"https://github.com/balansubr/ruby-rails-sample/tarball/master/"}, 
"overrides": {"env": { "RAILS_ENV":"development", "SETUP_BY":"MyDeployerScript" } } }' 
```

Heroku kicks off the setup of the application by creating the Heroku app with a generated app name, and immediately returns a response, which contains an ID that can be used in later requests:

```javascript
{
    "id": "df1c2983-fbde-455b-8e7b-e17c16bdf757",
    "failure_message": null,
    "status": "pending",
    "app": {
        "id": "888ee9fb-c090-499b-a115-2f335a1f0ef5",
        "name": "pacific-peak-6986"
    },
    "build": {
        "id": null,
        "status": null
    },
    "manifest_errors": [],
    "postdeploy": {
        "output": null,
        "exit_code": null
    },
    "resolved_success_url": null,
    "created_at": "2014-05-09T18:41:35+00:00",
    "updated_at": "2014-05-09T18:41:35+00:00"
}
```

Sometimes app creation may fail. If this happens, you get a failed response with some details about the failure, for example:

```javascript
{ "id": "invalid_params", "message": "You've reached the limit of 5 apps for unverified accounts. Add a credit card to verify your account." }
```

## Polling for setup status

Using the ID, poll the API for status updates:
 
```term
$ curl -n https://api.heroku.com/app-setups/df1c2983-fbde-455b-8e7b-e17c16bdf757 \
-H "Content-Type:application/json" \
-H "Accept:application/vnd.heroku+json; version=3"
```

Here is the response when the build is kicked off:

```javascript
{ 
  "id": "df1c2983-fbde-455b-8e7b-e17c16bdf757",
  "failure_message": null,
  "status": "pending",
  "app": { 
    "id": "888ee9fb-c090-499b-a115-2f335a1f0ef5",
    "name": "pacific-peak-6986" 
  },
  "build": { 
    "id": "06503167-f75e-4ad6-bd06-4d5da3825eb5",
    "status": "pending"
   },
   "resolved_success_url": null,
   ...
}
```

Keep polling until the status changes from `pending` to `succeeded` or `failed`.

If there are any issues during the setup, the response indicates those errors. 

```javascript
{ 
  "id": "df1c2983-fbde-455b-8e7b-e17c16bdf757",
  "failure_message": "app.json not found",
  "status": "failed",
  "app": { 
    "id": "888ee9fb-c090-499b-a115-2f335a1f0ef5",
     "name": "pacific-peak-6986" 
  },
  ...
}
```

At any point a step in the setup process fails, the app is deleted but the setup status is always available.

Once the build status has been updated to `succeeded` or `failed` you can use the build ID to call the Platform API for more detailed status of the build. See the [Building and Releasing using the Platform API](https://devcenter.heroku.com/articles/build-and-release-using-the-api) for more information. To construct the build status request, you need both the name of the app being set up and the build ID; both of these are available in the response above.

 ```term
$ curl -n -X GET https://api.heroku.com/apps/pacific-peak-6986/builds/06503167-f75e-4ad6-bd06-4d5da3825eb5/result \
-H "Content-Type:application/json" \
-H "Accept:application/vnd.heroku+json; version=3"
```

This returns detailed build results which includes every line of the build output.

```javascript
{
  "build": {
    "id": "06503167-f75e-4ad6-bd06-4d5da3825eb5",
    "status": "succeeded"
  },
  "exit_code": 0,
  "lines": [
    {
      "stream": "STDOUT",
      "line": "\n"
     },
     {
       "stream": "STDOUT",
       "line": "-----> Ruby app detected\n"
     },
     ...
```

The output of the post deploy script is provided inline within the response to the polling request for the overall setup status. 

```javascript
"postdeploy": {
  "output": "",
  "exit_code": 0
}
```

When the status is `succeeded`, the `resolved_success_url` is populated with a fully-qualified URL to which to redirect users upon completion of the setup. The value is derived from the `success_url` attribute in the `app.json` manifest file. If the `success_url` is absolute, it is returned as-is; if it relative, it is resolved in the context of the app's `web_url`.

```javascript
"resolved_success_url": "http://pacific-peak-6986.herokuapp.com/"
```

## Behind the scenes

Here's a look at what the Heroku Platform API does with different elements in the `app.json` file. Applications that have an `app.json` manifest file won't behave any differently when deployed using the standard [git based workflow](https://devcenter.heroku.com/articles/git). The setup flow described in this article is only currently available through the API.

### Application metadata

The `name`, `description`, `website`, `repository` and `logo` fields provide basic information about the application. This is simply for users looking at the `app.json` to understand what the application is about&mdash;the API does not use this section during application setup.

```javascript
"name": "Ruby on Rails",
"description": "A template for getting started with the popular Ruby framework.",
"website": "http://rubyonrails.org"
```

### Environment variables
The `env` section consists of a series of variables with more information about them. For each variable, the API sets up a [config var](config-vars) on the app.
 
```javascript
"env": {
  "RAILS_ENV": "production",
  "COOKIE_SECRET": {
    "description": "This gets generated",
    "generator": "secret"
  },
  "SETUP_BY": {
    "description": "Who initiated this setup",
    "required": true
  }
}
```

A variable can have a description and a default value. As shown in a previous example, the Platform API request may include a `overrides` section that provides values to override these defaults.

If a value is provided in the `app.json`, the API treats it as a required variable. Otherwise, values for variables marked as required must be provided in the `overrides` section when the Platform API is called or the setup will fail. 

Some variables need values that are generated when the application is deployed and set up. You may specify a generator for these variables. The only generator supported today is `secret` which generates a 64 character hexadecimal string. 

This section may also contain a `BUILDPACK_URL` to specify which buildpack should be used to build the application’s slug.

### Add-ons

```javascript
"addons": ["heroku-postgresql:hobby-dev", "papertrail"]
```

The API provisions add-ons immediately after creating the app, before the code is built and released. The `app.json` may specify just the add-on name or the add-on name together with a specific tier. When no tier is specified, the Platform API provisions the lowest tier, which for many add-ons is its free tier. 

### Post-deployment scripts

You can specify one postdeploy script in the `app.json` file. This script will be executed by Heroku on a [one-off dyno](https://devcenter.heroku.com/articles/one-off-dynos) as soon as your application has been built and released. The script is run in the same environment as your application and has access to its config vars and add-ons.

```javascript
"scripts": {
  "postdeploy": "bundle exec rake db:migrate"
}
```

If you have multiple commands to execute, put them in a script, add the script to the source bundle and provide the command you would use to run that script as the value for `postdeploy`. You can also write your scripts in the same language as your application and provide the appropriate command such as `rails setup-script.rb`.

## The deployed app

The Heroku app in this example has been setup with the following config vars:

```term
$ heroku config -a pacific-peak-6986

=== pacific-peak-6986 Config Vars
COOKIE_SECRET:              1e1867380b9365f2c212e31e9c43a87c17e82be0ce1a61406ea8274fac0680dc
DATABASE_URL:               postgres://bdlgvbfnitiwtf:DGuFLR87rMNFe7cr_y1HGwadMm@ec2-54-225-182-133.compute-1.amazonaws.com:5432/d8p7bm6d7onr10
HEROKU_POSTGRESQL_ONYX_URL: postgres://bdlgvbfnitiwtf:DGuFLR87rMNFe7cr_y1HGwadMm@ec2-54-225-182-133.compute-1.amazonaws.com:5432/d8p7bm6d7onr10
PAPERTRAIL_API_TOKEN:       VikcKA2wQf2H1ajww3s
RAILS_ENV:                  development
SETUP_BY:                   MyDeployerScript
```

It has these add-ons provisioned:

```term
$ heroku addons -a pacific-peak-6986

=== pacific-peak-6986 Configured Add-ons
heroku-postgresql:hobby-dev  HEROKU_POSTGRESQL_ONYX
papertrail:choklad
```

The database has been migrated and the application is now ready to serve traffic.
![Sample Ruby App](https://s3.amazonaws.com/appjson/ruby-sample-app.png)

The git repo associated with the Heroku app has been primed with the source code. To continue coding the app and push changes with the standard `git push` deploy, simply clone the app:

```term
$ heroku git:clone pacific-peak-6986

Cloning from app 'pacific-peak-6986'...
Cloning into 'pacific-peak-6986'...
Initializing repository, done.
remote: Counting objects: 77, done.
remote: Compressing objects: 100% (69/69), done.
remote: Total 77 (delta 2), reused 0 (delta 0)
Receiving objects: 100% (77/77), 17.85 KiB | 0 bytes/s, done.
Resolving deltas: 100% (2/2), done.
Checking connectivity... done
```
