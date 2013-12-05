---
title: CLI Usage
slug: using-the-cli
url: https://devcenter.heroku.com/articles/using-the-cli
description: Use the Heroku Command Line Tool to interact with your Heroku account and applications.
---

Running `heroku help` displays a usage summary:

```term
$ heroku help
Usage: heroku COMMAND [--app APP] [command-specific-options]

Primary help topics, type "heroku help TOPIC" for more details:

  addons    # manage addon resources
  apps      # manage apps (create, destroy)
  auth      # authentication (login, logout)
  config    # manage app config vars
  domains   # manage custom domains
  logs      # display logs for an app
  ps        # manage processes (dynos, workers)
  releases  # view release history of an app
  run       # run one-off commands (console, rake)
  sharing   # manage collaborators on an app

Additional topics:

  account      # manage heroku account options
  db           # manage the database for an app
  drains       # display syslog drains for an app
  help         # list commands and display help
  keys         # manage authentication keys
  maintenance  # toggle maintenance mode
  pg           # manage heroku postgresql databases
  pgbackups    # manage backups of heroku postgresql databases
  plugins      # manage plugins to the heroku gem
  ssl          # manage ssl certificates for an app
  stack        # manage the stack for an app
  status       # check status of Heroku platform
  update       # update the heroku client
  version      # display version
```

The commands are divided into two types: general commands and app commands.

### General commands

General commands operate on your Heroku account as a whole, and are not specific
to a particular app.  For instance, to get a list of apps you created or are a
collaborator on:

```term
$ heroku apps
example
collabapp                 owner@example.org
example2
```

### App commands

App commands are typically executed from within an app's local git working copy.
The app name is automatically detected by scanning the git remotes for the
current working copy, so you don't have to specify which app to operate on
explicitly. For example, the `heroku apps:info` command can be executed without any
arguments inside the working copy:

```term
$ cd example
$ heroku apps:info
=== example
Git Repo:       git@heroku.com:example.git
Owner:          you@example.org
Repo size:      960k
Slug size:      512k
Stack:          cedar
Web URL:        http://example.heroku.com/
```

If you have multiple heroku remotes or want to execute an app command outside of
a local working copy, you can specify an explicit app name as follows:

```term
$ heroku apps:info --app example
```

### Using an HTTP proxy

If you're behind a firewall that requires use of a proxy to connect with external HTTP/HTTPS services, you can set the `HTTP_PROXY` or `HTTPS_PROXY` environment variables before running the `heroku` command.