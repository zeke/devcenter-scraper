---
title: Managing Add-ons
slug: managing-add-ons
url: https://devcenter.heroku.com/articles/managing-add-ons
description: Manage an application's add-ons using the Heroku CLI or the Heroku Dashboard.
---

You can manage your add-ons either through the [command line interface](heroku-command) or through the Heroku Dashboard web interface.  

Using the command line interface
---------------

You can view your current add-ons within an app with the `heroku addons` command.

    :::term
    $ heroku addons
    newrelic:gold
    heroku-postgresql:dev

### Adding an add-on:

    :::term
    $ heroku addons:add newrelic:standard
    Adding newrelic:standard on myapp...done, v27 (free)
    Use `heroku addons:docs newrelic:standard` to view documentation

### Removing an add-on:

    :::term
    $ heroku addons:remove newrelic:standard
    Removing newrelic:standard from myapp...done, v27 (free)

### Upgrade an add-on:

    :::term
    $ heroku addons:upgrade newrelic:professional
    Upgrading newrelic:professional to myapp... done, v28 ($0.06/dyno/hr)
    Use `heroku addons:docs newrelic:professional` to view documentation   

### Downgrade an add-on:

    :::term
    $ heroku addons:downgrade newrelic:standard
    Downgrading to newrelic:standard on myapp... done, v27 (free)
    Use `heroku addons:docs newrelic:standard` to view documentation.

### Open an add-on dashboard 

    :::term
    $ heroku addons:open newrelic
    Opening newrelic:professional for myapp.

Using the Dashboard
---------------

### List installed add-ons
To see a list of currently installed add-ons for any application, visit [Heroku Dashboard](https://dashboard.heroku.com), and click on the name of the app or click on the Resources tab when viewing an app.

### Add an add-on
Visit the [add-on catalog](https://addons.heroku.com) to find and install add-ons.

### Remove an add-on
From the app Resources tab, find the add-on resource and click the remove icon next to the name, and then click Apply Changes to remove the add-on.

![Remove add-on resources](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/68-original.jpg?1348681909 'Remove add-on resources')

### Configure an add-on
From the app Resources tab, find the add-on resource you want to configure and click on the name. This will take you to a configuration page that allows you to change the settings for the add-on.