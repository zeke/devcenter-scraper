---
title: Creating slugs from scratch
slug: platform-api-deploying-slugs
url: https://devcenter.heroku.com/articles/platform-api-deploying-slugs
description: Creating and deploying slugs on Heroku via the Heroku Platform API's slug and release API endpoints.
---

This article describes creating slugs from scratch on a machine that you control, and then uploading and running those slugs on Heroku apps. Doing this is appropriate if full control over what goes into slugs is needed.

For most uses, however, we recommend using the [`build` resource](https://devcenter.heroku.com/articles/platform-api-reference#build) of the Platform API to transform source code into slugs. Using the build resource is generally simpler than creating slugs from scratch, and will cause slugs to be generated using the standard [Heroku slug compiler](slug-compiler) and the standard Heroku [buildspacks](buildpacks). Slugs generated using the standard build pipeline are more likely to be compatible and work on Heroku. For details on how to create slugs using the Platform API and the build resource, see [Build and release using the API](build-and-release-using-the-api).

> callout
> If you want to use the standard [Buildpack and slug compilation process](slug-compiler) but want to re-use slugs in multiple apps, please see the [Copying Slugs with the Platform API](platform-api-copying-slugs).

## Create the slug

> callout
> Slugs are [gzip](http://en.wikipedia.org/wiki/Gzip) compressed [tar](http://en.wikipedia.org/wiki/Tar_(computing)) files containing a runnable [Cedar](https://devcenter.heroku.com/articles/cedar) application in the `./app` directory. Slugs may contain files outside of `./app`; however, they will be ignored when unpacked by Heroku. Slug size should not exceed the [slug size limits](limits#slug-size).

In this example, we will demonstrate how to create, from scratch, slugs containing either Node.js, Ruby or Go apps. For all slugs, contents should be in the `./app` directory, so first create and enter this directory:

```term
$ mkdir app 
$ cd app
```

Now add the actual app and any required dependencies. The details depends on the chosen app and framework.

> callout
> If you're following this guide, choose one language and complete the steps for that language only

### Node.js

Get the Node.js runtime for x64 Linux:

```term
$ curl http://nodejs.org/dist/v0.10.20/node-v0.10.20-linux-x64.tar.gz | tar xzv
```

Now add the code for the app in a file named `web.js`:

```javascript
// Load the http module to create an http server
var http = require('http');
 
// Configure HTTP server to respond with Hello World to all requests
var server = http.createServer(function (request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.end("Hello World\n");
});
 
var port = process.env.PORT;
 
// Listen on assigned port
server.listen(port);
 
// Put a friendly message on the terminal
console.log("Server listening on port " + port);
```

### Ruby

The Ruby project does not provide precompiled self-contained runtimes, so we'll use one created by the Heroku Ruby team for the [buildpack](https://github.com/heroku/heroku-buildpack-ruby). It's available at `https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/ruby-2.0.0.tgz`.

Get the Ruby runtime:

```term
$ mkdir ruby-2.0.0
$ cd ruby-2.0.0
$ curl https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/ruby-2.0.0.tgz | tar xzv
$ cd ..
```

Add a very simple Ruby app to `server.rb`:

```ruby
require 'webrick'
 
server = WEBrick::HTTPServer.new :Port => ENV["PORT"]
 
server.mount_proc '/' do |req, res|
    res.body = "Hello, world!\n"
end
 
trap 'INT' do
  server.shutdown
end
 
server.start
```

### Go

Creating Go slugs is surprisingly simple. This is because the `go build` command produces standalone executables that do not require bundling any additional runtime dependencies. One caveat is that you have to cross-compile executables if you're not creating the slug on the same architecture that Heroku uses (linux/amd64). [Setting up the Go toolchain for cross-compilation](https://coderwall.com/p/pnfwxg) is relatively simple.

Add the app in `web.go`:

```go
package main

import (
    "fmt"
    "net/http"
    "os"
)

func main() {
    http.HandleFunc("/", hello)
    fmt.Println("listening...")
    err := http.ListenAndServe(":"+os.Getenv("PORT"), nil)
    if err != nil {
      panic(err)
    }
}

func hello(res http.ResponseWriter, req *http.Request) {
    fmt.Fprintln(res, "hello, world")
}
```

Now build an executable that will work on Heroku:

```term
GOARCH=amd64 GOOS=linux go build web.go 
```

## Create slug archive

Change back to the parent directory of `app` and compress `./app` (the `./` prefix is important) to create the slug:

```term
$ cd ..
$ tar czfv slug.tgz ./app
```

> warning
> Heroku currently has limited tar-file compatibility. Please use [GNU Tar](http://www.gnu.org/software/tar/tar.html) (and not bsdtar) when creating slug archives. You can check your tar version with `tar --version`.
> If you find that a slug created with GNU Tar fails to boot on Heroku, then feel free to [open a support ticket](https://help.heroku.com/) to get help debugging the problem.

## Publish to the platform

Start by creating the Heroku app that will be running this slug:

```term
$ heroku create example
Creating example... done, stack is cedar
http://example.herokuapp.com/ | git@heroku.com:example.git
```

Publishing your slug to the platform is a two-step process. First, request that Heroku allocate a new slug for your app. When allocating the slug, use the `process_types` parameter to provide a list of runnable commands that are available in the slug being created.

The `process_types` parameter has content similar to what is included in the [Procfile](https://devcenter.heroku.com/articles/procfile) that’s typically included in apps pushed to Heroku. The Procfile is not parsed when slugs are launched in dynos; instead they are parsed by the build system and the contents are passed in when the slug is created.

The `process_types` parameter depends on what kind of slug you created above:

 * Node.js: `{ "web": "node-v0.10.20-linux-x64/bin/node web.js" }`
 * Ruby: `{"web": "ruby-2.0.0/bin/ruby server.rb"}`
 * Go: `{"web":"./web"}`

> callout
> The `-n` flag tells `curl` to read the credentials for `api.heroku.com` from `~/.netrc` and automatically sets the `Authorization` header. See the [Getting Started with the Platform API](platform-api-quickstart) for other authentication options.

```term
$ curl -X POST \
-H 'Content-Type: application/json' \
-H 'Accept: application/vnd.heroku+json; version=3' \
-d '{"process_types":{"web":"node-v0.10.20-linux-x64/bin/node web.js"}}' \
-n https://api.heroku.com/apps/example/slugs
{
  "blob":{
    "method": "put",
    "url": "https://s3-external-1.amazonaws.com/herokuslugs/heroku.com/v1/d969e0b3-9892-4567-7642-1aa1d1108bc3?AWSAccessKeyId=AKIAJWLOWWHPBWQOPJZQ&Signature=2oJJEtemTp7h0qTH2Q4B2nIUY9w%3D&Expires=1381273352"
  },
  "commit":null,
  "created_at":"2013-10-08T22:04:13Z",
  "id":"d969e0b3-9892-3113-7653-1aa1d1108bc3",
  "process_types":{
    "web":"node-v0.10.20-linux-x64/bin/node web.js"
  },
  "updated_at":"2013-10-08T22:04:13Z"
}
```

> callout
> Please note that the blob URL is not passed in the slug create request. Instead, it's returned in the slug create response, and you can then use the URL to `PUT` your binary slug artifact.

For the second step we will use the `blob` URL provided in the response above to upload `slug.tgz` and make it available to the platform:

```term
$ curl -X PUT \
-H "Content-Type:" \
--data-binary @slug.tgz \
"https://s3-external-1.amazonaws.com/herokuslugs/heroku.com/v1/d969e0b3-9892-4567-7642-1aa1d1108bc3?AWSAccessKeyId=AKIAJWLOWWHPBWQOPJZQ&Signature=2oJJEtemTp7h0qTH2Q4B2nIUY9w%3D&Expires=1381273352" 
```

## Release the slug

The slug is now uploaded to Heroku, but is not yet released to an app. To actually start running this slug, `POST` its id to the `/apps/:app/releases` endpoint:

```term
$ curl -X POST \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d '{"slug":"d969e0b3-9892-3113-7653-1aa1d1108bc3"}' \
-n https://api.heroku.com/apps/example/releases
{
  "created_at":"2013-10-08T16:09:54Z",
  "description":"deploy",
  "id":"a0ff4658-ec55-4ee2-96a9-8c67287a807e",
  "slug":{
    "id":"d969e0b3-9892-3113-7653-1aa1d1108bc3"
  },
  "updated_at":"2013-10-08T16:09:54Z",
  "user":{
    "email":"jane@doe.com",
    "id":"2930066e-c315-4097-8e88-56126f3d4dc1"
  },
  "version":3
}
```

> callout
> The same slug can be released to multiple apps. This can be used for more advanced deployment workflows.

You can now see the new release in your app's release history:

```term
$ heroku releases --app example
=== example Releases
v3  deploy  jane@doe.com  2013/10/08 16:09:54 (~ 1m ago)
...
```

View your app in your browser to see it running with the newly released slug.

```term
$ heroku open --app example
``` 