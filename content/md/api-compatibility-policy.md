---
title: API Compatibility Policy
slug: api-compatibility-policy
url: https://devcenter.heroku.com/articles/api-compatibility-policy
description: This article describes Heroku's commitment to compatibility for services built on the Platform API. It also describes how we will introduce changes to the API and how those changes are communicated.
---

This article describes Heroku's commitment to compatibility for services built on the Platform API. It also describes how we will introduce changes to the API and how those changes are communicated.

## Versions and resource stability

V3 is the current and only supported version of the Platform API.

Within any given version of the API, any given resource (eg. `/apps`, `/account` or `/apps/:id/addons`) has a specified level of stability. The stability of a resource is specified in the [JSON Schema](https://devcenter.heroku.com/articles/json-schema-for-platform-api) `stability` property. It's also displayed in the [Platform API reference document](https://devcenter.heroku.com/articles/platform-api-reference).

The stability of a resource specifies what changes (if any) Heroku will make to the resource and how changes will be communicated. The possible types of changes are detailed below. All changes are communicated in the [Heroku Changelog](https://devcenter.heroku.com/changelog).

There are three levels of stability: prototype, development, and production.

### Prototype

A prototype resource is experimental and major changes are likely. In time, a prototype resource may or may not advance to production.

 * Compatible and emergency changes may be made with no advance notice
 * Disruptive changes may be made with one week notice
 * Deprecated resources will remain available for at least one month after deprecation

### Development

A Development resource is a work-in-progress, but major changes should be infrequent. Development resources should advance to production stability in time.

* Compatible and emergency changes may be made with no advance notice
* Disruptive changes may be made with one month notice
* Deprecated resources will remain available for at least six months after deprecation

### Production

A production resources is complete and major changes will no longer occur.

* Compatible and emergency changes may be made with no advance notice
* Disruptive changes may not occur, instead a new major version is developed
* Deprecated resources will remain available for at least twelve months after deprecation

### Deprecation

Deprecated resources have a `deprecated_at` date property in the JSON Schema which is also displayed in the API Reference documentation. Deprecated resources will keep working for at least as long after deprecation as mandated by their stability: 1 month for prototype resources, 6 month for development resources and 12 months for production resources. Deprecated resources will not change stability.

Once a resource has been completely deactivated, it will return HTTP 410 for all requests.

## Types of changes

### Compatible change

Small in scope and unlikely to break or change semantics of existing methods.

* Add resources, methods and attributes
* Change documentation
* Change undocumented behavior

### Disruptive change

May have larger impact and effort will be made to provide migration paths as needed.

* Change semantics of existing methods
* Remove resources, methods and attributes

### Emergency change

May have larger impact, but are unavoidable due to legal compliance, security vulnerabilities or violation of specification.

## Selecting API version

To use the current v3 version of the API, pass this header in requests: `Accept: application/vnd.heroku+json; version=3`.

A particular resource will only ever have one stability for a particular version of the API. That means that if the `/apps` endpoint is of production stability in v3, there's is no "prototype" work happening for `/apps` in v3.

If Heroku wanted to introduce breaking changes to the `/apps` endpoint after it had reached production stability in v3, that work would happen in a new API version, eg. v4. No such version currently exists, but if it did, you could access it by passing the correct header: `Accept: application/vnd.heroku+json; version=4`.

A future API version may not support all resources available in current API versions, it might support new ones, or resources may be re-organized or re-named. A future v4 API may thus have an `/apps` resource, but no `/account` resource (requests to that would return HTTP 404). To see what resources are supported for a particular API version, you can always inspect its published JSON Schema:

```term
$ curl https://api.heroku.com/schema  -H "Accept: application/vnd.heroku+json; version=4"
``` 