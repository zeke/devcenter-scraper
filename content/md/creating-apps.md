---
title: Creating Apps from the CLI
slug: creating-apps
url: https://devcenter.heroku.com/articles/creating-apps
description: Create apps using the Heroku Command Line Tool. You can choose a name for the application, as well as the stack, when creating the app.
---

The app is the fundamental unit of organization on Heroku. Each app can be associated with its own set of provisioned add-ons.

### Creating a named app

<div class="callout" markdown="1">After creating an app, you will probably want to [git push to
deploy](git) and [add collaborators](sharing) so that others can deploy
changes as well.</div>

To create a new app named "example", [install the Heroku Toolbelt](http://toolbelt.heroku.com) and run the following command:

    :::term
    $ heroku apps:create example
    Creating example... done, stack is cedar
    http://example.herokuapp.com/ | git@heroku.com:example.git

The command's output shows that the app will be available at
`http://example.herokuapp.com`. The second URL, `git@heroku.com:example.git`,
is the remote git repository URL; by default, the `heroku create` command automatically
adds a git remote named "heroku" pointing at this URL.

### Creating an app without a name

The app name argument ("example") is optional. If no app name is specified, a
random name will be generated.

    :::term
    $ heroku apps:create
    Created http://mystic-wind-83.herokuapp.com/ | git@heroku.com:mystic-wind-83.git

Since Heroku app names are in a global namespace, you can expect that common names, like "blog" or "wiki", will already be taken. It's often easier to start with a default name and [rename the
app](renaming-apps) later. 

### Welcome page

Once your new app is created, before any code has been deployed, Heroku will display a generic welcome message to its visitors. This page is served with HTTP status code 502 to indicate that the app is not yet running.