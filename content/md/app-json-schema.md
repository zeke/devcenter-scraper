---
title: app.json Schema
slug: app-json-schema
url: https://devcenter.heroku.com/articles/app-json-schema
description: app.json is a manifest format for describing web apps. It declares environment variables, add-ons, and other information required to deploy and run an app on Heroku.
---

`app.json` is a manifest format for describing web apps. It declares environment
variables, add-ons, and other information required to run an app on Heroku. This
document describes the schema in detail.

See the [Setting Up Apps using the Platform API](https://devcenter.heroku.com/articles/setting-up-apps-using-the-heroku-platform-api) for details on how to use `app.json` to set up apps on Heroku.

## Example app.json

```json
{
  "name": "Small Sharp Tool",
  "description": "This app does one little thing, and does it well.",
  "keywords": [
    "productivity",
    "HTML5",
    "scalpel"
  ],
  "website": "https://small-sharp-tool.com/",
  "repository": "https://github.com/jane-doe/small-sharp-tool",
  "logo": "https://small-sharp-tool.com/logo.svg",
  "success_url": "/welcome",
  "scripts": {
    "postdeploy": "bundle exec rake bootstrap"
  },
  "env": {
    "BUILDPACK_URL": "https://github.com/stomita/heroku-buildpack-phantomjs",
    "SECRET_TOKEN": {
      "description": "A secret key for verifying the integrity of signed cookies.",
      "generator": "secret"
    },
    "WEB_CONCURRENCY": {
      "description": "The number of processes to run.",
      "value": "5"
    }
  },
  "addons": [
    "openredis",
    "mongolab:shared-single-small"
  ]
}
```

## Schema Reference


### name

*(string, optional)* A clean and simple name to identify the template.

```json
{
  "name": "Small Sharp Tool"
}
```


### description

*(string, optional)* A brief summary of the app: what it does, who it&#39;s for, why it exists, etc.

```json
{
  "description": "This app does one little thing, and does it well."
}
```


### keywords

*(array, optional)* An array of strings describing the app.

```json
{
  "keywords": [
    "productivity",
    "HTML5",
    "scalpel"
  ]
}
```


### website

*(string, optional)* The project&#39;s website.

```json
{
  "website": "https://small-sharp-tool.com/"
}
```


### repository

*(string, optional)* The location of the application&#39;s source code, such as a Git URL, GitHub URL, Subversion URL, or Mercurial URL.

```json
{
  "repository": "https://github.com/jane-doe/small-sharp-tool"
}
```


### logo

*(string, optional)* The URL of the application&#39;s logo image. Dimensions should be square. Format can be SVG, PNG, or JPG.

```json
{
  "logo": "https://small-sharp-tool.com/logo.svg"
}
```


### success_url

*(string, optional)* A URL specifying where to redirect the user once their new app is deployed. If value is a fully-qualified URL, the user should be redirected to that URL. If value begins with a slash `/`, the user should be redirected to that path in their newly deployed app.

```json
{
  "success_url": "/welcome"
}
```


### scripts

*(object, optional)* A key-value object specifying scripts or shell commands to execute at different stages in the build/release process. Currently, `postdeploy` is the only supported script.

```json
{
  "scripts": {
    "postdeploy": "bundle exec rake bootstrap"
  }
}
```


### env

*(object, optional)* A key-value object for environment variables, or [config vars](https://devcenter.heroku.com/articles/config-vars) in Heroku parlance. Keys are the names of the environment variables. Values can be strings or objects. If the value is a string, it will be used. If the value is an object, it defines specific requirements for that variable:

- `description`: a human-friendly blurb about what the value is for and how to determine what it should be
- `value`: a default value to use. This should always be a string.
- `required`: A boolean indicating whether the given value is required for the app to function.
- `generator`: a string representing a function to call to generate the value. Currently the only supported generator is `secret`, which generates a pseudo-random string of characters.

```json
{
  "env": {
    "BUILDPACK_URL": "https://github.com/stomita/heroku-buildpack-phantomjs",
    "SECRET_TOKEN": {
      "description": "A secret key for verifying the integrity of signed cookies.",
      "generator": "secret"
    },
    "WEB_CONCURRENCY": {
      "description": "The number of processes to run.",
      "value": "5"
    }
  }
}
```


### addons

*(array, optional)* An array of strings specifying Heroku add-ons to provision on the app before deploying. Each `addon` string should be in the format `addon:plan` or `addon`. If plan is omitted, that addon's default plan will be provisioned.

```json
{
  "addons": [
    "openredis",
    "mongolab:shared-single-small"
  ]
}
```