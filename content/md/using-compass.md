---
title: Using Compass on Heroku Bamboo
slug: using-compass
url: https://devcenter.heroku.com/articles/using-compass
description: Use the Compass CSS framework on Rails 3.0 applications running on the Heroku Bamboo stack.
---

> warning
> This article applies to apps using Compass with Rails 3.0 on the [Bamboo](bamboo) stack. They will not work for other versions of Rails. On the most recent stack, [Cedar](cedar), this configuration is unnecessary.

> callout
> [Compass](http://compass-style.org/) is a popular framework for creating stylesheets. With Compass, you write [SASS](http://sass-lang.com/) and can easily pull in useful CSS frameworks like [Blueprint](http://blueprintcss.org/).

If you'd like to use Compass in your Heroku app, you'll need to do some configuration - by default, Compass generates CSS files in `public/stylesheets`, which [isn't writable](read-only-filesystem) on Heroku. 

## Gems

The first step is to require the gems that you'll need. In your `Gemfile`, add the following:

> callout
> You may want to include other gems to get specific functionality. The `compass-52-plugin` gem enables the [52 CSS framework](http://www.52framework.com/), for instance.

```ruby
gem 'compass'
gem 'haml' # for SASS
```

## Configuration

Next, you'll need to direct Compass to save the generated files to `tmp`. In `config/compass.rb`:

```ruby
project_type = :rails
http_path    = '/'
css_dir      = 'tmp/stylesheets'
sass_dir     = 'app/views/stylesheets'
```

> callout
> Please note that if you use this technique, *all* stylesheet requests will be redirected to `tmp` -- which means that any CSS files you leave in `public/stylesheets` will be ignored.

And finally, you'll need to make sure that `tmp/stylesheets` exists when your app starts running and that your stylesheets are served as static assets. For these two tasks, you'll need to add the following to `config/initializers/compass.rb`:

```ruby
require 'fileutils'
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets"))

Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Rack::Static',
    :urls => ['/stylesheets'],
    :root => "#{Rails.root}/tmp")
```

## Start using Compass

Once your configuration is complete, you're free to start using Compass. For detailed instructions, check out the [Compass documentation](http://compass-style.org/docs/).