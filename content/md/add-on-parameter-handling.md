---
title: Add-on Parameter Handling
slug: add-on-parameter-handling
url: https://devcenter.heroku.com/articles/add-on-parameter-handling
description: The Heroku CLI gives users the ability to send additional parameters through with provisioning requests for add-ons.
---

This article describes how to access command-line parameters that a user may have added as part of  add-on provisioning. 

## Command-line parameter format

The command-line accepts parameters in standard Unix-style switch format, with or without an equals sign. Single parameters are interpreted as boolean switches and will have the string `'true'` as their value.

For example, the following command line:

``` term
$ heroku addons:add youraddon --foo=bar --bar foo --baz
```

Will be interpreted as:

``` json
{ "foo" : "bar", "bar" : "foo", "baz" : "true" }
```

## Accessing parameters

Heroku passes command-line parameters given to the `addons:add` action during add-on provisioning to the add-on provider.  These options are passed in the JSON body of the provision request via the "options" key.

Consider this example:

``` term
$ heroku addons:add youraddon --foo=bar --bar foo --baz
```

The options are included as part of the JSON in the provision request:

``` json
POST /heroku/resources HTTP/1.0
Content-Type: application/json
{
  "options": {"foo":"bar","bar":"foo","baz":"true"},
  "heroku_id": "app12345@heroku.com",
  "plan": "test",
  "callback_url": "http://localhost:7779/callback/999"
}
```

You can use the `kensa` gem to test the extra command line parameters:

``` term
$ kensa test provision --foo=bar --bar foo --baz
``` 