---
title: Ruby Gems Available on Bamboo
slug: gems-on-aspen-bamboo
url: https://devcenter.heroku.com/articles/gems-on-aspen-bamboo
description: Some Ruby gems come pre-installed on the Bamboo platform
---

> callout
> You can use [Bundler](http://devcenter.heroku.com/articles/bundler) to manage and provide an isolated environment that is not affected by existing system gems.

A limited number of Gems come pre-installed on the [Bamboo](bamboo) stack. This stack supports using the [gem manifest](gemmanifest) to install additional gems. Below is a list of all Gems pre-installed on Bamboo.

Bamboo  mri 1.9.2  gems
--------------------

```term
bundler (1.0.7)
daemons (1.1.0)
eventmachine (0.12.10)
minitest (1.6.0)
pg (0.9.0, 0.8.0)
rack (1.1.0)
rake (0.8.7)
rdoc (2.5.8)
thin (1.2.6)
```

Bamboo  ree 1.8.7  gems
--------------------

```term
abstract (1.0.0)
bundler (1.0.7, 0.9.26, 0.9.5)
chef (0.7.16)
daemons (1.0.10)
erubis (2.6.5)
eventmachine (0.12.10)
extlib (0.9.14)
fattr (2.1.0)
json (1.2.0)
mime-types (1.16)
mixlib-cli (1.0.4)
mixlib-config (1.0.12)
mixlib-log (1.0.3)
ohai (0.3.6)
pg (0.8.0)
rack (1.0.1)
rake (0.8.7)
rdiscount (1.6.3)
rest-client (1.2.0)
ruby-openid (2.1.7)
rubygems-update (1.3.7, 1.3.6)
rush (0.6.7)
session (2.4.0)
stomp (1.1.3)
systemu (1.2.0)
thin (1.2.6)
```
