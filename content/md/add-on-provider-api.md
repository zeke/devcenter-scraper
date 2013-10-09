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
  "logplex_token": "t.abc123",
  "options": {}
}
Response Body: {
  "id": 456,
  "config": {"MYADDON_URL": "http://myaddon.com/52e82f5d73"},
  "message": "your message here"
}
```
Only information which is immutable between requests is provided at the time of provisioning.
If you wish to access information which can change (e.g., owner email address or application name) then it is available via the [App Info API](https://addons.heroku.com/provider/resources/technical/reference/app-info). The App Info API will return a 4XX response until you've returned a successful provisioning request to Heroku, as a result we recommend accessing it asynchronously after provisioning. It is the responsibility of the provider to periodically check this endpoint to ensure data is consistent. 

The `region` attribute in the request specifies geographical region of the app that the add-on is being provisioned to. Use this to provision the resource in geopgraphical proximity to the app, ignore it (if your add-on is not latency sensitive) or respond with an error if your add-on does not support apps in the region specified.

The `logplex_token` attribute is provided so that logs can be sent to the app's log stream. For more information, see [the article describing logplex input](add-on-provider-log-integration).

The `options` object in the request are [extra command line options](/articles/additional-provisioning-options) passed in to the `heroku addons:add` command.

The `id` value returned in the response may be a string or integer value. It should be an
immutable value that can be used to address the relationship between this app and resource. This means that a plan change can *not* change the value of this `id`, you can however update the
`config` later to point the app to a different resource.

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

See [manifest formats](https://addons.heroku.com/provider/resources/technical/reference/manifest) for more information about configuring single sign-on via GET or POST.

## List Apps
This endpoint returns a list of apps that have installed your add-on.

```
Request: GET https://username:password@api.heroku.com/vendor/apps
Response Body: [
  { "provider_id": "1", 
    "heroku_id": "app123@heroku.com", 
    "callback_url": "https://api.heroku.com/vendor/apps/app123%40heroku.com", 
    "plan": "test" 
  },
  { "provider_id": "3", 
    "heroku_id": "app456@heroku.com", 
    "callback_url": "https://api.heroku.com/vendor/apps/app456%40heroku.com", 
    "plan": "premium" 
  }
]
```

### Pagination

Results larger than 4000 will be paginated. Pagination information is passed
via the `Link` HTTP header. Use those URIs to navigate the pagination rather
than constructing them in your client code.

Example:

```
Link: <https://api.heroku.com/vendor/apps?offset=100>; rel="prev",
      <https://api.heroku.com/vendor/apps?offset=1000>; rel="next"
```

The possible `rel` values within that header are:

`next`: Shows the URL of the immediate next page of results.  
`prev`: Shows the URL of the immediate previous page of results.

## App Info
This endpoint returns app information for an app which has installed the Add-on. Information returned is mutable and should be updated when the most recent data is required.

```
Request: GET https://username:password@api.heroku.com/vendor/apps/:heroku_id
Response Body: { 
  "id": "app123@heroku.com",
  "name": "myapp", 
  "config": {"MYADDON_URL": "http://myaddon.com/52e82f5d73"}, 
  "callback_url": "https://api.heroku.com/vendor/apps/app123%40heroku.com", 
  "owner_email": "user@email.com",
  "region": "amazon-web-services::us-east-1",
  "logplex_token": "t.abc123",
  "domains": ["www.the-consumer.com", "the-consumer.com"]
}
```

## Update config Vars
This endpoint allows the Add-on provider to update the config vars defined in the Add-on provider's manifest.

```
Request: PUT https://username:password@api.heroku.com/vendor/apps/:heroku_id 
Request Body : { "config": {"MYADDON_URL": "http://myaddon.com/ABC123"}}
Response: 200 OK
```