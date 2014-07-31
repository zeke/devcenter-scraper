---
title: Platform API Reference
slug: platform-api-reference
url: https://devcenter.heroku.com/articles/platform-api-reference
description: A technical description of the Heroku Platform API, which lets you programmatically automate, extend and combine Heroku with other services.
---

<!--
DON'T EDIT THIS ARTICLE.
It is auto-generated, so please leave comments instead.
-->

## Overview

The platform API empowers developers to automate, extend and combine Heroku with other services. You can use the platform API to programmatically create apps, provision add-ons and perform other tasks that could previously only be accomplished with Heroku toolbelt or dashboard. For details on getting started, see [Getting Started with the Platform API](https://devcenter.heroku.com/articles/platform-api-quickstart).

### Authentication

OAuth should be used to authorize and revoke access to your account to yourself and third parties. Details can be found in the [OAuth article](https://devcenter.heroku.com/articles/oauth).

For personal scripts you may also use HTTP basic authentication, but OAuth is recommended for any third party services. HTTP basic authentication must be constructed using an [API token](https://devcenter.heroku.com/articles/authentication) as `:{token}`, base64 encoded and passed as the Authorization header for each request, for example `Authorization: Basic 0123456789ABCDEF=`. The [quick start guide](https://devcenter.heroku.com/articles/platform-api-quickstart#authentication) has more details.

### Caching

All responses include an `ETag` (or Entity Tag) header, identifying the specific version of a returned resource. You may use this value to check for changes to a resource by repeating the request and passing the `ETag` value in the `If-None-Match` header. If the resource has not changed, a `304 Not Modified` status will be returned with an empty body. If the resource has changed, the request will proceed normally.

### Clients

Clients must address requests to `api.heroku.com` using HTTPS and specify the `Accept: application/vnd.heroku+json; version=3` Accept header. Clients should specify a `User-Agent` header to facilitate tracking and debugging.

### CORS

The Platform API supports cross-origin resource sharing (CORS) so that requests can be sent from browsers using JavaScript served from any domain.

### Schema

The API has a machine-readable [JSON schema](http://json-schema.org/) that describes what resources are available via the API, what their URLs are, how they are represented and what operations they support. You can access the schema using cURL:

```bash
$ curl https://api.heroku.com/schema \
-H "Accept: application/vnd.heroku+json; version=3"
```
```json
{
  "description": "The platform API empowers developers to automate, extend and combine Heroku with other services.",
  "definitions": {
  ...
  }
}
```

### cURL Examples

cURL examples are provided to facilitate experimentation. Variable values are represented as `$SOMETHING` so that you can manipulate them using environment variables. Examples use the `-n` option to fetch credentials from a `~/.netrc` file, which should include an entry for `api.heroku.com` similar to the following:

```
machine api.heroku.com
  login {your-email}
  password {your-api-token}
```

Because Heroku's V3 API is only accessible through HTTP `Accept` header, it may also be convenient to create a cURL alias for easy access:

```
alias c3='curl -n -H "Accept: application/vnd.heroku+json; version=3"'
```

### Custom Types

| Name      | JSON Type | Description
| --------- | --------- | ---
| date-time | string    | timestamp in iso8601 format
| uuid      | string    | uuid in 8-4-4-4-12 format

### Data Integrity

Both unique id and more human-friendly attributes can be used reference resources. For example you can use `name` or `id` to refer to an app. Though the human-friendly version may be more convenient, `id` should be preferred to avoid ambiguity.

You may pass the `If-Match` header with an `ETag` value from a previous response to ensure a resource has not changed since you last received it. If the resource has changed, you will receive a `412 Precondition Failed` response. If the resource has not changed, the request will proceed normally.

### Errors

Failing responses will have an appropriate [status](#statuses) and a JSON body containing more details about a particular error. See [error responses](#error-responses) for more example ids.

### Error Attributes

| Name    | Type   | Description                                         | Example
| ------- | ------ | --------------------------------------------------- | ---
| id      | string | id of error raised                                  | ```"rate_limit"```
| message | string | end user message of error raised                    | ```"Your account reached the API limit. Please wait a few minutes before making new requests"```
| url     | string | reference url with more information about the error | ```https://devcenter.heroku.com/articles/platform-api-reference#rate-limits```

Note that the `url` is included only when relevant and may not be present in the response.

### Error Response

```
HTTP/1.1 429 Too Many Requests
```

```javascript
{
  "id":       "rate_limit",
  "message":  "Your account reached the API rate limit\nPlease wait a few minutes before making new requests",
  "url":      "https://devcenter.heroku.com/articles/platform-api-reference#rate-limits"
}
```

### Legacy API

Those utilizing the legacy, v2 API should instead consult [legacy-api-docs.heroku.com](https://legacy-api-docs.heroku.com)

### Methods

| Method | Usage
| ------ | ---
| DELETE | used for destroying existing objects
| GET    | used for retrieving lists and individual objects
| HEAD   | used for retrieving metadata about existing objects
| PATCH  | used for updating existing objects
| POST   | used for creating new objects

### Method Override

When using a client that does not support all of the [methods](#methods), you can override by using a `POST` and setting the `X-Http-Method-Override` header to the desired methed. For instance, to do a `PATCH` request, do a `POST` with header `X-Http-Method-Override: PATCH`.

### Parameters

Values that can be provided for an action are divided between optional and required values. The expected type for each value is specified and unlisted values should be considered immutable. Parameters should be JSON encoded and passed in the request body.

### Ranges

List requests will return a `Content-Range` header indicating the range of values returned. Large lists may require additional requests to retrieve. If a list response has been truncated you will receive a `206 Partial Content` status and the `Next-Range` header set. To retrieve the next range, repeat the request with the `Range` header set to the value of the previous request's `Next-Range` header.

The number of values returned in a range can be controlled using a `max` key in the `Range` header. For example, to get only the first 10 values, set this header: `Range: id ..; max=10;`. `max` can also be passed when iterating over `Next-Range`. The default page size is 200 and maximum page size is 1000.

The property used to sort values in a list response can be changed. The default property is `id`, as in `Range: id ..;`. To learn what other properties you can use to sort a list response, inspect the `Accept-Ranges` headers. For the `apps` resource, for example, you can sort on either `id` or `name`:

```bash
$ curl -i -n -X GET https://api.heroku.com/apps \
-H "Accept: application/vnd.heroku+json; version=3"
```
```
...
Accept-Ranges: id, name
...
```

The default sort order for resource lists responses is ascending. You can opt for descending sort order by passing a `order` key in the range header:

```bash
$ curl -i -n -X GET https://api.heroku.com/apps \
-H "Accept: application/vnd.heroku+json; version=3" -H "Range: name ..; order=desc;"
```

Combining with the `max` key would look like this:

```bash
$ curl -i -n -X GET https://api.heroku.com/apps \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Range: name ..; order=desc,max=10;"
```

### Rate Limits

The API limits the number of requests each user can make per hour to protect against abuse and buggy code. Each account has a pool of request tokens that can hold at most 2400 tokens. Each API call removes one token from the pool. Tokens are added to the account pool at a rate of roughly 20 per minute (or 1200 per hour), up to a maximum of 2400. If no tokens remain, further calls will return 429 `Too Many Requests` until more tokens become available.

You can use the `RateLimit-Remaining` response header to check your current token count. You can also query the [rate limit](#rate-limits) endpoint to get your token count. Requests to the rate limit endpoint do not count toward the limit. If you find your account is being rate limited but don't know the cause, consider cycling your API key on the account page on Heroku dashboard.

### Request Id

Each API response contains a unique request id in the `Request-Id` header to facilitate tracking. When reporting issues, providing this value makes it easier to pinpoint problems and provide solutions more quickly.

### Responses

Values returned by the API are split into a section with example status code and relevant headers (with common http headers omitted) and a section with an example JSON body (if any).

### Response Headers

| Header              | Description
| ------------------- | -----------
| RateLimit-Remaining | allowed requests remaining in current interval

### Stability

Each resource in the Heroku Platform API Schema is annotated with a `stability` attribute, which will be set to one of three values: `prototype`, `development`, or `production`.
This attribute reflects the change management policy in place for the resource. For a full explanation of these policies, please see the [Dev Center API compatibility article](https://devcenter.heroku.com/articles/api-compatibility-policy).

### Statuses

The result of responses can be determined by returned status.

#### Successful Responses

| Status              | Description
| ------------------- | -----------
| 200 OK              | request succeeded
| 201 Created         | resource created, for example a new app was created or an add-on was provisioned
| 202 Accepted        | request accepted, but the processing has not been completed
| 206 Partial Content | request succeeded, but this is only a partial response, see [ranges](#ranges)

#### Error Responses

Error responses can be divided in to two classes. Client errors result from malformed requests and should be addressed by the client. Heroku errors result from problems on the server side and must be addressed internally.

##### Client Error Responses

| Status                                | Error ID                          | Description
| ------------------------------------- | --------------------------------- | -----------
| 400  Bad Request                      | `bad_request`                     | request invalid, validate usage and try again
| 401  Unauthorized                     | `unauthorized`                    | request not authenticated, API token is missing, invalid or expired
| 402  Payment Required                 | `delinquent`                      | either the account has become delinquent as a result of non-payment, or the account's payment method must be confirmed to continue
| 403  Forbidden                        | `forbidden`                       | request not authorized, provided credentials do not provide access to specified resource
| 403  Forbidden                        | `suspended`                       | request not authorized, account or application was suspended.
| 404  Not Found                        | `not_found`                       | request failed, the specified resource does not exist
| 406  Not Acceptable                   | `not_acceptable`                  | request failed, set ```Accept: application/vnd.heroku+json; version=3``` header and try again
| 416  Requested Range Not Satisfiable  | `requested_range_not_satisfiable` | request failed, validate ```Content-Range``` header and try again
| 422  Unprocessable Entity             | `invalid_params`                  | request failed, validate parameters try again
| 422  Unprocessable Entity             | `verification_needed`             | request failed, enter billing information in the [Heroku Dashboard](https://dashboard.heroku.com/account) before utilizing resources.
| 429  Too Many Requests                | `rate_limit`                      | request failed, wait for rate limits to reset and try again, see [rate limits](#rate-limits)

##### Heroku Error Responses

| Status                      | Description
| ----------------------------| -----------
| 500  Internal Server Error  | error occurred, we are notified, but contact [support](https://help.heroku.com) if the issue persists
| 503  Service Unavailable    | API is unavailable, check response body or [Heroku status](https://status.heroku.com) for details

### Versioning

The current version of the API is version 3. See the [API compatibility policy article](api-compatibility-policy) for details on versioning.

## Account Feature
Stability: `production`

An account feature represents a Heroku labs capability that can be enabled or disabled for an account on Heroku.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when account feature was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>description of account feature</td>
    <td><code>"Causes account to example."</code></td>
  </tr>
  <tr>
    <td><strong>doc_url</strong></td>
    <td><em>string</em></td>
    <td>documentation URL of account feature</td>
    <td><code>"http://devcenter.heroku.com/articles/example"</code></td>
  </tr>
  <tr>
    <td><strong>enabled</strong></td>
    <td><em>boolean</em></td>
    <td>whether or not account feature has been enabled</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of account feature</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name of account feature</td>
    <td><code>"name"</code></td>
  </tr>
  <tr>
    <td><strong>state</strong></td>
    <td><em>string</em></td>
    <td>state of account feature</td>
    <td><code>"public"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when account feature was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Account Feature Info
Info for an existing account feature.


```
GET /account/features/{account_feature_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account/features/$ACCOUNT_FEATURE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "description": "Causes account to example.",
  "doc_url": "http://devcenter.heroku.com/articles/example",
  "enabled": true,
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "name",
  "state": "public",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Account Feature List
List existing account features.

Acceptable order values for the Range header are `id` or `name`.

```
GET /account/features
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account/features \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "description": "Causes account to example.",
    "doc_url": "http://devcenter.heroku.com/articles/example",
    "enabled": true,
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "name",
    "state": "public",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```

### Account Feature Update
Update an existing account feature.


```
PATCH /account/features/{account_feature_id_or_name}
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>enabled</strong></td>
    <td><em>boolean</em></td>
    <td>whether or not account feature has been enabled</td>
    <td><code>true</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/account/features/$ACCOUNT_FEATURE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "enabled": true
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "description": "Causes account to example.",
  "doc_url": "http://devcenter.heroku.com/articles/example",
  "enabled": true,
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "name",
  "state": "public",
  "updated_at": "2012-01-01T12:00:00Z"
}
```


## Account
Stability: `production`

An account represents an individual signed up to use the Heroku platform.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>allow_tracking</strong></td>
    <td><em>boolean</em></td>
    <td>whether to allow third party web activity tracking<br/><b>default:</b> <code>true</code></td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><strong>beta</strong></td>
    <td><em>boolean</em></td>
    <td>whether allowed to utilize beta Heroku features</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when account was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>email</strong></td>
    <td><em>email</em></td>
    <td>unique email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of an account</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>last_login</strong></td>
    <td><em>date-time</em></td>
    <td>when account last authorized with Heroku</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>nullable string</em></td>
    <td>full name of the account owner</td>
    <td><code>"Tina Edmonds"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when account was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>verified</strong></td>
    <td><em>boolean</em></td>
    <td>whether account has been verified with billing information</td>
    <td><code>false</code></td>
  </tr>
</table>

### Account Info
Info for account.


```
GET /account
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "allow_tracking": true,
  "beta": false,
  "created_at": "2012-01-01T12:00:00Z",
  "email": "username@example.com",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "last_login": "2012-01-01T12:00:00Z",
  "name": "Tina Edmonds",
  "updated_at": "2012-01-01T12:00:00Z",
  "verified": false
}
```

### Account Update
Update account.


```
PATCH /account
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>password</strong></td>
    <td><em>string</em></td>
    <td>current password on the account</td>
    <td><code>"currentpassword"</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>allow_tracking</strong></td>
    <td><em>boolean</em></td>
    <td>whether to allow third party web activity tracking<br/><b>default:</b> <code>true</code></td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><strong>beta</strong></td>
    <td><em>boolean</em></td>
    <td>whether allowed to utilize beta Heroku features</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>nullable string</em></td>
    <td>full name of the account owner</td>
    <td><code>"Tina Edmonds"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/account \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "allow_tracking": true,
  "beta": false,
  "name": "Tina Edmonds",
  "password": "currentpassword"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "allow_tracking": true,
  "beta": false,
  "created_at": "2012-01-01T12:00:00Z",
  "email": "username@example.com",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "last_login": "2012-01-01T12:00:00Z",
  "name": "Tina Edmonds",
  "updated_at": "2012-01-01T12:00:00Z",
  "verified": false
}
```

### Account Change Email
Change Email for account.


```
PATCH /account
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>email</strong></td>
    <td><em>email</em></td>
    <td>unique email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>password</strong></td>
    <td><em>string</em></td>
    <td>current password on the account</td>
    <td><code>"currentpassword"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/account \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "email": "username@example.com",
  "password": "currentpassword"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "allow_tracking": true,
  "beta": false,
  "created_at": "2012-01-01T12:00:00Z",
  "email": "username@example.com",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "last_login": "2012-01-01T12:00:00Z",
  "name": "Tina Edmonds",
  "updated_at": "2012-01-01T12:00:00Z",
  "verified": false
}
```

### Account Change Password
Change Password for account.


```
PATCH /account
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>new_password</strong></td>
    <td><em>string</em></td>
    <td>the new password for the account when changing the password</td>
    <td><code>"newpassword"</code></td>
  </tr>
  <tr>
    <td><strong>password</strong></td>
    <td><em>string</em></td>
    <td>current password on the account</td>
    <td><code>"currentpassword"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/account \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "new_password": "newpassword",
  "password": "currentpassword"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "allow_tracking": true,
  "beta": false,
  "created_at": "2012-01-01T12:00:00Z",
  "email": "username@example.com",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "last_login": "2012-01-01T12:00:00Z",
  "name": "Tina Edmonds",
  "updated_at": "2012-01-01T12:00:00Z",
  "verified": false
}
```


## Add-on Service
Stability: `production`

Add-on services represent add-ons that may be provisioned for apps. Endpoints under add-on services can be accessed without authentication.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when addon-service was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this addon-service</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name of this addon-service</td>
    <td><code>"heroku-postgresql"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when addon-service was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Add-on Service Info
Info for existing addon-service.


```
GET /addon-services/{addon_service_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/addon-services/$ADDON_SERVICE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "heroku-postgresql",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Add-on Service List
List existing addon-services.

Acceptable order values for the Range header are `id` or `name`.

```
GET /addon-services
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/addon-services \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```


## Add-on
Stability: `production`

Add-ons represent add-ons that have been provisioned for an app.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>addon_service:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this addon-service</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>addon_service:name</strong></td>
    <td><em>string</em></td>
    <td>unique name of this addon-service</td>
    <td><code>"heroku-postgresql"</code></td>
  </tr>
  <tr>
    <td><strong>config_vars</strong></td>
    <td><em>array</em></td>
    <td>config vars associated with this application</td>
    <td><code>["FOO","BAZ"]</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when add-on was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of add-on</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>name of the add-on unique within its app</td>
    <td><code>"heroku-postgresql-teal"</code></td>
  </tr>
  <tr>
    <td><strong>plan:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this plan</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>plan:name</strong></td>
    <td><em>string</em></td>
    <td>unique name of this plan</td>
    <td><code>"heroku-postgresql:dev"</code></td>
  </tr>
  <tr>
    <td><strong>provider_id</strong></td>
    <td><em>string</em></td>
    <td>id of this add-on with its provider</td>
    <td><code>"app123@heroku.com"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when add-on was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Add-on Create
Create a new add-on.


```
POST /apps/{app_id_or_name}/addons
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>plan</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or name of this plan</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"heroku-postgresql:dev"</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>config</strong></td>
    <td><em>object</em></td>
    <td>custom add-on provisioning options</td>
    <td><code>{"db-version":"1.2.3"}</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/addons \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "config": {
    "db-version": "1.2.3"
  },
  "plan": "01234567-89ab-cdef-0123-456789abcdef"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "addon_service": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql"
  },
  "config_vars": [
    "FOO",
    "BAZ"
  ],
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "heroku-postgresql-teal",
  "plan": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql:dev"
  },
  "provider_id": "app123@heroku.com",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Add-on Delete
Delete an existing add-on.


```
DELETE /apps/{app_id_or_name}/addons/{addon_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/addons/$ADDON_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "addon_service": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql"
  },
  "config_vars": [
    "FOO",
    "BAZ"
  ],
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "heroku-postgresql-teal",
  "plan": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql:dev"
  },
  "provider_id": "app123@heroku.com",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Add-on Info
Info for an existing add-on.


```
GET /apps/{app_id_or_name}/addons/{addon_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/addons/$ADDON_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "addon_service": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql"
  },
  "config_vars": [
    "FOO",
    "BAZ"
  ],
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "heroku-postgresql-teal",
  "plan": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql:dev"
  },
  "provider_id": "app123@heroku.com",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Add-on List
List existing add-ons.

Acceptable order values for the Range header are `id` or `name`.

```
GET /apps/{app_id_or_name}/addons
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/addons \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "addon_service": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "name": "heroku-postgresql"
    },
    "config_vars": [
      "FOO",
      "BAZ"
    ],
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql-teal",
    "plan": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "name": "heroku-postgresql:dev"
    },
    "provider_id": "app123@heroku.com",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```

### Add-on Update
Change add-on plan. Some add-ons may not support changing plans. In that case, an error will be returned.


```
PATCH /apps/{app_id_or_name}/addons/{addon_id_or_name}
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>plan</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or name of this plan</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"heroku-postgresql:dev"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/addons/$ADDON_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "plan": "01234567-89ab-cdef-0123-456789abcdef"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "addon_service": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql"
  },
  "config_vars": [
    "FOO",
    "BAZ"
  ],
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "heroku-postgresql-teal",
  "plan": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql:dev"
  },
  "provider_id": "app123@heroku.com",
  "updated_at": "2012-01-01T12:00:00Z"
}
```


## App Feature
Stability: `production`

An app feature represents a Heroku labs capability that can be enabled or disabled for an app on Heroku.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app feature was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>description of app feature</td>
    <td><code>"Causes app to example."</code></td>
  </tr>
  <tr>
    <td><strong>doc_url</strong></td>
    <td><em>string</em></td>
    <td>documentation URL of app feature</td>
    <td><code>"http://devcenter.heroku.com/articles/example"</code></td>
  </tr>
  <tr>
    <td><strong>enabled</strong></td>
    <td><em>boolean</em></td>
    <td>whether or not app feature has been enabled</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of app feature</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name of app feature</td>
    <td><code>"name"</code></td>
  </tr>
  <tr>
    <td><strong>state</strong></td>
    <td><em>string</em></td>
    <td>state of app feature</td>
    <td><code>"public"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app feature was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### App Feature Info
Info for an existing app feature.


```
GET /apps/{app_id_or_name}/features/{app_feature_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/features/$APP_FEATURE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "description": "Causes app to example.",
  "doc_url": "http://devcenter.heroku.com/articles/example",
  "enabled": true,
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "name",
  "state": "public",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### App Feature List
List existing app features.

Acceptable order values for the Range header are `id` or `name`.

```
GET /apps/{app_id_or_name}/features
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/features \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "description": "Causes app to example.",
    "doc_url": "http://devcenter.heroku.com/articles/example",
    "enabled": true,
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "name",
    "state": "public",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```

### App Feature Update
Update an existing app feature.


```
PATCH /apps/{app_id_or_name}/features/{app_feature_id_or_name}
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>enabled</strong></td>
    <td><em>boolean</em></td>
    <td>whether or not app feature has been enabled</td>
    <td><code>true</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/features/$APP_FEATURE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "enabled": true
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "description": "Causes app to example.",
  "doc_url": "http://devcenter.heroku.com/articles/example",
  "enabled": true,
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "name",
  "state": "public",
  "updated_at": "2012-01-01T12:00:00Z"
}
```


## App Setup
Stability: `production`

An app setup represents an app on Heroku that is setup using an environment, addons, and scripts described in an app.json manifest file.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>app:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of app</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>app:name</strong></td>
    <td><em>string</em></td>
    <td>unique name of app</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>build:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of build</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>build:status</strong></td>
    <td><em>string</em></td>
    <td>status of build<br/><b>one of:</b><code>"failed"</code> or <code>"pending"</code> or <code>"succeeded"</code></td>
    <td><code>"succeeded"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app setup was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>failure_message</strong></td>
    <td><em>nullable string</em></td>
    <td>reason that app setup has failed</td>
    <td><code>"invalid app.json"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of app setup</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>manifest_errors</strong></td>
    <td><em>array</em></td>
    <td>errors associated with invalid app.json manifest file</td>
    <td><code>["config var FOO is required"]</code></td>
  </tr>
  <tr>
    <td><strong>postdeploy</strong></td>
    <td><em>nullable object</em></td>
    <td>result of postdeploy script</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>postdeploy:exit_code</strong></td>
    <td><em>integer</em></td>
    <td>The exit code of the postdeploy script</td>
    <td><code>1</code></td>
  </tr>
  <tr>
    <td><strong>postdeploy:output</strong></td>
    <td><em>string</em></td>
    <td>output of the postdeploy script</td>
    <td><code>"assets precompiled"</code></td>
  </tr>
  <tr>
    <td><strong>resolved_success_url</strong></td>
    <td><em>nullable string</em></td>
    <td>fully qualified success url</td>
    <td><code>"http://example.herokuapp.com/welcome"</code></td>
  </tr>
  <tr>
    <td><strong>status</strong></td>
    <td><em>string</em></td>
    <td>the overall status of app setup<br/><b>one of:</b><code>"failed"</code> or <code>"pending"</code> or <code>"succeeded"</code></td>
    <td><code>"succeeded"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app setup was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### App Setup Create
Create a new app setup from a gzipped tar archive containing an app.json manifest file.


```
POST /app-setups
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>source_blob:url</strong></td>
    <td><em>string</em></td>
    <td>URL of gzipped tarball of source code containing app.json manifest file</td>
    <td><code>"https://example.com/source.tgz?token=xyz"</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>app:name</strong></td>
    <td><em>string</em></td>
    <td>unique name of app</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>app:region</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or name of region</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"us"</code></td>
  </tr>
  <tr>
    <td><strong>app:stack</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or name of stack</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"cedar"</code></td>
  </tr>
  <tr>
    <td><strong>overrides:env</strong></td>
    <td><em>object</em></td>
    <td>overrides of the env specified in the app.json manifest file</td>
    <td><code>{"FOO":"bar","BAZ":"qux"}</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/app-setups \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "app": {
    "name": "example",
    "region": "01234567-89ab-cdef-0123-456789abcdef",
    "stack": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "source_blob": {
    "url": "https://example.com/source.tgz?token=xyz"
  },
  "overrides": {
    "env": {
      "FOO": "bar",
      "BAZ": "qux"
    }
  }
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "created_at": "2012-01-01T12:00:00Z",
  "updated_at": "2012-01-01T12:00:00Z",
  "status": "succeeded",
  "failure_message": "invalid app.json",
  "app": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  },
  "build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "succeeded"
  },
  "manifest_errors": [
    "config var FOO is required"
  ],
  "postdeploy": {
    "output": "assets precompiled",
    "exit_code": 1
  },
  "resolved_success_url": "http://example.herokuapp.com/welcome"
}
```

### App Setup Info
Get the status of an app setup.


```
GET /app-setups/{app_setup_id}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/app-setups/$APP_SETUP_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "created_at": "2012-01-01T12:00:00Z",
  "updated_at": "2012-01-01T12:00:00Z",
  "status": "succeeded",
  "failure_message": "invalid app.json",
  "app": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  },
  "build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "succeeded"
  },
  "manifest_errors": [
    "config var FOO is required"
  ],
  "postdeploy": {
    "output": "assets precompiled",
    "exit_code": 1
  },
  "resolved_success_url": "http://example.herokuapp.com/welcome"
}
```


## App Transfer
Stability: `production`

An app transfer represents a two party interaction for transferring ownership of an app.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>app:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of app</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>app:name</strong></td>
    <td><em>string</em></td>
    <td>unique name of app</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app transfer was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of app transfer</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>owner:email</strong></td>
    <td><em>email</em></td>
    <td>unique email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>owner:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of an account</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>recipient:email</strong></td>
    <td><em>email</em></td>
    <td>unique email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>recipient:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of an account</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>state</strong></td>
    <td><em>string</em></td>
    <td>the current state of an app transfer<br/><b>one of:</b><code>"pending"</code> or <code>"accepted"</code> or <code>"declined"</code></td>
    <td><code>"pending"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app transfer was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### App Transfer Create
Create a new app transfer.


```
POST /account/app-transfers
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>app</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or name of app</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>recipient</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or email address of account</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"username@example.com"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/account/app-transfers \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "app": "01234567-89ab-cdef-0123-456789abcdef",
  "recipient": "01234567-89ab-cdef-0123-456789abcdef"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "app": {
    "name": "example",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "recipient": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "state": "pending",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### App Transfer Delete
Delete an existing app transfer


```
DELETE /account/app-transfers/{app_transfer_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/account/app-transfers/$APP_TRANSFER_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "app": {
    "name": "example",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "recipient": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "state": "pending",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### App Transfer Info
Info for existing app transfer.


```
GET /account/app-transfers/{app_transfer_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account/app-transfers/$APP_TRANSFER_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "app": {
    "name": "example",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "recipient": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "state": "pending",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### App Transfer List
List existing apps transfers.

Acceptable order values for the Range header are `id` or `name`.

```
GET /account/app-transfers
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account/app-transfers \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "app": {
      "name": "example",
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "owner": {
      "email": "username@example.com",
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "recipient": {
      "email": "username@example.com",
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "state": "pending",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```

### App Transfer Update
Update an existing app transfer.


```
PATCH /account/app-transfers/{app_transfer_id_or_name}
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>state</strong></td>
    <td><em>string</em></td>
    <td>the current state of an app transfer<br/><b>one of:</b><code>"pending"</code> or <code>"accepted"</code> or <code>"declined"</code></td>
    <td><code>"pending"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/account/app-transfers/$APP_TRANSFER_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "state": "pending"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "app": {
    "name": "example",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "recipient": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "state": "pending",
  "updated_at": "2012-01-01T12:00:00Z"
}
```


## App
Stability: `production`

An app represents the program that you would like to deploy and run on Heroku.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>archived_at</strong></td>
    <td><em>nullable date-time</em></td>
    <td>when app was archived</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>buildpack_provided_description</strong></td>
    <td><em>nullable string</em></td>
    <td>description from buildpack of app</td>
    <td><code>"Ruby/Rack"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>git_url</strong></td>
    <td><em>string</em></td>
    <td>git repo URL of app</td>
    <td><code>"git@heroku.com:example.git"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>maintenance</strong></td>
    <td><em>boolean</em></td>
    <td>maintenance status of app</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>name of app</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>owner:email</strong></td>
    <td><em>email</em></td>
    <td>email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>owner:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>region:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>region:name</strong></td>
    <td><em>string</em></td>
    <td>name of region</td>
    <td><code>"us"</code></td>
  </tr>
  <tr>
    <td><strong>released_at</strong></td>
    <td><em>nullable date-time</em></td>
    <td>when app was released</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>repo_size</strong></td>
    <td><em>nullable integer</em></td>
    <td>git repo size in bytes of app</td>
    <td><code>0</code></td>
  </tr>
  <tr>
    <td><strong>slug_size</strong></td>
    <td><em>nullable integer</em></td>
    <td>slug size in bytes of app</td>
    <td><code>0</code></td>
  </tr>
  <tr>
    <td><strong>stack:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>stack:name</strong></td>
    <td><em>string</em></td>
    <td>name of stack</td>
    <td><code>"cedar"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>web_url</strong></td>
    <td><em>uri</em></td>
    <td>web URL of app</td>
    <td><code>"http://example.herokuapp.com/"</code></td>
  </tr>
</table>

### App Create
Create a new app.


```
POST /apps
```

#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>name of app</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>region</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or name of region</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"us"</code></td>
  </tr>
  <tr>
    <td><strong>stack</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or name of stack</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"cedar"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "name": "example",
  "region": "01234567-89ab-cdef-0123-456789abcdef",
  "stack": "01234567-89ab-cdef-0123-456789abcdef"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "git@heroku.com:example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "maintenance": false,
  "name": "example",
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "http://example.herokuapp.com/"
}
```

### App Delete
Delete an existing app.


```
DELETE /apps/{app_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "git@heroku.com:example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "maintenance": false,
  "name": "example",
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "http://example.herokuapp.com/"
}
```

### App Info
Info for existing app.


```
GET /apps/{app_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "git@heroku.com:example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "maintenance": false,
  "name": "example",
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "http://example.herokuapp.com/"
}
```

### App List
List existing apps.

Acceptable order values for the Range header are `id`, `name` or `updated_at`.

```
GET /apps
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name, updated_at
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "archived_at": "2012-01-01T12:00:00Z",
    "buildpack_provided_description": "Ruby/Rack",
    "created_at": "2012-01-01T12:00:00Z",
    "git_url": "git@heroku.com:example.git",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "maintenance": false,
    "name": "example",
    "owner": {
      "email": "username@example.com",
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "region": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "name": "us"
    },
    "released_at": "2012-01-01T12:00:00Z",
    "repo_size": 0,
    "slug_size": 0,
    "stack": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "name": "cedar"
    },
    "updated_at": "2012-01-01T12:00:00Z",
    "web_url": "http://example.herokuapp.com/"
  }
]
```

### App Update
Update an existing app.


```
PATCH /apps/{app_id_or_name}
```

#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>maintenance</strong></td>
    <td><em>boolean</em></td>
    <td>maintenance status of app</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>name of app</td>
    <td><code>"example"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "maintenance": false,
  "name": "example"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "git@heroku.com:example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "maintenance": false,
  "name": "example",
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "http://example.herokuapp.com/"
}
```


## Build Result
Stability: `production`

A build result contains the output from a build.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>build:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of build</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>build:status</strong></td>
    <td><em>string</em></td>
    <td>status of build<br/><b>one of:</b><code>"failed"</code> or <code>"pending"</code> or <code>"succeeded"</code></td>
    <td><code>"succeeded"</code></td>
  </tr>
  <tr>
    <td><strong>exit_code</strong></td>
    <td><em>number</em></td>
    <td>status from the build</td>
    <td><code>0</code></td>
  </tr>
  <tr>
    <td><strong>lines</strong></td>
    <td><em>array</em></td>
    <td>A list of all the lines of a build's output.</td>
    <td><code>[{"line":"-----\u003E Ruby app detected\n","stream":"STDOUT"}]</code></td>
  </tr>
</table>

### Build Result Info
Info for existing result.


```
GET /apps/{app_id_or_name}/builds/{build_id}/result
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/builds/$BUILD_ID/result \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "build": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "status": "succeeded"
  },
  "exit_code": 0,
  "lines": [
    {
      "line": "-----> Ruby app detected\n",
      "stream": "STDOUT"
    }
  ]
}
```


## Build
Stability: `production`

A build represents the process of transforming a code tarball into a slug

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when build was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of build</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>slug</strong></td>
    <td><em>nullable object</em></td>
    <td>slug created by this build</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>slug:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of slug</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>source_blob:url</strong></td>
    <td><em>string</em></td>
    <td>URL where gzipped tar archive of source code for build was downloaded.</td>
    <td><code>"https://example.com/source.tgz?token=xyz"</code></td>
  </tr>
  <tr>
    <td><strong>source_blob:version</strong></td>
    <td><em>nullable string</em></td>
    <td>Version of the gzipped tarball.</td>
    <td><code>"v1.3.0"</code></td>
  </tr>
  <tr>
    <td><strong>status</strong></td>
    <td><em>string</em></td>
    <td>status of build<br/><b>one of:</b><code>"failed"</code> or <code>"pending"</code> or <code>"succeeded"</code></td>
    <td><code>"succeeded"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when build was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>user:email</strong></td>
    <td><em>email</em></td>
    <td>email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>user:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
</table>

### Build Create
Create a new build.


```
POST /apps/{app_id_or_name}/builds
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>source_blob:url</strong></td>
    <td><em>string</em></td>
    <td>URL where gzipped tar archive of source code for build was downloaded.</td>
    <td><code>"https://example.com/source.tgz?token=xyz"</code></td>
  </tr>
  <tr>
    <td><strong>source_blob:version</strong></td>
    <td><em>nullable string</em></td>
    <td>Version of the gzipped tarball.</td>
    <td><code>"v1.3.0"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/builds \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "source_blob": {
    "url": "https://example.com/source.tgz?token=xyz",
    "version": "v1.3.0"
  }
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "source_blob": {
    "url": "https://example.com/source.tgz?token=xyz",
    "version": "v1.3.0"
  },
  "slug": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "status": "succeeded",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  }
}
```

### Build Info
Info for existing build.


```
GET /apps/{app_id_or_name}/builds/{build_id}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/builds/$BUILD_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "source_blob": {
    "url": "https://example.com/source.tgz?token=xyz",
    "version": "v1.3.0"
  },
  "slug": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "status": "succeeded",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  }
}
```

### Build List
List existing build.

Acceptable order values for the Range header are `id` or `started_at`.

```
GET /apps/{app_id_or_name}/builds
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/builds \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, started_at
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "source_blob": {
      "url": "https://example.com/source.tgz?token=xyz",
      "version": "v1.3.0"
    },
    "slug": {
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "status": "succeeded",
    "updated_at": "2012-01-01T12:00:00Z",
    "user": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "email": "username@example.com"
    }
  }
]
```


## Collaborator
Stability: `production`

A collaborator represents an account that has been given access to an app on Heroku.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when collaborator was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of collaborator</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when collaborator was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>user:email</strong></td>
    <td><em>email</em></td>
    <td>email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>user:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
</table>

### Collaborator Create
Create a new collaborator.


```
POST /apps/{app_id_or_name}/collaborators
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>user</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or email address of account</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"username@example.com"</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>silent</strong></td>
    <td><em>boolean</em></td>
    <td>whether to suppress email invitation when creating collaborator</td>
    <td><code>false</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/collaborators \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "silent": false,
  "user": "01234567-89ab-cdef-0123-456789abcdef"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```

### Collaborator Delete
Delete an existing collaborator.


```
DELETE /apps/{app_id_or_name}/collaborators/{collaborator_email_or_id}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/collaborators/$COLLABORATOR_EMAIL_OR_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```

### Collaborator Info
Info for existing collaborator.


```
GET /apps/{app_id_or_name}/collaborators/{collaborator_email_or_id}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/collaborators/$COLLABORATOR_EMAIL_OR_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```

### Collaborator List
List existing collaborators.

Acceptable order values for the Range header are `email` or `id`.

```
GET /apps/{app_id_or_name}/collaborators
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/collaborators \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: email, id
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "updated_at": "2012-01-01T12:00:00Z",
    "user": {
      "email": "username@example.com",
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    }
  }
]
```


## Config Vars
Stability: `production`

Config Vars allow you to manage the configuration information provided to an app on Heroku.

### Config Vars Info
Get config-vars for app.


```
GET /apps/{app_id_or_name}/config-vars
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/config-vars \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "FOO": "bar",
  "BAZ": "qux"
}
```

### Config Vars Update
Update config-vars for app. You can update existing config-vars by setting them again, and remove by setting it to `NULL`.


```
PATCH /apps/{app_id_or_name}/config-vars
```


#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/config-vars \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "FOO": "bar",
  "BAZ": "qux"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "FOO": "bar",
  "BAZ": "qux"
}
```


