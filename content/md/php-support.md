---
title: Heroku PHP Support
slug: php-support
url: https://devcenter.heroku.com/articles/php-support
description: Heroku support for PHP.
---

>warning
>This article describes a [beta feature](heroku-beta-features). Functionality may change prior to general availability.

This document describes the general behavior of the [Heroku Cedar stack](cedar) as it relates to the recognition and execution of PHP applications.

## Activation

The Heroku PHP Support will be applied to applications only when the application has a file named `composer.json` in the root directory. Even if an application has no [Composer](http://getcomposer.org) dependencies, it must include an **empty** `composer.json` in order to be recognized as a PHP application.

When Heroku recognizes a PHP application, it will respond accordingly during a push:

```term
$ git push heroku master
-----> PHP app detected
```

## PHP runtimes

Heroku makes a number of different runtimes available.  You can configure your app to select a particular runtime. 

### Supported runtimes

Heroku’s PHP support extend to apps using **PHP 5.5** (5.5.14, 64-bit), which is also the default PHP runtime for apps. The PHP runtime has [OPcache](http://docs.php.net/opcache) enabled for improved performance, with a configuration optimized for Heroku.

### Available runtimes

An additional, unsupported runtime is available - HipHop VM (**HHVM**) (3.1.0, 64-bit). However, we only currently endorse and support the use of PHP 5.5.  

This runtime can be enabled via `composer.json`.

> note
> Specify PHP or HHVM runtime versions other than exactly "5.5.14" and "3.1.0", respectively, will currently generate a warning which can be ignored.

### Selecting a runtime

You may select the runtime to use via [Composer Platform Packages](https://getcomposer.org/doc/02-libraries.md#platform-packages) in `composer.json`. Upon deploy, Heroku will confirm the request:

```
-----> Detected request for PHP 5.5.14 in composer.json.
```

If you specify an unknown or unsupported version, Heroku will default to the latest version and inform you of the problem:

```
-----> Fetching custom git buildpack... done
-----> PHP app detected

 !     WARNING: Your composer.json requires an unknown HHVM version.
       Defaulting to HHVM 3.1.0; install may fail!
```

#### PHP

Specify "`php`" as a dependency in the `require` section of your `composer.json` to use PHP as the runtime:

```json
{
  "require": {
    "php": "~5.5.12"
  }
}
```

> note
> Currently, using a lenient selector such as `~5.5.0` will generate a warning which can be ignored as long as the selected range includes PHP 5.5.14.

#### HHVM

> warning
> Support for HHVM is highly [experimental](heroku-beta-features). Functionality may change prior to general availability.

Specify "`hhvm`" as a dependency in the `require` section of your `composer.json` to use HHVM as the runtime:

```json
{
  "require": {
    "hhvm": "~3.1.0"
  }
}
```

> note
> Specifying an exact version like this may not be practical in all circumstances. Currently, using a more lenient selector such as `~3.1` will generate a warning which can be ignored as long as the selected range includes HHVM 3.1.0.

> warning
> If you specify `hhvm` as a dependency in your project, Composer will check for it during `composer update` or `composer install` commands. This means that you need HHVM installed on the computer where you run the command, and you need to run Composer using HHVM (e.g. by running ```hhvm `which composer` update``` or ```hhvm composer.phar update```) for Composer to successfully finish the operation and write a `composer.lock` lock file.

### Supported versions

#### PHP

* 5.5.11
* 5.5.12
* 5.5.13
* 5.5.14 (default)

#### HHVM

* 3.0.1
* 3.1.0 (default)

### Upgrades

If you deploy an application that does not declare a runtime version dependency, the then-latest version of PHP 5.5 or HHVM 3 will be used. Your application will be upgraded to more recent versions of PHP 5.5 (e.g. 5.5.15) or HHVM (e.g. 3.2.0) if available automatically upon the next deploy, but you will never automatically be upgraded to PHP 5.6 or HHVM 4.0.

## Extensions

### PHP 5.5

The following built-in extensions are enabled automatically on Heroku (this list does not include extensions that PHP enables by default, such as [DOM](http://docs.php.net/dom), [JSON](http://docs.php.net/json), [PCRE](http://docs.php.net/pcre) or [PDO](http://docs.php.net/pdo)):

* [Bzip2](http://docs.php.net/bzip2)
* [cURL](http://docs.php.net/curl)
* [FPM](http://docs.php.net/fpm)
* [mcrypt](http://docs.php.net/mcrypt)
* [MySQL (PDO)](http://docs.php.net/pdo_mysql) (uses [mysqlnd](http://docs.php.net/mysqlnd))
* [MySQLi](http://docs.php.net/mysqli) (uses [mysqlnd](http://docs.php.net/mysqlnd))
* [OPcache](http://docs.php.net/opcache)
* [OpenSSL](http://docs.php.net/openssl)
* [PostgreSQL](http://docs.php.net/pgsql)
* [PostgreSQL (PDO)](http://docs.php.net/pdo_pgsql)
* [Readline](http://docs.php.net/readline)
* [Sockets](http://docs.php.net/sockets)
* [Zip](http://docs.php.net/zip)
* [Zlib](http://docs.php.net/zlib)

The following built-in extensions have been built "shared" and can be enabled through `composer.json` (internal identifier names given in parentheses):

* [BCMath](http://docs.php.net/bcmath) (`bcmath`)
* [Exif](http://docs.php.net/exif) (`exif`)
* [GD](http://docs.php.net/gd) (`gd`; with PNG, JPEG and FreeType support)
* [gettext](http://docs.php.net/gettext) (`gettext`)
* [intl](http://docs.php.net/intl) (`intl`)
* [mbstring](http://docs.php.net/mbstring) (`mbstring`)
* [MySQL](http://docs.php.net/book.mysql) (`mysql`; note that this extension is deprecated since PHP 5.5, please migrate to MySQLi or PDO)
* [PCNTL](http://docs.php.net/pcntl) (`pcntl`)
* [Shmop](http://docs.php.net/shmop) (`shmop`)
* [SOAP](http://docs.php.net/soap) (`soap`)
* [SQLite3](http://docs.php.net/sqlite3) (`sqlite3`)
* [SQLite (PDO)](http://docs.php.net/pdo_sqlite) (`pdo_sqlite`)
* [XMLRPC](http://docs.php.net/xmlrpc) (`xmlrpc`)
* [XSL](http://docs.php.net/xsl) (`xsl`)

The following third-party extensions can be enabled through `composer.json` (internal identifier names given in parentheses):

* [APCu](http://pecl.php.net/package/apcu) (`apcu`)
* [ImageMagick](http://docs.php.net/imagick) (`imagick`)
* [memcached](http://docs.php.net/memcached) (`memcached`; built against a version of *libmemcached* with [SASL](http://en.wikipedia.org/wiki/Simple_Authentication_and_Security_Layer) support)
* [MongoDB](http://docs.php.net/mongo) (`mongo`)
* [New Relic](http://newrelic.com/php) (`newrelic`; will also be enabled automatically when the [New Relic Add-On](https://addons.heroku.com/newrelic) is detected)
* [PHPRedis](http://pecl.php.net/package/redis) (`redis`)

### HHVM

HHVM is built with its standard set of extensions. Custom extensions for HHVM are not currently supported.

### Using optional extensions

You may declare any optional extensions you want to use via `composer.json` using [Composer Platform Packages](https://getcomposer.org/doc/02-libraries.md#platform-packages); simply prefix any of the identifiers in the list of extensions above with "`ext-`" in the package name.

For example, to enable extensions for using *bcmath*, *Memcached*, *MongoDB* and *XSL*:

```javascript
{
    "require": {
        "ext-bcmath": "*",
        "ext-memcached": "*",
        "ext-mongo": "*",
        "ext-xsl": "*"
    }
}
```

> warning
> It is strongly recommended that you use "`*`" as the version selector when specifying extensions, as their version numbers can be extremely inconsistent (most of them report their version as "0") and Heroku will sometimes update extensions outside the regular PHP update cycles.

Upon the next push, Heroku will enable the corresponding PHP extensions:

```term
-----> PHP app detected
-----> Setting up runtime environment...
       - PHP 5.5.14
       - Apache 2.4.9
       - Nginx 1.4.6
-----> Installing PHP extensions:
       - opcache (automatic; bundled, using 'ext-opcache.ini')
       - mongo (composer.json; downloaded, using 'ext-mongo.ini')
       - xsl (composer.json; bundled)
       - bcmath (composer.json; bundled)
       - memcached (composer.json; downloaded, using 'ext-memcached.ini')
```

## Customizing settings

### PHP

Any `.user.ini` file that is placed into a project [according to the instructions in the PHP manual](http://docs.php.net/manual/en/configuration.file.per-user.php) will be loaded after the main `php.ini`. You can use these to set any directive permitted in `PHP_INI_ALL`, `PHP_INI_USER` and `PHP_INI_PERDIR` contexts.

For additional details on this and other ways of customizing settings for the PHP runtime, please refer to the [corresponding Dev Center article](custom-php-settings).

### HHVM

For details on ways of customizing settings for the HHVM runtime, please refer to the [corresponding Dev Center article](custom-php-settings).

## Build behavior

The following command is run during a deploy to resolve dependencies:

```term
$ composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction
```

The installed version of Composer will be printed for your reference before installation begins.

> note
> Composer will always be `self-update`d to the latest version before this command is run.

Composer's cache directory is preserved between pushes to speed up package installation.

### Custom Composer versions

If the application contains a `composer.phar` in the root directory, then that executable will be used instead of the version provided by Heroku.

> warning
> Running your own version of Composer is not recommended. If you use this feature, you will need to make sure that your version of Composer is up to date. Heroku will not run `composer self-update` before.

### Custom GitHub OAuth tokens

GitHub's API is subject to rate limits for anonymous requests. If the limit is hit, Composer will fall back to source-based installs instead of distribution tarballs, which will slow down builds.

Using a [personal OAuth token](https://github.com/blog/1509-personal-api-tokens) raises the limit significantly. To use such a token on Heroku, follow these steps:

1. [Create a new Token](https://github.com/settings/tokens/new) (the `public_repo` and, if you need, `repo` scopes will suffice)
1. Copy the token for use in the next command
1. `$ heroku config:set COMPOSER_GITHUB_OAUTH_TOKEN=YOURTOKEN` (replacing "YOURTOKEN" with the actual token from the previous step, of course).

Now, pushes to Heroku will use your token during `composer install`, and Heroku will confirm its usage:

```
-----> Installing dependencies...
       NOTICE: Using custom GitHub OAuth token in $COMPOSER_GITHUB_OAUTH_TOKEN
```

For more information, you may also refer to the [troubleshooting section](https://getcomposer.org/doc/articles/troubleshooting.md#api-rate-limit-and-oauth-tokens) in the Composer documentation.

## Web servers

Heroku supports **[Apache](http://httpd.apache.org) 2.4** (2.4.9) and **[Nginx](http://nginx.org) 1.4** (1.4.6) as dedicated Web servers. For testing purposes, users may of course also use PHP's built-in Web server, although this is not recommended.

In the absence of a `Procfile` entry for the "web" dyno type, the Apache Web server will be used together with the PHP or HHVM runtime.

### Apache

Apache interfaces with PHP-FPM or HHVM via FastCGI using `mod_proxy_fcgi`.

To start Apache together with PHP-FPM and all the correct settings, use the `heroku-php-apache2` script in the Composer vendor `bin` dir (usually `vendor/bin`):

```
web: vendor/bin/heroku-php-apache2
```

> note
> Vendor binaries are usually installed to `vendor/bin` by Composer, but under some circumstances (e.g. when running a Symfony2 standard edition project), the location will be different. Run `composer config bin-dir` to find the right location.

To run HHVM instead, use the `heroku-hhvm-apache2` script:

```
web: vendor/bin/heroku-hhvm-apache2
```

By default, the root folder of your project will be used as the document root. To use a sub-directory, you may pass the name of a sub-folder as the argument to the boot script, e.g. "public_html":

```
web: vendor/bin/heroku-php-apache2 public_html
```

You can use regular `.htaccess` files to customize Apache's behavior, e.g. for [URL rewriting](http://httpd.apache.org/docs/2.4/rewrite/). For additional details on this and other options to customize settings for Apache, please refer to the [corresponding Dev Center article](custom-php-settings).

All other 

### Nginx

Nginx interfaces with PHP-FPM via FastCGI.

To start Nginx together with PHP-FPM and all the correct settings, use the `heroku-php-nginx` script in the Composer vendor `bin` dir (usually `vendor/bin`):

```
web: vendor/bin/heroku-php-nginx
```

> note
> Vendor binaries are usually installed to `vendor/bin` by Composer, but under some circumstances (e.g. when running a Symfony2 standard edition project), the location will be different. Run `composer config bin-dir` to find the right location.

To run HHVM instead, use the `heroku-hhvm-nginx` script:

```
web: vendor/bin/heroku-hhvm-nginx
```

By default, the root folder of your project will be used as the document root. To use a sub-directory, you may pass the name of a sub-folder as the argument to the boot script, e.g. "public_html":

```
web: vendor/bin/heroku-php-nginx public_html
```

For additional details on different ways of customizing settings for Nginx, please refer to the [corresponding Dev Center article](custom-php-settings).

### PHP Built-in Web server

For testing purposes, you may start [PHP's built-in Web server](http://docs.php.net/manual/en/features.commandline.webserver.php) by using `php -S 0.0.0.0:$PORT` as the entry for "web" in your `Procfile`:

```
web: php -S 0.0.0.0:$PORT
```

> note
> The `Procfile` must contain `$PORT` in the line shown above. It's used by Heroku at runtime to dynamically bind the web server instance to the correct port for the dyno.

> note
> It is important to bind to all interfaces using `0.0.0.0`, otherwise Heroku's [routing](http-routing) won't be able to forward requests to the web server!

You may also pass an alternative document root or use a so called router script to process requests. For details, please refer to the documentation for the built-in Web server.