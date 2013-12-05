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
<div class="warning">The Platform API is a <a href="https://devcenter.heroku.com/articles/heroku-beta-features">beta feature</a>. Functionality may change prior to general availability.</div>
## Overview
The platform API empowers developers to automate, extend and combine Heroku with other services. You can use the platform API to programmatically create apps, provision add-ons and perform other tasks that could previously only be accomplished with Heroku toolbelt or dashboard. For details on getting started, see the [quickstart](https://devcenter.heroku.com/articles/platform-api-quickstart).
### Authentication
OAuth should be used to authorize and revoke access to your account to yourself and third parties. Details can be found in this [devcenter OAuth article](https://devcenter.heroku.com/articles/oauth).

For personal scripts you may also use HTTP basic authentication, but OAuth is recommended for any third party services. HTTP basic authentication must be constructed from email address and [API token](https://devcenter.heroku.com/articles/authentication) as `{email-address}:{token}`, base64 encoded and passed as the Authorization header for each request, for example `Authorization: Basic 0123456789ABCDEF=`.

### Caching
All responses include an `ETag` (or Entity Tag) header, identifying the specific version of a returned resource. You may use this value to check for changes to a resource by repeating the request and passing the `ETag` value in the `If-None-Match` header. If the resource has not changed, a `304 Not Modified` status will be returned with an empty body. If the resource has changed, the request will proceed normally.
### Clients
Clients must address requests to `api.heroku.com` using HTTPS and specify the `Accept: application/vnd.heroku+json; version=3` Accept header. Clients should specify a `User-Agent` header to facilitate tracking and debugging.
### cURL Examples
cURL examples are provided to facilitate experimentation. Variable values are represented as `$SOMETHING` so that you can manipulate them using environment variables. Examples use the `-n` option to fetch credentials from a `~/.netrc` file, which should include an entry for `api.heroku.com` similar to the following:

```
machine api.heroku.com
  login {your-email}
  password {your-api-token}
```
### Custom Types
<table>
<tr><th>Name</th><th>JSON Type</th><th>Description</th></tr>
<tr><td>datetime</td><td>string</td><td>timestamp in iso8601 format</td></tr>

<tr><td>uuid</td><td>string</td><td>uuid in 8-4-4-4-12 format</td></tr>
</table>
### Data Integrity
Both unique id and more human-friendly attributes can be used reference resources. For example you can use `name` or `id` to refer to an app. Though the human-friendly version may be more convenient, `id` should be preferred to avoid ambiguity.

You may pass the `If-Match` header with an `ETag` value from a previous response to ensure a resource has not changed since you last received it. If the resource has changed, you will receive a `412 Precondition Failed` response. If the resource has not changed, the request will proceed normally.
### Errors
Failing responses will have an appropriate [status](#statuses) and a JSON body.
### Error Attributes
<table>
<tr><th>Name</th><th>Type</th><th>Description</th><th>Example</th></tr>
<tr><td>id</td><td>string</td><td>id of error raised</td><td><code>"rate_limit"</code></td></tr>

<tr><td>message</td><td>string</td><td>end user message of error raised </td><td><code>"Your account reached the API limit. Please wait a few minutes before making new requests"</code></td></tr>
</table>
### Error Response
```
HTTP/1.1 429 Too Many Requests
```
```javascript
{
  "id":       "rate_limit",
  "message":  "Your account reached the API rate limit\nPlease wait a few minutes before making new requests"
}
```
### Legacy API
Those utilizing the legacy, v2 API should instead consult [legacy-api-docs.heroku.com](https://legacy-api-docs.heroku.com)
### Methods
<table>
<tr><th>Method</th><th>Usage</th></tr>
<tr><td>DELETE</td><td>used for destroying existing objects</td></tr>

<tr><td>GET</td><td>used for retrieving lists and individual objects</td></tr>

<tr><td>HEAD</td><td>used for retrieving metadata about existing objects</td></tr>

<tr><td>PATCH</td><td>used for updating existing objects</td></tr>

<tr><td>PUT</td><td>used for replacing existing objects</td></tr>

<tr><td>POST</td><td>used for creating new objects</td></tr>
</table>
### Method Override
When using a client that does not support all of the [methods](#methods), you can override by using a `POST` and setting the `X-Http-Method-Override` header to the desired methed. For instance, to do a `PATCH` request, do a `POST` with header `X-Http-Method-Override: PATCH`.
### Parameters
Values that can be provided for an action are divided between optional and required values. The expected type for each value is specified and unlisted values should be considered immutable. Parameters should be JSON encoded and passed in the request body.
### Ranges
List requests will return a `Content-Range` header indicating the range of values returned. Large lists may require additional requests to retrieve. If a list response has been truncated you will receive a `206 Partial Content` status and one or both of `Next-Range` and `Prev-Range` headers if there are next and previous ranges respectively. To retrieve the next or previous range, repeat the request with the `Range` header set to either the `Next-Range` or `Prev-Range` value from the previous request.

The number of values returned in a range can be controlled using a `max` key in the `Range` header. For example, to get only the first 10 values, set this header: `Range: ids ..; max=10;`. `max` can also be passed when iterating over `Next-Range` and `Prev-Range`. The default page size is 200 and maximum page size is 1000.
### Limits
The API limits the number of requests each user can make per hour to protect against abuse and buggy code. Each account has a pool of request tokens that can hold at most 1200 tokens. Each API call removes one token from the pool. Tokens are added to the account pool at a rate of 1200 per hour, up to a maximum of 1200. If no tokens remain, further calls will return 429 `Too Many Requests` until more tokens become available.

You can use the `RateLimit-Remaining` response header to check your current token count. You can also query the [rate limit](#rate-limits) endpoint to get your token count. Requests to the rate limit endpoint do not count toward the limit. If you find your account is being rate limited but don't know the cause, consider cycling your API key on the account page on Heroku dashboard.
### Request Id
Each API response contains a unique request id in the `Request-Id` header to facilitate tracking. When reporting issues, providing this value makes it easier to pinpoint problems and provide solutions more quickly.
### Responses
Values returned by the API are split into a section with example status code and relevant headers (with common http headers omitted) and a section with an example JSON body (if any).
### Response Headers
<table>
<tr><th>Header</th><th>Description</th></tr>
<tr><td>RateLimit-Remaining</td><td>allowed requests remaining in current interval</td></tr>
</table>
### Statuses
<table>
<tr><th>Code</th><th>Culprit</th><th>Id</th><th>Message</th></tr>
<tr><td>200</td><td>Both</td><td>OK</td><td>request succeeded</td></tr>

<tr><td>201</td><td>Both</td><td>Created</td><td>resource created, for example a new app was created or an add-on was provisioned</td></tr>

<tr><td>202</td><td>Both</td><td>Accepted</td><td>request accepted, but the processing has not been completed</td></tr>

<tr><td>206</td><td>Both</td><td>Partial Content</td><td>request succeeded, but this is only a partial response, see <a href='#ranges'>ranges</a></td></tr>

<tr><td>400</td><td>Client</td><td>Bad Request</td><td>request invalid, validate usage and try again</td></tr>

<tr><td>401</td><td>Client</td><td>Unauthorized</td><td>request not authenticated, validate credentials and try again</td></tr>

<tr><td>402</td><td>Client</td><td>Payment Required</td><td>either the account has become delinquent as a result of non-payment, or the account's payment method must be confirmed to continue</td></tr>

<tr><td>403</td><td>Client</td><td>Forbidden</td><td>request not authorized, provided credentials do not provide access to specified resource</td></tr>

<tr><td>404</td><td>Client</td><td>Not Found</td><td>request failed, the specified resource does not exist</td></tr>

<tr><td>406</td><td>Client</td><td>Not Acceptable</td><td>request failed, set <code>Accept: application/vnd.heroku+json; version=3</code> header and try again</td></tr>

<tr><td>416</td><td>Client</td><td>Requested Range Not Satisfiable</td><td>request failed, validate <code>Content-Range</code> header and try again</td></tr>

<tr><td>422</td><td>Client</td><td>Unprocessable Entity</td><td>request failed, validate parameters try again</td></tr>

<tr><td>429</td><td>Client</td><td>Too Many Requests</td><td>request failed, wait for rate limits to reset and try again, see <a href='#rate-limits'>rate limits</a></td></tr>

<tr><td>500</td><td>Heroku</td><td>Internal Server Error</td><td>error occurred, we are notified, but contact <a href='https://help.heroku.com'>support</a> if the issue persists</td></tr>

<tr><td>503</td><td>Heroku</td><td>Service Unavailable</td><td>API is unavailable, check response body or <a href='https://status.heroku.com'>Heroku status</a> for details</td></tr>
</table>
### Versioning
The beta and release of the api will all occur within version 3. We will provide warning and migration strategies for any backwards incompatible changes we might make during the beta and will commit to no backwards incompatible changes to version 3 after the release.
### Warnings
Responses with warnings will have add headers describing the warning.
### Warning Headers
<table>
<tr><th>Header</th><th>Description</th><th>Example</th></tr>
<tr><td>id</td><td>id of warning</td><td><code>"stack_deprecated"</code></td></tr>
</table>
## Account
An account represents you on Heroku.
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
    <td>whether to allow web activity tracking with third-party services like Google Analytics</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><strong>beta</strong></td>
    <td><em>boolean</em></td>
    <td>whether to utilize beta Heroku features</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>datetime</em></td>
    <td>when account was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>email</strong></td>
    <td><em>string</em></td>
    <td>email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of account</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>last_login</strong></td>
    <td><em>datetime</em></td>
    <td>when account last authorized with Heroku</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when account was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>verified</strong></td>
    <td><em>boolean</em></td>
    <td>whether the account has been verified with billing information</td>
    <td><code>false</code></td>
  </tr>
</table>
### Account Info
```
GET /account
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/account \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "allow_tracking": true,
  "beta":           false,
  "created_at":     "2012-01-01T12:00:00Z",
  "email":          "username@example.com",
  "id":             "01234567-89ab-cdef-0123-456789abcdef",
  "last_login":     "2012-01-01T12:00:00Z",
  "updated_at":     "2012-01-01T12:00:00Z",
  "verified":       false
}
```
### Account Update
```
PATCH /account
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
    <td><strong>allow_tracking</strong></td>
    <td><em>boolean</em></td>
    <td>whether to allow web activity tracking with third-party services like Google Analytics</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><strong>email</strong></td>
    <td><em>string</em></td>
    <td>email address of account</td>
    <td><code>"username@example.com"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X PATCH https://api.heroku.com/account \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"allow_tracking\":true,\"email\":\"username@example.com\"}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "allow_tracking": true,
  "beta":           false,
  "created_at":     "2012-01-01T12:00:00Z",
  "email":          "username@example.com",
  "id":             "01234567-89ab-cdef-0123-456789abcdef",
  "last_login":     "2012-01-01T12:00:00Z",
  "updated_at":     "2012-01-01T12:00:00Z",
  "verified":       false
}
```
## Account Feature
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
    <td><em>datetime</em></td>
    <td>when account feature was created</td>
    <td><code>2012-01-01T12:00:00-00:00</code></td>
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
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name of account feature</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when account feature was updated</td>
    <td><code>2012-01-01T12:00:00-00:00</code></td>
  </tr>
</table>
### Account Feature List
```
GET /account/features
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/account/features \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at":  "2012-01-01T12:00:00-00:00",
    "description": "Causes account to example.",
    "doc_url":     "http://devcenter.heroku.com/articles/example",
    "enabled":     true,
    "id":          "01234567-89ab-cdef-0123-456789abcdef",
    "name":        "example",
    "updated_at":  "2012-01-01T12:00:00-00:00"
  }
]
```
### Account Feature Info
```
GET /account/features/{feature_id_or_name}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/account/features/$FEATURE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":  "2012-01-01T12:00:00-00:00",
  "description": "Causes account to example.",
  "doc_url":     "http://devcenter.heroku.com/articles/example",
  "enabled":     true,
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "name":        "example",
  "updated_at":  "2012-01-01T12:00:00-00:00"
}
```
### Account Feature Update
```
PATCH /account/features/{feature_id_or_name}
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
```term
$ curl -n -X PATCH https://api.heroku.com/account/features/$FEATURE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"enabled\":true}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":  "2012-01-01T12:00:00-00:00",
  "description": "Causes account to example.",
  "doc_url":     "http://devcenter.heroku.com/articles/example",
  "enabled":     true,
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "name":        "example",
  "updated_at":  "2012-01-01T12:00:00-00:00"
}
```
## Account Password

### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>current_password</strong></td>
    <td><em>string</em></td>
    <td>existing password value</td>
    <td><code>"0123456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>password</strong></td>
    <td><em>string</em></td>
    <td>new password value</td>
    <td><code>"abcdef0123456789"</code></td>
  </tr>
</table>
### Account Password Update
```
PUT /account/password
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
    <td><strong>current_password</strong></td>
    <td><em>string</em></td>
    <td>existing password value</td>
    <td><code>"0123456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>password</strong></td>
    <td><em>string</em></td>
    <td>new password value</td>
    <td><code>"abcdef0123456789"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X PUT https://api.heroku.com/account/password \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"current_password\":\"0123456789abcdef\",\"password\":\"abcdef0123456789\"}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
}
```
## Add-on
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
    <td><strong>config</strong></td>
    <td><em>object</em></td>
    <td>additional add-on service specific configuration</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>datetime</em></td>
    <td>when add-on was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this add-on</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>plan:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier for plan</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>plan:name</strong></td>
    <td><em>string</em></td>
    <td>unique name for plan</td>
    <td><code>"heroku-postgresql:dev"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when add-on was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Add-on Create
```
POST /apps/{app_id_or_name}/addons
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
    <td><strong>config</strong></td>
    <td><em>object</em></td>
    <td>additional add-on service specific configuration</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><strong>plan:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier for plan</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>plan:name</strong></td>
    <td><em>string</em></td>
    <td>unique name for plan</td>
    <td><code>"heroku-postgresql:dev"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/addons \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"config\":{},\"plan\":{\"id\":\"01234567-89ab-cdef-0123-456789abcdef\",\"name\":\"heroku-postgresql:dev\"}}"
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
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "plan": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql:dev"
  },
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### Add-on List
```
GET /apps/{app_id_or_name}/addons
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/addons \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "plan": {
      "id":   "01234567-89ab-cdef-0123-456789abcdef",
      "name": "heroku-postgresql:dev"
    },
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```
### Add-on Info
```
GET /apps/{app_id_or_name}/addons/{addon_id}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/addons/$ADDON_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "plan": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql:dev"
  },
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### Add-on Update
```
PATCH /apps/{app_id_or_name}/addons/{addon_id}
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
    <td><strong>config</strong></td>
    <td><em>object</em></td>
    <td>additional add-on service specific configuration</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><strong>plan:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier for plan</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>plan:name</strong></td>
    <td><em>string</em></td>
    <td>unique name for plan</td>
    <td><code>"heroku-postgresql:dev"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/addons/$ADDON_ID \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"config\":{},\"plan\":{\"id\":\"01234567-89ab-cdef-0123-456789abcdef\",\"name\":\"heroku-postgresql:dev\"}}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "plan": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql:dev"
  },
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### Add-on Delete
```
DELETE /apps/{app_id_or_name}/addons/{addon_id}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/addons/$ADDON_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "plan": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "heroku-postgresql:dev"
  },
  "updated_at": "2012-01-01T12:00:00Z"
}
```
## Add-on Service
Add-on services represent add-ons that may be provisioned for apps.
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
    <td><em>datetime</em></td>
    <td>when add-on service was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of service</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name for add-on service</td>
    <td><code>"heroku-postgresql"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when add-on service was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Add-on Service List
```
GET /addon-services
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/addon-services \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "name":       "heroku-postgresql",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```
### Add-on Service Info
```
GET /addon-services/{addon_service_id_or_name}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/addon-services/$ADDON_SERVICE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "name":       "heroku-postgresql",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
## App
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
    <td><em>datetime</em></td>
    <td>when app was archived</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>buildpack_provided_description</strong></td>
    <td><em>string</em></td>
    <td>description from buildpack of app</td>
    <td><code>"Ruby/Rack"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>datetime</em></td>
    <td>when app was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>git_url</strong></td>
    <td><em>string</em></td>
    <td>git repo URL of app</td>
    <td><code>"git@heroku.com/example.git"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of app</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
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
    <td>unique name of app</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>owner:email</strong></td>
    <td><em>string</em></td>
    <td>email address of app owner</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>owner:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of app owner</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>region:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of app region</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>region:name</strong></td>
    <td><em>string</em></td>
    <td>name of app region</td>
    <td><code>"us"</code></td>
  </tr>
  <tr>
    <td><strong>released_at</strong></td>
    <td><em>datetime</em></td>
    <td>when app was last released</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>repo_size</strong></td>
    <td><em>number</em></td>
    <td>app git repo size in bytes</td>
    <td><code>1024</code></td>
  </tr>
  <tr>
    <td><strong>slug_size</strong></td>
    <td><em>number</em></td>
    <td>app slug size in bytes</td>
    <td><code>512</code></td>
  </tr>
  <tr>
    <td><strong>stack</strong></td>
    <td><em>string</em></td>
    <td>stack of app</td>
    <td><code>"cedar"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when app was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>web_url</strong></td>
    <td><em>string</em></td>
    <td>web URL of app</td>
    <td><code>"http://example.herokuapp.com"</code></td>
  </tr>
</table>
### App Create
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
    <td>unique name of app</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>region:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of app region</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>region:name</strong></td>
    <td><em>string</em></td>
    <td>name of app region</td>
    <td><code>"us"</code></td>
  </tr>
  <tr>
    <td><strong>stack</strong></td>
    <td><em>string</em></td>
    <td>stack of app</td>
    <td><code>"cedar"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X POST https://api.heroku.com/apps \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"name\":\"example\",\"region\":{\"id\":\"01234567-89ab-cdef-0123-456789abcdef\",\"name\":\"us\"},\"stack\":\"cedar\"}"
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
  "archived_at":                    "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at":                     "2012-01-01T12:00:00Z",
  "git_url":                        "git@heroku.com/example.git",
  "id":                             "01234567-89ab-cdef-0123-456789abcdef",
  "maintenance":                    false,
  "name":                           "example",
  "owner": {
    "email": "username@example.com",
    "id":    "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at":                    "2012-01-01T12:00:00Z",
  "repo_size":                      1024,
  "slug_size":                      512,
  "stack":                          "cedar",
  "updated_at":                     "2012-01-01T12:00:00Z",
  "web_url":                        "http://example.herokuapp.com"
}
```
### App List
```
GET /apps
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "archived_at":                    "2012-01-01T12:00:00Z",
    "buildpack_provided_description": "Ruby/Rack",
    "created_at":                     "2012-01-01T12:00:00Z",
    "git_url":                        "git@heroku.com/example.git",
    "id":                             "01234567-89ab-cdef-0123-456789abcdef",
    "maintenance":                    false,
    "name":                           "example",
    "owner": {
      "email": "username@example.com",
      "id":    "01234567-89ab-cdef-0123-456789abcdef"
    },
    "region": {
      "id":   "01234567-89ab-cdef-0123-456789abcdef",
      "name": "us"
    },
    "released_at":                    "2012-01-01T12:00:00Z",
    "repo_size":                      1024,
    "slug_size":                      512,
    "stack":                          "cedar",
    "updated_at":                     "2012-01-01T12:00:00Z",
    "web_url":                        "http://example.herokuapp.com"
  }
]
```
### App Info
```
GET /apps/{app_id_or_name}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "archived_at":                    "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at":                     "2012-01-01T12:00:00Z",
  "git_url":                        "git@heroku.com/example.git",
  "id":                             "01234567-89ab-cdef-0123-456789abcdef",
  "maintenance":                    false,
  "name":                           "example",
  "owner": {
    "email": "username@example.com",
    "id":    "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at":                    "2012-01-01T12:00:00Z",
  "repo_size":                      1024,
  "slug_size":                      512,
  "stack":                          "cedar",
  "updated_at":                     "2012-01-01T12:00:00Z",
  "web_url":                        "http://example.herokuapp.com"
}
```
### App Update
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
    <td>unique name of app</td>
    <td><code>"example"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"maintenance\":false,\"name\":\"example\"}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "archived_at":                    "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at":                     "2012-01-01T12:00:00Z",
  "git_url":                        "git@heroku.com/example.git",
  "id":                             "01234567-89ab-cdef-0123-456789abcdef",
  "maintenance":                    false,
  "name":                           "example",
  "owner": {
    "email": "username@example.com",
    "id":    "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at":                    "2012-01-01T12:00:00Z",
  "repo_size":                      1024,
  "slug_size":                      512,
  "stack":                          "cedar",
  "updated_at":                     "2012-01-01T12:00:00Z",
  "web_url":                        "http://example.herokuapp.com"
}
```
### App Delete
```
DELETE /apps/{app_id_or_name}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "archived_at":                    "2012-01-01T12:00:00Z",
  "buildpack_provided_description": "Ruby/Rack",
  "created_at":                     "2012-01-01T12:00:00Z",
  "git_url":                        "git@heroku.com/example.git",
  "id":                             "01234567-89ab-cdef-0123-456789abcdef",
  "maintenance":                    false,
  "name":                           "example",
  "owner": {
    "email": "username@example.com",
    "id":    "01234567-89ab-cdef-0123-456789abcdef"
  },
  "region": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "us"
  },
  "released_at":                    "2012-01-01T12:00:00Z",
  "repo_size":                      1024,
  "slug_size":                      512,
  "stack":                          "cedar",
  "updated_at":                     "2012-01-01T12:00:00Z",
  "web_url":                        "http://example.herokuapp.com"
}
```
## App Feature
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
    <td><em>datetime</em></td>
    <td>when app feature was created</td>
    <td><code>2012-01-01T12:00:00-00:00</code></td>
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
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name of app feature</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when app feature was updated</td>
    <td><code>2012-01-01T12:00:00-00:00</code></td>
  </tr>
</table>
### App Feature List
```
GET /apps/{app_id_or_name}/features
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/features \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at":  "2012-01-01T12:00:00-00:00",
    "description": "Causes app to example.",
    "doc_url":     "http://devcenter.heroku.com/articles/example",
    "enabled":     true,
    "id":          "01234567-89ab-cdef-0123-456789abcdef",
    "name":        "example",
    "updated_at":  "2012-01-01T12:00:00-00:00"
  }
]
```
### App Feature Info
```
GET /apps/{app_id_or_name}/features/{feature_id_or_name}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/features/$FEATURE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":  "2012-01-01T12:00:00-00:00",
  "description": "Causes app to example.",
  "doc_url":     "http://devcenter.heroku.com/articles/example",
  "enabled":     true,
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "name":        "example",
  "updated_at":  "2012-01-01T12:00:00-00:00"
}
```
### App Feature Update
```
PATCH /apps/{app_id_or_name}/features/{feature_id_or_name}
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
```term
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/features/$FEATURE_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"enabled\":true}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":  "2012-01-01T12:00:00-00:00",
  "description": "Causes app to example.",
  "doc_url":     "http://devcenter.heroku.com/articles/example",
  "enabled":     true,
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "name":        "example",
  "updated_at":  "2012-01-01T12:00:00-00:00"
}
```
## App Transfer
[Transfers](https://devcenter.heroku.com/articles/transferring-apps) allow a user to transfer ownership of their app to another user. Apps being transferred may be free or have paid resources, but if they are paid, the receiving user must have a [verified account](https://devcenter.heroku.com/articles/account-verification).
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
    <td><em>datetime</em></td>
    <td>when the transfer was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>app:id</strong></td>
    <td><em>string</em></td>
    <td>unique identifier of the app being transferred</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>app:name</strong></td>
    <td><em>string</em></td>
    <td>name of the app being transferred</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this transfer</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>owner:id</strong></td>
    <td><em>string</em></td>
    <td>unique identifier of the sending user</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>owner:email</strong></td>
    <td><em>string</em></td>
    <td>email of the sending user</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>recipient:id</strong></td>
    <td><em>string</em></td>
    <td>unique identifier of the receiving user</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>recipient:email</strong></td>
    <td><em>string</em></td>
    <td>email of the receiving user</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>state</strong></td>
    <td><em>string</em></td>
    <td>new state of the transfer; accepted/declined/pending</td>
    <td><code>"pending"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when the transfer was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### App Transfer Create
```
POST /account/app-transfers
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
    <td><strong>app:id</strong></td>
    <td><em>string</em></td>
    <td>unique identifier of the app being transferred</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>app:name</strong></td>
    <td><em>string</em></td>
    <td>name of the app being transferred</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>recipient:id</strong></td>
    <td><em>string</em></td>
    <td>unique identifier of the receiving user</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>recipient:email</strong></td>
    <td><em>string</em></td>
    <td>email of the receiving user</td>
    <td><code>"username@example.com"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X POST https://api.heroku.com/account/app-transfers \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"app\":{\"id\":\"01234567-89ab-cdef-0123-456789abcdef\",\"name\":\"example\"},\"recipient\":{\"email\":\"username@example.com\",\"id\":\"01234567-89ab-cdef-0123-456789abcdef\"}}"
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
  "created_at": "2012-01-01T12:00:00Z",
  "app": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  },
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "owner": {
    "id":    "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "recipient": {
    "id":    "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "state":      "pending",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### App Transfer List
```
GET /account/app-transfers
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/account/app-transfers \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "app": {
      "id":   "01234567-89ab-cdef-0123-456789abcdef",
      "name": "example"
    },
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "owner": {
      "id":    "01234567-89ab-cdef-0123-456789abcdef",
      "email": "username@example.com"
    },
    "recipient": {
      "id":    "01234567-89ab-cdef-0123-456789abcdef",
      "email": "username@example.com"
    },
    "state":      "pending",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```
### App Transfer Info
```
GET /account/app-transfers/{transfer_id}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/account/app-transfers/$TRANSFER_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "app": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  },
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "owner": {
    "id":    "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "recipient": {
    "id":    "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "state":      "pending",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### App Transfer Update
```
PATCH /account/app-transfers/{transfer_id}
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
    <td>new state of the transfer; accepted/declined/pending</td>
    <td><code>"pending"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X PATCH https://api.heroku.com/account/app-transfers/$TRANSFER_ID \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"state\":\"pending\"}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "app": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  },
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "owner": {
    "id":    "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "recipient": {
    "id":    "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "state":      "pending",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### App Transfer Delete
```
DELETE /account/app-transfers/{transfer_id}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/account/app-transfers/$TRANSFER_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "app": {
    "id":   "01234567-89ab-cdef-0123-456789abcdef",
    "name": "example"
  },
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "owner": {
    "id":    "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "recipient": {
    "id":    "01234567-89ab-cdef-0123-456789abcdef",
    "email": "username@example.com"
  },
  "state":      "pending",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
## Collaborator
Collaborators are other users who have been given access to an app on Heroku.
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
    <td><em>datetime</em></td>
    <td>when collaborator was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this collaborator</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>silent</strong></td>
    <td><em>boolean</em></td>
    <td>when true, suppresses the invitation to collaborate e-mail</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when collaborator was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>user:email</strong></td>
    <td><em>string</em></td>
    <td>collaborator email address</td>
    <td><code>"collaborator@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>user:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of the user</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
</table>
### Collaborator Create
```
POST /apps/{app_id_or_name}/collaborators
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
    <td><strong>silent</strong></td>
    <td><em>boolean</em></td>
    <td>when true, suppresses the invitation to collaborate e-mail</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>user:email</strong></td>
    <td><em>string</em></td>
    <td>collaborator email address</td>
    <td><code>"collaborator@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>user:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of the user</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/collaborators \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"silent\":false,\"user\":{\"email\":\"collaborator@example.com\",\"id\":\"01234567-89ab-cdef-0123-456789abcdef\"}}"
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
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "email": "collaborator@example.com",
    "id":    "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```
### Collaborator List
```
GET /apps/{app_id_or_name}/collaborators
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/collaborators \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "updated_at": "2012-01-01T12:00:00Z",
    "user": {
      "email": "collaborator@example.com",
      "id":    "01234567-89ab-cdef-0123-456789abcdef"
    }
  }
]
```
### Collaborator Info
```
GET /apps/{app_id_or_name}/collaborators/{collaborator_id_or_email}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/collaborators/$COLLABORATOR_ID_OR_EMAIL \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "email": "collaborator@example.com",
    "id":    "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```
### Collaborator Delete
```
DELETE /apps/{app_id_or_name}/collaborators/{collaborator_id_or_email}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/collaborators/$COLLABORATOR_ID_OR_EMAIL \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "user": {
    "email": "collaborator@example.com",
    "id":    "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```
## Config Var
Config Vars allow you to manage the configuration information provided to an app on Heroku.
### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>{key}</strong></td>
    <td><em>string</em></td>
    <td>key/value pair for dyno env</td>
    <td><code>"{value}"</code></td>
  </tr>
</table>
### Config Var Info
```
GET /apps/{app_id_or_name}/config-vars
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/config-vars \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "FOO":  "bar",
  "BAZ":  "qux",
  "QUUX": "corge"
}
```
### Config Var Update
```
PATCH /apps/{app_id_or_name}/config-vars
```
#### Curl Example
```term
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/config-vars \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "BAZ":  "grault",
  "QUUX": "corge"
}
```
## Domain
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
    <td><em>datetime</em></td>
    <td>when domain was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
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
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when domain was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Domain Create
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
```term
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/domains \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"hostname\":\"subdomain.example.com\"}"
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
  "created_at": "2012-01-01T12:00:00Z",
  "hostname":   "subdomain.example.com",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### Domain List
```
GET /apps/{app_id_or_name}/domains
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/domains \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "hostname":   "subdomain.example.com",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```
### Domain Info
```
GET /apps/{app_id_or_name}/domains/{domain_id_or_hostname}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/domains/$DOMAIN_ID_OR_HOSTNAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "hostname":   "subdomain.example.com",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### Domain Delete
```
DELETE /apps/{app_id_or_name}/domains/{domain_id_or_hostname}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/domains/$DOMAIN_ID_OR_HOSTNAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "hostname":   "subdomain.example.com",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
## Dyno
Dynos represent running processes of an app on Heroku.
### Attributes
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
    <td><strong>attach_url</strong></td>
    <td><em>string</em></td>
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
    <td><em>datetime</em></td>
    <td>when domain was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>env</strong></td>
    <td><em>hash</em></td>
    <td>additional environment variables for the dyno execution</td>
    <td><code>{"COLUMNS"=>80, "LINES"=>24}</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this dyno</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>the name of this process on this app</td>
    <td><code>"run.1"</code></td>
  </tr>
  <tr>
    <td><strong>release:id</strong></td>
    <td><em>uuid</em></td>
    <td>the unique identifier of the release this process was started with</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>release:version</strong></td>
    <td><em>number</em></td>
    <td>the unique version of the release this process was started with</td>
    <td><code>456</code></td>
  </tr>
  <tr>
    <td><strong>size</strong></td>
    <td><em>number</em></td>
    <td>dyno size (default: 1)</td>
    <td><code>1</code></td>
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
    <td><em>datetime</em></td>
    <td>when process last changed state</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Dyno Create
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
    <td><em>hash</em></td>
    <td>additional environment variables for the dyno execution</td>
    <td><code>{"COLUMNS"=>80, "LINES"=>24}</code></td>
  </tr>
  <tr>
    <td><strong>size</strong></td>
    <td><em>number</em></td>
    <td>dyno size (default: 1)</td>
    <td><code>1</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"attach\":true,\"env\":{\"COLUMNS\":80,\"LINES\":24},\"size\":1,\"command\":\"bash\"}"
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
  "attach_url": "rendezvous://rendezvous.runtime.heroku.com:5000/{rendezvous-id}",
  "command":    "bash",
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "name":       "run.1",
  "release": {
    "id":      "01234567-89ab-cdef-0123-456789abcdef",
    "version": 456
  },
  "size":       1,
  "state":      "up",
  "type":       "run",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### Dyno List
```
GET /apps/{app_id_or_name}/dynos
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "attach_url": "rendezvous://rendezvous.runtime.heroku.com:5000/{rendezvous-id}",
    "command":    "bash",
    "created_at": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "name":       "run.1",
    "release": {
      "id":      "01234567-89ab-cdef-0123-456789abcdef",
      "version": 456
    },
    "size":       1,
    "state":      "up",
    "type":       "run",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```
### Dyno Info
```
GET /apps/{app_id_or_name}/dynos/{dyno_id_or_name}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos/$DYNO_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "attach_url": "rendezvous://rendezvous.runtime.heroku.com:5000/{rendezvous-id}",
  "command":    "bash",
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "name":       "run.1",
  "release": {
    "id":      "01234567-89ab-cdef-0123-456789abcdef",
    "version": 456
  },
  "size":       1,
  "state":      "up",
  "type":       "run",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### Dyno Delete
Restart single dyno.

```
DELETE /apps/{app_id_or_name}/dynos/{dyno_id_or_name}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos/$DYNO_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "attach_url": "rendezvous://rendezvous.runtime.heroku.com:5000/{rendezvous-id}",
  "command":    "bash",
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "name":       "run.1",
  "release": {
    "id":      "01234567-89ab-cdef-0123-456789abcdef",
    "version": 456
  },
  "size":       1,
  "state":      "up",
  "type":       "run",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### Dyno Delete All
Restart all dynos.

```
DELETE /apps/{app_id_or_name}/dynos
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/dynos \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "attach_url": "rendezvous://rendezvous.runtime.heroku.com:5000/{rendezvous-id}",
  "command":    "bash",
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "name":       "run.1",
  "release": {
    "id":      "01234567-89ab-cdef-0123-456789abcdef",
    "version": 456
  },
  "size":       1,
  "state":      "up",
  "type":       "run",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
## Formation
The formation of processes that should be maintained for your application. Commands and types are defined by the Procfile uploaded with an app.
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
    <td>command to use for process type</td>
    <td><code>"bundle exec rails server -p $PORT"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>datetime</em></td>
    <td>when process type was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this process type</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>quantity</strong></td>
    <td><em>number</em></td>
    <td>number of processes to maintain</td>
    <td><code>1</code></td>
  </tr>
  <tr>
    <td><strong>size</strong></td>
    <td><em>number</em></td>
    <td>dyno size (default: 1)</td>
    <td><code>1</code></td>
  </tr>
  <tr>
    <td><strong>type</strong></td>
    <td><em>string</em></td>
    <td>type of process to maintain</td>
    <td><code>"web"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when dyno type was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Formation List
```
GET /apps/{app_id_or_name}/formation
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/formation \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "command":    "bundle exec rails server -p $PORT",
    "created_at": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "quantity":   1,
    "size":       1,
    "type":       "web",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```
### Formation Info
```
GET /apps/{app_id_or_name}/formation/{formation_id_or_type}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/formation/$FORMATION_ID_OR_TYPE \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "command":    "bundle exec rails server -p $PORT",
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "quantity":   1,
  "size":       1,
  "type":       "web",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
### Formation Update
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
    <td><em>number</em></td>
    <td>number of processes to maintain</td>
    <td><code>1</code></td>
  </tr>
  <tr>
    <td><strong>size</strong></td>
    <td><em>number</em></td>
    <td>dyno size (default: 1)</td>
    <td><code>1</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/formation/$FORMATION_ID_OR_TYPE \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"quantity\":1,\"size\":1}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "command":    "bundle exec rails server -p $PORT",
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "quantity":   1,
  "size":       1,
  "type":       "web",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
## Key
Keys represent public SSH keys associated with an account and are used to authorize users as they are performing git operations.
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
    <td><em>datetime</em></td>
    <td>when key was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>email</strong></td>
    <td><em>string</em></td>
    <td>email address provided in key contents</td>
    <td><code>"username@example.com"</code></td>
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
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>public_key</strong></td>
    <td><em>string</em></td>
    <td>full public_key as uploaded</td>
    <td><code>"ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when key was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Key Create
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
```term
$ curl -n -X POST https://api.heroku.com/account/keys \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"public_key\":\"ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com\"}"
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
  "created_at":  "2012-01-01T12:00:00Z",
  "email":       "username@example.com",
  "fingerprint": "17:63:a4:ba:24:d3:7f:af:17:c8:94:82:7e:80:56:bf",
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "public_key":  "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com",
  "updated_at":  "2012-01-01T12:00:00Z"
}
```
### Key List
```
GET /account/keys
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/account/keys \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at":  "2012-01-01T12:00:00Z",
    "email":       "username@example.com",
    "fingerprint": "17:63:a4:ba:24:d3:7f:af:17:c8:94:82:7e:80:56:bf",
    "id":          "01234567-89ab-cdef-0123-456789abcdef",
    "public_key":  "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com",
    "updated_at":  "2012-01-01T12:00:00Z"
  }
]
```
### Key Info
```
GET /account/keys/{key_id_or_fingerprint}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/account/keys/$KEY_ID_OR_FINGERPRINT \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":  "2012-01-01T12:00:00Z",
  "email":       "username@example.com",
  "fingerprint": "17:63:a4:ba:24:d3:7f:af:17:c8:94:82:7e:80:56:bf",
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "public_key":  "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com",
  "updated_at":  "2012-01-01T12:00:00Z"
}
```
### Key Delete
```
DELETE /account/keys/{key_id_or_fingerprint}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/account/keys/$KEY_ID_OR_FINGERPRINT \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":  "2012-01-01T12:00:00Z",
  "email":       "username@example.com",
  "fingerprint": "17:63:a4:ba:24:d3:7f:af:17:c8:94:82:7e:80:56:bf",
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "public_key":  "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com",
  "updated_at":  "2012-01-01T12:00:00Z"
}
```
## Log Drain
[Log drains](https://devcenter.heroku.com/articles/logging#syslog-drains) provide a way to forward your Heroku logs to an external syslog server for long-term archiving. This external service must be configured to receive syslog packets from Heroku, whereupon its URL can be added to an app using this API.
### Attributes
<table>
  <tr>
    <th>Name</th>
    <th>Type</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td><strong>addon:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of the addon that provides the drain</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>datetime</em></td>
    <td>when log drain was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this log drain</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when log session was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>url</strong></td>
    <td><em>string</em></td>
    <td>url associated with the log drain</td>
    <td><code>"https://example.com/drain"</code></td>
  </tr>
</table>
### Log Drain Create
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
```term
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/log-drains \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"url\":\"https://example.com/drain\"}"
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
  "addon": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "url":        "https://example.com/drain"
}
```
### Log Drain List
```
GET /apps/{app_id_or_name}/log-drains
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/log-drains \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "addon": {
      "id": "01234567-89ab-cdef-0123-456789abcdef"
    },
    "created_at": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "updated_at": "2012-01-01T12:00:00Z",
    "url":        "https://example.com/drain"
  }
]
```
### Log Drain Info
```
GET /apps/{app_id_or_name}/log-drains/{drain_id_or_url}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/log-drains/$DRAIN_ID_OR_URL \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "addon": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "url":        "https://example.com/drain"
}
```
### Log Drain Delete
```
DELETE /apps/{app_id_or_name}/log-drains/{drain_id_or_url}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/log-drains/$DRAIN_ID_OR_URL \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "addon": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at": "2012-01-01T12:00:00Z",
  "url":        "https://example.com/drain"
}
```
## Log Session
Log sessions provide a URL to stream data from your app logs. Streaming is performed by doing an HTTP GET method on the provided Logplex URL and then repeatedly reading from the socket. Sessions remain available for about 5 minutes after creation or about one hour after connecting. For continuous access to an app's log, you should set up a [log drain](https://devcenter.heroku.com/articles/logging#syslog-drains).
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
    <td><em>datetime</em></td>
    <td>when log connection was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>dyno</strong></td>
    <td><em>string</em></td>
    <td>dyno to limit results to</td>
    <td><code>"web.1"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this log session</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>lines</strong></td>
    <td><em>number</em></td>
    <td>number of log lines to stream at once</td>
    <td><code>10</code></td>
  </tr>
  <tr>
    <td><strong>logplex_url</strong></td>
    <td><em>string</em></td>
    <td>URL for log streaming session</td>
    <td><code>"https://logplex.heroku.com/sessions/01234567-89ab-cdef-0123-456789abcdef?srv=1325419200"</code></td>
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
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when log session was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Log Session Create
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
    <td><em>number</em></td>
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
```term
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/log-sessions \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"dyno\":\"web.1\",\"lines\":10,\"source\":\"app\",\"tail\":true}"
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
  "created_at":  "2012-01-01T12:00:00Z",
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "logplex_url": "https://logplex.heroku.com/sessions/01234567-89ab-cdef-0123-456789abcdef?srv=1325419200",
  "updated_at":  "2012-01-01T12:00:00Z"
}
```
## OAuth Authorization
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
    <td><strong>access_token:expires_in</strong></td>
    <td><em>number</em></td>
    <td>seconds until OAuth access token expires</td>
    <td><code>7200</code></td>
  </tr>
  <tr>
    <td><strong>access_token:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this authorization's OAuth access token</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>access_token:token</strong></td>
    <td><em>string</em></td>
    <td>the actual OAuth access token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>client:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this OAuth authorization client</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>client:ignores_delinquent</strong></td>
    <td><em>boolean</em></td>
    <td>whether the client is still operable given a delinquent account</td>
    <td><code>false</code></td>
  </tr>
  <tr>
    <td><strong>client:name</strong></td>
    <td><em>string</em></td>
    <td>OAuth authorization client name</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>client:redirect_uri</strong></td>
    <td><em>string</em></td>
    <td>endpoint for redirection after authorization with OAuth authorization client</td>
    <td><code>"https://example.com/auth/heroku/callback"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>datetime</em></td>
    <td>when OAuth authorization was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>human-friendly description of this OAuth authorization</td>
    <td><code>"sample authorization"</code></td>
  </tr>
  <tr>
    <td><strong>grant:code</strong></td>
    <td><em>string</em></td>
    <td>code for the OAuth authorization grant</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>grant:expires_in</strong></td>
    <td><em>datetime</em></td>
    <td>date in which this authorization grant is no longer valid</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>grant:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier for this authorization's grant</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth authorization</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:expires_in</strong></td>
    <td><em>number</em></td>
    <td>seconds until OAuth refresh token expires; may be `null` for a refresh token with indefinite lifetime</td>
    <td><code>7200</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this authorization's OAuth refresh token</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:token</strong></td>
    <td><em>string</em></td>
    <td>the actual OAuth refresh token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>scope</strong></td>
    <td><em>array[string]</em></td>
    <td>The scope of access OAuth authorization allows</td>
    <td><code>["global"]</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when OAuth authorization was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### OAuth Authorization Create
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
    <td><em>array[string]</em></td>
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
    <td><strong>client:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this OAuth authorization client</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>human-friendly description of this OAuth authorization</td>
    <td><code>"sample authorization"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X POST https://api.heroku.com/oauth/authorizations \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"client\":{\"id\":\"01234567-89ab-cdef-0123-456789abcdef\"},\"description\":\"sample authorization\",\"scope\":[\"global\"]}"
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
  "access_token": {
    "expires_in": "7200",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "token":      "01234567-89ab-cdef-0123-456789abcdef"
  },
  "client": {
    "id":                 "01234567-89ab-cdef-0123-456789abcdef",
    "ignores_delinquent": false,
    "name":               "example",
    "redirect_uri":       "https://example.com/auth/heroku/callback"
  },
  "created_at":    "2012-01-01T12:00:00Z",
  "description":   "sample authorization",
  "grant": {
    "code":       "01234567-89ab-cdef-0123-456789abcdef",
    "expires_in": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef"
  },
  "id":            "01234567-89ab-cdef-0123-456789abcdef",
  "refresh_token": {
    "expires_in": "7200",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "token":      "01234567-89ab-cdef-0123-456789abcdef"
  },
  "scope":         ["global"],
  "updated_at":    "2012-01-01T12:00:00Z"
}
```
### OAuth Authorization List
```
GET /oauth/authorizations
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/oauth/authorizations \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "access_token": {
      "expires_in": "7200",
      "id":         "01234567-89ab-cdef-0123-456789abcdef",
      "token":      "01234567-89ab-cdef-0123-456789abcdef"
    },
    "client": {
      "id":                 "01234567-89ab-cdef-0123-456789abcdef",
      "ignores_delinquent": false,
      "name":               "example",
      "redirect_uri":       "https://example.com/auth/heroku/callback"
    },
    "created_at":    "2012-01-01T12:00:00Z",
    "description":   "sample authorization",
    "grant": {
      "code":       "01234567-89ab-cdef-0123-456789abcdef",
      "expires_in": "2012-01-01T12:00:00Z",
      "id":         "01234567-89ab-cdef-0123-456789abcdef"
    },
    "id":            "01234567-89ab-cdef-0123-456789abcdef",
    "refresh_token": {
      "expires_in": "7200",
      "id":         "01234567-89ab-cdef-0123-456789abcdef",
      "token":      "01234567-89ab-cdef-0123-456789abcdef"
    },
    "scope":         ["global"],
    "updated_at":    "2012-01-01T12:00:00Z"
  }
]
```
### OAuth Authorization Info
```
GET /oauth/authorizations/{authorization_id}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/oauth/authorizations/$AUTHORIZATION_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "access_token": {
    "expires_in": "7200",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "token":      "01234567-89ab-cdef-0123-456789abcdef"
  },
  "client": {
    "id":                 "01234567-89ab-cdef-0123-456789abcdef",
    "ignores_delinquent": false,
    "name":               "example",
    "redirect_uri":       "https://example.com/auth/heroku/callback"
  },
  "created_at":    "2012-01-01T12:00:00Z",
  "description":   "sample authorization",
  "grant": {
    "code":       "01234567-89ab-cdef-0123-456789abcdef",
    "expires_in": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef"
  },
  "id":            "01234567-89ab-cdef-0123-456789abcdef",
  "refresh_token": {
    "expires_in": "7200",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "token":      "01234567-89ab-cdef-0123-456789abcdef"
  },
  "scope":         ["global"],
  "updated_at":    "2012-01-01T12:00:00Z"
}
```
### OAuth Authorization Delete
```
DELETE /oauth/authorizations/{authorization_id}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/oauth/authorizations/$AUTHORIZATION_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "access_token": {
    "expires_in": "7200",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "token":      "01234567-89ab-cdef-0123-456789abcdef"
  },
  "client": {
    "id":                 "01234567-89ab-cdef-0123-456789abcdef",
    "ignores_delinquent": false,
    "name":               "example",
    "redirect_uri":       "https://example.com/auth/heroku/callback"
  },
  "created_at":    "2012-01-01T12:00:00Z",
  "description":   "sample authorization",
  "grant": {
    "code":       "01234567-89ab-cdef-0123-456789abcdef",
    "expires_in": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef"
  },
  "id":            "01234567-89ab-cdef-0123-456789abcdef",
  "refresh_token": {
    "expires_in": "7200",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "token":      "01234567-89ab-cdef-0123-456789abcdef"
  },
  "scope":         ["global"],
  "updated_at":    "2012-01-01T12:00:00Z"
}
```
## OAuth Client
OAuth clients are applications that Heroku users can authorize to automate, customize or extend their usage of the platform. For more information please refer to the [Heroku OAuth documentation](https://devcenter.heroku.com/articles/oauth)
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
    <td><em>datetime</em></td>
    <td>when OAuth client was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this OAuth client</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>ignores_delinquent</strong></td>
    <td><em>boolean</em></td>
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
    <td><em>datetime</em></td>
    <td>when OAuth client was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### OAuth Client Create
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
```term
$ curl -n -X POST https://api.heroku.com/oauth/clients \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"name\":\"example\",\"redirect_uri\":\"https://example.com/auth/heroku/callback\"}"
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
  "created_at":         "2012-01-01T12:00:00Z",
  "id":                 "01234567-89ab-cdef-0123-456789abcdef",
  "ignores_delinquent": false,
  "name":               "example",
  "redirect_uri":       "https://example.com/auth/heroku/callback",
  "secret":             "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at":         "2012-01-01T12:00:00Z"
}
```
### OAuth Client List
```
GET /oauth/clients
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/oauth/clients \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at":         "2012-01-01T12:00:00Z",
    "id":                 "01234567-89ab-cdef-0123-456789abcdef",
    "ignores_delinquent": false,
    "name":               "example",
    "redirect_uri":       "https://example.com/auth/heroku/callback",
    "secret":             "01234567-89ab-cdef-0123-456789abcdef",
    "updated_at":         "2012-01-01T12:00:00Z"
  }
]
```
### OAuth Client Info
```
GET /oauth/clients/{client_id}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/oauth/clients/$CLIENT_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":         "2012-01-01T12:00:00Z",
  "id":                 "01234567-89ab-cdef-0123-456789abcdef",
  "ignores_delinquent": false,
  "name":               "example",
  "redirect_uri":       "https://example.com/auth/heroku/callback",
  "secret":             "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at":         "2012-01-01T12:00:00Z"
}
```
### OAuth Client Update
```
PATCH /oauth/clients/{client_id}
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
```term
$ curl -n -X PATCH https://api.heroku.com/oauth/clients/$CLIENT_ID \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"name\":\"example\",\"redirect_uri\":\"https://example.com/auth/heroku/callback\"}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":         "2012-01-01T12:00:00Z",
  "id":                 "01234567-89ab-cdef-0123-456789abcdef",
  "ignores_delinquent": false,
  "name":               "example",
  "redirect_uri":       "https://example.com/auth/heroku/callback",
  "secret":             "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at":         "2012-01-01T12:00:00Z"
}
```
### OAuth Client Delete
```
DELETE /oauth/clients/{client_id}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/oauth/clients/$CLIENT_ID \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":         "2012-01-01T12:00:00Z",
  "id":                 "01234567-89ab-cdef-0123-456789abcdef",
  "ignores_delinquent": false,
  "name":               "example",
  "redirect_uri":       "https://example.com/auth/heroku/callback",
  "secret":             "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at":         "2012-01-01T12:00:00Z"
}
```
## OAuth Token
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
    <td><strong>authorization:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth token authorization</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>access_token:expires_in</strong></td>
    <td><em>number</em></td>
    <td>seconds until OAuth access token expires</td>
    <td><code>2592000</code></td>
  </tr>
  <tr>
    <td><strong>access_token:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth access token</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>access_token:token</strong></td>
    <td><em>string</em></td>
    <td>content of OAuth access token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>client:secret</strong></td>
    <td><em>string</em></td>
    <td>OAuth client secret used to obtain token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>created_at</strong></td>
    <td><em>datetime</em></td>
    <td>when OAuth token was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>grant:code</strong></td>
    <td><em>string</em></td>
    <td>grant code recieved from OAuth web application authorization</td>
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
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:expires_in</strong></td>
    <td><em>number</em></td>
    <td>seconds until OAuth refresh token expires; may be `null` for a refresh token with indefinite lifetime</td>
    <td><code>2592000</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of OAuth refresh token</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:token</strong></td>
    <td><em>string</em></td>
    <td>content of OAuth refresh token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>session:id</strong></td>
    <td><em>string</em></td>
    <td>unique identifier of OAuth token session</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when OAuth token was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>user:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of the user</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
</table>
### OAuth Token Create
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
    <td><strong>grant:type</strong></td>
    <td><em>string</em></td>
    <td>type of grant requested, one of `authorization_code` or `refresh_token`</td>
    <td><code>"authorization_code"</code></td>
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
    <td><strong>client:secret</strong></td>
    <td><em>string</em></td>
    <td>OAuth client secret used to obtain token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>grant:code</strong></td>
    <td><em>string</em></td>
    <td>grant code recieved from OAuth web application authorization</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
  <tr>
    <td><strong>refresh_token:token</strong></td>
    <td><em>string</em></td>
    <td>content of OAuth refresh token</td>
    <td><code>"01234567-89ab-cdef-0123-456789abcdef"</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X POST https://api.heroku.com/oauth/tokens \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"client\":{\"secret\":\"01234567-89ab-cdef-0123-456789abcdef\"},\"grant\":{\"code\":\"01234567-89ab-cdef-0123-456789abcdef\",\"type\":\"authorization_code\"},\"refresh_token\":{\"token\":\"01234567-89ab-cdef-0123-456789abcdef\"}}"
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
  "authorization": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "access_token": {
    "expires_in": 2592000,
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "token":      "01234567-89ab-cdef-0123-456789abcdef"
  },
  "created_at":    "2012-01-01T12:00:00Z",
  "id":            "01234567-89ab-cdef-0123-456789abcdef",
  "refresh_token": {
    "expires_in": 2592000,
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "token":      "01234567-89ab-cdef-0123-456789abcdef"
  },
  "session": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  },
  "updated_at":    "2012-01-01T12:00:00Z",
  "user": {
    "id": "01234567-89ab-cdef-0123-456789abcdef"
  }
}
```
## Plan
Plans represent different configurations of add-ons that may be added to apps.
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
    <td><em>datetime</em></td>
    <td>when plan was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
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
    <td>unique identifier of plan</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name for plan</td>
    <td><code>"heroku-postgresql:dev"</code></td>
  </tr>
  <tr>
    <td><strong>price:cents</strong></td>
    <td><em>number</em></td>
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
    <td><em>datetime</em></td>
    <td>when plan was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Plan List