## Credit
Stability: `development`

A credit represents value that will be used up before further charges are assigned to an account.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>amount</strong></td>
    <td><em>number</em></td>
    <td>total value of credit in cents</td>
    <td><code>10000</code></td>
  </tr>
  <tr>
    <td><strong>balance</strong></td>
    <td><em>number</em></td>
    <td>remaining value of credit in cents</td>
    <td><code>5000</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when credit was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>expires_at</strong></td>
    <td><em>date-time</em></td>
    <td>when credit will expire</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of credit</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>title</strong></td>
    <td><em>string</em></td>
    <td>a name for credit</td>
    <td><code>"gift card"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when credit was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Credit Info
Info for existing credit.


```
GET /account/credits/{credit_id}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account/credits/$CREDIT_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "amount": 10000,
  "balance": 5000,
  "created_at": "2012-01-01T12:00:00Z",
  "expires_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "title": "gift card",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Credit List
List existing credits.

The only acceptable order value for the Range header is `id`.

```
GET /account/credits
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account/credits \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "amount": 10000,
    "balance": 5000,
    "created_at": "2012-01-01T12:00:00Z",
    "expires_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "title": "gift card",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```


## Domain
Stability: `production`

Domains define what web routes should be routed to an app on Heroku.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when domain was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>hostname</strong></td>
    <td><em>string</em></td>
    <td>full hostname</td>
    <td><code>"subdomain.example.com"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this domain</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when domain was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Domain Create
