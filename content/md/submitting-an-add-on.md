---
title: Submitting an Add-on
slug: submitting-an-add-on
url: https://devcenter.heroku.com/articles/submitting-an-add-on
description: How to submit a new add-on service for availability in the Heroku Add-on marketplace.
---

Add-ons are visible to users in the [add-ons catalog](http://addons.heroku.com/), which includes information about your product and company, and plans and pricing for the add-on.

This document covers the steps between completing a technical integration and getting your add-on visible in the catalog and available to Heroku users.

### 1. Test your production service

Everything shown so far in this guide has been testing against your local development environment. Now you should get these changes deployed to your production service through your standard deploy process. Once ready, you can run the tests against your production system using the same manifest document.

Edit addon-manifest.json and set the production URLs to match your production service. For example:

```json
"api": {
  "production": {
    "base_url": "https://api.mysqlomatic.net/heroku/resources",
    "sso_url": "https://api.mysqlomatic.net/sso/login"
  },
```

Also update the regions setting to reflect what regions you want your add-on to be available in. For example, if you want it to be available in both US and EU regions:

```json
"api": {
  "regions": ["us","eu"],
```

Now you can run the full integration test again, this time against your production system. It should be provisioning and de-provisioning real resources:

```term
$ kensa run --production ruby use_mysql.rb
```

All tests (provision, consume, deprovision) should pass before proceeding to the next step.

### 2. Submit manifest to Heroku

Now you're almost ready to load your manifest onto Heroku, and start testing as a real Heroku users. First, collect your add-on manifest (`addon-manifest.json`) which describes provisioning.

If you haven't done so already, you will now need to <a href="https://addons.heroku.com/provider/">go to the Provider Portal and register as an Add-on Provider</a>. Once you have registered, you can use the kensa gem to send your manifest to heroku with one simple command.

```term
$ kensa push
```

Now your add-on is loaded on Heroku, although it's disabled and not visible to anyone yet. To activate your add-on and advance it through the stages of alpha, private beta, beta and general availability you must go to the Provider Portal and follow the instructions for verifying your Heroku account, providing docs, and inviting users.

The process of getting from the build stage to the general availability usually takes anywhere between 4-8 weeks. If you have questions that aren't addressed in these docs, or in the Provider Portal, you are always welcome to <a href="mailto:provider@heroku.com">contact us</a>. Good luck! We look forward to seeing your add-on on Heroku. 