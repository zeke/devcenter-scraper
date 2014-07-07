---
title: Running Rake Commands
slug: rake
url: https://devcenter.heroku.com/articles/rake
description: Run rake commands on Heroku with `heroku run rake`.
---

Rake tasks are executed as [one-off dynos](one-off-dynos) on Heroku, using the same environment as your app's [dynos](dynos). You can run Rake tasks within the remote app environment using the `heroku run rake` command as follows:

```term
$ heroku run rake db:version
Running `rake db:version` attached to terminal... up, run.1
(in /home/slugs/41913_06f36ef_ab3a/mnt)
Current version: 20081118092504
```

You can pass Rake arguments, run multiple tasks, and pass environment variables
just as you would locally. For instance, to migrate the database to a specific
version with verbose backtraces:

```term
$ heroku run rake --trace db:migrate VERSION=20081118092504
```

After running a migration you'll want to restart your app with `heroku restart` to reload the schema and pickup any schema changes.

### Limitations

Not all Rake features are supported on Heroku. The following is
a list of known limitations:

* Rake tasks that write to disk, such as `rake db:schema:dump`, are not
  compatible with Heroku's ephemeral filesystem.

* The `db:reset` task is not supported. Heroku apps do not have permission to drop and create databases. Use the `heroku pg:reset` command instead. 