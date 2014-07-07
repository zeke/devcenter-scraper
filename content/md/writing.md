---
title: Writing a Dev Center Article
slug: writing
url: https://devcenter.heroku.com/articles/writing
description: A short guide quantifying the characteristics of a well-written Dev Center article and the expectations around its creation.
---


The Dev Center contains a diverse collection of articles from both internal and external contributors across a variety of topics including platform reference material, getting started guides and general web application development tutorials. Having a standardized tone, style and structure ensures cohesion and consistency across this content. 

This guide quantifies the characteristics of a well-written Dev Center article and the shared expectations around its creation.

## Style

### Factual tone

Stylistically the tone of the Dev Center is both factual and academic. In standard how-to fashion, focus on the steps and rationale necessary to convey the subject matter in a clear, concise and confident manner. 

For instance, avoid using language such as "it seems", "probably" and other non-determinant phrases. Instead of:

> It seems like every SSL reseller packs their certs in a slightly different way with slightly different filenames.

Use:

> SSL resellers use a variety of naming conventions when packaging certs.

### Second-person narrative

The [second-person narrative](http://en.wikipedia.org/wiki/Narrative_mode#Second-person_view) uses "you" to address the reader and works well because it allows the use of the imperative voice, is concise and focuses on the reader<sup>[<a href="http://www.techwr-l.com/archives/0508/techwhirl-0508-00646.html#.TyqvS-NWpy8">1</a>]</sup>. Using "I" or "we" (a [first-person narrative](http://en.wikipedia.org/wiki/Narrative_mode#First-person_view)) is discouraged in the Dev Center.

Instead of relating the reader to your personal experiences:

> Based on our own experience managing remote assets we created the `foo` gem so you can transparently upload your static assets to S3 on deploy.

Succinctly present the concept based on its own merits:

> The `foo` gem reflects real world experience and gives you the ability to transparently upload static assets at deploy time.

### Tense

The present tense should be used when possible to convey temporal relevance. `was created`, `was built` and other `was ...` phrases are an indication of the unnecessary use of the past tense.

> The following guide was created to quantify the characteristics of a well-written Dev Center article.

Should be re-stated as:

> The following guide quantifies the characteristics of a well-written Dev Center article.

## Structure

### Introductory statement

Provide a brief overview of the problem or situation the content is intended to address as the article introduction. Compel readers to engage with the content by providing supporting motivation and a clear problem statement. Sell the problem or opportunity at hand.

For reference, here is the introductory statement from this very article.

> The Dev Center contains a diverse collection of articles from both internal and external contributors across a variety of topics including platform reference material, getting started guides and general web application development tutorials. Having a standardized tone, style and structure ensures cohesion and consistency across this content.

> This guide quantifies the characteristics of a well-written Dev Center article and the shared expectations around its creation.

### Title

Dev Center article titles should contain reference to the major language, framework and concepts being presented.

> Database-Driven Web Apps with Play!

Doing so clearly defines the purpose and ensures accurate recognition by readers viewing the article title within a list of other search results.

### Section titles

All section titles should use sentence-casing. For instance, use:

> This is a sentence case title

Instead of:

> This is Not a Sentence Case Title

>warning
>The H2 header (`##`) should be used for all top-level sections. These titles will be extracted to form the table of contents. No H1 headers (`#`) should be used within the article body.


### Sequence

Content should be structured in sequential fashion. Keep the work-flow as linear as possible to minimize the cognitive overhead. Provide clear article structure through the use of H2/3/4 section headers (`##`, `###`, etc…)

## Content

### Graphics

Images succinctly convey hard to understand concepts or step explanations and are great tools to provide a visual break from the monotony of reading a large block of text. Use them to emphasize important concepts and support the larger article structure.

>callout
>Hosting image files on S3, GitHub or similar service ensures the portability of the article throughout the authorship process.

```
![Image title](https://s3.amazonaws.com/bucket/image.jpg)
```

All images (and external assets in general) should be referenced via `https` to ensure readers securely accessing the Dev Center aren't presented with warnings.

### Step verification

If the article is a tutorial the author is responsible for executing the steps in the sequence mandated by the article. Utilizing a fresh environment will ensure symmetry between the writer and readers' environments.

Articles with sample applications should include complete instructions for running the application in a local environment and any required system dependencies.

### Minimize introduction of new tools

As part of creating technical Dev Center content it may be necessary to introduce new tooling, libraries and frameworks to efficiently solve a particular class of problems. *Introduce new tools with great forethought*.

Build the work-flow on top of easily understood and widely documented technologies. If unavoidable, consider structuring the content into multiple articles to establish the benefit of a new tool independently. Only if its presence speaks directly to the solving of the core problem should a new tool be presented within the article.

### Library/framework configuration

Applications running on Heroku should not store configuration settings within the code-base as files. To maintain consistency with the Heroku approach to application configuration all referenced frameworks should read settings from environment-based configuration variables.

This presents a consistent face to the tenet of [separation of config from code](http://www.12factor.net/config) and reinforces the clean contract between the platform and the application.

### Supporting applications

A deployable reference application is a great way to convey the totality of a particular approach and allows the writer to focus on the core steps associated with the broader solution being presented.

If such a companion application exists provide the following note after the article introduction.

<pre><code>
>note
>Source for this article's [reference application](https://github.com/xyz) is available on
>GitHub and can be seen running at
>[http://glowing-sun-4312.herokuapp.com](http://glowing-sun-4312.herokuapp.com)
</code></pre>

This will produce an obvious reference to the app early in the article and present users with the option to go directly to deploying.

>note
>Source for this article's [reference application](https://github.com/xyz) is available on
>GitHub and can be seen running at
>[http://glowing-sun-4312.herokuapp.com](http://glowing-sun-4312.herokuapp.com)

The GitHub project should contain README instructions for running the application both locally with Foreman/Procfile and on Heroku using standard add-on, deployment and scaling CLI commands.

## Formatting

### Markdown formatting

Articles should be written in [GitHub flavored markdown](http://github.github.com/github-flavored-markdown/). Here is a brief syntax example:

<pre><code>
## Section header

Here is some text, and a [link](http://heroku.com/).

![A descriptive image title](https://example.com/test.png)

### Sub header

* Bullet 1
* Bullet 2

And some output from a command:

```term
$ echo hi
hi
```

Now some code:

```ruby
puts "hello"
```  

And a table:

|  A  |  B  |
| --- | --- |
|  1  |  2  |
|  3  |  4  | 

</code></pre>

### Table of contents

A table of contents will automatically be generated by the Dev Center keyed off of top level H2 (`##`) elements.

The following header structure will result in a TOC with `Header 1` and `Header 2` elements.

    ## Header 1
    ### Header 1.1
    ## Header 2

>note
>Give thought to ensure the top-level header elements provide accurate structural 
>and navigational representation of the article.

### Inline notes

Notices or warnings of destructive or irreversible behavior should be displayed inline to reinforce their importance. Warnings are specified with the `warning` class.

<pre><code>
>warning
>This is a warning message
</code></pre>

And are rendered as:

>warning
>This is a warning 
>message


Similarly, notices of a less destructive nature that are still central to the reader's comprehension of the topic are denoted by the `note` class:

<pre><code>
>note
>This is an important notice
</code></pre>

and are rendered as:

>note
>This is an important notice

Callouts provide a mechanism to display relevant but non critical-path information, and are created by beginning each line of the called out text with a `>` character, and by having a line at the start with the word `callout`: 

<pre><code>
>callout
>Called out content
</code></pre>

> callout
> Called out content

## Code

As expected, code is a big part of Dev Center documentation. The Dev Center supports syntax highlighting for all languages supported on Heroku.

### Fenced code blocks

Code blocks should be clearly associated with the containing file for clarity with users that are unfamiliar with file structure of the framework being used.

The first line of fenced code blocks should begin with three back ticks <code>```</code> and an optional language identifier:

<pre><code>
```ruby
puts "hello world"
```
</code></pre>

Is rendered as:

```ruby
puts "hello world"
```

The following are the language identifiers for major languages on Heroku:

<table>
  <tr>
    <th>Language</th>
    <th>Identifier</th>
  </tr>
  <tr>
    <td>Ruby</td>
    <td style="text-align: left;"><code>ruby</code></td>
  </tr>
  <tr>
    <td>Node.js / JavaScript</td>
    <td style="text-align: left;"><code>javascript</code></td>
  </tr>
  <tr>
    <td>Python</td>
    <td style="text-align: left;"><code>python</code></td>
  </tr>
  <tr>
    <td>Java</td>
    <td style="text-align: left;"><code>java</code></td>
  </tr>
  <tr>
    <td>Scala</td>
    <td style="text-align: left;"><code>scala</code></td>
  </tr>
  <tr>
    <td>Clojure</td>
    <td style="text-align: left;"><code>clojure</code></td>
  </tr>
  <tr>
    <td>Objective-C</td>
    <td style="text-align: left;"><code>c</code></td>
  </tr>
  <tr>
    <td>PHP</td>
    <td style="text-align: left;"><code>php</code></td>
  </tr>
</table>

### Inline code

In-line filenames, commands and code should be surrounded by back-ticks. This will ensure \`file.rb\` is rendered as `file.rb`.

### Terminal commands

Terminal commands and output should use the <code>term</code> code block identifier. Precede terminal commands with a `$` prompt indicator.

<pre><code>
```term
$ heroku create
Creating blooming-water-4431... done, stack is cedar
http://blooming-water-4431.herokuapp.com/ | git@heroku.com:blooming-water-4431.git
Git remote heroku added
```
</code></pre>

Is rendered as:

```term
$ heroku create
Creating blooming-water-4431... done, stack is cedar
http://blooming-water-4431.herokuapp.com/ | git@heroku.com:blooming-water-4431.git
Git remote heroku added
```

Be sure to show sample output from commands to provide context and successful execution expectations. Output should be limited to the relevant portions so as not to overwhelm the reader and obscure the topically supportive nature of the example.

## Terminology

There are several common Heroku terms with ambiguous spellings. To maintain consistency please use the following representations:

* Add-ons: `Add-ons` or `add-ons` but never `addons`.  When dealing with the pronoun referring to our product/marketplace it's always capitalized (e.g., Heroku Add-ons, Add-ons Marketplace). When referring to an instance or a service, it's lowercase (e.g., installing an add-on).
* Dev Center: `Dev Center` but not `Devcenter` or `devcenter`

When naming apps, try to use `example` as the name of the application, leading to a Heroku hostname of `example.herokuapp.com`.  The app at [http://example.herokuapp.com](http://example.herokuapp.com) makes it clear that the reader is viewing an example.

When naming a domain, try to use `www.example.com` as an example domain name.

## Conclusion

This guide identifies the patterns present within successful articles and the collaborations that produce them. Following the framework presented here aids in the Dev Center authorship process and ensures a consistent experience for readers. 