---
title: Renaming Apps from the CLI
slug: renaming-apps
url: https://devcenter.heroku.com/articles/renaming-apps
description: Heroku applications can be renamed at any time with the `heroku rename` command.
---

You can rename an app at any time with the `heroku apps:rename` command. For example,
to rename an app named "oldname" to "newname", change into the app's git
checkout and run:

```term
$ heroku apps:rename newname
Renaming oldname to newname... done
http://newname.herokuapp.com/ | git@herokuapp.com:newname.git
Git remote heroku updated
```

Renaming an app will cause it to immediately become available at the new
subdomain (`newname.herokuapp.com`) and unavailable at the old name
(`oldname.herokuapp.com`).  

If you have custom domains configured that use these subdomains, for example [a CNAME record](https://devcenter.heroku.com/articles/custom-domains#subdomain-dns) set up that references `oldname.herokuapp.com`, then it will also need to be updated.

## Renaming without a checkout

You can rename an app while outside a git checkout by passing an explicit
`--app` argument:

```term
$ heroku apps:rename newname --app oldname
http://newname.herokuapp.com/ | git@herokuapp.com:newname.git
```

Note that you will need to manually update any existing git remotes that point
to the old name.

## Updating Git remotes

If you are using the CLI to rename an app from inside the Git checkout directory, your remote will be updated automatically. If you rename from the website or have other checkouts, such as those belonging to other developers, these will need to be updated manually:

```term
$ git remote rm heroku
$ heroku git:remote -a newname
```

Replace "newname" with the new name of the app, as specified in the rename
command. 