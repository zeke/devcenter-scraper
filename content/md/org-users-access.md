---
title: Managing Organization Users and Application Access
slug: org-users-access
url: https://devcenter.heroku.com/articles/org-users-access
description: Organization admins are responsible for adding and removing users, managing their access, and locking applications to prevent additional access.
---

> note
> Organization Accounts are currently only available for purchase through our sales channel. <a href="https://www.heroku.com/critical">Contact us</a> if you would like to purchase an Organization Account.

Organization admins are responsible for adding and removing users, managing their access, and locking applications to prevent additional membership. This guide contains a description of the available user roles and commands to manage application access.

## Roles

Organization users can be assigned one of three roles: Admin, member or collaborator. An organization can have any number of each role, but must have at least one admin user.

### Admin

The admin role allows users to:

* List all apps in the organization
* Join all apps in the organization, even if locked
* Lock apps (that they’ve joined)
* Add/remove admins & members in the organization
* Add collaborators to apps
* View resources for the organization
* Access billing for the organization
* Rename the organization
* Transfer in or out, create, and delete apps in the org (deleting the app currently requires joining it first)
* Deploy to all apps in the organization
* Scale dynos for all apps in the organization
* Add free and paid add-ons to apps

Each org must have at least one admin user. The last administrator in the organization cannot be removed to enforce this.

Admin users can only be added by other org admins.

### Member

Assigning a user the member role gives them access to all apps within an organization. Members can:

* List all apps in the organization
* Join unlocked apps
* View admins & members in the organization
* Add collaborators to apps
* View resources for the organization
* Transfer personal apps into the org
* Create apps in the org (but not delete them)
* Deploy to all apps in the organization
* Scale dynos for all apps in the organization
* Add free and paid add-ons to apps

Member users can only be added by org admins.

### Collaborator

A collaborator is not formally a user in the organization, but is a per-app role given to individuals that need access to a specific application.

Only for the apps in the organization they've been given direct access to, a collaborator can:

* List those apps
* Deploy
* Scale dynos
* Add and remove free add-ons

An app collaborator will be unable to:

* List or join other org apps
* View other org users
* Add collaborators to apps
* Create or transfer apps to the org
* Add or remove paid add-ons

App collaborators can be added to an app by org admin or member users.

## Adding users

Users can be managed from the Access tab in your org Dashboard.

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/265-original.jpg 'Add members')

You can also manage users using the Heroku CLI. Add a new org member with:

```term
$ heroku members:add joe@acme.com --org acme-inc
Adding joe@acme.com as member to organization acme-inc... done
```

Add additional admin users using the same command with the `--role` flag:

```term
$ heroku members:add joe@acme.com --org acme-inc --role admin
Adding joe@acme.com as admin to organization acme-inc... done
```

Because of their app-level access, collaborators are a special case and require a different command.

```term
$ heroku sharing:add jill@daimyo-creative.com --app acme-website
Adding jill@daimyo-creative.com to acme-website as collaborator... done
```

## Changing user roles

If you wish to change the role assigned to an existing org user, you can use the `members:set` command.

```term
$ heroku members:set joe@acme.com --org acme-inc --role admin
Setting role of joe@acme.com to admin in organization acme-inc... done
```

The same rules apply here as when adding a user to an org: Only an admin user can set another user's role to admin.

> note
> Note that `members:set` can only be used for the admin and member roles. Collaborators are not considered org users and cannot be given another role until they are explicitly added to the org with `members:add`.

## Removing users

Removing a user will prevent them from being able to access the org and all apps within it. You can remove users using the Access tab in the org Dashboard.

From the CLI you can remove admin and member users with:

```term
$ heroku members:remove joe@acme.com --org acme-inc
Removing joe@acme.com from organization acme-inc... done
```

To remove a collaborator from an app, use `sharing:remove` instead:

```term
$ heroku sharing:remove joe@acme.com --app acme-website
Removing joe@acme.com from acme-website collaborators... done
```

## Locking an app

Org members have access to all applications within an organization, but are unable to work on an application until they explicitly ["join" the app](develop-orgs#developing-apps) themselves. Admin users can freeze application access by "locking" the app. This prevents any new members from joining the app.

Locking an app is traditionally performed when the app has reached some level of maturity, i.e. production status, as a safeguard to prevent errant modification.

To lock or unlock an app, navigate to the Access tab in the org Dashboard and click the "Lock this app" button.

![](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/277-original.jpg 'Lock an app')

From the CLI use the `lock` command.

```term
$ heroku lock --app myapp
Locking myapp...  done
Organization members must be invited this app.
```

You can view the locked status of your joined apps with `list`.

```term
$ heroku list
=== Apps joined in organization acme
test
myapp (locked)
website-staging
website-prod (locked)
```

### Granting access to locked apps

When an app is locked no new members are allowed to join the app. However, users can be added to locked apps in the collaborator role. Admins can add an org user, or outside user, to a locked app by adding them as a collaborator:

```term
$ heroku sharing:add joe@acme.com --app myapp
Adding joe@acme.com to myapp in acme-inc... done
```

### Unlocking apps

To open a locked app back up for general member access, use the "Access" tab of the org Dashboard or the `unlock` command from the CLI:

```term
$ heroku unlock --app myapp
Unlocking myapp...  done
All organization members can join this app.
``` 