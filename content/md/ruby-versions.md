---
title: Specifying a Ruby Version
slug: ruby-versions
url: https://devcenter.heroku.com/articles/ruby-versions
description: Specifying a particular version of Ruby via your app's Gemfile.
---

> note
> If you have questions about Ruby on Heroku, consider discussing it in the [Ruby on Heroku forums](https://discussion.heroku.com/category/ruby).

## Selecting a version of Ruby

> callout
> You'll need to install `1.2.0` of bundler to use the `ruby` keyword.

> callout
> See a complete list of supported <a href="https://devcenter.heroku.com/articles/ruby-support#ruby-versions">Ruby versions</a>

You can use the `ruby` keyword in your app's `Gemfile` to specify a particular version of Ruby.

```ruby
source "https://rubygems.org"
ruby "1.9.3"
# ...
```

When you commit and push to Heroku you'll see that Ruby `1.9.3` is detected:

```
-----> Heroku receiving push
-----> Ruby/Rack app detected
-----> Using Ruby version: 1.9.3
-----> Installing dependencies using Bundler version 1.2.1
...
```

For specifying non MRI ruby engines, you'll need to use the `:engine` and `:engine_version` options. You can specify JRuby by using the following line:

```ruby
ruby "1.9.3", :engine => "jruby", :engine_version => "1.7.8"
```

Please see [Ruby Support](ruby-support#ruby-versions) for a list of available versions.

> warning
> If you were previously using `RUBY_VERSION` to select a version of Ruby, please follow the instructions above to specify your desired version of Ruby using Bundler.

## Specifying a Ruby version via the environment

Gemfiles are actually just Ruby code, so you can also specify your Ruby version in the environment. For example:

```ruby
ruby ENV['CUSTOM_RUBY_VERSION'] || '2.0.0'
```

Would let you specify a Ruby version in the `CUSTOM_RUBY_VERSION` environment variable, or default to 2.0.0 if it's not set. This is handy if you are running your app through a continuous integration tool and want to ensure it checks your codebase against other versions of Ruby, but restrict it to a certain version when deployed to Heroku.

> warning
> Changing environment variables does not recompile your app. For a Ruby version change to take effect through this method, you should force a restart of your app with `heroku restart` after setting the environment variable.

## Troubleshooting

### Migration
Applications that migrate to a non-default version of Ruby should have `bin` be the first entry in their `PATH` config var. This var's current value can be determined using `heroku config`.

```term
$ heroku config -s | grep PATH
PATH=vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin
```

If absent or not the first entry, add `bin:` to the config with `heroku config:set`.

```term
$ heroku config:set PATH=bin:vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin
```

If the `PATH` is set correctly you will see the expected version using `heroku run`:

```term
$ heroku run "ruby -v"
Running `ruby -v` attached to terminal... up, run.1
ruby 1.9.2p290 (2011-07-09 revision 32553) [x86_64-linux]
```

If the `PATH` is not setup correctly, you might see this error:

```
Your Ruby version is 1.9.2, but your Gemfile specified 1.9.3
```

### Bundler

If you're using a Bundler `1.1.4` or lower you'll see the following error:

```
undefined method `ruby' for #<Bundler::Dsl:0x0000000250acb0> (NoMethodError)
```

You'll need to install bundler `1.2.0` or greater to use the `ruby` keyword.

```term
$ gem install bundler
```
 