Create a new domain.


```
POST /apps/{app_id_or_name}/domains
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>hostname</strong></td>
    <td><em>string</em></td>
    <td>full hostname</td>
    <td><code>"subdomain.example.com"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/domains \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "hostname": "subdomain.example.com"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "hostname": "subdomain.example.com",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Domain Delete
Delete an existing domain


```
DELETE /apps/{app_id_or_name}/domains/{domain_id_or_hostname}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/domains/$DOMAIN_ID_OR_HOSTNAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "hostname": "subdomain.example.com",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Domain Info
Info for existing domain.


```
GET /apps/{app_id_or_name}/domains/{domain_id_or_hostname}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/domains/$DOMAIN_ID_OR_HOSTNAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "hostname": "subdomain.example.com",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Domain List
List existing domains.

Acceptable order values for the Range header are `hostname` or `id`.

```
GET /apps/{app_id_or_name}/domains
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/domains \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: hostname, id
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "hostname": "subdomain.example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```


## Dyno
Stability: `production`

Dynos encapsulate running processes of an app on Heroku.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>attach_url</strong></td>
    <td><em>nullable string</em></td>
    <td>a URL to stream output from for attached processes or null for non-attached processes</td>
    <td><code>"rendezvous://rendezvous.runtime.heroku.com:5000/{rendezvous-id}"</code></td>
  </tr>
  <tr>
    <td><strong>command</strong></td>
    <td><em>string</em></td>
    <td>command used to start this process</td>
    <td><code>"bash"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when dyno was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this dyno</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>the name of this process on this dyno</td>
    <td><code>"run.1"</code></td>
  </tr>
  <tr>
    <td><strong>release:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of release</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>release:version</strong></td>
    <td><em>integer</em></td>
    <td>unique version assigned to the release</td>
    <td><code>11</code></td>
  </tr>
  <tr>
    <td><strong>size</strong></td>
    <td><em>string</em></td>
    <td>dyno size (default: "1X")</td>
    <td><code>"1X"</code></td>
  </tr>
  <tr>
    <td><strong>state</strong></td>
    <td><em>string</em></td>
    <td>current status of process (either: crashed, down, idle, starting, or up)</td>
    <td><code>"up"</code></td>
  </tr>
  <tr>
    <td><strong>type</strong></td>
    <td><em>string</em></td>
    <td>type of process</td>
    <td><code>"run"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when process last changed state</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Dyno Create
