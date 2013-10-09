---
title: Logplex
slug: logplex
url: https://devcenter.heroku.com/articles/logplex
description: Logplex collates log entries from all the running dynos of your app, and other components of the Heroku platform.
---

Logplex collates and distributes log entries from your app and other components of the Heroku platform. It makes these entries [available](/articles/logging) through the [Logplex public API](https://github.com/heroku/logplex/blob/master/README.md) and the [Heroku command-line tool](logging).

In a distributed system such as Heroku, manually accessing logs spread across many dynos provides a very disjointed view of an application's event stream and omits relevant platform-level events. The logplex facility solves these issues in an accessible and extensible manner.

<!--
Without a facility like logplex, accessing logs from many processes in a distributed system such as Heroku would require ssh-ing to each machine and copying log files (without forgetting also to set up log rotation), or dealing with syslog daemons and the unstandardized network syslog protocol and management of a log processing server.
-->

## Sources and drains

Logplex routes messages from sources to drains.

<!--
![Routing diagram](https://github.com/heroku/routing-docs/blob/master/components/logplex/Logplex%20architecture%20scribble.pdf?raw=true)
-->

* Log sources are any processes that might want to emit log entries relevant to your app. Some examples: your `web` dynos, the Heroku platform, the [Heroku routing stack](/articles/http-routing), and many add-ons.

* Log drains are any network services that want to consume your app's logs, either for automatic processing, archival, or human consumption. Examples include the Heroku command-line tool and several [log-processing and management add-ons](https://addons.heroku.com/).

## Best-effort delivery

Logplex is a high-performance, real-time system for log delivery -- not storage. It keeps a [limited buffer of log entries](logging#log-history-limits).

Logplex interacts directly with various external tools and services, and requires prompt action for real-time processing. If one of these services has trouble keeping up, Logplex may be forced to discard log entries for some time. If this happens, it will insert a [warning entry](error-codes#l10-drain-buffer-overflow) to indicate that some entries are missing.