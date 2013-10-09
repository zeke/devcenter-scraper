---
title: Add-on Plan Creation
slug: add-on-plan-creation
url: https://devcenter.heroku.com/articles/add-on-plan-creation
description: How to create a new plan for your Add-on.
---

Add-on Providers can create Add-on plans using the [Add-on Provider interface](https://addons.heroku.com/provider/dashboard). 

Choose your naming scheme with care. You will not be able to change it once your add-on is in GA.

Care should  also be taken when creating plans since they are immutable. Plans must be immutable since there is no support for updating the name or price of a plan once it has been installed. 

When naming plans please observe the following rules for the names and slugs:

* No numbers or versioning, should be present. e.g "small" is acceptable whereas "small_v2" is not.
* No inclusion of Heroku, as it's implied in the use of the platform. e.g "small_heroku" is not acceptable
* Where possible avoid underscores and hyphens unless absolutely necessary.
* Do not name your basic plan "free". Keep the naming focused on the value provided. The real purpose of your free plan is to allow users to get started without having to make a purchasing decision right away, and to support even the most basic, personal development environment. Names like "starter", "developer" communicate these intentions much more accurately than "free".

Once an add-on plan has been created, it is eligible for installation by any one of our [beta](https://devcenter.heroku.com/articles/heroku-beta-features) or [alpha](https://addons.heroku.com/provider/resources/business/becoming) users.