---
title: Using Sass on Bamboo
slug: using-sass
url: https://devcenter.heroku.com/articles/using-sass
description: Configure your Rails application to get Sass working on the Bamboo stack.
---

<div class="deprecated" markdown="1">This article applies to apps on the [Bamboo](bamboo) stack.  For the most recent stack, [Cedar](cedar), see [Rails 3.1 on Heroku Cedar](rails3x-asset-pipeline-cedar).</div>

If you’d like to use Sass in your Heroku app on the Bamboo stack, you’ll need to do some configuration - by default, Sass generates CSS files in `public/stylesheets`, which isn’t writable on Heroku.

## Gems

The first step is to require the gem that you’ll need. In your `Gemfile`, add the following:

    :::ruby
    gem 'sass'

## Configuration
<div class="callout" markdown="1">
Please note that if you use this technique, all stylesheet requests will be redirected to `tmp` – which means that any CSS files you leave in `public/stylesheets` will be ignored.
</div>

Next, you’ll need to direct Sass to save the generated files to `tmp` and tell Rails how to access them. In `config/initializers/sass.rb`:

    :::ruby
    Sass::Plugin.options.merge!(
      :template_location => 'public/stylesheets/sass',
      :css_location => 'tmp/stylesheets'
    )

    Rails.configuration.middleware.delete('Sass::Plugin::Rack')
    Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Sass::Plugin::Rack')

    Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Rack::Static',
        :urls => ['/stylesheets'],
        :root => "#{Rails.root}/tmp")

## Start using Sass

Once your configuration is complete, you’re free to start using Sass. For detailed instructions, check out the [Sass documentation](http://sass-lang.com/).
