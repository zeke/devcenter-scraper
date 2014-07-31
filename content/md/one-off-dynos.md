---
title: One-Off Dynos
slug: one-off-dynos
url: https://devcenter.heroku.com/articles/one-off-dynos
description: Use one-off dynos to execute administrative or maintenance tasks for the app. They can be executed using the `heroku run` command.
---

The set of dynos declared in your [Procfile](procfile) and managed by the [dyno manager](dynos#the-dyno-manager) via `heroku ps:scale` are known as the [dyno formation](scaling).  These dynos do the app's regular business (such as handling web requests and processing background jobs) as it runs.  But when you wish to do one-off administrative or maintenance tasks for the app, you'll want to spin up a one-off dyno using the `heroku run` command. 

## One-off dynos

After you push your application to Heroku, the [slug compiler](slug-compiler) generates a slug  containing the application. The application may contain many components, including a web server, a console application, and scripts to initialize the database. While the web dyno would be defined in the [Procfile](procfile) and managed by the platform, the console and script would only be executed when needed. These are one-off dynos.

>note
>Any time spent executing a one-off dyno will contribute to usage and [will be charged](usage-and-billing#one-off-dynos) just like any other dyno.

## Formation dynos vs. one-off dynos

One-off dynos run alongside other dynos, exactly like the app's web, worker, and other formation dynos. They get all the benefits of [dyno isolation](dynos#isolation-and-security).  

Each dyno has its own ephemeral filesystem, not shared with any other dyno, that is discarded as soon as you disconnect.  This filesystem is populated with the slug archive - so one-off dynos can make full use of anything deployed in the application.

There are four differences between one-off dynos (run with `heroku run`) and formation dynos (run with `heroku ps:scale`):

* One-off dynos run attached to your terminal, with a character-by-character TCP connection for `STDIN` and `STDOUT`.  This allows you to use interactive processes like a console.  Since `STDOUT` is going to your terminal, the only thing recorded in the app's logs is the startup and shutdown of the dyno.
* One-off dynos terminate as soon as you press Ctrl-C or otherwise disconnect in your local terminal.  One-off dynos never automatically restart, whether the process ends on its own or whether you manually disconnect.
* One-off dynos are named in the scheme `run.N` rather than the scheme `<process-type>.N`.
* One-off dynos can never receive HTTP traffic, since the routers only routes traffic to dynos named `web.N`.

Other than these differences, the dyno manager makes no distinction between one-off dynos and formation dynos.

## An example one-off dyno

One-off dynos are created using `heroku run`.  To see one-off dynos in action, execute the `bash` command, available in all applications deployed to Heroku:

```term
$ heroku run bash
Running bash attached to terminal... up, run.1
~ $
```
	
At this point you have a one-off dyno executing the `bash` command - which provides a shell environment that can be used to explore the file system and process environment.

Interact with the shell and list all the files that you deployed:

```term
~ $ ls
Procfile project.clj src bin ...
```
	
If you had a batch file in the `bin` directory, you can simply execute it, just as you can many other unix commands:

```term
~ $ echo "Hi there"
Hi there
~ $ pwd
/app
~ $ bin/do-work
```

Remove a few files, and exit:
	
```term    
~ $ rm Procfile project.clj
~ $ exit
```
	
Because each dyno is populated with its own copy of the slug-archive, the deleted files won't change your running application.  

## One-off dyno execution syntax

`heroku run` takes two types of parameters - you can either supply the command to execute, or a process type that is present in your application's [Procfile](procfile).

If you supply a command, either a script or other executable available to your application, then it will be executed as a one-off dyno, together with any additional arguments.  For example, to  execute the Python interpreter with a file `dowork.py` supplied as an argument, then execute `heroku run python dowork.py`.

If you instead supply a process type, as declared in a `Procfile`, then its definition will be substituted, and executed together with any additional arguments.  For example, given the following `Procfile`:

    myworker:  python dowork.py

Executing `heroku run myworker 42` will run `python dowork.py 42` as a one-off dyno.

## Types of one-off dynos

Some types of one-off dynos include:

* Initialising databases or running database migrations.  (e.g. `rake db:migrate` or `node migrate.js migrate`)
* Running a console (also known as a REPL shell) to run arbitrary code or inspect the app's models against the live database.  (e.g. `rails console`, `irb`, or `node`)
* One-time scripts committed into the app's repo (e.g. `ruby scripts/fix_bad_records.rb` or `node tally_results.js`).

In your local environment, you invoke these one-off dynos by a direct shell command inside the app's checkout directory.  For example:

>callout
>To pass command line flags to the command being executed, you can quote the entire string to be executed to avoid the Heroku CLI processing the flags: `heroku run "rake --help"`

```term
$ rake db:migrate
(in /Users/adam/widgets)
==  CreateWidgets: migrating ==================================================
-- create_table(:widgets)
   -> 0.0040s
==  CreateWidgets: migrated (0.0041s) =========================================
```

You can do the exact same thing, but run against your latest Heroku release by prefixing your command with `heroku run`:

```term
$ heroku run rake db:migrate
(in /app)
Migrating to CreateWidgets (20110204210157)
==  CreateWidgets: migrating ==================================================
-- create_table(:widgets)
   -> 0.0497s
==  CreateWidgets: migrated (0.0498s) =========================================
```

Likewise, if you can run a console in your local environment by executing a command, as you can with Rails and `rails console` command:

```term
$ rails console
Loading development environment (Rails 3.0.3)
ruby-1.9.2-p136 :001 > Widget.create :name => 'Test'
 => #<Widget id: 1, name: "Test", size: nil, created_at: "2011-05-31 02:36:39", updated_at: "2011-05-31 02:36:39">
```

Running the same command against your deployed Heroku app will execute it, and attach it to your terminal:

```term
$ heroku run rails console
Running rails console attached to terminal... up, run.2
Loading production environment (Rails 3.0.3)
irb(main):001:0> Widget.create :name => 'Test'
=> #<Widget id: 1, name: "Test", size: nil, created_at: "2011-05-31 02:37:51", updated_at: "2011-05-31 02:37:51">
```
		
## Running tasks in background

You can run a dyno in the background using `heroku run:detached`. Unlike `heroku run`, these dynos will send their output to your logs instead of your console window. You can use `heroku logs` to view the output from these commands:

```term
$ heroku run:detached rake db:migrate
Running rake db:migrate... up, run.2
Use 'heroku logs -p run.2' to view the log output.
```

## Stopping one-off dynos

You can check your current running dynos using `heroku ps`:

```term
$ heroku ps
=== run: one-off processes
run.7364: starting 2013/03/13 15:38:08 (~ 1s ago): `bash`

=== web: `bundle exec unicorn -p $PORT -c ./config/unicorn.rb`
web.1: up 2013/03/13 15:08:07 (~ 30m ago)
web.2: up 2013/03/12 17:06:09 (~ 22h ago)
```

If you wish to stop a running one-off dyno, use `heroku ps:stop` with its name.

```term
$ heroku ps:stop run.1
Stopping run.1 process... done
```

A one-off dyno will not stop if you issue `heroku ps:restart` on your application.

## One-off dyno timeout

>callout
>It is possible to trap `SIGHUP` and cause your dyno to continue running even when the connection is closed. See the [signal manual page](http://man.cx/signal%287%29) for more information.

Connections to one-off dynos will be closed after one hour of inactivity (in both input and output). When the connection is closed, the dyno will be sent `SIGHUP`. This idle timeout helps prevent unintended charges from leaving interactive console sessions open and unused.

Detached dynos have no connection, so they have no timeout.  However, like all dynos, one-off dynos [are cycle](https://devcenter.heroku.com/articles/dynos#automatic-dyno-restarts) every 24 hours.  As a result, a one-off dyno will run for a maximum of 24 hours. 

## One-off dyno size

By default, one-off dynos run at the [1X size](https://devcenter.heroku.com/articles/dyno-size) irrespective of the default dyno size of your app. You can run one-off dynos at a 2X or PX size by using the `size` argument:

```term
$ heroku run --size=2X rake heavy:job
```

or

```term
$ heroku run --size=PX rake heavy:job
```

## Limits

See the [Default scaling limits](https://devcenter.heroku.com/articles/dyno-size#default-scaling-limits) section for limits on how many one-off dynos can run concurrently.

## Troubleshooting

### Timeout awaiting process

The `heroku run` command opens a connection to Heroku on port 5000. If your local network or ISP is blocking port 5000, or you are experiencing a connectivity issue, you will see an error similar to:

```term
$ heroku run rails console
Running rails console attached to terminal... 
Timeout awaiting process
```

You can test your connection to Heroku by trying to connect directly to `rendezvous.runtime.heroku.com` on port 5000 using telnet. A successful session will look like this:

```term
$ telnet rendezvous.runtime.heroku.com 5000
Trying 50.19.103.36...
Connected to ec2-50-19-103-36.compute-1.amazonaws.com.
Escape character is '^]'. 
```

If you do not get this output, your computer is being blocked from accessing our services. We recommend contacting your IT department, ISP, or firewall manufacturer to move forward with this issue.

## SSH access

Since your app is spread across many dynos by the [dyno manager](dynos#the-dyno-manager), there is no single place to SSH into. You deploy and manage apps, not servers.

You can invoke a shell as a one-off dyno:

```term
$ heroku run bash
```

However, there is little to be gained from doing so.  The filesystem is [ephemeral](dynos#ephemeral-filesystem), and the dyno itself will only live as long as your console session.

When you find yourself wanting SSH access, instead try using tools that properly accounts for Heroku's distributed environment, such as the [heroku command line tool](heroku-command) and one-off dynos. 