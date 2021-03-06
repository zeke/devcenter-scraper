---
title: Add-on Provider API
slug: add-on-provider-api
url: https://devcenter.heroku.com/articles/add-on-provider-api
description: An API reference for Add-on Providers
---

The Add-on Provider API is used when Heroku calls your add-on service. In these examples Heroku is issuing the requests and your add-on is providing the responses.

All calls should be protected by HTTP basic auth with the add-on id and password specified in your add-on manifest. All calls are required, any requests that are unable to be serviced should [return a 422 response](/articles/add-on-provider-api#exceptions) with an informative message for the user.

## Provision
```
Request: POST https://username:password@api.heroku.com/heroku/resources
Request Body: {
  "heroku_id": "app123@heroku.com",
  "plan": "basic",
  "region": "amazon-web-services::us-east-1",
  "callback_url": "https://api.heroku.com/vendor/apps/app123%40heroku.com",
  "log_input_url": "https://token:t.01234567-89ab-cdef-0123-456789abcdef@1.us.logplex.io/logs",
  "options": {}
}
Response Body: {
  "id": 456,
  "config": {"MYADDON_URL": "http://myaddon.com/52e82f5d73"},
  "message": "your message here"
}
```
Only information which is immutable between requests is provided at the time of provisioning.
If you wish to access information which can change (e.g., owner email address or application name) then it is available via the [App Info API](https://addons.heroku.com/provider/resources/technical/reference/app-info). The App Info API will return a 4XX response until you've returned a successful provisioning response to Heroku. As a result, we recommend accessing it asynchronously after provisioning. It is the responsibility of the provider to periodically check this endpoint to ensure data is consistent. 

The `region` attribute in the request specifies geographical region of the app that the add-on is being provisioned to—either `amazon-web-services::us-east-1` or `amazon-web-services::eu-west-1` are possible at this time. Use this to provision the resource in geopgraphical proximity to the app, ignore it (if your add-on is not latency sensitive) or respond with an error if your add-on does not support apps in the region specified.

The `log_input_url` attribute is provided so that logs can be sent to the app's log stream. This field is only present when configured in you manifest. For more information, see [the article describing logplex input](add-on-provider-log-integration). The `logplex_token` attribute used to be used for this purpose, but is deprecated and will be removed in the near future. 

The `options` object in the request are [extra command line options](add-on-parameter-handling) passed in to the `heroku addons:add` command.

The `id` value returned in the response may be a string or integer value. It should be an immutable value that can be used to address the relationship between this app and resource. This means that a plan change can *not* change the value of this `id`, although you can update the `config` later to point the app to a different resource.

The `config` object and `message` in the response are both optional.

Heroku can also pass [command-line parameters](https://addons.heroku.com/provider/resources/technical/reference/advanced-features) given to the addons:add action during add-on provisioning to the add-on provider. Providers that require access to [advanced features](https://addons.heroku.com/provider/resources/technical/reference/advanced-features) will receive additional attributes based on the features they've requested.

## Plan change

```
Request: PUT https://username:password@api.heroku.com/heroku/resources/:id
Request Body: {"heroku_id": "app123@heroku.com", "plan": "premium"}
Response Body: {"config": { ... }, "message": "your message here"}
```

The config object and message in the response are both optional.

## Deprovision

```
Request: DELETE https://username:password@api.heroku.com/heroku/resources/:id
Request Body: none
Response Status: 200
```

## Exceptions

```
Request: https://username:password@api.heroku.com/
Request Body: any
Response Status: 422
Response Body: { "message": "your message here" }
```

For 422 and 503 responses the message property from your JSON response will be
displayed to the user. For all other responses, and when no message property is available,
a standard error message will displayed.

## Single sign-on

```
Request: POST https://username:password@api.heroku.com/sso/login/
Request Body: id=<id>&token=<token>&timestamp=<ts>&nav-data=<data>&email=<user-email>&app=<app-name>&other=vals
Response Header: Set-Cookie: heroku-nav-data=<data>
Response Body: Web view for logged-in user
```

Optional values can be passed through by appending them to the Heroku API SSO URL. Users can be automatically logged in to and add-on dashboard via SSO by directing them to

```
https://api.heroku.com/myapps/<heroku_app_id>/addons/<addon-name>?other=vals
```

See [manifest formats](https://addons.heroku.com/provider/resources/technical/reference/manifest) for more information about configuring single sign-on.

## App Info API

After your addon is provisioned, you can use the [App Info API](https://addons.heroku.com/provider/resources/technical/reference/app-info) to query information about your addon installations or to update the Config Vars for your addon. 