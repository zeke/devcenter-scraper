---
title: Slug Compiler
slug: slug-compiler
url: https://devcenter.heroku.com/articles/slug-compiler
description: Slugs are compressed and pre-packaged copies of an application, optimized for distribution by the Heroku dyno manager. Minimize slug size with .slugignore
---

Slugs are compressed and pre-packaged copies of your application
optimized for distribution to the
[dyno manager](dynos#the-dyno-manager). When you `git push` to
Heroku, your code is received by the slug compiler which transforms
your repository into a slug. Scaling an application then downloads and
expands the slug to a dyno for execution.

## Compilation

The slug compiler is invoked by a
[git pre-receive hook](http://git-scm.com/book/en/Customizing-Git-Git-Hooks#Server-Side-Hooks),
which follows these steps:

1. Create a fresh checkout of HEAD from the master branch.
2. Remove unused files, including `.git` directories, `.gitmodules` files, anything in
`log` and `tmp`, and anything specified in a top-level `.slugignore`
file.
3. Download, build, and install local dependencies as specified in
your build file (for example,  [Gemfile](bundler), `package.json`,
`requirements.txt`,  `pom.xml`, etc.) with the dependency management
tool supported by the language (e.g. Bundler, npm, pip, Maven).
4. Package the final slug archive.

## Time limit

Slug compilation is currently limited to 15 minutes. If your deploys start timing out during compilation there are various strategies to speed things up, but these will vary based upon the build tool used. Very large applications which time out should usually have independent components spun off into separate libraries. Keep in mind that disk IO performance on dynos can vary widely, so in some cases compilations that finish in 10 minutes on a local SSD could take over 15 during deployment.

## Ignoring files with `.slugignore`

If your repository contains files not necessary to run your app, you
may wish to add these to a `.slugignore` file in the root of your
repository. Examples of files you may wish to exclude from the slug:

* Unit tests or specs
* Art sources (like .psd files)
* Design documents (like .pdf files)
* Test data

The format is roughly the same as `.gitignore`. Here's an example
`.slugignore`:

```text
*.psd
*.pdf
/test
/spec
```

The `.slugignore` file causes files to be removed after you push code
to Heroku and before the [buildpack](buildpacks) runs. This lets you
prevent large files from being included in the final slug. Unlike
`.gitignore`, `.slugignore` does not support negated `!` patterns.

You can further reduce the number of unnecessary files (for example,
`log` and `tmp` directories) by ensuring that they aren't tracked by
git, in which case they won't be deployed to Heroku either. See
[Using a .gitignore](gitignore) file. 

## Slug size

Your slug size is displayed at the end of a successful compile after the `Compressing` message. The maximum allowed slug size (after compression) is 300MB.

>callout
>You can inspect the extracted contents of your slug with `heroku run bash` and by using commands such as `ls` and `du`.

Slug size varies greatly depending on what language and framework you are using, how many dependencies you have added and other factors specific to your app. Smaller slugs can be transferred to the dyno manager more quickly, allowing for more immediate scaling. You should try to keep your slugs as small and nimble as possible.

Here are some techniques for reducing slug size:

* Move large assets like PDFs or audio files to [asset storage](s3).
* Remove unneeded dependencies and exclude unnecessary files via
`.slugignore`. 