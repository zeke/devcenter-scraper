---
title: Developing Apps within an Organization
slug: develop-orgs
url: https://devcenter.heroku.com/articles/develop-orgs
description: Develop and deploy applications as part of an organization.
---

Developing and deploying applications within an organization account is largely the same experience as doing so in your personal account. Git-based deploys, command line scaling, add-ons etc... are all the same. However, just as with [account administration](create-manage-org), there are a few additions to the experience you should be aware of when working within an org.

> note
> Organization Accounts are currently only available for purchase through our sales channel. <a href="https://www.heroku.com/critical">Contact us</a> if you would like to purchase an Organization Account.

## Joining an org

Org accounts centralize the management of users and roles. If you wish to join an org, an [admin user must add you directly](create-manage-org#adding-users).

Once you have been added to an org you will be able to see the list of apps included in that org using the CLI. Use the familiar `heroku list` command, but now include the `--org` flag to specify which apps to show, and the `-all` flag to list all org apps.

```term
$ heroku apps --org acme-inc --all
=== Apps joined in organization acme-inc
frozen-wave-4030
salty-depths-3445

=== Apps available to join in organization acme-inc
acme-website
acme-website-staging
```

You can also go the org Dashboard to view its applications. Switch between your personal account and the org using the drop-down available in the top left corner of the purple context bar:

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/255-original.jpg 'Dashboard context toggle')

## Developing apps

As an admin or member user in an org you have the ability to access all applications in the org. However, most development groups are working on several projects simultaneously while each individual developer is only working on one or two projects simultaneously. Within an org account you indicate the apps you're working on right now by "joining" them.

### Joining apps

Most of the Dashboard and CLI views automatically filter to the apps you've explicitly joined, so as not to overwhelm you with apps that may be part of your org but are not ones you're directly involved with.

To join an app so you can begin developing against it use the `heroku join` command.

```term
$ heroku join --app acme-website
Joining application acme-website... done
```

Once an app is joined, it will be in your default list of org apps.

```term
$ heroku apps --org acme-inc
=== Apps joined in organization acme-inc
acme-website
```

You can also join an app from the org dashboard. In the top section of the apps view of your org Dashboard, all the apps you have currently joined are listed. The bottom section shows the rest of the organization's applications ("Unjoined apps"). To join an app, click on the Join button next to the unjoined app you wish to work on:

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/267-original.jpg 'Join apps')

### Leaving an app

Once you are no longer working with an application on a regular basis, you can leave the app. This will remove it from your list of joined apps, though you can always rejoin it yourself at a later time.

From the CLI, use the `leave` command.

```term
$ heroku leave --app acme-website
Leaving application acme-website... done
```

Or, in the org dashboard, go to the Access tab of the app and remove yourself from the list of members.

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/268-original.jpg 'Leave apps')

## Adding apps to an org

If you have existing apps you've been developing under your personal account, you will need to transfer them to your org in order for them to be consider a part of the org and billed against the org.

You can use the CLI to transfer apps to your org (where `acme-inc` is your org name and `deep-spring-4274` is the app):

```term
$ heroku sharing:transfer acme-inc --app deep-spring-4274
Transferring deep-spring-4274 to acme-inc... done
```

You can also use the org Dashboard to [transfer personal apps in bulk](create-manage-org#transferring-apps).

Apps can also be created directly in the org:

```term
$ heroku create --org acme-inc
Creating frozen-wave-4030 in organization acme-inc...done, stack is cedar
http://frozen-wave-4030.herokuapp.com/ | git@heroku.com:frozen-wave-4030.git
Git remote heroku added
```

## Default org

The [Heroku CLI](https://devcenter.heroku.com/articles/heroku-command) defaults to your personal account and requires the `--org` flag when performing org actions. Having to specify the org on every command quickly becomes burdensome and can be alleviated by setting a default org.

```term
$ heroku orgs:default acme-inc
Setting acme-inc as the default organization... done
```

With a default org set, CLI commands like `create` and `apps` will operate within the context of that org.

```term
$ heroku apps
=== Apps joined in organization acme-inc
frozen-wave-4030
salty-depths-3445
```

You can see your default org at any time with the `orgs` command.

```term
$ heroku orgs
acme-inc  admin, default
foo       member
bar       member 
```

You may occasionally wish to work against a personal app without unsetting your default org. You can do so by specifying the `--personal` flag on account-specific commands.

```term
$ heroku apps --personal
=== My Apps
morning-forest-9083
warm-temple-1487

=== Collaborated Apps
blazing-dusk-89           john.doe@johndoe.me
```

## Next steps

This guide gives you a high-level overview of developing applications within an organization account. To learn how to manage an org as an administrator more see one of the articles on [creating and managing an org](https://devcenter.heroku.com/articles/create-manage-org) or [managing org users and app access](https://devcenter.heroku.com/articles/org-users-access). 