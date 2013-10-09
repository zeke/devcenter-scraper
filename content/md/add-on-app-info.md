---
title: Add-on Provider App Info API
slug: add-on-app-info
url: https://devcenter.heroku.com/articles/add-on-app-info
description: API reference for App Info
---

This is a reference document for the API calls you can use to query information about your add-on installations. In these examples you are issuing the requests and Heroku is providing the response. All calls should use HTTP basic auth with the add-on id and password specified in your add-on manifest.


## Get All Apps

``` json
Request       : GET https://username:password@api.heroku.com/vendor/apps
Response Body : 
  [
    { "provider_id": "1",
      "heroku_id": "app123@heroku.com",
      "callback_url": "https://api.heroku.com/vendor/apps/app123%40heroku.com",
      "plan": "test" },
    { "provider_id": "3",
      "heroku_id": "app456@heroku.com",
      "callback_url": "https://api.heroku.com/vendor/apps/app456%40heroku.com",
      "plan": "premium" }
  ]
```

Use this call to get a list of apps that have installed your add-on.

## Result Pagination

Results larger than 4000 will be paginated. Pagination information is passed
via the `Link` HTTP header. Use those URIs to navigate the pagination rather
than constructing them in your client code.

Example:

```
Link: <https://api.heroku.com/vendor/apps?offset=100>; rel="prev",   <https://api.heroku.com/vendor/apps?offset=1000>; rel="next"
```

The possible `rel` values within that header are:

- `next`: Shows the URL of the immediate next page of results.
- `prev`: Shows the URL of the immediate previous page of results.

## Get App Info

```  json
Request       : GET https://username:password@api.heroku.com/vendor/apps/:heroku_id
Response Body : 
  { "id": "app123@heroku.com",
    "name": "myapp",
    "config": {"MYADDON_URL": "http://myaddon.com/52e82f5d73"},
    "callback_url": "https://api.heroku.com/vendor/apps/app123%40heroku.com",
    "owner_email": "glenn@heroku.com",
    "region": "amazon-web-services::us-east-1",
    "domains": ["www.the-consumer.com", "the-consumer.com"]
  }
```
Use this call to get the full set of details on any of your add-on instances.

## Update Config Vars

``` json
Request        : PUT https://username:password@api.heroku.com/vendor/apps/:heroku_id
Request Body   : { "config": {"MYADDON_URL": "http://myaddon.com/ABC123"}}
Response       : 200 OK
```

Use this call to update config vars you have set for an application during provisioning.

You can only update config vars that have been declared in your addon-manifest.json.