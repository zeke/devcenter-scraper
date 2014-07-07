---
title: Building a Heroku Add-on
slug: building-a-heroku-add-on
url: https://devcenter.heroku.com/articles/building-a-heroku-add-on
description: A description of kensa and other tools that can be used by a provider of an add-on service in the Heroku Add-on marketplace, who wish to create a new add-on.
---

This document is a hands-on guide to turning your existing cloud service into a Heroku add-on.

## Overview

There are two ways to create a Heroku add-on: you can either implement the HTTP calls directly in an app you already have or you can start a new application from a template.

>callout
>`kensa create`  
>The [kensa create](building-a-heroku-add-on) command allows you to clone an add-on from a template.

If you would like to start your add-on from a template, use the [kensa create](building-a-heroku-add-on) command.

If you would like to start your add-on by implementing the HTTP API directly, follow the walkthrough provided in this section of the site.

You'll begin by implementing a [provisioning API](building-a-heroku-add-on#provisioning) for your service, which Heroku will call when your add-on is installed by a customer.  We provide you with a command-line tool to test your API in your development environment.  You will also create a JSON document that will serve as the add-on manifest (link). The manifest describes to Heroku how your add-on should appear in our catalog and important information about your add-on like configuration information.

Next you'll write docs explaining install and use of your add-on.

