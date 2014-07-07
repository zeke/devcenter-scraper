---
title: Add-on Plan Creation
slug: add-on-plan-creation
url: https://devcenter.heroku.com/articles/add-on-plan-creation
description: How to create a new plan for your Add-on.
---

Plans can be created anytime from Alpha onwards. Plan tiers should be considered carefully, and take account of possible future expansions within your business.

Providers can create Add-on plans in the [Provider Portal](https://addons.heroku.com/provider/dashboard)

## Naming plans
Choose your naming scheme with care, you will not be able to change it easily once your add-on is available to the public.

Plan names and slugs are immutable, there is no support for changing them once a user has installed it. Instead the plan has to be deprecated and a new one would have to be chosen to be installed by the user.

When naming please observe the following rules for names and slugs:

* Numbers or versions must not be present. e.g "small" is acceptable whereas "small_v2" is not
* No inclusion of Heroku is necessary as it's implied in the use of the platform. e.g "small_Heroku" is not acceptable
* Where possible please avoid underscores and hyphens in the name unless absolutely necessary
* Do not name your entry level plan "free" if you have one. Keep the naming focused on the value provided. The real purpose of your free plan is to allow users to get started without having to make a purchasing decision right away, and to support even the most basic, personal development environment. Names like “starter”, “developer” communicate these intentions much more accurately than “free”.

Once your plan has been created it will be in Alpha state, you can then submit it for approval so that your GA users can use it.

>callout
>This article covers [add-on states](https://devcenter.heroku.com/articles/stages-of-add-on-development) in more detail.

## Pricing plans
Choosing pricing can be hard and it's going to vary depending on the service you provide. You may already be running a successful business before creating an add-on so your pricing might follow what you currently offer. If you are unsure of pricing consider the following guidelines:

* Be aware of the Platform; Heroku users currently purchase and consume resources on Heroku via a freemium model. As such, it might make sense to replicate this by offering low onboarding plans and higher-end enterprise plans.
* Be aware of your competitors; is there a similar service on Heroku today? Understanding their pricing and whether it's successful will help you form your own successful pricing approach.
* Speak to your users; Heroku provides a way to [gather information about your users via the API](https://devcenter.heroku.com/articles/add-on-app-info) and this can be done through Alpha and Beta. Make sure you speak to your users and understand the value your users receive from using your service.  