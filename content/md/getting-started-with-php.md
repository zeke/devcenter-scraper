---
title: Getting Started with PHP on Heroku
slug: getting-started-with-php
url: https://devcenter.heroku.com/articles/getting-started-with-php
description: This quickstart will get you going with a PHP application. For general information on how to develop and architect apps for use on Heroku, see Architecting Applications for Heroku.
---

This guide will get you going with a [PHP](http://php.net/) application. For general information on how to develop and architect apps for use on Heroku, see [Architecting Applications for Heroku](https://devcenter.heroku.com/articles/architecting-apps).

## Prerequisites

* Basic PHP knowledge
* A Heroku user account. [Signup is free and instant.](https://signup.heroku.com/signup/dc)
* A PHP project with a `composer.json` file describing the project's dependencies. If you are not using Composer, a completely empty `composer.json` file will suffice.

> note
> Heroku uses [Composer](http://getcomposer.org) for dependency management in PHP projects. For this reason, including a `composer.json` file will indicate to Heroku that your application is written in PHP.

## Local workstation setup

First, install the Heroku Toolbelt on your local workstation.  

<a class="toolbelt" href="https://toolbelt.heroku.com/">Install the Heroku Toolbelt</a>

This ensures that you have access to the [Heroku command-line client](/categories/command-line), Foreman, and the Git revision control system.

Once installed, you can use the `heroku` command from your command shell.  Log in using the email address and password you used when creating your Heroku account:

```term
$ heroku login
Enter your Heroku credentials.
Email: dzuelke@example.com
Password:
Could not find an existing public key.
Would you like to generate one? [Yn]
Generating new SSH public key.
Uploading ssh public key /Users/dzuelke/.ssh/id_rsa.pub
```

Press enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on.

## A Hello World application

You may be starting from an existing application. If not, here is a basic application to deploy that will get you going.

Create a directory for your app and change to it:

```term
$ mkdir hello_heroku_php
$ cd hello_heroku_php
```

Now, create an `index.php` inside this folder with the following contents:

```php
<?php

echo "Hello World!";

?>
```

In addition, you need to give Heroku an indication that this application is a PHP application. To do this, create an empty file called `composer.json`. On a Unix system you can create this file like so::

```term
$ touch composer.json
```

Your application is now ready to deploy to Heroku. The next steps are to put this application into a git repository, followed by pushing it to Heroku.

### Create a Git repository

Initialize a repository, add the two files, and commit them:

```term
$ git init
Initialized empty Git repository in ~/hello_heroku_php/.git/
$ git add .
$ git commit -m "Initial import of Hello Heroku"
[master (root-commit) 06ba0a7] Initial import of Hello Heroku
 2 files changed, 5 insertions(+)
 create mode 100644 composer.json
 create mode 100644 index.php
```

This creates a new git repository and commits `index.php` and `composer.json` into the "master" branch.

### Create a Heroku application

Create a new Heroku application:

```term
$ heroku create
Creating polar-chamber-3014... done, stack is cedar
http://polar-chamber-3014.herokuapp.com/ | git@heroku.com:polar-chamber-3014.git
Git remote heroku added
```

> note
> You will, of course, see a different [auto-generated application name](creating-apps#creating-an-app-without-a-name) (and thus different URLs) when running the `heroku create` command, not "polar-chamber-3014".

### Deploy to Heroku

The `heroku create` command registered a new application with Heroku, and added a git remote called `heroku` to your local repository. You may be familiar with other remotes such as `origin` or `upstream`. A remote specifies a git server location under a name. 

Now deploy the application by pushing the master branch to the heroku remote using the git command:

> note
> You may see a message such as the following when you push to Heroku for the very first time:
>
> ```
> The authenticity of host 'heroku.com (50.19.85.132)' can't be established.
> RSA key fingerprint is 8b:48:5e:67:0e:c9:16:47:32:f2:87:0c:1f:c8:60:ad.
> Are you sure you want to continue connecting (yes/no)?
> ```
>
> In this case, you need to confirm by typing "`yes`" and hitting return - ideally after you've [verified that the RSA key fingerprint is correct](git-repository-ssh-fingerprints).

```term
$ git push heroku master
Initializing repository, done.
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (4/4), 306 bytes | 0 bytes/s, done.
Total 4 (delta 0), reused 0 (delta 0)

-----> PHP app detected
-----> WARNING!
       Your composer.json is completely empty, please consider putting at least "{}" in there to make it valid JSON.
-----> Setting up runtime environment...
       - PHP 5.5.11
       - Apache 2.4.9
       - Nginx 1.4.6
-----> Building runtime environment...
-----> Discovering process types
       Procfile declares types -> (none)
       Default types for PHP   -> web

-----> Compressing... done, 60.7MB
-----> Launching... done, v4
       http://polar-chamber-3014.herokuapp.com/ deployed to Heroku

To git@heroku.com:polar-chamber-3014.git
 * [new branch]      master -> master
```

> note
> You can safely ignore the warning about an empty `composer.json` for now. We will fix that in just a moment.

You can now open your browser, either by manually pointing it to the URL `heroku create` gave you, or by using the Heroku Toolbelt:

```term
$ heroku open
Opening polar-chamber-3014... done
```

Et voilà! You should be seeing "Hello World!" in your browser.

### Process and dyno tuning

When Heroku detected that you pushed a PHP application, it automatically created a default [Procfile](procfile) with an entry for a web [dyno](dynos), instructing Heroku to launch an instance of the Apache Web server together with PHP. You can manually declare this by adding a `Procfile` with the following contents to your project:

```
web: vendor/bin/heroku-php-apache2
```

> callout
> The PHP [buildpack](buildpacks) installs some resources necessary at runtime into the `vendor/heroku/heroku-buildpack-php` directory of your application. This follows standard Composer practices. For more details on how to launch other Web servers, please refer to the [PHP support](php-support) article.


Now, add and commit the `Procfile` and push to Heroku again:

```term
$ git add .
$ git commit -m "Add Procfile"
[master bd24c74] Add Procfile
 1 file changed, 1 insertion(+)
 create mode 100644 Procfile
$ git push heroku master
Fetching repository, done.
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 338 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)

-----> PHP app detected
-----> WARNING!
       Your composer.json is completely empty, please consider putting at least "{}" in there to make it valid JSON.
-----> Setting up runtime environment...
       - PHP 5.5.11
       - Apache 2.4.9
       - Nginx 1.4.6
-----> Discovering process types
       Procfile declares types -> web

-----> Compressing... done, 60.7MB
-----> Launching... done, v5
       http://polar-chamber-3014.herokuapp.com/ deployed to Heroku

To git@heroku.com:polar-chamber-3014.git
   3600080..bd24c74  master -> master
```

Refresh your browser, or running `heroku open` and you will still see "Hello World!", but this time, you're reaching a new, re-launched dyno instance. Pushing out changes to your application is that simple!

You can verify the changes on your running dyno by running a [one-off dyno](one-off-dynos):

```term
$ heroku run bash
Running `bash` attached to terminal... up, run.5662
~ $ cat Procfile
web: vendor/bin/heroku-php-apache2
```

### Dyno scaling and sleeping

Having only a single web dyno running will result in the dyno [going to sleep](dynos#dyno-sleeping) after one hour of inactivity.  This causes a delay of a few seconds for the first request upon waking. Subsequent requests will respond more rapidly.

If you want to avoid this, or if you are expecting more traffic to your website, it is encouraged to run more than one dyno. To scale your dynos you can run the `ps:scale` command:

```term
$ heroku ps:scale web=2
Scaling dynos... done, now running web at 2:1X.
```

Run `heroku open` to switch back to the browser and refresh the page a couple of times.  Each refresh will be routed randomly to one of the two dynos - something you will test later.  For now, scale back the number of dynos!

> note
> For each application, Heroku provides [750 free dyno-hours](usage-and-billing#750-free-dyno-hours-per-app). Running your app at two dynos would exceed this free monthly allowance, so scale back to one dyno, which you can run for free all month (24 x 31 = 744).

```term
$ heroku ps:scale web=1
Scaling dynos... done, now running web at 1:1X.
```

### Managing Dependencies with Composer

To get started with logging and our first dependency, add a logging module to the application.

In your `composer.json`, declare a dependency on the popular [Monolog](https://github.com/Seldaek/monolog) package:

```json
{
    "require": {
        "monolog/monolog": "~1.7"
    }
}
```

Once you've added any new dependencies you will need to generate and add your [lock file](https://getcomposer.org/doc/01-basic-usage.md#composer-lock-the-lock-file). This lock file is important to ensure reproducible behavoior for your dependencies, but also helps ensure [dev/prod parity](https://devcenter.heroku.com/articles/development-configuration#dev-prod-parity). *A lock file is not required for an empty `composer.json` which contains no dependencies.* To generate your `composer.lock` file, once you have composed installed:

> note
> From this point forward, we're assuming that you have a working local PHP installation, and [Composer is installed](https://getcomposer.org/doc/00-intro.md#installation-nix).

```term

$ composer install
Loading composer repositories with package information
Installing dependencies (including require-dev)
  - Installing psr/log (1.0.0)
    Loading from cache

  - Installing monolog/monolog (1.8.0)
    Loading from cache

monolog/monolog suggests installing graylog2/gelf-php (Allow sending log messages to a GrayLog2 server)
monolog/monolog suggests installing raven/raven (Allow sending log messages to a Sentry server)
monolog/monolog suggests installing doctrine/couchdb (Allow sending log messages to a CouchDB server)
monolog/monolog suggests installing ruflin/elastica (Allow sending log messages to an Elastic Search server)
monolog/monolog suggests installing ext-amqp (Allow sending log messages to an AMQP server (1.0+ required))
monolog/monolog suggests installing ext-mongo (Allow sending log messages to a MongoDB server)
monolog/monolog suggests installing aws/aws-sdk-php (Allow sending log messages to AWS services like DynamoDB)
monolog/monolog suggests installing rollbar/rollbar (Allow sending log messages to Rollbar)
Writing lock file
Generating autoload files
``` 

You will now have a lot of stuff in the `vendor/` directory where Composer places dependencies, and [none of that should ever end up in your Git repository](https://getcomposer.org/doc/01-basic-usage.md#installing-dependencies), so  create a file called `.gitignore` and put a single line in there:

```
vendor/
```

Now commit both changes (best to keep them separate in your history):

```term
$ git add .gitignore
$ git commit -m "Ignore vendors"
[master fecb53a] Ignore vendors
 1 file changed, 1 insertion(+)
 create mode 100644 .gitignore
$ git add composer.json
$ git add composer.lock
$ git commit -m "Lock down dependencies"
[master e2c31a4] Lock down dependencies
 1 file changed, 130 insertions(+)
 create mode 100644 composer.lock
```

At this point no new version of the application has been deployed yet - that's because no new code has been written to use the dependency yet. But if you were to push the contents of that repository to Heroku, it would automatically install your dependencies (which is `monolog/monolog` and whatever packages that depends upon) before re-launching your dynos.

> note
> Heroku uses an always up-to-date version of Composer to install your dependencies whenever you push. If, for any reason, you would like to use a specific version of Composer, e.g. with custom patches, simply have its `composer.phar` in the root directory of your app. Heroku will inform you it's using your custom version, and remind you to keep it up to date.

### Basic logging

Now that you have Monolog available in your application, add some basic [logging](logging) to your app.

Update your `index.php` to use the [autoloader generated by Composer](https://getcomposer.org/doc/01-basic-usage.md#autoloading), and write a little warning to [`STDERR`](http://docs.php.net/manual/en/wrappers.php.php).  Heroku treats [logs as streams](https://devcenter.heroku.com/articles/management-visibility#logging) - and expects them to be written to STDOUT and STDERR and not to its [ephemeral filesystem](dynos#ephemeral-filesystem).

```php
<?php

require('vendor/autoload.php');

use Monolog\Logger;
use Monolog\Handler\StreamHandler;

// create a log channel to STDERR
$log = new Logger('name');
$log->pushHandler(new StreamHandler('php://stderr', Logger::WARNING));

// add records to the log
$log->addWarning("Running PHP!");

// don't forget to greet the world!
echo "Hello World!";

?>
```

Now commit and push this change.  You'll notice a lot more output on the terminal as Heroku uses Composer to install the dependencies:

```term
$ git add .
$ git commit -m "Add basic logging"
[master 4b42543] Add basic logging
 1 file changed, 14 insertions(+), 1 deletion(-)
$ git push heroku master
Fetching repository, done.
Counting objects: 15, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (11/11), done.
Writing objects: 100% (12/12), 2.39 KiB | 0 bytes/s, done.
Total 12 (delta 3), reused 0 (delta 0)

-----> PHP app detected
-----> Setting up runtime environment...
       - PHP 5.5.11
       - Apache 2.4.9
       - Nginx 1.4.6
-----> Installing dependencies...
       Composer version 1e4df0690a08c4653b5c932d51a337b10d6c19bf 2014-04-10 19:10:45
       Loading composer repositories with package information
       Installing dependencies from lock file
         - Installing psr/log (1.0.0)
           Downloading: 100%         
       
         - Installing monolog/monolog (1.8.0)
           Downloading: 100%         
       
       Generating optimized autoload files
-----> Building runtime environment...
-----> Discovering process types
       Procfile declares types -> web

-----> Compressing... done, 60.8MB
-----> Launching... done, v6
       http://polar-chamber-3014.herokuapp.com/ deployed to Heroku

To git@heroku.com:polar-chamber-3014.git
   bd24c74..4b42543  master -> master
```

You can view your logs after deploying and visiting your app by running `heroku logs`:

```term
$ heroku open
Opening polar-chamber-3014... done
$ heroku logs
2014-03-12T01:37:04.776925+00:00 heroku[router]: at=info method=GET path=/ host=polar-chamber-3014.herokuapp.com request_id=b355fca1-c66d-4090-a98b-81a5d2d3282f fwd="91.61.72.154" dyno=web.1 connect=17ms service=5ms status=200 bytes=141
2014-03-12T01:37:04.780217+00:00 app[web.1]: [2014-03-12 01:37:04] name.WARNING: Running an alpha version of Heroku's PHP support [] []
2014-03-12T01:37:04.780263+00:00 app[web.1]: [Wed Mar 12 01:37:04 2014] 10.90.247.124:41202 [200]: /
```

The warning is now present.

#### Log aggregation

Examine what happens if you run more than one dyno. Scale up to three dynos, refresh the browser a few times while tailing logs on the terminal (this time, we'll also filter to only show application messages ones from the "web" process), and observe the result:

```term
$ heroku ps:scale web=3
Scaling dynos... done, now running web at 3:1X.
$ heroku open
$ heroku logs --source app --ps web --tail
```

Switch back to your web browser and refresh the page (which still happily announces "Hello World!").  You will notice how different web dyno instances log their messages to [Logplex](logplex), and that these get aggregated automatically:

```
2014-03-12T01:44:10.776998+00:00 app[web.2]: [2014-03-12 01:44:10] name.WARNING: Running an alpha version of Heroku's PHP support [] []
2014-03-12T01:44:10.776998+00:00 app[web.2]: [Wed Mar 12 01:44:10 2014] 10.240.102.115:53766 [200]: /
2014-03-12T01:44:12.004717+00:00 app[web.3]: [2014-03-12 01:44:12] name.WARNING: Running an alpha version of Heroku's PHP support [] []
2014-03-12T01:44:12.004717+00:00 app[web.3]: [Wed Mar 12 01:44:12 2014] 10.238.165.77:34265 [200]: /
2014-03-12T01:44:24.315213+00:00 app[web.3]: [2014-03-12 01:44:24] name.WARNING: Running an alpha version of Heroku's PHP support [] []
2014-03-12T01:44:24.315213+00:00 app[web.3]: [Wed Mar 12 01:44:24 2014] 10.238.128.189:50616 [200]: /
2014-03-12T01:44:24.784998+00:00 app[web.1]: [2014-03-12 01:44:24] name.WARNING: Running an alpha version of Heroku's PHP support [] []
2014-03-12T01:44:24.785413+00:00 app[web.1]: [Wed Mar 12 01:44:24 2014] 10.236.143.6:36137 [200]: /
2014-03-12T01:44:25.458754+00:00 app[web.1]: [2014-03-12 01:44:25] name.WARNING: Running an alpha version of Heroku's PHP support [] []
2014-03-12T01:44:25.458754+00:00 app[web.1]: [Wed Mar 12 01:44:25 2014] 10.68.97.23:44653 [200]: /
2014-03-12T01:44:25.945548+00:00 app[web.2]: [2014-03-12 01:44:25] name.WARNING: Running an alpha version of Heroku's PHP support [] []
2014-03-12T01:44:25.945548+00:00 app[web.2]: [Wed Mar 12 01:44:25 2014] 10.241.69.228:45901 [200]: /
```

Press `Ctrl-C` to exit the log tailing session:

```term
^C
 !    Command cancelled.
$
```

> note
> There are many other ways than just the `heroku` command line tool to retrieve these logs; refer to the [logging documentation](logging) for more information.

Since your application would once again exhaust its [750 free dyno hours per month](usage-and-billing#750-free-dyno-hours-per-app), scale back to one web dyno:

```term
$ heroku ps:scale web=1
Scaling dynos... done, now running web at 1:1X.
```

## Using a different Web server

On Heroku, you should always use a dedicated Web server that will interface with PHP using the FastCGI protocol. Heroku supports both the [Apache](http://httpd.apache.org) and the [Nginx](http://nginx.org) Web servers for this purpose, and as you've seen earlier, it will default to Apache if you don't declare a command for `web` dynos in your `Procfile`.

To run Nginx instead of Apache, Heroku needs to be told to use the `heroku-php-nginx` instead of the `heroku-php-apache2` *boot script*, both of which automatically get installed to `vendor/bin` during deployment. These boot scripts will start a Web server together with PHP-FPM and all the correct settings.

> note
> Vendor binaries are usually installed to `vendor/bin` by Composer, but under some circumstances (e.g. when running a Symfony2 standard edition project), the location will be different. Run `composer config bin-dir` to find the right location.

### Nginx

Since your application already works on Apache, why not try Nginx as an alternative? This is a a simple `Procfile` change away:

```
web: vendor/bin/heroku-php-nginx
```

Then, another commit and push:

```term
$ git add Procfile
$ git commit -m "use Nginx"
$ git push heroku master
```

You just migrated your PHP project from using Apache to using Nginx as the Web server! The [PHP on Heroku reference documentation](php-support) has more details about Nginx usage and possible options.

## Interactive shell

Heroku allows you to run commands in a [one-off dyno](one-off-dynos) with `heroku run`.  Use this for scripts and applications that only need to be executed when needed, or to launch an interactive PHP shell attached to your local terminal for experimenting in your app's environment:

```term
$ heroku run "php -a"
Running `php -a` attached to terminal... up, run.8081
Interactive shell

php > echo PHP_VERSION;
5.5.11
```

> note
> For debugging purposes, e.g. to examine the state of your application after a deploy, you can use `heroku run bash` for a full shell into a one-off dyno. But remember that this will not connect you to one of the web dynos that may be running at the same time!

## Next steps

- Deploy your own custom PHP application;
- Read the [PHP on Heroku Reference](php-support) to learn about available versions, extensions, features and behaviors;
- Learn how to [customize](https://devcenter.heroku.com/articles/custom-php-settings)  web server and runtime settings for PHP, in particular how to [set the document root](/articles/custom-php-settings#setting-the-document-root) for your application;
- Use a [custom GitHub OAuth token](https://devcenter.heroku.com/articles/php-support#custom-github-oauth-tokens) for Composer;
- Explore the [PHP category](/categories/php) on Dev Center;
- Join Heroku's [PHP Forums](http://discussion.heroku.com/category/php).