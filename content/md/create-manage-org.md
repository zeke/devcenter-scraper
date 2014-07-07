---
title: Creating and Managing an Organization
slug: create-manage-org
url: https://devcenter.heroku.com/articles/create-manage-org
description: After it has been provisioned for you, setup a new org by adding members and apps.
---

Organizations allow you to manage access to a shared group of applications across your development team. The development experience remains largely the same, but you now have access to more granular roles and can more efficiently manage your development process.

> note
> Organization Accounts are currently only available for purchase through our sales channel. <a href="https://www.heroku.com/critical">Contact us</a> if you would like to purchase an Organization Account.

Once your org is provisioned, you will receive an email from Heroku with the org name, resource limits and a link to your dashboard. This guide outlines how to complete the setup of your org.

## Users

When an organization is provisioned it only has a single user - the admin user that requested the org. It is up to this initial admin to add other users to the org and give them the appropriate access.

### Roles

Organizations access is partitioned across three distinct roles: [Admin, member and collaborator](https://devcenter.heroku.com/articles/org-users-access#roles).

An admin user controls membership to the org, can view billing information, and can perform high-level lifecycle actions like [locking an app](https://devcenter.heroku.com/articles/org-users-access#locking-an-app) to prevent additional access. The admin role is often given to those in the organization that are responsible for the development process, such as engineering or team leads.

The member role allows a user to create apps within, and transfer apps to, an org, and perform common development tasks like deploying and scaling the app. The member role is commonly assigned to the in-house developers working on your applications.

Collaborators are a more limited case of a member in that they can deploy and develop against only specific applications – not all the apps within the org. Give collaborator access to users that you only want manipulating specific apps. Contract developers assigned to a specific project are a good example of the collaborator role.

### Adding users

[Users can be managed](https://devcenter.heroku.com/articles/org-users-access) from the Access tab in your org Dashboard.

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/265-original.jpg 'Add members')

You can also manage users using the Heroku CLI. Add a new org member with:

```term
$ heroku members:add joe@acme.com --org acme-widgets
Adding joe@acme.com as member to organization acme-widgets... done
```

Add additional admin users using the same command with the `--role` flag:

```term
$ heroku members:add joe@acme.com --org acme-widgets --role admin
Adding joe@acme.com as admin to organization acme-widgets... done
```

Because of their app-level access, collaborators are a special case and require a different command.

```term
$ heroku sharing:add jill@daimyo-creative.com --app acme-website
Adding jill@daimyo-creative.com to acme-website as collaborator... done
```

## Applications

Applications become part of an organization in one of two ways – by being transferred into the org or by being created as part of the org.

### Transferring apps

It is common for existing development teams to have several apps already in development under each developer's personal account or even a shared personal account. The owner of these apps must transfer in their app to the org before it can be managed as part of the org. Otherwise the individual app owners will continue to be billed for them using their personal billing details.

To transfer an application, the current app owner must select the app to transfer from their Dashboard, then go to the Settings pane and use the transfer drop-down at the bottom of the settings page:

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/270-original.jpg 'Transfer an app')

You can also import applications in bulk from your personal account to an organization that you are a member of. To import multiple applications, select the Import app icon at the bottom of the apps list of your org Dashboard, select the apps that you want to move into the organization, and confirm your choice(s):

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/271-original.jpg 'Import apps')

You can also use the CLI to transfer apps into an organization:

```term
$ heroku sharing:transfer acme-widgets -a deep-spring-4274
Transferring deep-spring-4274 to acme-widgets... done
```

### Creating apps

When starting a new project, org admin and member users can create an app directly within the org.

From the org dashboard, select 'Create a new app' at the bottom of the apps list.

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/257-original.jpg 'Creating apps')

Or, from the CLI, specify the org with the `--org` flag on the `heroku create` command.

```term
$ heroku create --org acme-inc
Creating frozen-wave-4030 in organization acme-inc...done, stack is cedar
http://frozen-wave-4030.herokuapp.com/ | git@heroku.com:frozen-wave-4030.git
Git remote heroku added
```

### Remove apps

Applications can be removed from an org by transferring them to a new owner. 

To transfer an application, a current org admin must select the app to transfer from their Dashboard, then go to the Settings pane and use the transfer drop-down at the bottom of the settings page:

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/282-original.jpg 'Removing apps from an org')

You can also use the CLI to transfer apps out of an organization:

```term
$ heroku sharing:transfer joe@acme.com --app acme-website-staging
Transferring acme-website-staging to joe@acme.com... done
```

## Monitoring usage

Org admins have access to the Usage tab in Dashboard. From there, you can see your current resource usage against package limits as well as historical usage.

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/279-original.jpg 'Organization usage')

## Next steps

At this stage your org should be populated with an initial list of applications and users, and your development team should be able to deploy and manage the apps using the standard Heroku workflow and tools. Your developers will benefit from reading the guide on [developing apps within an org](https://devcenter.heroku.com/articles/develop-orgs), which describes how to efficiently work within an organization account.

Beyond the basic steps described in this guide, there is also a detailed doc that covers the [administration of org users and application access](https://devcenter.heroku.com/articles/org-users-access). 