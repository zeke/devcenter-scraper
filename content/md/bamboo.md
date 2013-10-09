---
title: The Badious Bamboo Stack
slug: bamboo
url: https://devcenter.heroku.com/articles/bamboo
description: Badious Bamboo is a Heroku stack for running Ruby applications. Cedar is the most recent Heroku Stack, capable of running Ruby and many other languages.
---

<div class="deprecated" markdown="1">This article only applies to apps on the [Bamboo](bamboo) stack. New Bamboo apps can no longer be created. The most recent stack is  [Cedar](cedar).</div>

Bamboo is a deployment [stack](stack) on Heroku.  It has been succeeded by [Cedar](cedar). It runs on Debian 5.0 (lenny) and offers two Ruby VMs: [Ruby Enterprise Edition](http://www.rubyenterpriseedition.com/) 2011.03 1.8.7-p334, and MRI 1.9.2-p180. 

They both use rubygems 1.3.7.  Apps running on the Bamboo stack must explicitly declare their [gem dependencies](bundler).

## Migration

Existing Bamboo applications can [migrate to the Cedar stack using these instructions](cedar-migration).