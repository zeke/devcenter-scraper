---
title: Heroku CLI
slug: heroku-command
url: https://devcenter.heroku.com/articles/heroku-command
description: Install the Heroku CLI from http://toolbelt.herokuapp.com/ which includes the CLI, the Foreman procfile runner and git.
---

The `heroku` command-line tool is an interface to the Heroku Platform API and
includes support for things like creating/renaming apps, running one-off dynos,
taking backups, and configuring add-ons. Most app management activities require
the Heroku CLI to be installed and configured alongside your local
working environment.

## Installing the Heroku CLI

Set up your local workstation with the Heroku command-line client, the Git revision control system and the Foreman app runner by installing the [Heroku Toolbelt](http://toolbelt.herokuapp.com/).

To verify your toolbelt installation use the `heroku --version` command.

```term
$ heroku --version
heroku-toolbelt/2.39.0 (x86_64-darwin10.8.0) ruby/1.9.3
```

You should see `heroku-toolbelt/x.y.z` in the output. If you don't, but have installed the toolbelt, it's possible you have the old heroku gem on your system. To find out where the executable is located, run `which`.

```term
$ which heroku
/usr/local/heroku/bin/heroku
```

The path to the `heroku` command should not be a Ruby gem directory. If it is, uninstall it and any other heroku gems:

```term
$ gem uninstall heroku --all
```

Retry `heroku --version` until it reflects the expected `heroku-toolbelt` output.

## Logging in

You will be asked to enter your Heroku credentials the first time you run a command; after the first time, your email address and an API token will be saved to `~/.netrc` for future use. For more information, see [Heroku CLI Authentication](http://devcenter.heroku.com/articles/authentication)

It's generally a good idea to login and add your public key immediately after installing the
heroku toolbelt so that you can use git to push or clone Heroku app repositories:

```term
$ heroku login
Enter your Heroku credentials.
Email: joe@example.com
Password: 
Uploading ssh public key /Users/joe/.ssh/id_rsa.pub
```

> callout
> Autoupdate was added to the Toolbelt in version 2.32.0. If you have an older version, please [reinstall the Toolbelt](https://toolbelt.heroku.com).

## Staying up to date

The Heroku Toolbelt will automatically keep itself up to date.

#### How it works

When you run a `heroku` command, a background process will be spawned that checks a URL for the latest available version of the CLI. If a new version is found, it will be downloaded and stored in `~/.heroku/client`. This background check will happen at most once every 5 minutes.

The `heroku` binary will check for updated clients in `~/.heroku/client` before loading the system-installed version.