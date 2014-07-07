---
title: Documenting an Add-on
slug: documenting-an-add-on
url: https://devcenter.heroku.com/articles/documenting-an-add-on
description: How to document an add-on - an important step in creating a new add-on service for the Heroku Add-on catalog.
---

The Heroku Add-on catalog is a unique marketing channel that places the add-on
in front of a large and diverse group of technologists and is capable of
accelerating its adoption and awareness. Well-written and maintained Dev
Center documentation is central to clearly identifying the service benefits to
the various language communities and provides confidence to developers
considering integrating the add-on into their application.

## Duplicate documentation

Many add-on providers maintain product documentation on their own site and
attempt to remove all areas of duplication by linking to their site
documentation throughout the article or by providing a very thin document that
delegates back to the provider site. This type of documentation is not
appropriate for the Dev Center.

Developers look to the Dev Center as their first resource for all topics
surrounding the platform and add-ons and as many of their questions as
possible should be answered on this initial visit. It creates a very
inconsistent and poor experience for the reader to have to navigate outside
the Dev Center. The user experience is paramount at Heroku.

Additionally, the Dev Center should be thought of as its own marketing
channel. Different channels necessarily duplicate some content to speak more
directly to that particular audience. The business benefits far outweigh any
minor administrative overhead incurred.

## Starter template

Developers unfamiliar with an add-on may have very little knowledge about the
functionality it provides, how to integrate it with their preferred language
or even how to use it during development and testing. It is important to
provide both broad context and specific examples to ensure complete coverage.

### Download template

To aid in this task, Heroku provides a starter-template that can be used as
a starting point for add-on documentation. It includes topics that have been
found to increase clarity and reduce developer confusion.

Copy [the template](https://gist.githubusercontent.com/jonmountjoy/3aa2739ec0984a67ef97/raw/79683477b6596e989453752dac1bdfa86eb2cf94/README.md) to your local environment for editing.

```term
$ curl 
https://gist.githubusercontent.com/jonmountjoy/3aa2739ec0984a67ef97/raw/79683477b6596e989453752dac1bdfa86eb2cf94/README.md > addon-doc.md
```

Dev Center documentation is written using a slight extension to the text-based [GitHub Flavored 
Markdown](http://daringfireball.net/projects/markdown/) format. Any text
editor can be used to edit the article.

### Replace stubs

Open the article and replace the following keywords with the appropriate
values for the article's add-on.

<table>
  <tr>
    <th>Replace...</th>
    <th>with</th>
  </tr>
  <tr>
    <td><code>ADDON-NAME</code></td>
    <td style="text-align: left">The name of the add-on. E.g. <code>New Relic</code>.</td>
  </tr>
  <tr>
    <td><code>ADDON-SLUG</code></td>
    <td style="text-align: left">The shorthand name used by the CLI and Add-on site URL. E.g. <code>newrelic</code>.</td>
  </tr>
  <tr>
    <td><code>ADDON-CONFIG-NAME</code></td>
    <td style="text-align: left">The name of the add-on config expose to integrated apps. E.g. <code>CLOUDANT_URL</code>.</td>
  </tr>
</table>

Sections wrapped in `[[` `]]` brackets are notes to the author and should be
removed before publishing.

## Content

Many of the sections in the starter template may not be appropriate for the
add-on being documented. In such cases the sections can be removed. However,
this should be the exception and not the rule as these sections have been
found create the best experience for potential users of the add-on.

### Writing guide

In order to provide a consistent experience across the Dev Center, Heroku has
created a [writing guide](http://devcenter.heroku.com/articles/writing) with
clear style, structure and formatting guidance. Please read the writing guide
to ensure the add-on documentation maintains consistency with the rest of the
Dev Center content.

### About the add-on

Please describe the details of the service you are providing in the opening
section. Information you may want to include are: 1) how the service works
2) the benefits of your service. 3) how your service differs from other
options in the market place. Developers have many choices in application
services, use this as an opportunity to convince them of the value of your
offering.

### Code samples/polyglot

Heroku is a polyglot platform. Add-ons should also support the tenet of
polyglot application development by providing code samples in languages
supported by the add-on. The starter template has several areas where code and
integration samples are given in Ruby followed by a placeholder for other
languages. Please complete the other language sections with as much detail as
the Ruby section as possible.

Documenting support for only a single language severely limits the potential
market for the add-on amongst Heroku's increasingly polyglot developer-base.

### Rendering tools

Many services support the rendering of Markdown into HTML including
[GitHub Gists](https://gist.github.com/). Storing the article in a private
gist and using it to collaborate with others during the writing process is
a common and convenient practice.

### Writing support

If review and feedback is desired, please contact the Heroku Add-ons team
at [addons@heroku.com](mailto:addons@heroku.com).

## Examples

The [CloudAMQP add-on documentation](https://devcenter.heroku.com/articles/cloudamqp)
is a great example of a well-written, consistent and polyglot document.

## Submission

Once the add-on article has been created, please follow the submission process
in the [Provider Portal](https://addons.heroku.com/provider/dashboard)
to submit the documentation.

## Maintenance

Content is only as compelling as it is relevant. Add-on providers should
ensure their Dev Center documentation stays up-to-date with new versions and
language releases. 