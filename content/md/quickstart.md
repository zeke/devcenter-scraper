---
title: Getting Started with Heroku
slug: quickstart
url: https://devcenter.heroku.com/articles/quickstart
description: Sign up, install the toolbelt, and get started with the Heroku polyglot cloud application platform in Ruby, Java, Node.js, Python, Clojure and Scala.
---

Heroku is a polyglot cloud application platform.  With Heroku, you don't need to think about servers at all.  You can write apps using [modern development practices](https://devcenter.heroku.com/articles/architecting-apps) in [the programming language of your choice](http://devcenter.heroku.com/articles/cedar#polyglot-platform), back it with add-on resources such as [SQL](http://devcenter.heroku.com/articles/heroku-postgresql) and [NoSQL](http://addons.heroku.com/mongohq) databases, [Memcached](https://addons.heroku.com/memcachier), and [many others](https://addons.heroku.com/).  You manage your app using the Heroku command-line tool and you deploy code using the [Git](http://devcenter.heroku.com/articles/git) revision control system, all running on the Heroku infrastructure.

Let's get started.

## Step 1: Sign up 

[Sign up](https://api.heroku.com/signup/devcenter) for a Heroku account, if you don't already have one.

## Step 2: Install the Heroku Toolbelt

Install the [Heroku Toolbelt](https://toolbelt.heroku.com/) for your development operating system. 

The toolbelt contains the [Heroku client](http://devcenter.heroku.com/categories/command-line), a command-line tool for creating and managing Heroku apps; Foreman, an easy option for running your apps locally; and Git, the revision control system needed for deploying applications to Heroku.

## Step 3: Login

After installing the Toolbelt, you'll have access to the `heroku` command from your command shell.  Authenticate using the email address and password you used when creating your Heroku account:

>callout
>If you have previously uploaded a key to Heroku, we assume you will keep using it and do not prompt you about creating a new one during login.  If you would prefer to create and upload a new key after login, simply run `heroku keys:add`.

```term
$ heroku login
Enter your Heroku credentials.
Email: adam@example.com
Password: 
Could not find an existing public key.
Would you like to generate one? [Yn] 
Generating new SSH public key.
Uploading ssh public key /Users/adam/.ssh/id_rsa.pub
```

Press enter at the prompt to upload your existing `ssh` key or create a new one, used for pushing code later on.

## Step 4: Deploy an application

Choose from the following getting started tutorials to learn how to deploy your first application using a supported language or framework:

<table>
  <tr>
    <th colspan="2">Get started with...</th>
  </tr>
  <tr>
    <td style="text-align: left; width: 50%;">
<a href="https://devcenter.heroku.com/articles/getting-started-with-ruby">Ruby</a> or <a href="https://devcenter.heroku.com/articles/getting-started-with-rails4">Rails</a>
</td>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-nodejs">Node.js</a>
</td>	
  </tr>
  <tr>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-java">Java</a>, <a href="https://devcenter.heroku.com/articles/getting-started-with-spring-mvc-hibernate">Spring</a> or <a href="https://devcenter.heroku.com/articles/getting-started-with-play">Play</a>
</td>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-python">Python</a> or <a href="https://devcenter.heroku.com/articles/getting-started-with-django">Django</a>
</td>
  </tr>
  <tr>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-clojure">Clojure</a>
</td>
    <td style="text-align: left">
<a href="https://devcenter.heroku.com/articles/getting-started-with-scala">Scala</a>
</td>
  </tr>
</table>