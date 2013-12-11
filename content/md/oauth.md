---
title: OAuth
slug: oauth
url: https://devcenter.heroku.com/articles/oauth
description: OAuth provides a way to authorize and revoke access to your account to yourself and third parties. OAuth is the preferred authentication mechanism for the Platform API due to the ability to granularly grant and revoke access to some or
---

OAuth provides a way to authorize and revoke access to your account to yourself and third parties. Third parties can use this to provide services, such as monitoring and scaling your applications. You can also use these tokens obtained with OAuth to grant access for your own scripts on your machine or to other applications.

The Heroku Platform API implements OAuth version 2.0 as the preferred authentication mechanism. For further details of the specific API endpoints see the [Platform API Reference](https://devcenter.heroku.com/articles/platform-api-reference).

Third parties who wish to provide services to Heroku users should implement [web application authorization](#web-application-authorization). Users who would like to use a personal OAuth token should instead use [direct authorization](#direct-authorization).

## A note on architecture

An OAuth authorization can be generated in one of two ways: via web authorization flow, or from the Heroku API. The web authorization flow (located at the domain `id.heroku.com`) is designed to easily support common OAuth conventions and be accessible to widely-used libraries. The component supporting this web flow is itself built on the Heroku API (located at the domain `api.heroku.com`), which is the canonical source for all OAuth data. Both components will be covered in this article.

## Web application authorization

Web application authorization allows third parties to ask for and gain access to the resources of a Heroku user, which they can then use to provide services and features on top of the Heroku platform.

### Register client

The client is what identifies you, the third-party integrator, to Heroku and to authorizing users. When you register a client, you provide a callback URL and a name. The name is displayed to users when authorization is requested, so choose a name that identifies your site or application.

There are three ways to register a client: on [dashboard](https://dashboard.heroku.com/account) (easiest), using the [heroku-oauth](https://github.com/heroku/heroku-oauth) CLI plugin or [using the API directly](platform-api-reference#oauth-client).

When you register a client, you get an ID and a secret that you use to authorize Heroku users against.

### OAuth flow

This section describes the flow required to authorize your app to get access to a Heroku user's account.

#### Redirect to Heroku

From your app, redirect the user to authorize:

```
GET https://id.heroku.com/oauth/authorize?client_id={client-id}&response_type=code&scope={scopes}&state={anti-forgery-token}
```

Include `client-id` in the request, which is the public identifier of an OAuth client. Also make sure to to include `response_type`, and to set it to `code`, which is the only currently supported grant type.

The `scope` URL parameter is a space-delimited (and url-encoded) list of the authorization scopes you are requesting. See [available scopes below](#scopes).

The `state` parameter is a unique string used to maintain state between Heroku's OAuth provider and your app. When Heroku redirects users back to your app's `redirect_uri`, this parameter's value will be included in the response (see below). This parameter's value should be an anti-forgery token to protect against [cross-site request forgery](http://en.wikipedia.org/wiki/Cross-site_request_forgery) (CSRF).

#### Redirect back

The user will then be redirected back, based on the client redirect uri:

```
GET {redirect-uri}?code={code}&state={anti-forgery-token}
```

#### Token exchange

Given the code from the redirect url, a token may now be acquired.

```
POST /oauth/token
```

#### Curl Example
```term
$ curl -X POST https://id.heroku.com/oauth/token \
-d "grant_type=authorization_code&code=01234567-89ab-cdef-0123-456789abcdef&client_secret=01234567-89ab-cdef-0123-456789abcdef"
```

#### Response
```
HTTP/1.1 200 OK
Content-Type: application/json;charset=utf-8
```
```javascript
{
  "access_token":"01234567-89ab-cdef-0123-456789abcdef",
  "expires_in":28799,
  "refresh_token":"01234567-89ab-cdef-0123-456789abcdef",
  "token_type":"Bearer",
  "user_id":"01234567-89ab-cdef-0123-456789abcdef",
  "session_nonce":"2bf3ec81701ec291"
}
```

Subsequent requests should authenticate by adding the access token's `token` value to the `Authorization` header and specifying type `Bearer`. For example, given the access token `01234567-89ab-cdef-0123-456789abcdef`, request headers should be set to `Authorization: Bearer 01234567-89ab-cdef-0123-456789abcdef`.

### Token refresh

Access tokens expire 8 hours after they are issued. The refresh token can be used to make a request for a new access token, similar to the initial access token exchange. Refresh tokens don't expire.

```
POST /oauth/token
```

#### Curl example

```term
$ curl -X POST https://id.heroku.com/oauth/token \ 
-d "grant_type=refresh_token&refresh_token=036b9495-b39d-4626-b53a-34399e7bc737&client_secret=fa86a593-d854-4a3f-b68c-c6cc45fb6704"
```

#### Response

```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "access_token":"811235f4-16d3-476e-b940-ed5dfc7d6513",
  "expires_in":7199,
  "refresh_token":"036b9495-b39d-4626-b53a-34399e7bc737",
  "token_type":"Bearer",
  "user_id":"01234567-89ab-cdef-0123-456789abcdef",
  "session_nonce":"2bf3ec81701ec291"
}
```

Subsequent requests should authenticate by adding the access token's `token` value to the `Authorization` header and specifying type `Bearer`. For example, given the access token `01234567-89ab-cdef-0123-456789abcdef`, request headers should be set to `Authorization: Bearer 01234567-89ab-cdef-0123-456789abcdef`.

## Scopes

The following scopes are supported by the API:

* `global`: Read and write access to all of your account, apps and resources. Equivalent to the [default authorization obtained when using the CLI](https://devcenter.heroku.com/articles/authentication).
* `identity`: Read-only access to your [account information](https://devcenter.heroku.com/articles/platform-api-reference#account).
* `read` and `write`: Read and write access to all of your apps and resources, excluding account information and configuration variables. This scope lets you request access to an account without necessarily getting access to runtime secrets such as database connection strings.
* `read-protected` and `write-protected`: Read and write access to all of your apps and resources, excluding account information. This scope lets you request access to an account including access to runtime secrets such as database connection strings.

## Direct authorization

Direct authorization is used to provide a simpler workflow when users are creating authorizations for themselves. It allows the exchange of username and password for a non-expiring token.

### Token exchange

In order to acquire a direct authorization, a request is made to create an authorization while passing username and password in basic auth. A description may also be included to help distinguish this authorization from others, and like the web flow, the authorization can also be scoped to particular permissions on the account.

HTTP basic authentication must be constructed from the [api token](https://devcenter.heroku.com/articles/authentication) as `:{token}` (note the pre-pended colon), base64 encoded and passed as the Authorization header for each request, for example `Authorization: Basic 0123456789ABCDEF=`.

```
POST /oauth/authorizations
```

#### Curl example

```term
$ curl -X POST https://api.heroku.com/oauth/authorizations \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: Basic 0123456789ABCDEF=" \
-H "Content-Type: application/json" \
-d "{\"description\":\"sample authorization\"}"
```
#### Response

```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript```
{
  "access_token": {
    "expires_in": 2592000,
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "token": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "client": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example",
    "redirect_uri": "https://example.com/auth/heroku/callback"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "grant": {
    "code": "01234567-89ab-cdef-0123-456789abcdef",
    "expires_in": 2592000,
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "refresh_token": {
    "expires_in": 2592000,
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "token": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "scope": [
    "global"
  ],
  "updated_at": "2012-01-01T12:00:00Z"
}
```

Subsequent requests should use the access token's `token` value base64 encoded and prepended with a colon in the Authorization header. For example, given the token `01234567-89ab-cdef-0123-456789abcdef`, you'd base64 encode the string `:01234567-89ab-cdef-0123-456789abcdef` and set the header to `Authorization: Bearer MDEyMzQ1NjctODlhYi1jZGVmLTAxMjMtNDU2Nzg5YWJjZGVm`

Access tokens acquired through the direct authorization flow do not expire.

## Revoking authorization

Revoking an authorization will block associated tokens from making further requests.

```
DELETE /oauth/authorizations/{authorization-id}
```

#### Curl example

```term
$ curl -X DELETE https://api.heroku.com/oauth/authorizations/$AUTHORIZATION_ID \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: Bearer 0123456789ABCDEF="
```
#### Response

```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript```
{
  "access_token": {
    "expires_in": 2592000,
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "token": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "client": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example",
    "redirect_uri": "https://example.com/auth/heroku/callback"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "grant": {
    "code": "01234567-89ab-cdef-0123-456789abcdef",
    "expires_in": 2592000,
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "refresh_token": {
    "expires_in": 2592000,
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "token": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "scope": [
    "global"
  ],
  "updated_at": "2012-01-01T12:00:00Z"
}

```

## Resources and examples

* [Platform API Reference](/articles/platform-api-reference)
* [Heroku CLI plugin to manage OAuth clients and authorizations](https://github.com/heroku/heroku-oauth)
* [Ruby sample app](https://github.com/heroku/heroku-oauth-example-ruby) demonstrating OAuth
* [Go sample app](https://github.com/heroku/heroku-oauth-example-go) demonstrating OAuth
* [OmniAuth Strategy for Heroku](https://github.com/heroku/omniauth-heroku)
* Ruby Rack middleware [Heroku Bouncer](https://github.com/heroku/heroku-bouncer)
* [Python WSGI middleware](https://github.com/heroku/heroku-bouncer-python)
* [log2viz](https://github.com/heroku/log2viz) log analyzer that uses OAuth