---
title: Add-on Manifest Format
slug: add-on-manifest
url: https://devcenter.heroku.com/articles/add-on-manifest
description: Heroku Add-on manifest format definition
---

The add-on manifest is a JSON document which describes the interface between Heroku and your cloud service. You write the manifest and use it with the Kensa testing tool in your d
evelopment environment, then send the final manifest to Heroku when you're ready to submit your add-on to our marketplace.

## Generating a manifest

You can initialize a new manifest using the `kensa` tool:

``` term
$ kensa init
Initialized new addon manifest in addon-manifest.json
```

## Example manifest

``` json
{
  "id": "errorbucket",
  "api": {
    "config_vars": [
      "ERRORBUCKET_URL"
    ],
    "password": "GqAGAmdrnkDFcvR9",
    "sso_salt": "7CwqmJLEjv8YZTXK",
    "regions": ["us","eu"],
    "production": {
      "base_url": "https://errorbucket.com/heroku/resources",
      "sso_url": "https://errorbucket.com/sso/login"
    },
    "test": {
      "base_url": "http://localhost:4567/heroku/resources",
      "sso_url": "http://localhost:4567/sso/login"
    }
  }
}
```

## Fields

* **id** - An id for your add-on. This is what users will enter when they type "heroku addons:add [youraddon]" All lower case, no spaces or punctuation. This can't be changed after the first push to Heroku. It is also used for HTTP basic auth when making provisioning calls.
* **name** - The name of your add-on.
* **api/config_vars** - A list of config vars that will be returned on provisioning calls. Typically you will have exactly one, the resource URL.
* **api/password** - Password that Heroku will send in HTTP basic auth when making provisioning calls.
* **api/sso_salt** - Shared secret used in single sign-on between the Heroku admin panel and your service's admin panel.
* **api/regions** - The list of geographical regions supported by your add-on.  It cannot be empty.  It must either contain the elements "us", "eu", or both "us" and "eu".
* **api/production/base_url** - The production endpoint for heroku api actions (provision, deprovision, and plan change)
* **api/production/sso_url** - The production endpoint for single sign-on
* **api/test** - The root URL of your development host, typically local, or a map of URLs.
* **api/test/base_url** - The test endpoint for heroku api actions
* **api/test/sso_url** - The test endpoint for single sign-on