```
GET /addon-services/{addon_service_id_or_name}/plans
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/addon-services/$ADDON_SERVICE_ID_OR_NAME/plans \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at":  "2012-01-01T12:00:00Z",
    "description": "Heroku Postgres Dev",
    "id":          "01234567-89ab-cdef-0123-456789abcdef",
    "name":        "heroku-postgresql:dev",
    "price": {
      "cents": 0,
      "unit":  "month"
    },
    "state":       "public",
    "updated_at":  "2012-01-01T12:00:00Z"
  }
]
```
### Plan Info
```
GET /addon-services/{addon_service_id_or_name}/plans/{plan_id_or_name}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/addon-services/$ADDON_SERVICE_ID_OR_NAME/plans/$PLAN_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":  "2012-01-01T12:00:00Z",
  "description": "Heroku Postgres Dev",
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "name":        "heroku-postgresql:dev",
  "price": {
    "cents": 0,
    "unit":  "month"
  },
  "state":       "public",
  "updated_at":  "2012-01-01T12:00:00Z"
}
```
## Rate Limits
Rate Limits represent the number of request tokens each account holds. Requests to this endpoint do not count towards the rate limit.
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
    <td><em>number</em></td>
    <td>allowed requests remaining in current interval</td>
    <td><code>2399</code></td>
  </tr>
