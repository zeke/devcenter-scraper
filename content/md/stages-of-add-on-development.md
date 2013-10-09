---
title: Stages of Add-on Development
slug: stages-of-add-on-development
url: https://devcenter.heroku.com/articles/stages-of-add-on-development
description: This document describes the 4 stages of Add-on development.
---

Before you can start selling your Add-on in the public marketplace, you must complete the alpha and beta stages of Add-on development.

## Alpha
The goal of the alpha stage is to ensure that your Add-on service works correctly, and that users will have clear instruction on how to use it. The steps of the alpha process are as follows:

* Create [Dev Center documentation](https://devcenter.heroku.com/articles/documenting-an-add-on)
* Invite alpha users
* Test and collect feedback

You can invite Alpha users to start using your add-on by selecting the 'Alpha Users' from the dropdown menu in the top-right of the Provider Portal.

## Beta
Beta is a two-part phase in which your Add-on will be exposed to hundreds of users in Private Beta, and then subsequently to all tens of thousands of Heroku users in Public Beta.

This testing phase will provide you valuable info on steps need to ensure good performance and reliable operation of your Add-on. It's important that you carefully consider the feedback submitted by users in this stage, and evaluate whether changes are needed. Most add-ons go through a 3-4 week beta process on Heroku before applying for General Availability (GA)

### Private
Before you can enter private beta, you must have filled in the features & benefits sections for your Add-on in the Add-on provider UI.

In private beta you can, and should, invite hundreds of users to install your Add-on. The purpose of this phase is mainly to ensure that your Add-on service handles the increased load, and to confirm that your product meets the needs and expectations of a wide sample of Heroku customers.

### Public
This stage exposes the Add-on to all Heroku users and customers. The transition to public beta will let Heroku users know that GA is imminent, and let them have a head start in using your services in their apps. Also, since the Add-on is now available to all Heroku users, this is when you will start to receive requests for support - directly and through the Heroku Helpdesk. At the beginning of the public beta phase, you will be contacted by the Heroku Add-ons Team to set up integration between our support system and yours.

You can also start [setting up your payment plans](https://devcenter.heroku.com/articles/add-on-plan-creation).

## GA
At this point your Add-on has hopefully been throughly vetted by a large group of Heroku users. The next step is to finalize your plans & pricing into the Add-on catalog.

### Plans & Pricing

Although it's entirely possible to offer a free add-on with a single plan through the Add-on Catalog, the vast majority add-ons will offer set of plans with differentiated features and pricing.

### Free vs. Paid

Based on our experience with existing Add-on providers we have found that there are compelling arguments in favor of offering a basic, free version.

* Driving adoption quickly. A free version can be essential in lowering the bar for developers to adopt your service. Being able to quickly test for free is a tremendously effective way to spread awareness and buzz about your product. For us here at Heroku, it's safe to say that our basic, free level of service has been our best marketing tool by far.

* Supporting multiple environments. Most Heroku customers deploy multiple versions of any application from developer sandbox through staging and production. Being able to spin up to most basic application environment with a free plan that just allows enough access for, say, running tests can be an important selling point when determining whether to use an add-on.

Don't offer too much for free, you should be giving users a chance to understand and see the value in your offering before charging appropriately for the service you are offering.

### Pricing model

Add-ons must be priced in monthly, flat-rate tiers. Since Heroku bills by calendar month, add-on prices are automatically pro-rated when a customer adds an add-on within any given month. Currently, metered pricing is not offered in the add-on program. Thus, dealing with overages is the responsibility of the provider. One way to do this is to use standard HTTP status codes, having your API serve an HTTP 402 - Payment Required error code when current plan limits have been reached or exceeded.

### Determining Pricing

You are free to determine the pricing of your add-on. Heroku will not try to influence or otherwise determine how your service is priced. The pricing you offer on Heroku should make sense within the context of your product and business. We're happy to help with basic information about the add-on marketplace, and what you can reasonably expect when launching an add-on on Heroku. Beyond that, it's always helpful to survey the pricing of existing add-ons in a similar product category.

### Price Changes

Sometimes it's necessary to change pricing in response to customer feedback or business requirements. The Heroku Add-ons Program allows you to change your pricing with 30 days advance notice to addons@heroku.com.

### Defining Plans

Plan names, feature descriptions and pricing are defined in the Provider Portal. Names and descriptions should follow [these simple rules](https://devcenter.heroku.com/articles/add-on-plan-creation).

You can add new plans later. If you're unsure of how many plans you'll need, err on the side of fewer plans and watch your user feedback to determine if you need additional offerings.