Create a new dyno.


```
POST /apps/{app_id_or_name}/dynos
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>command</strong></td>
    <td><em>string</em></td>
    <td>command used to start this process</td>
    <td><code>"bash"</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>attach</strong></td>
    <td><em>boolean</em></td>
    <td>whether to stream output or not</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><strong>env</strong></td>
    <td><em>object</em></td>
    <td>custom environment to add to the dyno config vars</td>
    <td><code>{"COLUMNS":"80","LINES":"24"}</code></td>
  </tr>
  <tr>
    <td><strong>size</strong></td>
    <td><em>string</em></td>
    <td>dyno size (default: "1X")</td>
    <td><code>"1X"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "attach": true,
  "command": "bash",
  "env": {
    "COLUMNS": "80",
    "LINES": "24"
  },
  "size": "1X"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "attach_url": "rendezvous://rendezvous.runtime.heroku.com:5000/{rendezvous-id}",
  "command": "bash",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "run.1",
  "release": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "version": 11
  },
  "size": "1X",
  "state": "up",
  "type": "run",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Dyno Restart
Restart dyno.


```
DELETE /apps/{app_id_or_name}/dynos/{dyno_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos/$DYNO_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 202 Accepted
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
```

### Dyno Restart all
Restart all dynos


```
DELETE /apps/{app_id_or_name}/dynos
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 202 Accepted
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
```

### Dyno Info
Info for existing dyno.


```
GET /apps/{app_id_or_name}/dynos/{dyno_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos/$DYNO_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "attach_url": "rendezvous://rendezvous.runtime.heroku.com:5000/{rendezvous-id}",
  "command": "bash",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "run.1",
  "release": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "version": 11
  },
  "size": "1X",
  "state": "up",
  "type": "run",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Dyno List
List existing dynos.

Acceptable order values for the Range header are `id` or `name`.

```
GET /apps/{app_id_or_name}/dynos
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "attach_url": "rendezvous://rendezvous.runtime.heroku.com:5000/{rendezvous-id}",
    "command": "bash",
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "run.1",
    "release": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "version": 11
    },
    "size": "1X",
    "state": "up",
    "type": "run",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```


## Formation
Stability: `production`

The formation of processes that should be maintained for an app. Update the formation to scale processes or change dyno sizes. Available process type names and commands are defined by the `process_types` attribute for the [slug](#slug) currently released on an app.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>command</strong></td>
    <td><em>string</em></td>
    <td>command to use to launch this process</td>
    <td><code>"bundle exec rails server -p $PORT"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when process type was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this process type</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>quantity</strong></td>
    <td><em>integer</em></td>
    <td>number of processes to maintain</td>
    <td><code>1</code></td>
  </tr>
  <tr>
    <td><strong>size</strong></td>
    <td><em>string</em></td>
    <td>dyno size (default: "1X")</td>
    <td><code>"1X"</code></td>
  </tr>
  <tr>
    <td><strong>type</strong></td>
    <td><em>string</em></td>
    <td>type of process to maintain</td>
    <td><code>"web"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when dyno type was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Formation Info
Info for a process type


```
GET /apps/{app_id_or_name}/formation/{formation_id_or_type}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/formation/$FORMATION_ID_OR_TYPE \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "command": "bundle exec rails server -p $PORT",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "quantity": 1,
  "size": "1X",
  "type": "web",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Formation List
List process type formation

Acceptable order values for the Range header are `id` or `type`.

```
GET /apps/{app_id_or_name}/formation
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/formation \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, type
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "command": "bundle exec rails server -p $PORT",
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "quantity": 1,
    "size": "1X",
    "type": "web",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```

### Formation Batch update
Batch update process types


```
PATCH /apps/{app_id_or_name}/formation
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>updates</strong></td>
    <td><em>array</em></td>
    <td>Array with formation updates. Each element must have "process", the id or name of the process type to be updated, and can optionally update its "quantity" or "size".</td>
    <td><code>[{"process":"web","quantity":1,"size":"2X"}]</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/formation \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "updates": [
    {
      "process": "web",
      "quantity": 1,
      "size": "2X"
    }
  ]
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "command": "bundle exec rails server -p $PORT",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "quantity": 1,
  "size": "1X",
  "type": "web",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Formation Update
Update process type


```
PATCH /apps/{app_id_or_name}/formation/{formation_id_or_type}
```

#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>quantity</strong></td>
    <td><em>integer</em></td>
    <td>number of processes to maintain</td>
    <td><code>1</code></td>
  </tr>
  <tr>
    <td><strong>size</strong></td>
    <td><em>string</em></td>
    <td>dyno size (default: "1X")</td>
    <td><code>"1X"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/formation/$FORMATION_ID_OR_TYPE \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "quantity": 1,
  "size": "1X"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "command": "bundle exec rails server -p $PORT",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "quantity": 1,
  "size": "1X",
  "type": "web",
  "updated_at": "2012-01-01T12:00:00Z"
}
```


## Key
Stability: `production`

Keys represent public SSH keys associated with an account and are used to authorize accounts as they are performing git operations.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>comment</strong></td>
    <td><em>string</em></td>
    <td>comment on the key</td>
    <td><code>"username@host"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when key was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>email</strong></td>
    <td><em>string</em></td>
    <td>deprecated. Please refer to 'comment' instead</td>
    <td><code>"username@host"</code></td>
  </tr>
  <tr>
    <td><strong>fingerprint</strong></td>
    <td><em>string</em></td>
    <td>a unique identifying string based on contents</td>
    <td><code>"17:63:a4:ba:24:d3:7f:af:17:c8:94:82:7e:80:56:bf"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this key</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>public_key</strong></td>
    <td><em>string</em></td>
    <td>full public_key as uploaded</td>
    <td><code>"ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when key was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Key Create
Create a new key.


```
POST /account/keys
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>public_key</strong></td>
    <td><em>string</em></td>
    <td>full public_key as uploaded</td>
    <td><code>"ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/account/keys \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "comment": "username@host",
  "created_at": "2012-01-01T12:00:00Z",
  "email": "username@host",
  "fingerprint": "17:63:a4:ba:24:d3:7f:af:17:c8:94:82:7e:80:56:bf",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Key Delete
Delete an existing key


```
DELETE /account/keys/{key_id_or_fingerprint}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/account/keys/$KEY_ID_OR_FINGERPRINT \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "comment": "username@host",
  "created_at": "2012-01-01T12:00:00Z",
  "email": "username@host",
  "fingerprint": "17:63:a4:ba:24:d3:7f:af:17:c8:94:82:7e:80:56:bf",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Key Info
Info for existing key.


```
GET /account/keys/{key_id_or_fingerprint}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account/keys/$KEY_ID_OR_FINGERPRINT \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "comment": "username@host",
  "created_at": "2012-01-01T12:00:00Z",
  "email": "username@host",
  "fingerprint": "17:63:a4:ba:24:d3:7f:af:17:c8:94:82:7e:80:56:bf",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Key List
List existing keys.

Acceptable order values for the Range header are `fingerprint` or `id`.

```
GET /account/keys
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account/keys \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: fingerprint, id
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "comment": "username@host",
    "created_at": "2012-01-01T12:00:00Z",
    "email": "username@host",
    "fingerprint": "17:63:a4:ba:24:d3:7f:af:17:c8:94:82:7e:80:56:bf",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```


## Log Drain
Stability: `production`

[Log drains](https://devcenter.heroku.com/articles/logging#syslog-drains) provide a way to forward your Heroku logs to an external syslog server for long-term archiving. This external service must be configured to receive syslog packets from Heroku, whereupon its URL can be added to an app using this API. Some addons will add a log drain when they are provisioned to an app. These drains can only be removed by removing the add-on.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>addon</strong></td>
    <td><em>nullable object</em></td>
    <td>addon that created the drain</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>addon:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of add-on</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when log drain was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this log drain</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>token</strong></td>
    <td><em>string</em></td>
    <td>token associated with the log drain</td>
    <td><code>"d.01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when log drain was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>url</strong></td>
    <td><em>string</em></td>
    <td>url associated with the log drain</td>
    <td><code>"https://example.com/drain"</code></td>
  </tr>
</table>

### Log Drain Create
Create a new log drain.


```
POST /apps/{app_id_or_name}/log-drains
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>url</strong></td>
    <td><em>string</em></td>
    <td>url associated with the log drain</td>
    <td><code>"https://example.com/drain"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/log-drains \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "url": "https://example.com/drain"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "addon": "example",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "token": "d.01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "url": "https://example.com/drain"
}
```

### Log Drain Delete
Delete an existing log drain. Log drains added by add-ons can only be removed by removing the add-on.


```
DELETE /apps/{app_id_or_name}/log-drains/{log_drain_id_or_url}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/log-drains/$LOG_DRAIN_ID_OR_URL \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "addon": "example",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "token": "d.01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "url": "https://example.com/drain"
}
```

### Log Drain Info
Info for existing log drain.


```
GET /apps/{app_id_or_name}/log-drains/{log_drain_id_or_url}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/log-drains/$LOG_DRAIN_ID_OR_URL \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "addon": "example",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "token": "d.01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "url": "https://example.com/drain"
}
```

### Log Drain List
List existing log drains.

Acceptable order values for the Range header are `id` or `url`.

```
GET /apps/{app_id_or_name}/log-drains
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/log-drains \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, url
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "addon": "example",
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "token": "d.01234567-89ab-cdef-0123-456789abcdef",
    "updated_at": "2012-01-01T12:00:00Z",
    "url": "https://example.com/drain"
  }
]
```


## Log Session
Stability: `production`

A log session is a reference to the http based log stream for an app.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when log connection was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this log session</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>logplex_url</strong></td>
    <td><em>string</em></td>
    <td>URL for log streaming session</td>
    <td><code>"https://logplex.heroku.com/sessions/01234567-89ab-cdef-0123-456789abcdef?srv=1325419200"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when log session was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Log Session Create
Create a new log session.


```
POST /apps/{app_id_or_name}/log-sessions
```

#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>dyno</strong></td>
    <td><em>string</em></td>
    <td>dyno to limit results to</td>
    <td><code>"web.1"</code></td>
  </tr>
  <tr>
    <td><strong>lines</strong></td>
    <td><em>integer</em></td>
    <td>number of log lines to stream at once</td>
    <td><code>10</code></td>
  </tr>
  <tr>
    <td><strong>source</strong></td>
    <td><em>string</em></td>
    <td>log source to limit results to</td>
    <td><code>"app"</code></td>
  </tr>
  <tr>
    <td><strong>tail</strong></td>
    <td><em>boolean</em></td>
    <td>whether to stream ongoing logs</td>
    <td><code>true</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/log-sessions \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "dyno": "web.1",
  "lines": 10,
  "source": "app",
  "tail": true
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "logplex_url": "https://logplex.heroku.com/sessions/01234567-89ab-cdef-0123-456789abcdef?srv=1325419200",
  "updated_at": "2012-01-01T12:00:00Z"
}
```


## OAuth Authorization
Stability: `production`

OAuth authorizations represent clients that a Heroku user has authorized to automate, customize or extend their usage of the platform. For more information please refer to the [Heroku OAuth documentation](https://devcenter.heroku.com/articles/oauth)

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>access_token</strong></td>
    <td><em>nullable object</em></td>
    <td>access token for this authorization</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>access_token:expires_in</strong></td>
    <td><em>nullable integer</em></td>
    <td>seconds until OAuth token expires; may be `null` for tokens with indefinite lifetime</td>
    <td><code>2592000</code></td>
  </tr>
  <tr>
    <td><strong>access_token:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>access_token:token</strong></td>
    <td><em>string</em></td>
    <td>contents of the token to be used for authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>client</strong></td>
    <td><em>nullable object</em></td>
    <td>identifier of the client that obtained this authorization, if any</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>client:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this OAuth client</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>client:name</strong></td>
    <td><em>string</em></td>
    <td>OAuth client name</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>client:redirect_uri</strong></td>
    <td><em>string</em></td>
    <td>endpoint for redirection after authorization with OAuth client</td>
    <td><code>"https://example.com/auth/heroku/callback"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when OAuth authorization was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>grant</strong></td>
    <td><em>nullable object</em></td>
    <td>this authorization's grant</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>grant:code</strong></td>
    <td><em>string</em></td>
    <td>grant code received from OAuth web application authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>grant:expires_in</strong></td>
    <td><em>integer</em></td>
    <td>seconds until OAuth grant expires</td>
    <td><code>2592000</code></td>
  </tr>
  <tr>
    <td><strong>grant:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth grant</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token</strong></td>
    <td><em>nullable object</em></td>
    <td>refresh token for this authorization</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:expires_in</strong></td>
    <td><em>nullable integer</em></td>
    <td>seconds until OAuth token expires; may be `null` for tokens with indefinite lifetime</td>
    <td><code>2592000</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:token</strong></td>
    <td><em>string</em></td>
    <td>contents of the token to be used for authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>scope</strong></td>
    <td><em>array</em></td>
    <td>The scope of access OAuth authorization allows</td>
    <td><code>["global"]</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when OAuth authorization was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### OAuth Authorization Create
Create a new OAuth authorization.


```
POST /oauth/authorizations
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>scope</strong></td>
    <td><em>array</em></td>
    <td>The scope of access OAuth authorization allows</td>
    <td><code>["global"]</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>client</strong></td>
    <td><em>string</em></td>
    <td>unique identifier of this OAuth client</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>human-friendly description of this OAuth authorization</td>
    <td><code>"sample authorization"</code></td>
  </tr>
  <tr>
    <td><strong>expires_in</strong></td>
    <td><em>nullable integer</em></td>
    <td>seconds until OAuth token expires; may be `null` for tokens with indefinite lifetime</td>
    <td><code>2592000</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/oauth/authorizations \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "client": "01234567-89ab-cdef-0123-456789abcdef",
  "description": "sample authorization",
  "expires_in": 2592000,
  "scope": [
    "global"
  ]
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
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

### OAuth Authorization Delete
Delete OAuth authorization.


```
DELETE /oauth/authorizations/{oauth_authorization_id}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/oauth/authorizations/$OAUTH_AUTHORIZATION_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
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

### OAuth Authorization Info
Info for an OAuth authorization.


```
GET /oauth/authorizations/{oauth_authorization_id}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/oauth/authorizations/$OAUTH_AUTHORIZATION_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
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

### OAuth Authorization List
List OAuth authorizations.

The only acceptable order value for the Range header is `id`.

```
GET /oauth/authorizations
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/oauth/authorizations \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
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
]
```


## OAuth Client
Stability: `production`

OAuth clients are applications that Heroku users can authorize to automate, customize or extend their usage of the platform. For more information please refer to the [Heroku OAuth documentation](https://devcenter.heroku.com/articles/oauth).

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when OAuth client was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this OAuth client</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>ignores_delinquent</strong></td>
    <td><em>nullable boolean</em></td>
    <td>whether the client is still operable given a delinquent account</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>OAuth client name</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>redirect_uri</strong></td>
    <td><em>string</em></td>
    <td>endpoint for redirection after authorization with OAuth client</td>
    <td><code>"https://example.com/auth/heroku/callback"</code></td>
  </tr>
  <tr>
    <td><strong>secret</strong></td>
    <td><em>string</em></td>
    <td>secret used to obtain OAuth authorizations under this client</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when OAuth client was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### OAuth Client Create
Create a new OAuth client.


```
POST /oauth/clients
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>OAuth client name</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>redirect_uri</strong></td>
    <td><em>string</em></td>
    <td>endpoint for redirection after authorization with OAuth client</td>
    <td><code>"https://example.com/auth/heroku/callback"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/oauth/clients \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "name": "example",
  "redirect_uri": "https://example.com/auth/heroku/callback"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "ignores_delinquent": false,
  "name": "example",
  "redirect_uri": "https://example.com/auth/heroku/callback",
  "secret": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### OAuth Client Delete
Delete OAuth client.


```
DELETE /oauth/clients/{oauth_client_id}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/oauth/clients/$OAUTH_CLIENT_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "ignores_delinquent": false,
  "name": "example",
  "redirect_uri": "https://example.com/auth/heroku/callback",
  "secret": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### OAuth Client Info
Info for an OAuth client


```
GET /oauth/clients/{oauth_client_id}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/oauth/clients/$OAUTH_CLIENT_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "ignores_delinquent": false,
  "name": "example",
  "redirect_uri": "https://example.com/auth/heroku/callback",
  "secret": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### OAuth Client List
List OAuth clients

The only acceptable order value for the Range header is `id`.

```
GET /oauth/clients
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/oauth/clients \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "ignores_delinquent": false,
    "name": "example",
    "redirect_uri": "https://example.com/auth/heroku/callback",
    "secret": "01234567-89ab-cdef-0123-456789abcdef",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```

### OAuth Client Update
Update OAuth client


```
PATCH /oauth/clients/{oauth_client_id}
```

#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>OAuth client name</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>redirect_uri</strong></td>
    <td><em>string</em></td>
    <td>endpoint for redirection after authorization with OAuth client</td>
    <td><code>"https://example.com/auth/heroku/callback"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/oauth/clients/$OAUTH_CLIENT_ID \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "name": "example",
  "redirect_uri": "https://example.com/auth/heroku/callback"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "ignores_delinquent": false,
  "name": "example",
  "redirect_uri": "https://example.com/auth/heroku/callback",
  "secret": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```



## OAuth Token
Stability: `production`

OAuth tokens provide access for authorized clients to act on behalf of a Heroku user to automate, customize or extend their usage of the platform. For more information please refer to the [Heroku OAuth documentation](https://devcenter.heroku.com/articles/oauth)

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>access_token:expires_in</strong></td>
    <td><em>nullable integer</em></td>
    <td>seconds until OAuth token expires; may be `null` for tokens with indefinite lifetime</td>
    <td><code>2592000</code></td>
  </tr>
  <tr>
    <td><strong>access_token:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>access_token:token</strong></td>
    <td><em>string</em></td>
    <td>contents of the token to be used for authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>authorization:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>client</strong></td>
    <td><em>nullable object</em></td>
    <td>OAuth client secret used to obtain token</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>client:secret</strong></td>
    <td><em>string</em></td>
    <td>secret used to obtain OAuth authorizations under this client</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when OAuth token was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>grant:code</strong></td>
    <td><em>string</em></td>
    <td>grant code received from OAuth web application authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>grant:type</strong></td>
    <td><em>string</em></td>
    <td>type of grant requested, one of `authorization_code` or `refresh_token`</td>
    <td><code>"authorization_code"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:expires_in</strong></td>
    <td><em>nullable integer</em></td>
    <td>seconds until OAuth token expires; may be `null` for tokens with indefinite lifetime</td>
    <td><code>2592000</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:token</strong></td>
    <td><em>string</em></td>
    <td>contents of the token to be used for authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>session:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when OAuth token was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>user:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
</table>

### OAuth Token Create
Create a new OAuth token.


```
POST /oauth/tokens
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>client:secret</strong></td>
    <td><em>string</em></td>
    <td>secret used to obtain OAuth authorizations under this client</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>grant:code</strong></td>
    <td><em>string</em></td>
    <td>grant code received from OAuth web application authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>grant:type</strong></td>
    <td><em>string</em></td>
    <td>type of grant requested, one of `authorization_code` or `refresh_token`</td>
    <td><code>"authorization_code"</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:token</strong></td>
    <td><em>string</em></td>
    <td>contents of the token to be used for authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/oauth/tokens \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "client": {
    "secret": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "grant": {
    "code": "01234567-89ab-cdef-0123-456789abcdef",
    "type": "authorization_code"
  },
  "refresh_token": {
    "token": "01234567-89ab-cdef-0123-456789abcdef"
  }
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "access_token": {
    "expires_in": 2592000,
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "token": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "authorization": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "client": {
    "secret": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "grant": {
    "code": "01234567-89ab-cdef-0123-456789abcdef",
    "type": "authorization_code"
  },
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "refresh_token": {
    "expires_in": 2592000,
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "token": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "session": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```


## Organization App Collaborator
Stability: `prototype`

An organization collaborator represents an account that has been given access to an organization app on Heroku.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when collaborator was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of collaborator</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>role</strong></td>
    <td><em>string</em></td>
    <td>role in the organization<br/><b>one of:</b><code>"admin"</code> or <code>"member"</code> or <code>"collaborator"</code></td>
    <td><code>"admin"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when collaborator was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>user:email</strong></td>
    <td><em>email</em></td>
    <td>email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>user:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
</table>

### Organization App Collaborator Create
Create a new collaborator on an organization app. Use this endpoint instead of the `/apps/{app_id_or_name}/collaborator` endpoint when you want the collaborator to be granted [privileges] (https://devcenter.heroku.com/articles/org-users-access#roles) according to their role in the organization.


```
POST /organizations/apps/{app_id_or_name}/collaborators
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>user</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or email address of account</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"username@example.com"</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>silent</strong></td>
    <td><em>boolean</em></td>
    <td>whether to suppress email invitation when creating collaborator</td>
    <td><code>false</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/organizations/apps/$APP_ID_OR_NAME/collaborators \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "silent": false,
  "user": "01234567-89ab-cdef-0123-456789abcdef"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "role": "admin",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```

### Organization App Collaborator Delete
Delete an existing collaborator from an organization app.


```
DELETE /organizations/apps/{organization_app_name}/collaborators/{organization_app_collaborator_email}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/organizations/apps/$ORGANIZATION_APP_NAME/collaborators/$ORGANIZATION_APP_COLLABORATOR_EMAIL \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "role": "admin",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```

### Organization App Collaborator Info
Info for a collaborator on an organization app.


```
GET /organizations/apps/{organization_app_name}/collaborators/{organization_app_collaborator_email}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/organizations/apps/$ORGANIZATION_APP_NAME/collaborators/$ORGANIZATION_APP_COLLABORATOR_EMAIL \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "role": "admin",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```

### Organization App Collaborator List
List collaborators on an organization app.

The only acceptable order value for the Range header is `email`.

```
GET /organizations/apps/{organization_app_name}/collaborators
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/organizations/apps/$ORGANIZATION_APP_NAME/collaborators \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: email
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "role": "admin",
    "updated_at": "2012-01-01T12:00:00Z",
    "user": {
      "email": "username@example.com",
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    }
  }
]
```


## Organization App
Stability: `prototype`

An organization app encapsulates the organization specific functionality of Heroku apps.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>archived_at</strong></td>
    <td><em>nullable date-time</em></td>
    <td>when app was archived</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>buildpack_provided_description</strong></td>
    <td><em>nullable string</em></td>
    <td>description from buildpack of app</td>
    <td><code>"Ruby/Rack"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>git_url</strong></td>
    <td><em>string</em></td>
    <td>git repo URL of app</td>
    <td><code>"git@heroku.com:example.git"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>joined</strong></td>
    <td><em>boolean</em></td>
    <td>is the current member a collaborator on this app.</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>locked</strong></td>
    <td><em>boolean</em></td>
    <td>are other organization members forbidden from joining this app.</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>maintenance</strong></td>
    <td><em>boolean</em></td>
    <td>maintenance status of app</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>name of app</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>organization</strong></td>
    <td><em>nullable object</em></td>
    <td>organization that owns this app</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>organization:name</strong></td>
    <td><em>string</em></td>
    <td>unique name of organization</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>owner</strong></td>
    <td><em>nullable object</em></td>
    <td>identity of app owner</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>owner:email</strong></td>
    <td><em>email</em></td>
    <td>email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>owner:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>region:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>region:name</strong></td>
    <td><em>string</em></td>
    <td>name of region</td>
    <td><code>"us"</code></td>
  </tr>
  <tr>
    <td><strong>released_at</strong></td>
    <td><em>nullable date-time</em></td>
    <td>when app was released</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>repo_size</strong></td>
    <td><em>nullable integer</em></td>
    <td>git repo size in bytes of app</td>
    <td><code>0</code></td>
  </tr>
  <tr>
    <td><strong>slug_size</strong></td>
    <td><em>nullable integer</em></td>
    <td>slug size in bytes of app</td>
    <td><code>0</code></td>
  </tr>
  <tr>
    <td><strong>stack:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>stack:name</strong></td>
    <td><em>string</em></td>
    <td>name of stack</td>
    <td><code>"cedar"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when app was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>web_url</strong></td>
    <td><em>uri</em></td>
    <td>web URL of app</td>
    <td><code>"http://example.herokuapp.com/"</code></td>
  </tr>
</table>

### Organization App Create
Create a new app in the specified organization, in the default organization if unspecified,  or in personal account, if default organization is not set.


```
POST /organizations/apps
```

#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>locked</strong></td>
    <td><em>boolean</em></td>
    <td>are other organization members forbidden from joining this app.</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>name of app</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>organization</strong></td>
    <td><em>string</em></td>
    <td>unique name of organization</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>personal</strong></td>
    <td><em>boolean</em></td>
    <td>force creation of the app in the user account even if a default org is set.</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>region</strong></td>
    <td><em>string</em></td>
    <td>name of region</td>
    <td><code>"us"</code></td>
  </tr>
  <tr>
    <td><strong>stack</strong></td>
    <td><em>string</em></td>
    <td>name of stack</td>
    <td><code>"cedar"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/organizations/apps \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "locked": false,
  "name": "example",
  "organization": "example",
  "personal": false,
  "region": "us",
  "stack": "cedar"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "git@heroku.com:example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "joined": false,
  "locked": false,
  "maintenance": false,
  "name": "example",
  "organization": {
    "name": "example"
  },
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "http://example.herokuapp.com/"
}
```

### Organization App List
List apps in the default organization, or in personal account, if default organization is not set.

The only acceptable order value for the Range header is `name`.

```
GET /organizations/apps
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/organizations/apps \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "archived_at": "2012-01-01T12:00:00Z",
    "buildpack_provided_description": "Ruby/Rack",
    "created_at": "2012-01-01T12:00:00Z",
    "git_url": "git@heroku.com:example.git",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "joined": false,
    "locked": false,
    "maintenance": false,
    "name": "example",
    "organization": {
      "name": "example"
    },
    "owner": {
      "email": "username@example.com",
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "region": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "name": "us"
    },
    "released_at": "2012-01-01T12:00:00Z",
    "repo_size": 0,
    "slug_size": 0,
    "stack": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "name": "cedar"
    },
    "updated_at": "2012-01-01T12:00:00Z",
    "web_url": "http://example.herokuapp.com/"
  }
]
```

### Organization App List For Organization
List organization apps.

The only acceptable order value for the Range header is `name`.

```
GET /organizations/{organization_name}/apps
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/organizations/$ORGANIZATION_NAME/apps \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "archived_at": "2012-01-01T12:00:00Z",
    "buildpack_provided_description": "Ruby/Rack",
    "created_at": "2012-01-01T12:00:00Z",
    "git_url": "git@heroku.com:example.git",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "joined": false,
    "locked": false,
    "maintenance": false,
    "name": "example",
    "organization": {
      "name": "example"
    },
    "owner": {
      "email": "username@example.com",
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "region": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "name": "us"
    },
    "released_at": "2012-01-01T12:00:00Z",
    "repo_size": 0,
    "slug_size": 0,
    "stack": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "name": "cedar"
    },
    "updated_at": "2012-01-01T12:00:00Z",
    "web_url": "http://example.herokuapp.com/"
  }
]
```

### Organization App Info
Info for an organization app.


```
GET /organizations/apps/{organization_app_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/organizations/apps/$ORGANIZATION_APP_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "git@heroku.com:example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "joined": false,
  "locked": false,
  "maintenance": false,
  "name": "example",
  "organization": {
    "name": "example"
  },
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "http://example.herokuapp.com/"
}
```

### Organization App Update Locked
Lock or unlock an organization app.


```
PATCH /organizations/apps/{organization_app_name}
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>locked</strong></td>
    <td><em>boolean</em></td>
    <td>are other organization members forbidden from joining this app.</td>
    <td><code>false</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/organizations/apps/$ORGANIZATION_APP_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "locked": false
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "git@heroku.com:example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "joined": false,
  "locked": false,
  "maintenance": false,
  "name": "example",
  "organization": {
    "name": "example"
  },
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "http://example.herokuapp.com/"
}
```

### Organization App Transfer to Account
Transfer an existing organization app to another Heroku account.


```
PATCH /organizations/apps/{organization_app_name}
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>owner</strong></td>
    <td><em>string</em></td>
    <td>unique identifier or email address of account</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code> or <code>"username@example.com"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/organizations/apps/$ORGANIZATION_APP_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "owner": "01234567-89ab-cdef-0123-456789abcdef"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "git@heroku.com:example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "joined": false,
  "locked": false,
  "maintenance": false,
  "name": "example",
  "organization": {
    "name": "example"
  },
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "http://example.herokuapp.com/"
}
```

### Organization App Transfer to Organization
Transfer an existing organization app to another organization.


```
PATCH /organizations/apps/{organization_app_name}
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>owner</strong></td>
    <td><em>string</em></td>
    <td>unique name of organization</td>
    <td><code>"example"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/organizations/apps/$ORGANIZATION_APP_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "owner": "example"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "archived_at": "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at": "2012-01-01T12:00:00Z",
  "git_url": "git@heroku.com:example.git",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "joined": false,
  "locked": false,
  "maintenance": false,
  "name": "example",
  "organization": {
    "name": "example"
  },
  "owner": {
    "email": "username@example.com",
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at": "2012-01-01T12:00:00Z",
  "repo_size": 0,
  "slug_size": 0,
  "stack": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar"
  },
  "updated_at": "2012-01-01T12:00:00Z",
  "web_url": "http://example.herokuapp.com/"
}
```


## Organization Member
Stability: `prototype`

An organization member is an individual with access to an organization.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when organization-member was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>email</strong></td>
    <td><em>string</em></td>
    <td>email address of the organization member</td>
    <td><code>"someone@example.org"</code></td>
  </tr>
  <tr>
    <td><strong>role</strong></td>
    <td><em>string</em></td>
    <td>role in the organization<br/><b>one of:</b><code>"admin"</code> or <code>"member"</code> or <code>"collaborator"</code></td>
    <td><code>"admin"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when organization-member was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Organization Member Create or Update
Create a new organization member, or update their role.


```
PUT /organizations/{organization_name}/members
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>email</strong></td>
    <td><em>string</em></td>
    <td>email address of the organization member</td>
    <td><code>"someone@example.org"</code></td>
  </tr>
  <tr>
    <td><strong>role</strong></td>
    <td><em>string</em></td>
    <td>role in the organization<br/><b>one of:</b><code>"admin"</code> or <code>"member"</code> or <code>"collaborator"</code></td>
    <td><code>"admin"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X PUT https://api.heroku.com/organizations/$ORGANIZATION_NAME/members \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "email": "someone@example.org",
  "role": "admin"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "email": "someone@example.org",
  "role": "admin",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Organization Member Delete
