---
title: How Add-ons Work
slug: how-addons-work
url: https://devcenter.heroku.com/articles/how-addons-work
description: A technical description of how the add-on platform interacts with an add-on service provider, intended for add-on providers interested in creating an add-on.
---

Heroku customers use the [marketplace](https://addons.heroku.com) or the [Heroku Toolbelt](https://toolbelt.heroku.com/) to provision your add-on.  When this happens, Heroku sends a request to your service, which creates a new private resource for the app.  

This resource represents your service, and is what the client application will interact with.

The URI representing the resource is made available to the app as a [config var](config-vars). The app can then consume its private resource via a library, plugin, or over HTTP, depending on your service.

![Add-on Overview](https://heroku-provider-assets.s3.amazonaws.com/how-overview.png)

## Provisioning

### Customer adds add-on

![Provision Step 1](https://heroku-provider-assets.s3.amazonaws.com/how-provision1.png)

The provisioning process begins when a Heroku customer finds your add-on in the add-ons catalog and clicks Add, or alternatively, they can use the command line tool:

```term
$ heroku addons:add addon-name
```
### Heroku requests service provisioning

![Provision Step 2](https://heroku-provider-assets.s3.amazonaws.com/how-provision2.png)

The make-up of the provisioned resource(s) depends on the type of service you're operating.

In almost every case, you will want to provision a user account. However, a database provider may choose to also immediately create a database that the app can start using, whereas exception reporting service may issue an API key in addition to the user credentials.

### Return resource URL
![Provision Step 3](https://heroku-provider-assets.s3.amazonaws.com/how-provision3.png)

Once the resource is created, your service will respond with a URL with the exact location and credentials that the app can use to access their private resource.

For example, a database provider like Amazon RDS may return:

```term
MYSQL_URL=mysql://user:pass@mysqlhost.net/database
```

A general provider such as New Relic may return:

```term
NEW_RELIC_URL=http://newrelic.com/accounts/[apitoken]
```

### Heroku rebuilds app

![Provision Step 4](https://heroku-provider-assets.s3.amazonaws.com/how-provision4.png)

Heroku adds the returned URL as a [config var](config-vars) in the app, rebuilds the slug and restarts all [dynos](https://devcenter.heroku.com/articles/dynos). The user's app is now ready to consume the resource your cloud service has provisioned for them.

## Consumption

![Consume Step 1](https://heroku-provider-assets.s3.amazonaws.com/how-consume1.png)

The app may wish to consume the resource when an end user makes a request to the app from their web browser. Or, a worker dyno in the app may need to consume the resource as part of performing a background job.

For example, a page might wish to consume a database resource by sending a query like "SELECT * FROM table", or consume a web service with a call like POST /exceptions.

### App accesses resource URL

![Consume Step 2](https://heroku-provider-assets.s3.amazonaws.com/how-consume2.png)

The app uses a URL, which was stored as a config var in the app during provisioning, to access the remote resource.

Datastore resources such as MySQL, MongoDB, or Memcache have their own protocol and will use a client library such as ActiveRecord, MongoMapper, or MemcacheClient to access the resource. These resources will have URLs that start with protocol names like mysql://, mongo://, or memcache://.

Web service resources such as Exceptional or New Relic use HTTP as their protocol, so their URLs will begin with https://.

### Resource responds

![Consume Step 3](https://heroku-provider-assets.s3.amazonaws.com/how-consume3.png)

The invoked resource within your cloud service can now process the request, assuming the credentials are valid

If it's a read request (such as SQL's SELECT or HTTP's GET) it will look up the information to return to the app. If it's a write request (such as SQL's INSERT or HTTP's POST) it will store that information to the resource and return an acknowledgment.

Once the app has its response, it can use this to build a page for the end user (if this consume request came from a dyno processing a web request), or to continue processing its background job (if this consume request came from a worker).

## Single sign on

### Heroku Dashboard

![SSO Step 1](https://heroku-provider-assets.s3.amazonaws.com/sso5.png)

By providing us with your manifest, you will have described your add-on to our system in such a way that we can integrate it into our Marketplace as well as the Dashboard. The Dashboard is where customers manage the resources associated with their app.

A Heroku customer can log into the [Heroku Dashboard](https://dashboard.heroku.com/) to view information about their app.

### Add-on selection

![SSO Step 2](https://heroku-provider-assets.s3.amazonaws.com/sso6.png)

Clicking an app will take you to an in-depth page about on the app, which also shows all the installed add-ons. The customer finds your add-on in the list and clicks on it.

### Redirect to add-on property

Heroku generates a single sign-on token using the ID of the resource, the current time, and the salt (a shared secret known to both Heroku and your service).

This generates a request for the user looking something like this:

```term
POST https://yourcloudservice.net/sso/login
id=123&token=4af1e20905361a570&timestamp=1267592469&user@example.com
```

The add-on provider site site receives this request, confirms that the token matches, and confirms that the timestamp is fresh. The site can set a cookie in the user's browser to indicate that they are authenticated, and then redirect to the admin panel for the resource.

### Heroku nav header

The user is now on the add-on provider site, but to preserve the smooth and unified user experience, your site should display the Heroku nav header for sessions created via single sign-on from Heroku.
![SSO Step 4](https://heroku-provider-assets.s3.amazonaws.com/sso4.png)
The most efficient way to include the navigation header is to embed the following snippet in your template:

```term
<script src="https://s3.amazonaws.com/assets.heroku.com/boomerang/boomerang.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", function() {
    Boomerang.init({app: 'app-name-here', addon: 'addon-name'});
  });
</script>
```

The "app-name-here" value should be replaced with the name of the user's application (it is passed as the parameter 'app' from Heroku during SSO sign on), and the value 'addon-name' should be replaced with the name of add-on (e.g., cloudcounter).

Your site probably contains navigational elements not applicable to users coming from Heroku: change password, change billing information, or log out. These links should be hidden for Heroku user sessions.

### Logging users in via SSO

You can log users into your site quickly with SSO URLs. The link can be placed in email or Campfire notifications, and when the user clicks them they can proceed directly to your add-on dashboard.

SSO URLs follow this format:

```term
https://api.heroku.com/myapps/<heroku_id>/addons/<addon_name>
```

Here is an example:

```term
https://api.heroku.com/myapps/app123@heroku.com/addons/cloudcounter
```

Additional information can be supplied as GET parameters. The additional keys and values will then be submitted along with the rest of the user data via SSO POST and allow you to set relevant state or context for the user within your dashboard, e.g.:

```term
https://api.heroku.com/myapps/app123@heroku.com/addons/cloudcounter?issue_no=42
```