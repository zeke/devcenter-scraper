---
title: Deploying a Ruby Project Generated on Windows
slug: bundler-windows-gemfile
url: https://devcenter.heroku.com/articles/bundler-windows-gemfile
description: How to handle Windows-specific gems and the handling of Gemfile.lock on Heroku when deploying Ruby applications.
---

Heroku's [runtime stacks](stack) run on a distribution of Linux, and as a result requires all libraries installed to be Linux compatible. If you are developing on a Windows machine there can be problems when deploying to Linux due to cross OS compatibility issue with dependencies. Generally developers on a Mac or another Linux distribution will not have the problems described below.

## Background: dependency resolution

If you are developing a Ruby application, you use a `Gemfile` to declare the dependencies that you need. When you run `bundle install` all of your dependencies are evaluated to see if they can be resolved. Bundler then creates a `Gemfile.lock`. This file has the exact versions of the dependencies that were installed so that if you give the same `Gemfile` and `Gemfile.lock` to someone on another computer and have them run `bundle install` it should install the exact same versions. 

Some gems have decided to create specialized versions to maintain compatibility with windows. When you run `bundle install` on a Windows machine you may see something that looks like this in the `Gemfile.lock`:

```
PLATFORMS
  ruby
  x86-mingw32
```

This `x86-mingw32` line tells bundler that the `Gemfile` was evaluated on a Windows machine. You may also see `mswin` instead of `mingw`. You may or may not notice individual gems that contain a special marker:

```
sqlite3 (1.3.8-x86-mingw32)
```

This indicates that this gem is custom for the platform `x86-mingw32` or windows. 

Because the Cedar runtime stack is based on Linux, it cannot install these custom libraries, due to this problem the previous `Gemfile.lock` resolution must be discarded and we must run `bundle install` from scratch.

## Bundle install with no lockfile

When a `Gemfile.lock` is removed before running `bundle install` all history of libraries and their versions installed is gone. The resolver in bundler must now work to re-generate a new `Gemfile.lock` and install gems. This has two problems: inconsistency between development and production code, and the potential to have a Gemfile that does not resolve at all.


## Detection

When Heroku detects that you a Windows specific `Gemfile.lock` it will output a warning in line. Check your deploy output for something like this:

```
Removing `Gemfile.lock` because it was generated on Windows.
```

## Inconsistent dev-prod parity

Without a `Gemfile.lock` If you have a line in your Gemfile like this:

```
gem 'rails'
```

You are stating you want bundler to install __any__ version of Rails. If it detects that you already have `3.2.x` installed on your local machine it may decide to use that version, where if you were to install on a co-worker's machine it may install `4.0.x`. 

This inconsistency between machines and between development and production is likely to cause errors. You may see strange behavior in production that you cannot re-produce in development. To help avoid that, and achieve [dev/prod parity](development-configuration#dev-prod-parity), be as specific as possible in your Gemfile:

```
gem 'rails', '4.0.1'
```

This guarantees that Rails 4.0.1 will be installed even if the `Gemfile.lock` is missing. While it is impossible to do this for all of your dependencies you can use operators such as greater than or equal (`>=`) or preferably the pessimistic locking operator (`~>`) to limit the scope of your gem requirements.

The down side to being specific in the Gemfile is that upgrading one gem may cause a gem resolution to fail and you may need to spend some time figuring out exactly how declare the versions of your dependencies manually.


## Cannot resolve Gemfile

If your gem versions are too vague, and if those libraries have circular requirements it is possible to get bundler into a state where it cannot resolve your dependencies but continues to try in an infinite loop. If the output after `bundle install` seems to freeze for many minutes, or continuously outputs dots `..........` it may be a sign that it cannot resolve your `Gemfile` when the `Gemfile.lock` is removed. In this scenario you likely need to make your gem version requirements more specific to better help bundler do its job and narrow down its search space.

## Mitigation

Be as specific in your Gemfile as you possibly can when developing on Windows. If only one developer on your team has a Windows machine, consider not checking in their `Gemfile.lock` changes or manually bundle installing and committing on a non-Windows machine before deploying.

  