</table>
### Rate Limits List
```
GET /account/rate-limits
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/account/rate-limits \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "remaining": 2399
  }
]
```
## Region
Regions represent geographic locations in which your application may run.
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
    <td><em>datetime</em></td>
    <td>when region was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>description</strong></td>
    <td><em>string</em></td>
    <td>description of the region</td>
    <td><code>"United States"</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this region</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name of the region</td>
    <td><code>"us"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when region was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Region List
```
GET /regions
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/regions \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at":  "2012-01-01T12:00:00Z",
    "description": "United States",
    "id":          "01234567-89ab-cdef-0123-456789abcdef",
    "name":        "us",
    "updated_at":  "2012-01-01T12:00:00Z"
  }
]
```
### Region Info
```
GET /regions/{region_id_or_name}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/regions/$REGION_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":  "2012-01-01T12:00:00Z",
  "description": "United States",
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "name":        "us",
  "updated_at":  "2012-01-01T12:00:00Z"
}
```
## Release
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
    <td><em>datetime</em></td>
    <td>when release was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
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
    <td>unique identifier of this release</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when region was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>user:email</strong></td>
    <td><em>string</em></td>
    <td>email address of user that created the release</td>
    <td><code>"username@example.com"</code></td>
  </tr>
  <tr>
    <td><strong>user:id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of the user that created the release</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>version</strong></td>
    <td><em>number</em></td>
    <td>unique version assigned to the release</td>
    <td><code>456</code></td>
  </tr>
