---
title: Account Verification
slug: account-verification
url: https://devcenter.heroku.com/articles/account-verification
description: Account verification lets you use any of Heroku's free add-ons, and lets you turn on paid services at any time with a few easy clicks.
---

You must verify your account by adding a credit card before you can add **any** add-on to your app other than heroku-postgresql:dev and pgbackups:plus.

Visa, MasterCard, American Express and Discover credit cards are accepted. Debit cards are also accepted for Visa and MasterCard. We currently do not have the ability to accept any other methods of payment (wire transfer, PayPal, etc).

## Verification requirement

Credit card information is not required for free apps without add-ons. It becomes a requirement once you wish to use add-ons other than postgresql:dev or pgbackups:plus–**even if the add-ons are free**. This is because some features (most notably outgoing email and custom domains) carry a potential for abuse.

As a business, we need to be able to reliably identify and contact our users in the event of an issue. We have found that a credit card on file provides the most reliable way of obtaining verified contact information.

## Add-ons and credit cards

Adding a credit card to your account lets you use any of our free add-ons and gives you access to turn on paid services any time with a few easy clicks. The easiest way to do this is to go to [your account](https://dashboard.heroku.com/account) and click Add Credit Card.

Alternatively, when you attempt to perform an action that requires a credit card, either from the [Heroku CLI](heroku-command) or through the web interface, you will be prompted to visit the credit card page.

If you run into any issues trying to add a credit card, please open a [support request](https://help.heroku.com/tickets/new?query=referral+devcenter+account-verification).

## Foreign credit cards

Foreign credit cards may be used for verification and payment. A standard Visa, MasterCard or American Express should work regardless of issuing country. If your card doesn't work, please [submit a support ticket](https://help.heroku.com/tickets/new).

## One dollar verification hold

Every bank works differently, and some of them require a one dollar ($1.00) hold by the verifier before a card can be confirmed. After a few business days **the hold will be released** and your card will be verified if successful.

If you see multiple instances of a $1.00 charge, it may be because the card information was submitted multiple times. The duplicate holds will also be released and returned to your account after a few business days.

## No credit or debit card

If you do not have a credit or debit card (or do not have one that we are able to accept), **you may still use Heroku as a free service**. Without a credit card, each app will allow you 1 free dyno as well as the use of the add-ons heroku-postgresql:dev and pgbackups:plus.

Anything more will require account verification with a credit or debit card.