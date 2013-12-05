---
title: Getting Started with Heroku Labs
slug: labs
url: https://devcenter.heroku.com/articles/labs
description: Heroku Labs allows you to try out experimental features that are under consideration for inclusion into the platform.
---

Heroku Labs allows you to try out experimental features that are under consideration for inclusion into the platform.

> warning
>Features added through Heroku Labs are experimental and subject to change.

### Usage

View the available features:

```term
$ heroku labs:list
=== App Available Features
flux-capacitor:   Adds time travel capability

=== User Available Features
superpowers:      Adds flight and laser vision
```

View detailed information about a particular feature:

```term
$ heroku labs:info flux-capacitor
=== flux-capacitor
Summary: Adds time travel capability
Docs:    https://devcenter.heroku.com/articles/labs-flux-capacitor
```

Enable a feature for an app:

```term
$ heroku labs:enable flux-capacitor --app example
Enabling flux-capacitor for example... done
WARNING: This feature is experimental and may change or be removed without notice.
```

Disable a feature for an app:

```term
$ heroku labs:disable flux-capacitor --app example
Disabling flux-capacitor for example... done
```

See all the features applied to an app and user:

```term
$ heroku labs --app example
=== example Enabled Features
flux-capacitor:   Adds time travel capability

=== user@domain Enabled Features
superpowers:      Adds flight and laser vision
```