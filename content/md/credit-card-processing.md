---
title: Credit Card Processing
slug: credit-card-processing
url: https://devcenter.heroku.com/articles/credit-card-processing
description: Standard VISA, Mastercard or American Express should work regardless of issuing country.
---

Heroku accepts standard credit cards. To learn how Heroku calculates billing, please see [Usage & Billing](usage-and-billing).

## Pending invoice

An invoice with the status of **Pending** is one that has not yet been charged. Usually this will be for the most recent completed billing cycle, i.e. the previous month. This invoice will be charged automatically within a few days without any action required on your part (so make sure your billing information is up-to-date).

Once the payment is placed, the invoice will be updated to either a **Paid** or **Declined** status.

## Automatic payment

Every account with invoices of one dollar or more are placed into our automatic payment system. You will receive an e-mail with your invoice summary **24 to 48 hours in advance**, notifying you that we will be charging cards.

You do not have to worry about remembering to pay your bill unless the payment is declined three times or more.

## Declined payment

Sometimes attempted payments are declined. If this happens, you will receive an e-mail notifying you that we will be re-attempting to charge your card. You may use this time to update your billing information from your [account page](https://dashboard.heroku.com/account) if needed.

Our credit card processing service does not specify the reason for declined charges, so if the payment continues to fail we recommend contacting your credit card provider for further information. You may also want to wait 24 hours and try [paying your balance](https://dashboard.heroku.com/account/pay-balance) again, in case the issue was temporary. 