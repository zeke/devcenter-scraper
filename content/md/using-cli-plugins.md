---
title: Using CLI Plugins
slug: using-cli-plugins
url: https://devcenter.heroku.com/articles/using-cli-plugins
description: Heroku plugins allow developers to extend the functionality of the Heroku command interface, adding commands or features.
---

Plugins allow developers to extend the functionality of the Heroku command interface, adding commands or features.

```term
=== Plugins
plugins                      # list installed plugins
plugins:install <url>        # install the plugin from the specified git url
plugins:uninstall <url/name> # remove the specified plugin
plugins:update <url/name>    # update a plugin, if specified, or update all plugins
```

### Installing plugin

To install a plugin, you need to know the git url for the plugin.  Use the `heroku plugins:install` command, and specify the git repo:

```term
$ heroku plugins:install git://github.com/ddollar/heroku-accounts.git
```

### List plugins

To see a list of currently installed plugins:

```term
$ heroku plugins
=== Installed Plugins
heroku-accounts
```

### Removing plugins

```term
$ heroku plugins:uninstall heroku-accounts
```

### Updating plugins

To update all installed plugins:

```term
$ heroku plugins:update
```

To update a particular plugin:

```term
$ heroku plugins:update heroku-accounts
```
