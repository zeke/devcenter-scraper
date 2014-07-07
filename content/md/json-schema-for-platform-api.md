---
title: JSON Schema for Platform API
slug: json-schema-for-platform-api
url: https://devcenter.heroku.com/articles/json-schema-for-platform-api
description: The API JSON schema describes what resources are available via the API, what their URLs are, how they are represented and what operations they support.
---

The Heroku Platform API has a machine-readable JSON schema that describes what resources are available via the API, what their URLs are, how they are represented and what operations they support. Example intended uses for the schema include:

 * Auto-creating client libraries for your favorite programming language
 * Generating up-to-date reference docs
 * Writing automatic acceptance and integration tests

A number of Platform API client libraries are already being generated using the schema:

 * [Heroics](https://github.com/heroku/heroics), for Ruby
 * [node-heroku-client](https://github.com/heroku/node-heroku-client) for Node.js
 * [Heroku.scala](https://github.com/heroku/heroku.scala)
 * and [heroku-go](https://github.com/bgentry/heroku-go)

## Format

Heroku uses [JSON Schema](http://json-schema.org/) to describe the Platform API. The draft [Validation](http://tools.ietf.org/html/draft-fge-json-schema-validation-00) and [Hypertext](http://tools.ietf.org/html/draft-luff-json-hyper-schema-00) extension standards are also used.

JSON Schema is also used as the basis for [Swagger](https://developers.helloreverb.com/swagger/) and the [Google API discovery service](https://developers.google.com/discovery/v1/getting_started) and the [JSON Schema website lists many resources and links](http://json-schema.org/implementations.html) that demonstrate how to get started.

## How to use

The API serves up its own JSON-formatted schema using HTTP:

```term
$ curl https://api.heroku.com/schema  -H "Accept: application/vnd.heroku+json; version=3"
{
  "description": "The platform API empowers developers to automate, extend and combine Heroku with other services.",
  "definitions": {
  ...
  }
}
```

Please see client libraries mentioned in the introduction for examples of how to consume the schema. 