Remove a member from the organization.


```
DELETE /organizations/{organization_name}/members/{organization_member_email}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/organizations/$ORGANIZATION_NAME/members/$ORGANIZATION_MEMBER_EMAIL \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "email": "someone@example.org",
  "role": "admin",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Organization Member List
List members of the organization.

The only acceptable order value for the Range header is `email`.

```
GET /organizations/{organization_name}/members
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/organizations/$ORGANIZATION_NAME/members \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: email
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "email": "someone@example.org",
    "role": "admin",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```


## Organization
Stability: `prototype`

Organizations allow you to manage access to a shared group of applications across your development team.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>credit_card_collections</strong></td>
    <td><em>boolean</em></td>
    <td>whether charges incurred by the org are paid by credit card.</td>
    <td><code>"true"</code></td>
  </tr>
  <tr>
    <td><strong>default</strong></td>
    <td><em>boolean</em></td>
    <td>whether to use this organization when none is specified</td>
    <td><code>"true"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name of organization</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>provisioned_licenses</strong></td>
    <td><em>boolean</em></td>
    <td>whether the org is provisioned licenses by salesforce.</td>
    <td><code>"true"</code></td>
  </tr>
  <tr>
    <td><strong>role</strong></td>
    <td><em>string</em></td>
    <td>role in the organization<br/><b>one of:</b><code>"admin"</code> or <code>"member"</code> or <code>"collaborator"</code></td>
    <td><code>"admin"</code></td>
  </tr>
</table>

### Organization List
List organizations in which you are a member.

The only acceptable order value for the Range header is `name`.

```
GET /organizations
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/organizations \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "credit_card_collections": "true",
    "default": "true",
    "name": "example",
    "provisioned_licenses": "true",
    "role": "admin"
  }
]
```

### Organization Update
Set or unset the organization as your default organization.


```
PATCH /organizations/{organization_name}
```

#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>default</strong></td>
    <td><em>boolean</em></td>
    <td>whether to use this organization when none is specified</td>
    <td><code>"true"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/organizations/$ORGANIZATION_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "default": "true"
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "credit_card_collections": "true",
  "default": "true",
  "name": "example",
  "provisioned_licenses": "true",
  "role": "admin"
}
```