With the manifest and docs, you can [submit the add-on](https://devcenter.heroku.com/articles/submitting-an-add-on) to Heroku for inclusion in the add-ons catalog.

An optional final step would be to [implement single sign-on](https://devcenter.heroku.com/articles/add-on-single-sign-on) to allow Heroku customers to access the web-based admin panel for their private resource.

## Getting started

First we need to install some software and create your add-on manifest.

### Prerequisites

Your service can be written in any language. You'll need Ruby to run Kensa, the manifest validation tool. In both cases you only need Ruby in your development environment, not on your production system.

OS X comes with Ruby installed. Ubuntu users can install with:

```term
$ sudo apt-get install ruby rubygems irb libopenssl-ruby
```

Windows users can use [Ruby Installer](http://rubyinstaller.org/).

### 1. Install Kensa

Everything in this document will take place in your local development environment. We'll simulate the calls from Heroku using the Kensa command-line tool. To install:

```term
$ gem install kensa
```

Run `kensa` with no arguments for a quick reference to the commands available.

### 2. Run your development service

Launch a development version of your service in your local dev environment through your usual means. For the purpose of this document we'll assume the web portion of your service is listening on localhost port 5000.

### 3. Generate an add-on manifest

>callout
**Manifest**  
>The add-on manifest is a JSON document that describes your add-on. [Read the full reference](add-on-manifest)

Now you'll create a new manifest describing your add-on with kensa.

Run:

```term
$ kensa init
Initialized new addon manifest in addon-manifest.json
```

or: 

```term
$ kensa create myaddon --template sinatra|node|clojure
Initialized new addon manifest in addon-manifest.json
Initialized new .env file for foreman
```

If you are using `create`, [follow the instructions](kensa-create) to start and test your add-on before changing the manifest.

Open addon-manifest.json in your editor:

```json
{
  "id": "myaddon",
  "api": {
    "config_vars": [ "MYADDON_URL" ],
    "password": "tYpx1jt652dRGIcK",
    "sso_salt": "zPzckKkGf3XiJaD0",
    "regions": ["us"],
    "production": {
      "base_url": "https://yourapp.com/heroku/resources",
      "sso_url": "https://yourapp.com/sso/login"
    },
    "test": {
      "base_url": "http://localhost:4567/heroku/resources",
      "sso_url": "http://localhost:4567/sso/login"
    }
  }
}
```

>callout
>**Plans** 
>Your add-on will eventually be able to support several different subscription plans. Through alpha and beta testing, however, you should simply support a single plan called "test". The Heroku provisioning API will automatically look for it.

The add-on manifest starts mostly blank, with a few defaults. Start by changing the `id` field. For example, if your product is called "MySQL-o-Matic", then use "mysqlomatic" for `id`. Later on, you'll be able to add a human-friendly display name for the <a href="http://addons.heroku.com">Add-on Catalog</a> through the <a href="https://addons.heroku.com/provider">Provider Portal</a>

The only field you must change is the test URLs, at the bottom. If your service is running at localhost:5000, then change it to `http://localhost:5000/`.

## Provisioning

>callout
>**Resource** 
>A private resource is created for each app that adds your add-on.


When a Heroku customer installs your add-on, Heroku makes a REST call to your cloud service to [provision](https://devcenter.heroku.com/articles/how-addons-work#provisioning) a private resource for their app.

This document is a hands-on guide to adding the functionality to your service to handle these calls.

### 1. Test provision - fail

Heroku will call your service via a POST to `/heroku/resources` to provision a new resource. You haven't yet implemented this call, so we'll expect that the kensa tool can detect this. Run the test for provisioning:

```term
$ kensa test provision
Testing POST /heroku/resources
  Check response [FAIL]
    ! expected 200, got 404
```

>callout
>**Red first** 
>You may notice the way we're using the Kensa tests here is similar to the way you would use unit tests in TDD. Run the test before implementation to confirm a fail (red); run again after implementation to see success (green). <a href="http://userstories.blogspot.com/2007/10/tdd-red-green-refactor-red-as-important.html">read more</a>

As expected, the test got a 404 Not Found response, since you haven't implemented this call yet. (If you get another error, such as connection refused, check your test URL in the manifest, and make sure your service is running.)

### 2. Implement provision call

Now you can edit the code of your service and add support for the provision call. Here's an example of how your code might look if your service is a MySQL cloud service with the web portion written using the Sinatra framework:

```ruby
post '/heroku/resources' do
  db = Database.create!
  result = { id: db.id, config: { "MYSQL_URL" => db.url } }
  result.to_json
end
```

>callout
>**URL**  
>Any provisioned resource should be referenced by a unique URL, which is how the customer's app consumes the resource. [read more](https://devcenter.heroku.com/articles/how-addons-work#consumption)

This code responds to the incoming request by provisioning a database in the service, and returning the ID and a config var hash containing a URL to the database. The resource has been provisioned and a URL is returned to Heroku, to be embedded into the environment of the customer's app.

### 3. Authentication

Running the test again with this code added to your server:

>callout
>**Password**  
>When you run kensa init to generate an add-on manifest, a password (auto-generated) is filled in for you. You can use the defaults, or change these values to anything you like.

```term
$ kensa test provision
Testing POST /heroku/resources
  Check response [PASS]
  Check valid JSON [PASS]
  Check authentication [FAIL]
    ! expected 401, got 200
```

...and you'll see that we get further this time, before failing on authentication. Your service is expected to authenticate all provisioning calls with the add-on id and password found in the add-on manifest. A failed authentication should return 401 Not Authorized.

>callout
>**HTTP basic auth**  
>Some web frameworks such as Rails, Sinatra, and CherryPy make it easy to check HTTP basic auth from within your code. For frameworks which don't directly support basic auth, like Django, you'll need to <a href="http://noah.heroku.com/past/2010/2/19/django_http_basic_auth/">parse the HTTP headers yourself</a>, or wrap the path in an Apache AuthType Basic directive or equivalent.

Continuing the Sinatra example, we can add this code:

```ruby
use Rack::Auth::Basic do |username, password|
  username == 'errorbucket' && password == 'tYpx1jt652dRGIcK'
end
```

### 4. Config vars

Running the provision test once again, we see it gets quite a bit further:

```term
Testing POST /heroku/resources
  Check response [PASS]
  Check valid JSON [PASS]
  Check authentication [PASS]

Testing response
  Check contains an id [PASS]

Testing config data
  Check is a hash [PASS]
  Check all config keys were previously defined in the manifest [FAIL]
    ! MYSQL_URL is not in the manifest
```

>callout
>**Config vars**  
>Your service can return any number of config vars, but in most cases you should need exactly one, a URL which is named after your service type and ends in the postfix _URL.

Now the failure is happening in validating the config vars. Our service returns a MYSQL_URL, but we haven't defined this in the add-on manifest. Open addon-manifest.json in your editor again and change this:

```json
  "config_vars": [
    "MYADDON_URL"
  ],
```

...to this:

```json
  "config_vars": [
    "MYSQL_URL"
  ],
```

### 5. Test provision - pass

Now that we've added code for provisioning, authentication, and have set our add-on manifest to declare the config vars we need, our tests should pass. Run it a final time:

```term
$ kensa test provision
Testing POST /heroku/resources
  Check response [PASS]
  Check valid JSON [PASS]
  Check authentication [PASS]

Testing response
  Check contains an id [PASS]

Testing config data
  Check is a hash [PASS]
  Check all config keys were previously defined in the manifest [PASS]
  Check all config values are strings [PASS]

done.
```

Congratulations, your service now successfully provisions resources based on the simulated call from Heroku.

### 6. Regions

The provisioning call contains a region parameter that indicates the geographical placement of the app that the add-on is being provisioned for. You can use this information to create the resource in geographical proximity to the app, you can ignore it (if your add-on is not latency sensitive, for example) or you can deny the provision request by returning 422 with an error (see "Exceptions" below).

In our Sinatra example, you would get the region information like this:

```ruby
region = JSON.parse(request.body.read)['region']
```

You can use the [manifest](https://devcenter.heroku.com/articles/add-on-manifest) submitted to Heroku to specify what regions your add-on supports.

### 7. Implement deprovision call

When a user removes an add-on, we make a call to deprovision the resource. Continuing the MySQL cloud service example, we'll implement a Sinatra call like this:

```ruby
delete '/heroku/resources/:id' do
  Database.find(params[:id]).destroy
  "ok"
end
```

Test this using the deprovision test, passing an additional argument which is the ID of a previously provisioned resource to be destroyed.

```term
$ kensa test deprovision 123
Testing DELETE /heroku/resources/123
  Check response [PASS]
```

The service can now handle both adding and removing of an add-on.

### 8. Plan changes

If your add-on offers multiple plans, you should also implement support for instant plan changes. A plan change maps to the HTTP PUT verb. In your code, this would look like:

```ruby
put '/heroku/resources/:id' do
  db = Database.find(params[:id])
  plan = JSON.parse(request.body.read)['plan']
  db.change_plan(plan)
  result = { config: { "MYSQL_URL" => db.url },
    	 message: "your message here" }
  result.to_json
end
```

If the resource changed location or credentials, you can once again render new config vars, just like you would for the provision call.

To test it:

```term
$ kensa test planchange 123 premium
Testing PUT /heroku/resources/123
  ...
```

In this case Kensa will try to update the plan for the resource 123 to "premium".

In some cases an add-on will be unable to support instant plan changes. Examples of this would be where large, time-consuming data migrations are involved, or where the requested resources takes more than a minute to provision. In such cases, you should do the following:

* Render a 503 response
* Supply a custom message
* In the message, provide a link to a section in your add-on documentation providing instructions for changing plans manually.

### 9. Exceptions

If your service is unable to fulfill a provision or plan change request, you should render a [503 response with a custom message](https://devcenter.heroku.com/articles/add-on-provider-api#exceptions). Doing so will pass the message through to the client.

Optionally, you can render a custom message to be displayed to the user, like:

```ruby
post '/heroku/resources' do
  if on_maintenance?
    halt 503, { message: "We're under scheduled maintenance. The service is unavailable until 4pm PST" }
  end
  ...
```

The same pattern can be used for [Plan change API calls](https://devcenter.heroku.com/articles/add-on-provider-api#plan-change).

If a non-200 response code is returned, Heroku will assume an intermittent error occurred and display a standard error message.

### 10. Next step

Your server-side integration is now complete. The next step is to implement a code-sample that demonstrates how to consume a provisioned resource from a customer's app. Read about this in [Part 2: Consumer](https://devcenter.heroku.com/articles/building-a-heroku-add-on#consumer).

## Consumer

A running Heroku app consumes your cloud service via the tools and
instructions you provide to the customer. This section will show you how to
build those tools and instructions, centering around a consumer test you'll
write in Ruby.

This section assumes you've already implemented [provisioning](#provisioning) as described in this guide.

### 1. Create a consumer test in Ruby

In order for Heroku apps to [consume your service](https://devcenter.heroku.com/articles/how-addons-work#consumption) once the add-on is installed,
you'll need to write a sample that demonstrates how to consume your service
from Ruby, using a URL passed in through the environment.

>callout
>**URL**  
>During provisioning, your service returns
a URL which provides all the information the customer's app will need to
connect to their private resource.

This URL is the same one that was generated and returned in the response to
Heroku during the provisioning call.  Heroku bundles this value (along with
anything else you wish to pass through to the client app) into the app's
environment so that it is easily accessible from the application code.

As an example, let's assume your service is a MySQL cloud service, similar to
Amazon RDS.  You might chose to use the [Sequel](http://sequel.rubyforge.org/)
database adapter to demonstrate consuming your service from Ruby.  Your test
script would then look something like this:

```ruby
require 'sequel'

url = ENV['MYSQL_URL']
puts "Connecting to #{url}"

begin
  db = Sequel.connect(url)
  puts "This database has the following tables: #{db.tables.inspect}"
rescue => e
  abort "Failed to access database: #{e.message}"
end
```

>callout
>**Passing environment variables**  
>Simulate config vars available in the Heroku app by passing shell environment variables, in the
>format: `VARIABLE=value command`

Start by testing it against an invalid URL.  You should get an error:

```term
$ MYSQL_URL=mysql://root@localhost/nonexistentdb ruby use_mysql.rb
Connecting to mysql://root@localhost/nonexistentdb Failed to access
database: Mysql::Error: Unknown database 'nonexistentdb'
```

As expected, the library complains that this database does not exist.  Now try
it against a known working resource:

```term
$ mysqladmin5 create db
$ MYSQL_URL=mysql://root@localhost/db ruby use_mysql.rb
Connecting to mysql://root@localhost/db
This database has the following tables: []
```

It connects successfully to the database and correctly reports that it is a
fresh database with no tables.

### 2. Test against an automatically provisioned resource

The kensa tool used to test provisioning of resources in the first part of this
guide can also be used to do an end-to-end test.  The steps on this are:

1. Provision the resource, returning a URL
1. Run the consumer test with the URL passed via the environment (simulating how it will run in a Heroku dyno or worker)
1. Deprovision the resource

We can run this sequence using the run command in kensa.  Here's how it will
look:

```term
$ kensa run ruby use_mysql.rb
Testing POST /heroku/resources

Starting ruby... 
Connecting to mysql://1ba348f9ea:e6efd15da88149782c2be2@localhost:3306/1ba348f9ea
This database has the following tables: []
End of ruby

Testing DELETE /heroku/resources/1ba348f9ea

done.
```

>callout
**Generating resource names**
>Your service should auto-generate usernames, passwords, and names of resources such as databases. The user doesn't care what these values are, as long as they are secure and
passed along in the URL.

The example output above shows a resource being provisioned and the resulting
MySQL URL being passed into the consumer test.  The program connected cleanly
and returned success, so kensa continued with a deprovision call, passing in
the ID it received from the original provision.

Once this full test passes, you've completed the most fundamental parts of both
sides of the add-on: provisioning in your service, and consuming from a client.

### 3. Docs and libraries

Cloud services each have their own protocol and matching libraries for
consuming them.  In this example we showed consuming of a MySQL resource, which
has the benefit of having existing Ruby database libraries that can connect to
it via the MySQL protocol.  A RESTful service can likewise use a standard HTTP
library like [RestClient](http://rdoc.info/projects/archiloque/rest-client) or
[HTTParty](http://httparty.rubyforge.org/).

If your service has its own protocol, or if you provide app integration by way
of a Rails plugin or Ruby gem installed into the user's code, you may need
package and provide that separately.  Websolr is a stellar example of a service
that provides <a
href="http://websolr.com/guides/heroku-add-on">Heroku-specific
documentation and libraries</a>, in addition to their <a
href="http://websolr.com/guides">general docs</a>.

Clear, concise docs and easy-to-install and use libraries are crucial for
adoption of your add-on, so give plenty of attention this part of the process.

### 4. Next step

If you've made it this far, you've done the bulk of the technical integration
needed to make your cloud service into a Heroku add-on.  Congratulations!

The next step will be to [Submit your
add-on](https://devcenter.heroku.com/articles/submitting-an-add-on) to the add-ons catalog. 