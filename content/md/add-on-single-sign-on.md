---
title: Add-on Single Sign-on
slug: add-on-single-sign-on
url: https://devcenter.heroku.com/articles/add-on-single-sign-on
description: How to integrate single sign-on with an add-on service, so that users of the add-on are able to access admin panels, dashboard, and more.
---

Your cloud service probably has a web UI admin panel that your users log into to manage and view their resources.  For example, a Memcache cloud service would probably offer a <a href="https://devcenter.heroku.com/articles/memcachier#usage-analytics">dashboard</a> for web-based usage analytics and the ability to flush a cache.

Heroku customers will be able to access the admin panel for their resource if you implement [single sign-on](add-on-single-sign-on) as described in this document.

### Summary

Heroku will generate a single sign-on token by combining the salt (a shared secret), timestamp, and resource ID.  The user's browser will be redirected to your site with this token.  Your site can confirm the authenticity of the token, then set a cookie for the user session and redirect them to the admin panel for their resource.  Pages displayed during the session on your site must inject the HTML for the Heroku nav header.  Test this with "kensa test sso," or try in your browser with "kensa sso."

### Salt, timestamp, and token

>callout
>**Manifest**  
>The add-on manifest is a JSON document that describes your add-on. [Read the full reference](add-on-manifest)


When you init an add-on manifest, the fields include a randomly-generated sso_salt field:

```term
$ kensa init
Initialized new addon manifest in addon-manifest.json
$ grep salt addon-manifest.json
    "sso_salt": "2f97bfa52ca102f8874716e2eb1d3b4920ad0be4"
```

The token used to log in the user when they are redirected to your site is based on the following formula:

    token = sha1(id + ':' + salt + ':' + timestamp)

The id is the value returned from your cloud service on a provisioning call.  The salt comes from the manifest.  The timestamp will be included in the parameters for the POST request.

For example, given these inputs:

    id = 123
    salt = 2f97bfa52ca102f8874716e2eb1d3b4920ad0be4
    timestamp = 1267597772

...the SSO token will be:

    SHA1("123:2f97bfa52ca102f8874716e2eb1d3b4920ad0be4:1267597772") =
    bb466eb1d6bc345d11072c3cd25c311f21be130d

### Signing in the user on redirect

When the user clicks your add-on in their add-on menu, they will be directed via HTTP POST to a URL defined in your [manifest](add-on-manifest).

Requests will look like:

    POST <production/sso_url>
    id=<id>&token=<token>&timestamp=<timestamp>&nav-data=<nav data>&email=<user's email address>

The hostname or `sso_url` comes from your add-on manifest.  The id is the ID for the previously provisioned resource.  The timestamp is a time_t, and the token is computed using the formula above. Nav data contains information like the current app name and installed add-ons so the Heroku layout can build the appropriate view for the current app.

>callout
>**HTTP 403: Forbidden**  
>HTTP status code 403 indicates that the user was not allowed access to this page.  You can return this code and still render a normal, human-readable page for them, perhaps suggesting that they contact support if they believe their request is legitimate.

If the token you compute does not match the one passed in the query parameters, the user should be shown a page with an HTTP status code of 403.  If the timestamp is older than five minutes, they should also see a 403.

If the timestamp is current and the token matches, you should create a user session through whatever method you normally use, most likely setting a cookie.  The session should also store that it is a Heroku single sign-on, since what is displayed will be slightly different for Heroku customers than users logging in through your regular standalone service.

The final step in the authentication process is to write the parameter nav-data to a cookie named "heroku-nav-data", allowing our layout to read and display information about the current session, like the app name.

### Sample code

Here's a sample implementation of single sign-on written in Ruby/Sinatra:

```ruby
post "/heroku/sso" do
  pre_token = params[:id] + ':' + HEROKU_SSO_SALT + ':' + params[:timestamp]
  token = Digest::SHA1.hexdigest(pre_token).to_s
  halt 403 if token != params[:token]
  halt 403 if params[:timestamp].to_i < (Time.now - 2*60).to_i

  account = Account.find(params[:id])
  halt 404 unless account

  session[:user] = account.id
  session[:heroku_sso] = true
  response.set_cookie('heroku-nav-data', :value => params['nav-data'], :path => '/')
  redirect "/dashboard"
end
```

### Rendering the nav header

The <a href="https://github.com/heroku/boomerang">Heroku nav header</a> should be shown on all pages for the duration of the customer's stay on your site.

This is done by embedding some JavaScript code within you application dashboard.

### Removing non-relevant page elements

Once you have your site accepting single sign-on requests and rendering the nav header, the final step is to look for page elements that are not relevant for Heroku customer sessions.  Some examples include:

* Change password
* Change account name
* Update billing information
* Log out

These should be hidden in Heroku sessions via conditionals in your page rendering.


### Testing SSO with Kensa

You can try your single sign-on implementation in your browser with this command:

```term
$ kensa sso 123
Opening http://localhost:3000/heroku/sso
```

Provide the ID of a previously provisioned resource as an argument, and kensa will construct the same URL that Heroku would when initiating a single sign-on session.

You can also run a set of automated tests to confirm your single sign-on implementation works correctly and respects all the standards described in this document:


```term
$ kensa test sso 123
Testing POST /heroku/sso
  Check validates token [PASS]
  Check validates timestamp [PASS]
  Check logs in [PASS]
  Check creates the heroku-nav-data cookie [PASS]
  Check displays the heroku layout [PASS]

done.
```