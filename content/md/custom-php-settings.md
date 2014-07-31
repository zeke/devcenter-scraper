---
title: Customizing web server and runtime settings for PHP
slug: custom-php-settings
url: https://devcenter.heroku.com/articles/custom-php-settings
description: How to customize settings for the PHP runtime and web servers on Heroku.
---

PHP has a built-in web server that can be used to run on Heroku web [dynos](dynos), however this is not recommended. Instead you should be using a boot script which is referenced in your `Procfile` to launch a web server together with PHP. 

This article explains the different ways in which you can pass arguments to this boot script to customize settings for the PHP runtime and the web server software.

## How web servers are launched

During a deploy, Heroku will install the [heroku/heroku-buildpack-php](https://packagist.org/packages/heroku/heroku-buildpack-php) Composer package into your application as an additional dependency. This package contains boot scripts for launching PHP together with either Apache `heroku-php-apache2` or Nginx `heroku-php-nginx` and configuration files.

These boot scripts installed by the `heroku/heroku-buildpack-php` package are placed into `vendor/bin/` by Composer and will use configuration files from `vendor/heroku/heroku-buildpack-php/conf/` to launch PHP-FPM together with the web server of your choice.

> note
> Heroku recommends you maintain [dev/prod parity](http://12factor.net/dev-prod-parity) by running the same packages locally. You can use the package you are running in production as a development dependency by adding it to the `require-dev` section of your `composer.json`. Then you can run `foreman start` to launch a [local development environment](procfile#developing-locally-with-foreman) that will work seamlessly on your development machine, provided that you have the Apache or Nginx installed.

Once you've installed the `heroku/heroku-buildpack-php` package locally you can view the boot script help. The boot scripts accept various options and arguments that you can use to control settings related to PHP and the web server software. To get the detailed help you can execute the installed package with the `-h` flag. For Apache you would run:

```term
$ vendor/bin/heroku-php-apache2 -h
``` 

For Nginx the command is:

```term
$ vendor/bin/heroku-php-nginx -h
```

## Specifying which web server to use

In your `Procfile` you must specify which boot script to use and Heroku will launch the corresponding web server together with PHP on dyno startup.

For example, to use Nginx, your `Procfile` should contain:

```
web: vendor/bin/heroku-php-nginx
```

on Apache:

```
web: vendor/bin/heroku-php-apache2
```

> note
> Vendor binaries are usually installed to `vendor/bin` by Composer, but under some circumstances (e.g. when running a Symfony2 standard edition project), the location will be different. Run `$ composer config bin-dir` to find the right location.

## Default behavior

Heroku will launch a [FastCGI Process Manager](http://docs.php.net/fpm) (PHP-FPM) application server. This application server will get traffic from a web server, either [Apache](http://httpd.apache.org) or [Nginx](http://nginx.org). The web server will [bind to the port in the `$PORT` environment variable](dynos#web-dynos). HTTP requests will come in, they will be received by the web server (Apache or Nginx) and passed to the application server (PHP-FPM) by default for any URLs ending in `.php`. The configuration for these web servers can be customized.

Depending on the web server you chose (Apache or Nginx) each will come with different defaults. You can find them directly below.

### Apache defaults

Apache uses a [Virtual Host](http://httpd.apache.org/docs/2.4/vhosts/) that responds to all hostnames. The document root is set up as a [`<Directory>`](http://httpd.apache.org/docs/2.4/mod/core.html#directory) reachable without access limitations and [`AllowOverride All`](http://httpd.apache.org/docs/2.4/mod/core.html#allowoverride) set to enable the use of [`.htaccess`](http://httpd.apache.org/docs/2.4/howto/htaccess.html) files. Any request to a URL ending on `.php` will be rewritten to PHP-FPM using a proxy endpoint  named `fcgi://heroku-fcgi` via [mod_proxy_fcgi](https://httpd.apache.org/docs/2.4/mod/mod_proxy_fcgi.html). The `DirectoryIndex` directive is set to "`index.php index.html index.html`".

### Nginx defaults

Nginx uses a [`server`](http://nginx.org/en/docs/http/ngx_http_core_module.html#server) that responds to all hostnames. The document root has no access limitations. Any request to a URL containing `.php` will be be rendered by [`fastcgi_pass`](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_pass) with PHP-FPM using an upstream called "heroku-fcgi" after a [`try_files`](http://nginx.org/en/docs/http/ngx_http_core_module.html#try_files) call on the entire URL. The [`index`](http://nginx.org/en/docs/http/ngx_http_index_module.html#index) directive is set to "`index.php index.html index.html`"

## Setting the document root

The document root is the directory where the application will begin looking for your `.php` files. To change the document root, you may supply the path to the directory (relative to your application root directory) as the argument to the `heroku-php-apache2` or `heroku-php-nginx` boot script without having to change a configuration file.

For example, if you're using Apache and your document root should be set to the `public` directory of your application, your `Procfile` would look like this:

```
web: vendor/bin/heroku-php-apache2 public/
```

## Web server settings

You can configure Apache or Nginx, by providing your own site-specific settings (recommended). You can also replace the entire configuration for the host, this can be dangerous and should not be attempted unless you wish to maintain these settings manually. Replacing the configuration for the host is possible, but we cannot support your individual configuration choices.

### Apache

#### Using `.htaccess`

You may use regular [.htaccess files](http://httpd.apache.org/docs/2.4/howto/htaccess.html) to customize the behavior of the Apache HTTP server. The `AllowOverride` option for the document root is set to `all`, which means you can use any configuration directive allowed in `.htaccess` [contexts](http://httpd.apache.org/docs/2.4/mod/directive-dict.html#Context).

This is the recommended approach for customizing Apache settings, as it does not require the use of a custom (and potentially error-prone) config include.

#### Using a custom application level Apache configuration

Inside the default server level configuration file Heroku uses during the startup of Apache, it includes a very simple [default application level config](https://github.com/heroku/heroku-buildpack-php/blob/beta/conf/apache2/default_include.conf) file. You can replace this file with your custom configuration. For example, to configure Apache to use some rewrite rules for your Symfony2 application, you'd create a `apache_app.conf` inside your application's root directory with the following contents:

```
RewriteEngine On

RewriteCond %{REQUEST_URI}::$1 ^(/.+)/(.*)::\2$
RewriteRule ^(.*) - [E=BASE:%1]

RewriteCond %{ENV:REDIRECT_STATUS} ^$
RewriteRule ^app\.php(/(.*)|$) %{ENV:BASE}/$2 [R=301,L]

RewriteCond %{REQUEST_FILENAME} -f
RewriteRule .? - [L]

RewriteRule .? %{ENV:BASE}/app.php [L]
```

> note
> In this particular case, you may also put the corresponding rewrite rules into a `.htaccess` file. In fact, the entire snippet was copied from the [Symfony Standard Edition's `.htaccess` file](https://github.com/symfony/symfony-standard/blob/master/web/.htaccess)

Then, you can use the `-C` argument of the boot script to tell Heroku to include this file for you:

```
web: vendor/bin/heroku-php-apache2 -C apache_app.conf
```

> callout
> To understand in which context this configuration file will be included, we recommend you take a look at the [server-level configuration](https://github.com/heroku/heroku-buildpack-php/blob/beta/conf/apache2/heroku.conf) for Apache that Heroku loads right after the system-wide configuration file during startup.



### Nginx

#### Using a custom application level Nginx configuration

Inside the default server level configuration file Heroku uses during the startup of Nginx, it includes a very simple [default application level config](https://github.com/heroku/heroku-buildpack-php/blob/beta/conf/nginx/default_include.conf) file. You can replace this file with your custom configuration. For example, to [configure Nginx to use some rewrite rules for your Symfony2 application](http://symfony.com/doc/current/cookbook/configuration/web_server_configuration.html#nginx), you'd create a `nginx_app.conf` inside your application's root directory with the following contents:

```
location / {
    # try to serve file directly, fallback to rewrite
    try_files $uri @rewriteapp;
}

location @rewriteapp {
    # rewrite all to app.php
    rewrite ^(.*)$ /app.php/$1 last;
}

location ~ ^/(app|app_dev|config)\.php(/|$) {
    fastcgi_pass heroku-fcgi;
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param HTTPS off;
}
```

> note
> When using `fastcgi_pass`, use "`heroku-fcgi`" as the destination. It's an [upstream group](http://nginx.org/en/docs/http/ngx_http_upstream_module.html) and configured so that your FastCGI requests will always be handed to the correct backend process.

After you have created a new default configuration you can tell your application to start with this configuration by using the `-C` argument of the boot script. 

For example if you've written your own `nginx_app.conf` you can modify your `Procfile` to use this configuration file:

```
web: vendor/bin/heroku-php-nginx -C nginx_app.conf
```

> callout
> To understand in which context this configuration file will be included, we recommend you take a look at the [server-level configuration](https://github.com/heroku/heroku-buildpack-php/blob/beta/conf/nginx/heroku.conf.php) for Nginx that Heroku loads right after the system-wide configuration file during startup.

## PHP runtime settings

### INI settings

PHP allows you to change settings via directives in a [`php.ini`](http://docs.php.net/en/ini.list.php) file. 
Heroku allows you to use [`ini_set`](http://docs.php.net/ini_set), as well as a per-directory `.user.ini` file. While not recommended you can also  replace `php.ini` entirely.

> note
> In addition to its standard `php.ini` configuration file, Heroku will also read per-extension `.ini` configs from an internal directory used by Heroku on startup. This configuration is used to enable non-standard extensions as required in your `composer.json`. This behavior cannot be changed.

#### `.user.ini` files (recommended)

PHP will read settings from any `.user.ini` file in the same directory as the `.php` file that is being served. PHP will also read settings from a `.user.ini` file in any parent directory up to the document root. Heroku recommends using `.user.ini` files to customize PHP settings. Please refer to the [section on `.user.ini` files in the PHP manual](http://docs.php.net/en/configuration.file.per-user.php) to learn more about this feature and which settings you can control through it.

> note
> There is practically no performance penalty associated with this method, as the `user_ini.cache_ttl` setting is set high enough for PHP to only scan for this file once during the lifetime of a dyno. We recommend setting this to 24 hours.
