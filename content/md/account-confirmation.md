---
title: Account Confirmation
slug: account-confirmation
url: https://devcenter.heroku.com/articles/account-confirmation
description: Account confirmation is necessary before Heroku can start charging your card.
---

Older Heroku accounts may be asked to confirm that you agree to be billed before performing your first paid action such as adding a paid add-on or scaling your app's dynos.

From the command line, you will see:

    :::term
    $ heroku addons:add heroku-postgresql:crane
    Adding heroku-postgresql:crane to sushi... 
    This action will cause your account to be billed at the end of the month
    Are you sure you want to do this? (y/n)

and from the web UI, you will see a checkbox or a popup to confirm billing.

Alternatively, you can also use the heroku command line tool to confirm your account:

    :::term
    $ heroku account:confirm_billing
