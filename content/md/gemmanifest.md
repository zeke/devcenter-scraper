---
title: Heroku Gem Manifest
slug: gemmanifest
url: https://devcenter.heroku.com/articles/gemmanifest
description: The gem manifest is an older way to specify gem files, now replaced by Bundler.
---

> warning
> This article only applies to apps on the [Bamboo](bamboo) stack.  The most recent stack is [Cedar](cedar).

> note
> Heroku **strongly** recommends you use [Bundler](bundler) to manage your app's gem dependencies.  Gem manifest is not available on the [Cedar](cedar) stack.

The gem manifest is an older way to specify gem files.  It has issues managing gem dependencies, and has been replaced by [Bundler](bundler).  When a new version of the app is pushed to Heroku, any changes to the `.gems` file are detected and new gems are installed along with their dependencies.


## Creating a gem manifest 

The gems manifest is a simple text file that includes information about each of
the gems required by an application. Each entry in the manifest includes a
mandatory gem name along with optional `version` and `source` options.  The
following is an example `.gems` manifest file that includes two gems:

```ruby
hpricot --version '>= 0.2' --source code.whytheluckystiff.net
dm-core --version 0.9.10
formtastic --ignore-dependencies
```

> callout
> The `--version` and `--source` options have short forms just like the `gem` command; use `-v` and `-s`, respectively.

Each line of the `.gems` file includes the following:

* The name of the gem, as would be specified on the `gem install`
   command line.

* An optional gem version specifier. This can be a basic version
   number like `"0.1.2"` or an advanced version specifier with comparison
   constraints like `">= 0.1.2"` (see
   [Specifying Versions](http://www.rubygems.org/read/chapter/16) in the
   RubyGems manual for more information). When no explicit version is specified,
   the most recent version of the gem is installed.

* An optional gem repository source URL, like `gems.rubyforge.org`,
   `gems.github.com`, or `gems.mycustomrepo.com`. The `gems.rubyforge.org` repository
   is always included as the last source. Multiple `--source` arguments
   may be provided for cases where dependencies cross multiple repositories.

* An optional flag to ignore installing dependencies. This can be used to
   manually specify gem dependencies if they're causing conflicts.


## Deploying gem changes

When a `.gems` manifest file is added or modified, it must be committed to the
app's git repository and pushed to Heroku for changes to take effect. The actual
gem install process occurs during the `git push` operation.

The following example adds a `.gems` file to the app's git repository, commits
it, and pushes to the remote heroku repository:

```term
$ git add .gems
$ git commit -m 'added gems manifest file'
$ git push heroku
Counting objects: 4, done.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 356 bytes, done.
Total 3 (delta 1), reused 0 (delta 0)

-----> Heroku receiving push

-----> Installing gem hpricot >= 0.2 from http://code.whytheluckystiff.net
       Building native extensions.  This could take a while...
       Successfully installed hpricot-0.6
       1 gem installed

-----> Installing gem dm-core 0.9.10 from http://gems.rubyforge.org
       Successfully installed addressable-2.0.2
       Successfully installed extlib-0.9.10
       Successfully installed data_objects-0.9.11
       Successfully installed dm-core-0.9.10
       4 gems installed

-----> Rails app detected
       Compiled slug size is 4.3MB
-----> Launching.............. done
       App deployed to Heroku

To git@heroku.com:vivid-moon-60.git
   91425e3..fe10e87  master -> master
```

The push is aborted if the gem manifest is invalid or a gem fails to install,
ensuring that an application is not deployed in an inconsistent state.
 