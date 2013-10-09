---
title: Getting Started with the Platform API
slug: platform-api-quickstart
url: https://devcenter.heroku.com/articles/platform-api-quickstart
description: A tutorial showing how to get started with the Heroku Platform API, which lets you programmatically automate, extend and combine Heroku with other services.
---

<div class="warning">The Platform API is a <a href="https://devcenter.heroku.com/articles/heroku-beta-features">beta feature</a>. Functionality may change prior to general availability.</div>

This is a brief guide to help you get started with the Heroku Platform API. For a detailed reference, please see the [Platform API Reference](https://devcenter.heroku.com/articles/platform-api-reference) article.

## Prerequisites

1. A shell with [`curl`](http://curl.haxx.se/)
2. A Heroku user account. [Signup is free and instant](https://api.heroku.com/signup/devcenter).

## Samples

The samples below use `curl` simply for convenience. We recommend using your favorite programming language and a HTTP library with the API.

## Authentication

Authentication is passed in the `Authorization` header with a value set to `:{api-key}`, base64 encoded. You can find your api-key on the ["Account" page](https://dashboard.heroku.com/account) on dashboard or by running this command:

```term
$ heroku auth:token
01234567-89ab-cdef-0123-456789abcdef
```

If you are using `curl` and the Heroku toolbelt, then `curl` can handle authentication details by reading the `netrc` file as [demonstrated in the reference](https://devcenter.heroku.com/articles/platform-api-reference). The computation is included here for demonstration purposes.

Here's how to generate the header value with Bash and store it in the `$TUTORIAL_KEY` var:

```term
$ TUTORIAL_KEY=`(echo -n ":" ; heroku auth:token) | base64` ; echo $TUTORIAL_KEY
OjAxMjM0NTY3LTg5YWItY2RlZi0wMTIzLTQ1Njc4OWFiY2RlZgo=
```

## Calling the API

With the `Authorization` value in place, you can call the API. First create an app:

```term
$ curl -X POST https://api.heroku.com/apps \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: $TUTORIAL_KEY"
```

Note that we pass two headers, `Authorization` to authenticate and `Accept` to specify API version.

The API returns JSON with details of the newly created app:

```Javascript
{
  "created_at":"2013-05-21T22:36:48-00:00",
  "id":"01234567-89ab-cdef-0123-456789abcdef",
  "git_url":"git@heroku.com:cryptic-ocean-8852.git",
  "name":"cryptic-ocean-8852",
  ...
}
```

You can also query the API for info on the app you created by passing the id in the path:

```term
$ curl -X GET https://api.heroku.com/apps/01234567-89ab-cdef-0123-456789abcdef \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: $TUTORIAL_KEY"
```

You can also list all the apps that you own or collaborate on:

```term
$ curl -X GET https://api.heroku.com/apps \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: $TUTORIAL_KEY"
```

Let's update the name of the app we created above by making a PATCH request to the same path you used for info:

```term
$ curl -X PATCH https://api.heroku.com/apps/01234567-89ab-cdef-0123-456789abcdef \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: $TUTORIAL_KEY" \
-H "Content-Type: application/json" \
-d "{\"name\":\"my-awesome-app\"}"
```

You can also use the name to query the app, which is especially handy when you have changed it to something more memorable:

```term
$ curl https://api.heroku.com/apps/my-awesome-app \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: $TUTORIAL_KEY"
```

Finally, you can clean up and delete the test app:

```term
$ curl -X DELETE https://api.heroku.com/apps/01234567-89ab-cdef-0123-456789abcdef \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: $TUTORIAL_KEY"
```

## Wrap-up

This tutorial demonstrates how to call the Heroku Platform API from Bash and using `curl`, but you can transfer this approach to whatever language and environment you favor. The tutorial focused specifically on creating, updating and deleting apps. The API has many more resources available, including add-ons, config vars and domains. They all work quite similarly to apps and detailed information can be found in the [API reference](https://devcenter.heroku.com/articles/platform-api-reference).