## Plan
Stability: `production`

Plans represent different configurations of add-ons that may be added to apps. Endpoints under add-on services can be accessed without authentication.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when plan was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>default</strong></td>
    <td><em>boolean</em></td>
    <td>whether this plan is the default for its addon service</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>description of plan</td>
    <td><code>"Heroku Postgres Dev"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>name of this plan</td>
    <td><code>"heroku-postgresql:dev"</code></td>
  </tr>
  <tr>
    <td><strong>price:cents</strong></td>
    <td><em>integer</em></td>
    <td>price in cents per unit of plan</td>
    <td><code>0</code></td>
  </tr>
  <tr>
    <td><strong>price:unit</strong></td>
    <td><em>string</em></td>
    <td>unit of price for plan</td>
    <td><code>"month"</code></td>
  </tr>
  <tr>
    <td><strong>state</strong></td>
    <td><em>string</em></td>
    <td>release status for plan</td>
    <td><code>"public"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when plan was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Plan Info
Info for existing plan.


```
GET /addon-services/{addon_service_id_or_name}/plans/{plan_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/addon-services/$ADDON_SERVICE_ID_OR_NAME/plans/$PLAN_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "default": false,
  "description": "Heroku Postgres Dev",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "heroku-postgresql:dev",
  "price": {
    "cents": 0,
    "unit": "month"
  },
  "state": "public",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Plan List
List existing plans.

Acceptable order values for the Range header are `id` or `name`.

```
GET /addon-services/{addon_service_id_or_name}/plans
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/addon-services/$ADDON_SERVICE_ID_OR_NAME/plans \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "default": false,
    "description": "Heroku Postgres Dev",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql:dev",
    "price": {
      "cents": 0,
      "unit": "month"
    },
    "state": "public",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```


## Rate Limit
Stability: `production`

Rate Limit represents the number of request tokens each account holds. Requests to this endpoint do not count towards the rate limit.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>remaining</strong></td>
    <td><em>integer</em></td>
    <td>allowed requests remaining in current interval</td>
    <td><code>2399</code></td>
  </tr>
</table>

### Rate Limit Info
Info for rate limits.


```
GET /account/rate-limits
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/account/rate-limits \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "remaining": 2399
}
```


## Region
Stability: `production`

A region represents a geographic location in which your application may run.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when region was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>description of region</td>
    <td><code>"United States"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>name of region</td>
    <td><code>"us"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when region was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Region Info
Info for existing region.


```
GET /regions/{region_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/regions/$REGION_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "description": "United States",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "us",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Region List
List existing regions.

Acceptable order values for the Range header are `id` or `name`.

```
GET /regions
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/regions \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "description": "United States",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```


## Release
Stability: `production`

A release represents a combination of code, config vars and add-ons for an app on Heroku.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when release was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>description of changes in this release</td>
    <td><code>"Added new feature"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of release</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>slug</strong></td>
    <td><em>nullable object</em></td>
    <td>slug running in this release</td>
    <td><code>null</code></td>
  </tr>
  <tr>
    <td><strong>slug:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of slug</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when release was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>user:email</strong></td>
    <td><em>email</em></td>
    <td>email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>user:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>version</strong></td>
    <td><em>integer</em></td>
    <td>unique version assigned to the release</td>
    <td><code>11</code></td>
  </tr>
</table>

### Release Info
Info for existing release.


```
GET /apps/{app_id_or_name}/releases/{release_id_or_version}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/releases/$RELEASE_ID_OR_VERSION \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "description": "Added new feature",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "slug": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "user": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "version": 11
}
```

### Release List
List existing releases.

Acceptable order values for the Range header are `id` or `version`.

```
GET /apps/{app_id_or_name}/releases
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/releases \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, version
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "description": "Added new feature",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "updated_at": "2012-01-01T12:00:00Z",
    "slug": {
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "user": {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "email": "username@example.com"
    },
    "version": 11
  }
]
```

### Release Create
Create new release. The API cannot be used to create releases on Bamboo apps.


```
POST /apps/{app_id_or_name}/releases
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>slug</strong></td>
    <td><em>string</em></td>
    <td>unique identifier of slug</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>description of changes in this release</td>
    <td><code>"Added new feature"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/releases \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "description": "Added new feature",
  "slug": "01234567-89ab-cdef-0123-456789abcdef"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "description": "Added new feature",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "slug": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "user": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "version": 11
}
```

### Release Rollback
Rollback to an existing release.


```
POST /apps/{app_id_or_name}/releases
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>release</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of release</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
</table>



#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/releases \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "release": "01234567-89ab-cdef-0123-456789abcdef"
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "description": "Added new feature",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "slug": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "user": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "version": 11
}
```


## Slug
Stability: `production`

A slug is a snapshot of your application code that is ready to run on the platform.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>blob:method</strong></td>
    <td><em>string</em></td>
    <td>method to be used to interact with the slug blob</td>
    <td><code>"GET"</code></td>
  </tr>
  <tr>
    <td><strong>blob:url</strong></td>
    <td><em>string</em></td>
    <td>URL to interact with the slug blob</td>
    <td><code>"https://api.heroku.com/slugs/1234.tgz"</code></td>
  </tr>
  <tr>
    <td><strong>buildpack_provided_description</strong></td>
    <td><em>nullable string</em></td>
    <td>description from buildpack of slug</td>
    <td><code>"Ruby/Rack"</code></td>
  </tr>
  <tr>
    <td><strong>commit</strong></td>
    <td><em>nullable string</em></td>
    <td>identification of the code with your version control system (eg: SHA of the git HEAD)</td>
    <td><code>"60883d9e8947a57e04dc9124f25df004866a2051"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when slug was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of slug</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>process_types</strong></td>
    <td><em>object</em></td>
    <td>hash mapping process type names to their respective command</td>
    <td><code>{"web":"./bin/web -p $PORT"}</code></td>
  </tr>
  <tr>
    <td><strong>size</strong></td>
    <td><em>nullable integer</em></td>
    <td>size of slug, in bytes</td>
    <td><code>2048</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when slug was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Slug Info
Info for existing slug.


```
GET /apps/{app_id_or_name}/slugs/{slug_id}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/slugs/$SLUG_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "blob": {
    "method": "GET",
    "url": "https://api.heroku.com/slugs/1234.tgz"
  },
  "buildpack_provided_description": "Ruby/Rack",
  "commit": "60883d9e8947a57e04dc9124f25df004866a2051",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "process_types": {
    "web": "./bin/web -p $PORT"
  },
  "size": 2048,
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Slug Create
Create a new slug. For more information please refer to [Deploying Slugs using the Platform API](https://devcenter.heroku.com/articles/platform-api-deploying-slugs?preview=1).


```
POST /apps/{app_id_or_name}/slugs
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>process_types</strong></td>
    <td><em>object</em></td>
    <td>hash mapping process type names to their respective command</td>
    <td><code>{"web":"./bin/web -p $PORT"}</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>buildpack_provided_description</strong></td>
    <td><em>nullable string</em></td>
    <td>description from buildpack of slug</td>
    <td><code>"Ruby/Rack"</code></td>
  </tr>
  <tr>
    <td><strong>commit</strong></td>
    <td><em>nullable string</em></td>
    <td>identification of the code with your version control system (eg: SHA of the git HEAD)</td>
    <td><code>"60883d9e8947a57e04dc9124f25df004866a2051"</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/slugs \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "buildpack_provided_description": "Ruby/Rack",
  "commit": "60883d9e8947a57e04dc9124f25df004866a2051",
  "process_types": {
    "web": "./bin/web -p $PORT"
  }
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "blob": {
    "method": "GET",
    "url": "https://api.heroku.com/slugs/1234.tgz"
  },
  "buildpack_provided_description": "Ruby/Rack",
  "commit": "60883d9e8947a57e04dc9124f25df004866a2051",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "process_types": {
    "web": "./bin/web -p $PORT"
  },
  "size": 2048,
  "updated_at": "2012-01-01T12:00:00Z"
}
```


## SSL Endpoint
Stability: `production`

[SSL Endpoint](https://devcenter.heroku.com/articles/ssl-endpoint) is a public address serving custom SSL cert for HTTPS traffic to a Heroku app. Note that an app must have the `ssl:endpoint` addon installed before it can provision an SSL Endpoint using these APIs.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>certificate_chain</strong></td>
    <td><em>string</em></td>
    <td>raw contents of the public certificate chain (eg: .crt or .pem file)</td>
    <td><code>"-----BEGIN CERTIFICATE----- ..."</code></td>
  </tr>
  <tr>
    <td><strong>cname</strong></td>
    <td><em>string</em></td>
    <td>canonical name record, the address to point a domain at</td>
    <td><code>"example.herokussl.com"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when endpoint was created</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this SSL endpoint</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name for SSL endpoint</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when endpoint was updated</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### SSL Endpoint Create
Create a new SSL endpoint.


```
POST /apps/{app_id_or_name}/ssl-endpoints
```

#### Required Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>certificate_chain</strong></td>
    <td><em>string</em></td>
    <td>raw contents of the public certificate chain (eg: .crt or .pem file)</td>
    <td><code>"-----BEGIN CERTIFICATE----- ..."</code></td>
  </tr>
  <tr>
    <td><strong>private_key</strong></td>
    <td><em>string</em></td>
    <td>contents of the private key (eg .key file)</td>
    <td><code>"-----BEGIN RSA PRIVATE KEY----- ..."</code></td>
  </tr>
</table>


#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>preprocess</strong></td>
    <td><em>boolean</em></td>
    <td>allow Heroku to modify an uploaded public certificate chain if deemed advantageous by adding missing intermediaries, stripping unnecessary ones, etc.<br/><b>default:</b> <code>true</code></td>
    <td><code>true</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "preprocess": true,
  "private_key": "-----BEGIN RSA PRIVATE KEY----- ..."
}'
```