</table>
### Release List
```
GET /apps/{app_id_or_name}/releases
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/releases \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at":  "2012-01-01T12:00:00Z",
    "description": "Added new feature",
    "id":          "01234567-89ab-cdef-0123-456789abcdef",
    "updated_at":  "2012-01-01T12:00:00Z",
    "user": {
      "email": "username@example.com",
      "id":    "01234567-89ab-cdef-0123-456789abcdef"
    },
    "version":     456
  }
]
```
### Release Info
```
GET /apps/{app_id_or_name}/releases/{release_id_or_version}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/releases/$RELEASE_ID_OR_VERSION \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at":  "2012-01-01T12:00:00Z",
  "description": "Added new feature",
  "id":          "01234567-89ab-cdef-0123-456789abcdef",
  "updated_at":  "2012-01-01T12:00:00Z",
  "user": {
    "email": "username@example.com",
    "id":    "01234567-89ab-cdef-0123-456789abcdef"
  },
  "version":     456
}
```
## SSL Endpoint
[SSL Endpoints](https://devcenter.heroku.com/articles/ssl-endpoint) are public addresses serving custom SSL certs for HTTPS traffic to Heroku apps. Note that an app must have the `ssl:endpoint` addon installed before it can provision an SSL Endpoint using these APIs.
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
    <td><em>datetime</em></td>
    <td>when endpoint was created</td>
    <td><code>2012-01-01T12:00:00-00:00</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this SSL endpoint</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name for SSL endpoint</td>
    <td><code>"tokyo-1234"</code></td>
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
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when endpoint was updated</td>
    <td><code>2012-01-01T12:00:00-00:00</code></td>
  </tr>
</table>
### SSL Endpoint Create
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
#### Curl Example
```term
$ curl -n -X POST https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"certificate_chain\":\"-----BEGIN CERTIFICATE----- ...\",\"private_key\":\"-----BEGIN RSA PRIVATE KEY----- ...\"}"
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
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "cname":             "example.herokussl.com",
  "created_at":        "2012-01-01T12:00:00-00:00",
  "id":                "01234567-89ab-cdef-0123-456789abcdef",
  "name":              "tokyo-1234",
  "updated_at":        "2012-01-01T12:00:00-00:00"
}
```
### SSL Endpoint List
```
GET /apps/{app_id_or_name}/ssl-endpoints
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
    "cname":             "example.herokussl.com",
    "created_at":        "2012-01-01T12:00:00-00:00",
    "id":                "01234567-89ab-cdef-0123-456789abcdef",
    "name":              "tokyo-1234",
    "updated_at":        "2012-01-01T12:00:00-00:00"
  }
]
```
### SSL Endpoint Info
```
GET /apps/{app_id_or_name}/ssl-endpoints/{ssl_endpoint_id_or_name}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints/$SSL_ENDPOINT_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "cname":             "example.herokussl.com",
  "created_at":        "2012-01-01T12:00:00-00:00",
  "id":                "01234567-89ab-cdef-0123-456789abcdef",
  "name":              "tokyo-1234",
  "updated_at":        "2012-01-01T12:00:00-00:00"
}
```
### SSL Endpoint Update
Updates an SSL Endpoint with a new certificate and private key or [rolls back an SSL Endpoint](https://devcenter.heroku.com/articles/ssl-endpoint#undo) when the `rollback` parameter is given a value of `true`.

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
    <td><strong>private_key</strong></td>
    <td><em>string</em></td>
    <td>contents of the private key (eg .key file)</td>
    <td><code>"-----BEGIN RSA PRIVATE KEY----- ..."</code></td>
  </tr>
  <tr>
    <td><strong>rollback</strong></td>
    <td><em>boolean</em></td>
    <td>indicates that a rollback should be performed</td>
    <td><code>true</code></td>
  </tr>
</table>
#### Curl Example
```term
$ curl -n -X PATCH https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints/$SSL_ENDPOINT_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "{\"certificate_chain\":\"-----BEGIN CERTIFICATE----- ...\",\"private_key\":\"-----BEGIN RSA PRIVATE KEY----- ...\",\"rollback\":true}"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "cname":             "example.herokussl.com",
  "created_at":        "2012-01-01T12:00:00-00:00",
  "id":                "01234567-89ab-cdef-0123-456789abcdef",
  "name":              "tokyo-1234",
  "updated_at":        "2012-01-01T12:00:00-00:00"
}
```
### SSL Endpoint Delete
```
DELETE /apps/{app_id_or_name}/ssl-endpoints/{ssl_endpoint_id_or_name}
```
#### Curl Example
```term
$ curl -n -X DELETE https://api.heroku.com/apps/$APP_ID_OR_NAME/ssl-endpoints/$SSL_ENDPOINT_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "certificate_chain": "-----BEGIN CERTIFICATE----- ...",
  "cname":             "example.herokussl.com",
  "created_at":        "2012-01-01T12:00:00-00:00",
  "id":                "01234567-89ab-cdef-0123-456789abcdef",
  "name":              "tokyo-1234",
  "updated_at":        "2012-01-01T12:00:00-00:00"
}
```
## Stack
A stack represents an application execution environment.
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
    <td><em>datetime</em></td>
    <td>when stack was created</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
  <tr>
    <td><strong>id</strong></td>
    <td><em>uuid</em></td>
    <td>unique identifier of this stack</td>
    <td><code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <td><strong>name</strong></td>
    <td><em>string</em></td>
    <td>unique name of stack</td>
    <td><code>"example"</code></td>
  </tr>
  <tr>
    <td><strong>state</strong></td>
    <td><em>string</em></td>
    <td>state of the stack; beta/deprecated/public</td>
    <td><code>"public"</code></td>
  </tr>
  <tr>
    <td><strong>updated_at</strong></td>
    <td><em>datetime</em></td>
    <td>when stack was updated</td>
    <td><code>2012-01-01T12:00:00Z</code></td>
  </tr>
</table>
### Stack List
```
GET /stacks
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/stacks \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
Content-Range: ids 01234567-89ab-cdef-0123-456789abcdef..01234567-89ab-cdef-0123-456789abcdef; max=200
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
[
  {
    "created_at": "2012-01-01T12:00:00Z",
    "id":         "01234567-89ab-cdef-0123-456789abcdef",
    "name":       "example",
    "state":      "public",
    "updated_at": "2012-01-01T12:00:00Z"
  }
]
```
### Stack Info
```
GET /stacks/{stack_id_or_name}
```
#### Curl Example
```term
$ curl -n -X GET https://api.heroku.com/stacks/$STACK_ID_OR_NAME \
-H "Accept: application/vnd.heroku+json; version=3"
```
#### Response
```
HTTP/1.1 200 OK
ETag: "0123456789abcdef0123456789abcdef"
Last-Modified: Sun, 01 Jan 2012 12:00:00 GMT
RateLimit-Remaining: 1200
```
```javascript
{
  "created_at": "2012-01-01T12:00:00Z",
  "id":         "01234567-89ab-cdef-0123-456789abcdef",
  "name":       "example",
  "state":      "public",
  "updated_at": "2012-01-01T12:00:00Z"
}
```
        