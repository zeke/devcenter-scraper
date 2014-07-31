---
title: Stacks
slug: stack
url: https://devcenter.heroku.com/articles/stack
description: A Heroku stack is a complete deployment environment including the base operating system, the language runtime and associated libraries.
---

A stack is a complete deployment environment including the base operating system, the language runtime and associated libraries. As a result, different stacks support different runtime environments.  

## Stack summary

<table id="stack-compare" class="compare">
  <tr>
    <th class="icon">&nbsp;</th><th class="tech">Base Technology</th><th>REE 1.8.7</th><th>MRI 1.8.7</th><th>MRI 1.9.2</th><th>MRI 1.9.3</th><th>MRI 2.0.0</th><th>Node.js</th><th>Clojure</th><th>Java</th><th>Python</th><th>Scala</th>
  </tr>
  <tr id="celadon-cedar">
    <td class="icon" rowspan="2" style="vertical-align: top;"><a href="/articles/cedar">Celadon Cedar</a></td>
    <td class="tech">Ubuntu 10.04</td>
    <td>&nbsp;</td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
  </tr>
  <tr id="celadon-cedar-14">
    <td class="tech" style="text-align: center;">Ubuntu 14.04</td>
    <td>&nbsp;</td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
    <td>&nbsp;</td>
    <td><span class="check">&bull;</span></td>
    <td><span class="check">&bull;</span></td>
  </tr>
  <tr id="badious-bamboo">
    <td class="icon"><a href="/articles/bamboo">Badious Bamboo</a></td>
    <td class="tech">Debian Lenny 5.0</td>
    <td><span class="check">&bull;</span></td>
    <td>&nbsp;</td>
    <td><span class="check">&bull;</span></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>

You can provision new apps on both flavors of the [Cedar](cedar) stack. The stack for existing apps can be determined using the `stack` [CLI](using-the-cli) command.

```term
$ heroku stack
  bamboo-mri-1.9.2
  bamboo-ree-1.8.7
* cedar
  cedar-14
```

Here, the app is running on [Celadon Cedar](cedar).

## Changing stacks

You can change the stack for an existing application with the `stack:set` command. For example:

```term
$ heroku stack:set cedar
Stack set, next release on example-app will use cedar.
Run `git push heroku master` to create a new release on cedar.
```
## Migrating to a new stack

You will likely need to make changes to your application code as you move an app to a different stack. The `stack:set` command will tell Heroku what stack to use, but it is your responsibility, as the application developer, to make any required changes to your code.

When migrating a production app to a new stack, you should perform the migration work on a staging version of the app in a separate code branch. Once you have tested that the app runs correctly on the new stack, you can merge in your changes on the production environment, change the stack with `stack:set` and deploy.

Heroku Dev Center has instructions for [migrating from Bamboo to Cedar](cedar-migration).