#### Response Example
```
HTTP/1.1 201 Created
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "cname": "example.herokussl.com",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "example",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### SSL Endpoint Delete
Delete existing SSL endpoint.


```
DELETE /apps/{app_id_or_name}/ssl-endpoints/{ssl_endpoint_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints/$SSL_ENDPOINT_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "cname": "example.herokussl.com",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "example",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### SSL Endpoint Info
Info for existing SSL endpoint.


```
GET /apps/{app_id_or_name}/ssl-endpoints/{ssl_endpoint_id_or_name}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints/$SSL_ENDPOINT_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "cname": "example.herokussl.com",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "example",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### SSL Endpoint List
List existing SSL endpoints.

Acceptable order values for the Range header are `id` or `name`.

```
GET /apps/{app_id_or_name}/ssl-endpoints
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
    "cname": "example.herokussl.com",
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```

### SSL Endpoint Update
Update an existing SSL endpoint.


```
PATCH /apps/{app_id_or_name}/ssl-endpoints/{ssl_endpoint_id_or_name}
```

#### Optional Parameters
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>certificate_chain</strong></td>
    <td><em>string</em></td>
    <td>raw contents of the public certificate chain (eg: .crt or .pem file)</td>
    <td><code>"-----BEGIN CERTIFICATE----- ..."</code></td>
  </tr>
  <tr>
    <td><strong>preprocess</strong></td>
    <td><em>boolean</em></td>
    <td>allow Heroku to modify an uploaded public certificate chain if deemed advantageous by adding missing intermediaries, stripping unnecessary ones, etc.<br/><b>default:</b> <code>true</code></td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><strong>private_key</strong></td>
    <td><em>string</em></td>
    <td>contents of the private key (eg .key file)</td>
    <td><code>"-----BEGIN RSA PRIVATE KEY----- ..."</code></td>
  </tr>
  <tr>
    <td><strong>rollback</strong></td>
    <td><em>boolean</em></td>
    <td>indicates that a rollback should be performed</td>
    <td><code>false</code></td>
  </tr>
</table>


#### Curl Example
```bash
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints/$SSL_ENDPOINT_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "preprocess": true,
  "private_key": "-----BEGIN RSA PRIVATE KEY----- ...",
  "rollback": false
}'
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "cname": "example.herokussl.com",
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "example",
  "updated_at": "2012-01-01T12:00:00Z"
}
```


## Stack
Stability: `production`

Stacks are the different application execution environments available in the Heroku platform.

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>date-time</em></td>
    <td>when stack was introduced</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>name of stack</td>
    <td><code>"cedar"</code></td>
  </tr>
  <tr>
    <td><strong>state</strong></td>
    <td><em>string</em></td>
    <td>availability of this stack: beta, deprecated or public</td>
    <td><code>"public"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>date-time</em></td>
    <td>when stack was last modified</td>
    <td><code>"2012-01-01T12:00:00Z"</code></td>
  </tr>
</table>

### Stack Info
Stack info.


```
GET /stacks/{stack_name_or_id}
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/stacks/$STACK_NAME_OR_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
{
  "created_at": "2012-01-01T12:00:00Z",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "name": "cedar",
  "state": "public",
  "updated_at": "2012-01-01T12:00:00Z"
}
```

### Stack List
List available stacks.

Acceptable order values for the Range header are `id` or `name`.

```
GET /stacks
```


#### Curl Example
```bash
$ curl -n -X GET https://api.heroku.com/stacks \
-H "Accept: application/vnd.heroku+json; version=3"
```

#### Response Example
```
HTTP/1.1 200 OK
Accept-Ranges: id, name
Content-Range: id 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 2400
```
```json
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "cedar",
    "state": "public",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```


