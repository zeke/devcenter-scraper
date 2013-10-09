---
title: Read-only Filesystem
slug: read-only-filesystem
url: https://devcenter.heroku.com/articles/read-only-filesystem
description: Understand the read-only filesystem of the Heroku Bamboo stack.
---

<div class="deprecated" markdown="1">This article applies to apps on the [Bamboo](bamboo) stack.  For the most recent stack, [Cedar](cedar), see the note on the [ephemeral writeable filesystem](dynos#ephemeral-filesystem).</div>

Your app is [compiled into a slug](slug-compiler) for fast distribution by the [dyno manager](dynos#the-dyno-manager). The filesystem for the slug is read-only, which means you cannot dynamically write to the filesystem for semi-permanent storage. The following types of behaviors are _not_ supported:

* Caching pages in the `public` directory
* Saving uploaded assets to local disk (e.g. with attachment_fu or paperclip)
* Writing full-text indexes with Ferret
* Writing to a filesystem database like SQLite or GDBM
* Accessing a git repo for an app like git-wiki

There are two directories that _are_ writeable: `./tmp` and `./log` (under your application root). If you wish to drop a file temporarily for the duration of the request, you can write to a filename like `#{RAILS_ROOT}/tmp/myfile_#{Process.pid}`.  There is no guarantee that this file will be there on subsequent requests (although it might be), so this should not be used for any kind of permanent storage.

So how do you accomplish each of the following in a way that is compatible with a cloud environment?

* **Caching** - Use HTTP headers instead of writing to the filesystem.  See our discussion of [HTTP caching](http-caching) for more information.
* **Saving uploaded assets** - Use an asset store system like Amazon S3.  See [large static assets](s3) for further discussion.
* **SQLite or GDBM** - Use the provided PostgreSQL database instead of a filesystem database.
* **Accessing a git repo** - Sorry, but git-wiki and apps that use a similar technique won't work on Heroku. As clever as git-wiki is, it is fundamentally non-scalable and non-replicatable.

### Further reading
* Adam Wiggins's [Read-only Source Trees](http://adam.heroku.com/past/2008/7/2/readonly_source_trees/)
