---
title: .profile.d Scripts
slug: profiled
url: https://devcenter.heroku.com/articles/profiled
description: Heroku will run scripts found in the `.profile.d/` directory of an application during startup, providing you with explicit control over the startup environment.
---

During startup, the container starts a `bash` shell that runs scripts in the `.profile.d/` directory before executing the dyno's command.  

These scripts let you manipulate the initial environment, at runtime, for all dyno types in the app - an application can gain explicit control over its startup environment. Buildpacks can use these scripts to set up a [default environment](buildpack-api#default-config-values).

The scripts must be `bash` scripts, and their filenames must end in `.sh`.

> note
> If you have questions about the build process on Heroku, consider discussing it in the [Build forums](https://discussion.heroku.com/category/build).

## Example `.profile.d/path.sh`

>callout
>`.profile.d` scripts are sourced *after* the app's config vars are added to the environment. To have the app's config vars take precedence, use a technique like that shown here with `LANG`.

```term
# add vendor binaries to the path
PATH=$PATH:$HOME/vendor/bin

# set a default LANG if it does not exist in the environment
LANG=${LANG:-en_US.UTF-8}
```

>warning
>If you find yourself making frequent changes to your `.profile.d` scripts, you should probably be using [config vars](config-vars).

## Order

Scripts in the `.profile.d/` directory will be executed in an arbitrary order. 