---
title: Git Cloning Existing Heroku Applications
slug: git-clone-heroku-app
url: https://devcenter.heroku.com/articles/git-clone-heroku-app
description: Clone the source of an existing app directly from Heroku using the git:clone command.
---

To clone the source of an existing application from Heroku using [Git](git), use the `heroku git:clone` command:

    :::term
    $ heroku git:clone -a myapp

Replace `myapp` with the name of your app.

This will create a new directory named after your app with its source and complete repository history, as well as adding a `heroku` git remote to facilitate further updates.

Heroku provides the git service primarily for deployment, and the ability to clone from it is offered as a convenience. We strongly recommend you store your code in another git repository such as [GitHub](https://github.com) and treat that as canonical.