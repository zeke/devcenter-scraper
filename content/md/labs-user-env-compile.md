---
title: Heroku Labs: user-env-compile
slug: labs-user-env-compile
url: https://devcenter.heroku.com/articles/labs-user-env-compile
description: This Heroku Labs feature adds experimental support for having an app's config vars be present in the environment during slug compilation.
---

This [Heroku Labs](http://devcenter.heroku.com/categories/labs) feature adds experimental support for having an app's config vars be present in the environment during slug compilation.
 
<p class="warning">
The features added through labs are experimental and may change or be removed without notice.
</p>

<p class='callout'>Using this labs feature is considered counter to Heroku best practices. This labs feature can make your builds less deterministic and require re-deploys after making config changes. Ideally your app should be able to <a href='http://12factor.net/build-release-run'>build without config</a>.</p>

## Use case

Making an app's [config vars](https://devcenter.heroku.com/articles/config-vars) present during the build allows for build-time optimizations to run in an environment that more closely resembles the runtime environment. This also allows config vars to be used to configure the build.

For example, because Rails 3.1 couples configuration with initialization, the Rails 3.1 `assets:precompile` task performs much more reliably in the presence of the runtime config.

## Warning

Changing config vars will not cause an app's slug to be recompiled. This could lead to unexpected inconsistency if a slug was compiled with a different set of config vars than those it is run against. Pushing new code will cause the slug to be recompiled against the current set of config vars.

## Enabling

    :::term
    $ heroku labs:enable user-env-compile -a myapp
    -----> Enabling user-env-compile for myapp... done
    WARNING: This feature is experimental and may change or be removed without notice.

## Disabling

    :::term
    $ heroku labs:disable user-env-compile -a myapp
    -----> Disabling user-env-compile for myapp... done