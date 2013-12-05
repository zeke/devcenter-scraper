---
title: Heroku Labs: pipelines
slug: labs-pipelines
url: https://devcenter.heroku.com/articles/labs-pipelines
description: Heroku pipelines allows deployment between apps with a shared code base.
---

This [Heroku Labs](http://devcenter.heroku.com/categories/labs) feature adds support for managing application releases as part of a [continuous delivery workflow](http://en.wikipedia.org/wiki/Continuous_delivery).

<p class="warning">
Features added through Heroku Labs are experimental and subject to change.
</p>

## Multi-environment complexity

Maintaining multiple environments, such as staging and production, is simple on Heroku. However, maintaining consistent deployments between these environments requires app owners to manually manage the deployment workflow. Issues that can arise from a manual deployment workflow typically include pushing the wrong commit, releasing untested code, or pushing to the incorrect environment.

## Deployment with pipelines

Pipelines allow you to define how your code should be promoted from one environment to the next. For example, you can push code to `staging`, have it built into a [slug](slug-compiler) and later promote the `staging` slug to `production`. Common examples of pipelines include:

A simple staging to production pipeline: 

    myapp-staging ---> myapp

Or, a team's more complex pipeline:

    myapp-jim-dev ---
                      \
                        ---> myapp-staging ---> myapp
                      /
    myapp-kim-dev ---

<p class="note" markdown="1">
In pipeline vocabulary, "downstream" refers to the next target app in a pipeline. For example, given a `dev ---> staging ---> production` pipeline, staging is downstream of dev, and production is downstream of staging. 
</p>

Once you've defined a pipeline, you and your team no longer have to worry about the next app to deploy to. Instead, `heroku pipeline:promote` will copy your app's build artifact (i.e. [slug](slug-compiler)) to the downstream app as a new release.

<p class="warning" markdown="1">
Pipelines only manage the application slug. The [Git repo](git), [config vars](config-vars), [add-ons](managing-add-ons) and other environmental dependencies are not considered part of a pipeline and must be managed independently. You can use [Heroku Fork](fork-app) to quickly clone production apps to be used for dev and staging.
</p>

## Enable pipelines

To use pipelines, enable the labs feature:

    :::term
    $ heroku labs:enable pipelines
    Enabling pipelines for you@yourcompany.com... done
    WARNING: This feature is experimental and may change or be removed without notice.
    For more information see: https://devcenter.heroku.com/articles/using-pipelines-to-deploy-between-applications

And install the Heroku CLI plugin:

    :::term
    $ heroku plugins:install git://github.com/heroku/heroku-pipeline.git

## Using pipelines

`heroku pipeline:add` adds a downstream app to your current app. Specify the name of your downstream app when creating the pipeline.

    :::term
    $ heroku pipeline:add myapp
    Added downstream app: myapp

You can show the downstream app for your current app with `heroku pipeline`. For example, `myapp-staging` has a downstream of `myapp`.

    :::term
    $ heroku pipeline
    Pipeline: myapp-staging ---> myapp

You can also diff against the downstream app with `heroku pipeline:diff`. The results show a comparison of releases between the upstream and downstream apps.

    :::term
    $ heroku pipeline:diff
    Comparing myapp-staging to myapp...done, myapp-staging ahead by 1 commit:
    73ab415  2012-01-01  A super important fix  (Jim)

Promote an app using `heroku pipeline:promote`.

    :::term
    $ heroku pipeline:promote
    Promoting myapp-staging to myapp...done, v2

## Staging to production workflow

The most typical workflow involves deploying to staging, verifying functionality and performing some form of user acceptance testing, and then promoting to production.

First, use `git push` to deploy your code to the staging app.

    :::term
    $ git push heroku master
    ...

Once the staging app is ready to be promoted, it's a good practice to compare against its downstream. Use `heroku pipeline:diff` to see the differences:

    :::term
    $ heroku pipeline:diff
    Comparing myapp-staging to myapp...done, myapp-staging ahead by 2 commits:
    82af415  2012-01-02  A super important fix  (Jim)
    90dc189 2012-01-02  A super awesome feature (Kim)

Now that we know what we're promoting, use `heroku pipeline:promote` to promote the release from staging to production (the downstream app).

    :::term
    $ heroku pipeline:promote
    Promoting myapp-staging to myapp...done, v2

Pipeline promotion results in a [release-entry](releases) on the downstream app.

    :::term
    $ heroku releases --app myapp
    
    === myapp Releases
    v2  Promote myapp-staging v6 0f0a53b  you@yourcompany.com   1m ago
    ...

<div class="note" markdown="1">
Revert a promotion as you do other errant operations by invoking `heroku rollback` on the downstream app.
</div>