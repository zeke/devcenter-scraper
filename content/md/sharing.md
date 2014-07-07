---
title: Collaborating with Others
slug: sharing
url: https://devcenter.heroku.com/articles/sharing
description: Granting collaborators access to applications, viewing collaborators, and revoking access.
---

## Adding collaborators

Other developers (identified by email address) can be invited to collaborate on your app:

```term
$ heroku sharing:add joe@example.com
Adding joe@example.com to myapp collaborators... done
```

When you invite a collaborator, they'll be sent an email to let them know they were granted access
to the app. If no existing Heroku account matches the email specified, an invitation email is sent.


## Collaborator privileges

All actions are supported for collaborators as they are for app owners except for the following, which are only support for app owners:

* Adding or removing paid add-ons
* Deleting or renaming the app
* Viewing invoices

>warning
>These are the only actions that are restricted.  Outside of those actions, collaborators can perform any other action that an owner can, including scaling applications.

## Accessing an app as a collaborator

When someone grants you access to an app, you will receive an email with
the app name and some other information to help you get started:

```term
$ heroku info --app theirapp
=== theirapp
Web URL:        http://theirapp.herokuapp.com/
Git Repo:       git@heroku.com:theirapp.git
Repo Size:      960k
Slug Size:      512k
Owner Email:    owner@example.com
Collaborators:  adam@example.com 
                      joe@example.com
```

Next you should clone the app locally. You can use `heroku git:clone --app theirapp` for this, but it's recommended that you get access to their canonical repository (for instance on GitHub) and then use `heroku git:remote` to add a git remote to your checkout.

At this point you can use `git push heroku` to deploy local commits. Be sure your changes get pushed to the canonical repository (typically with `git push origin master`) as well as the Heroku remote to avoid getting out of sync with your collaborators.


## Viewing collaborators

Use the `heroku sharing` command to see the list of current collaborators:

```term
$ heroku sharing
=== theirapp Collaborators
adam@example.com
joe@example.com
```

## Revoking access

You can revoke a collaborator's access using the `heroku sharing:remove` command:

```term
$ heroku sharing:remove joe@example.com
Removing joe@example.com from myapp collaborators... done
```

Once access has been revoked, the user is no longer able to deploy changes or
modify the app's configuration.

## Merging code changes

Once you're collaborating with other developers, you may find that you're prevented from pushing to the repo with a message like this:

```term
$ git push heroku
error: remote 'refs/heads/master' is not a strict subset of local ref 'refs/heads/master'.
maybe you are not up-to-date and need to pull first?
```

This means that other developers have pushed up changes that you need to pull down and merge with your local repository. The easiest way to do this is to run `git pull --rebase`. Ensure your changes don't conflict with what you pulled down before deploying. 