---
title: PostGIS
slug: postgis
url: https://devcenter.heroku.com/articles/postgis
description: How to use PostGIS, available on Heroku Postgres, from Ruby on Rails and Django applications.
---

[PostGIS](http://postgis.org/) is available in public beta. The beta is available on all Production tier databases and currently supports PostGIS version 2.0. It is not available on the Dev or Basic Starter tier plans. PostGIS is only available with Postgres 9.2 databases provisioned after April 20, 2013 and all Postgres 9.3 database. To enable PostGIS once connected to your PostgreSQL 9.2 database run:

```sql
CREATE EXTENSION postgis;
```

## Setting up PostGIS with Rails

To use PostgreSQL as your database in Ruby applications you will need to include the `activerecord-postgis-adapter` gem in your Gemfile.

>callout
>To fully take advantage of PostGIS with Rails on Heroku you'll need configure your app with a custom buildpack which includes the appropriate system dependencies. [This buildpack](https://github.com/cyberdelia/heroku-geo-buildpack/) includes that support. 

```ruby
gem 'activerecord-postgis-adapter'
```

Run `bundle install` to download and resolve all dependencies. For more information on getting setup with `activerecord-postgis-adapter` you can visit [their docs](http://rdoc.info/gems/activerecord-postgis-adapter). Once you've installed the gem, configure ActiveRecord to read the database configuration from DATABASE_URL, but modify the adapter to `postgis`:

```ruby
# in config/application.rb, before the application loads
class ActiveRecordOverrideRailtie < Rails::Railtie
  initializer "active_record.initialize_database.override" do |app|

    ActiveSupport.on_load(:active_record) do
      if url = ENV['DATABASE_URL']
        ActiveRecord::Base.connection_pool.disconnect!
        parsed_url = URI.parse(url)
        config =  {
          adapter:             'postgis',
          host:                parsed_url.host,
          encoding:            'unicode',
          database:            parsed_url.path.split("/")[-1],
          port:                parsed_url.port,
          username:            parsed_url.user,
          password:            parsed_url.password
        }
        establish_connection(config)
      end
    end
  end
end
```

Additionally, if unicorn or any other process forking code is used where the connection is re-established, make sure to override the adapter to `postgis` as well. For example:


```ruby
# unicorn.rb
after_fork do |server, worker| 
  if defined?(ActiveRecord::Base) 
    config = Rails.application.config.database_configuration[Rails.env] 
    config['adapter'] = 'postgis' 
    ActiveRecord::Base.establish_connection(config)
  end 
end
```

## GeoDjango Setup 

Install the dj-database-url package using pip.

>callout
>To fully take advantage of GeoDjango on Heroku you'll need configure your app with a custom buildpack which includes the appropriate system dependencies. [This buildpack](https://github.com/cyberdelia/heroku-geo-buildpack/) includes that support. 

```terminal
$ pip install dj-database-url
$ pip freeze > requirements.txt
```

Then add the following to the bottom of settings.py:

```python
import dj_database_url
DATABASES['default'] =  dj_database_url.config()
DATABASES['default']['ENGINE'] = 'django.contrib.gis.db.backends.postgis'
```

This will parse the values of the DATABASE_URL environment variable and convert them to something Django can understand then set the engine to take advantage of PostGIS. 