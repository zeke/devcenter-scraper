---
title: Transferring Apps
slug: transferring-apps
url: https://devcenter.heroku.com/articles/transferring-apps
description: Transfer both free and paid Heroku applications between accounts at any time.
---

You can transfer applications between Heroku accounts at any time via the [Heroku Dashboard](https://dashboard.heroku.com). Billing responsibility will transfer to the new owner as of the time of accepting the transfer and the original owner will be responsible for pro-rated usage up until that point. After the transfer is complete, the original owner will now be a collaborator on the app.

## Initiate transfer

The current application owner must initiate the transfer request. To initiate the transfer the owner can navigate to the application's settings page in the dashboard. It looks like this:

![transfer](https://s3.amazonaws.com/heroku.devcenter/manual_uploads/owner-transfer.png)

As the current owner you can initiate the transfer request by selecting a collaborator to transfer the app to. 

## Accept transfer

The new owner can receive the transfer by accepting the pending transfer request at the top of the dashboard, once it's initiated:

![acceptance](https://s3.amazonaws.com/heroku.devcenter/manual_uploads/transfer-invite.png)

As the new owner you will have the option to accept or decline all transfer requests. If the app has an ongoing cost, such as paid add-ons or dynos, then you will be asked to enter in a credit card before accepting, if you haven't done so already.

## Cancel transfer

The owner can cancel the transfer request at anytime before the new owner accepts or declines the request. 