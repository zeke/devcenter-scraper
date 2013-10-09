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
    <td markdown="1" class="icon">[Celadon Cedar](cedar)</td>
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
  <tr id="badious-bamboo">
    <td markdown="1" class="icon">[Badious Bamboo](bamboo)</td>
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

The only stack on which you can provision new apps is [Cedar](cedar). The stack for existing apps can be determined using the `stack` [CLI](using-the-cli) command.

    :::term
    $ heroku stack
      bamboo-mri-1.9.2
      bamboo-ree-1.8.7
    * cedar

Here, the app is running on [Celadon Cedar](cedar).

## Migrating to Cedar

Migrating from previous stacks to Cedar allows an application to take advantage of a much more flexible and powerful runtime. Because the significant architectural differences, migrating to Cedar is a largely manual process.

You can find instructions for [migrating to Cedar](cedar-migration) here.