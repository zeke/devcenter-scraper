---
title: Getting Started as a Collaborator
slug: collab
url: https://devcenter.heroku.com/articles/collab
description: Once invited to collaborate on an application, clone the app from Heroku.
---

Heroku makes it easy to collaborate with others.  Collaborating allows you 
to share access to your source code, make any changes and deploy a new version 
of the application quickly and easily.  

You can [start sharing](sharing) existing applications with a single command.  

This articles shows how new collaborators can get started.

Setting up to collaborate
-------------

Install the [Heroku Toolbelt](https://toolbelt.herokuapp.com/) on your local workstation.  This ensures that you have access to the [Heroku command-line client](http://devcenter.heroku.com/categories/command-line) and the Git revision control system.
 
Collaborating on an app
-----------------------

### Clone the code

Next you should clone the app locally. The invitation email included the name of the app. You can use `heroku git:clone --app theirapp` for this, but it’s recommended that you get access to their canonical repository (for instance on GitHub) and then use `heroku git:remote` to add a git remote to your checkout.

### Edit and deploy

First ensure that your keys are already on Heroku. If you haven't already uploaded them, run:

```term
$ heroku keys:add
```

You can now make your changes.  When you are ready to deploy these changes, simply commit and push your changes:

```term
$ git commit -a -m "Description of the changes I made"
$ git push heroku master
-----> Heroku receiving push
-----> Launching.... done
```