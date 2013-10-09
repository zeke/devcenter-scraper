---
title: Resolving Application Dependencies with Git Submodules
slug: git-submodules
url: https://devcenter.heroku.com/articles/git-submodules
description: Git submodules, library-vendoring and private package repositories are all available when specifying application dependencies on Heroku.
---

Most modern applications rely heavily on third party libraries and must specify these dependencies within the application repository itself. Tools like [RubyGems](http://rubygems.org/), [Maven](http://maven.apache.org/) in Java, or Python's [pip](http://pypi.python.org/pypi/pip) are all dependency managers that translate a list of stated application dependencies into the code or binaries the application uses during execution.

However, in some cases the required third-party libraries can't be resolved by the dependency manager. Such scenarios include private libraries that aren't publicly accessible or libraries whose maintainers haven't packaged them for distribution via the dependency manager. In these situations you can use [git submodules](http://git-scm.com/book/en/Git-Tools-Submodules) to manually manage external dependencies.

This guide discusses the pros/cons of dependency management with git submodules as well as some alternative approaches to consider to avoid the use of submodules.

## Git submodules

[Git submodules](http://git-scm.com/book/en/Git-Tools-Submodules) are a feature of the [Git SCM](http://git-scm.com/) that allow you to include the contents of one repository within another by simply specifying the referenced repository location. This provides a mechanism of including an external library's source into an application's source tree.

For example, to include the `FooBar` source into the `heroku-rails` project simply use the `git submodule add` command.

    :::term
    $ cd ~/Code/heroku-rails/lib
    $ git submodule add https://github.com/myusername/FooBar
    Cloning into 'FooBar'...
    remote: Counting objects: 26, done.
    remote: Compressing objects: 100% (17/17), done.
    remote: Total 26 (delta 8), reused 19 (delta 5)
    Unpacking objects: 100% (26/26), done.

This would create a new submodule called `FooBar` and place a `FooBar` directory with the full source tree of the library into the `lib` application directory.

Once a git submodule is added locally you need to commit the new submodule reference to your application repository.

    :::term
    $ git commit -am "adding a submodule for FooBar"
    [master 314ef62] adding a submodule for testing
    2 files changed, 4 insertions(+)
    create mode 160000 FooBar

Heroku properly resolves and fetches submodules as part of deployment:

    :::term
    $ git push heroku
    Counting objects: 13, done.
    ...
    
    -----> Heroku receiving push
    -----> Git submodules detected, installing Submodule 'FooBar' (https://github.com/myusername/FooBar.git) registered for path 'FooBar'
    Initialized empty Git repository in /tmp/build_2qfce3fkvrug9/FooBar/.git/
    Submodule path 'FooBar': checked out '667e0b5717631a8cca657a0aa306c045f06cfda4'
    -----> Ruby/Rails app detected
    ...

Note that failures to fetch the submodules will cause the build to fail.

If it's at all possible to use your runtime's preferred dependency resolution mechanisms, you should prefer it to using submodules, which can often be confusing and error-prone.

## Protected Git submodules

If the referenced git repository is protected via a username and password it's still possible to reference it with a submodule. Since remote environments like Heroku don't have access to locally available credentials you will need to embed the username and password into the repository URL.

For instance, to add the `FooBar` submodule using an HTTP basic authentication URL scheme (note the presence of the `username:password` tokens):

    :::term
    $ git submodule add https://username:password@github.com/myusername/FooBar

This adds a private submodule dependency to the application while still allowing it to resolve in non-local environments.

<p class="warning" markdown="1">
Since submodule references are stored in plaintext in the `.git/submodules` directory please consider if this is acceptable for your particular security requirements.
</p>

## Vendoring

While Git submodules are one way to quickly reference external library source, users often run into issues with its nuanced update lifecycle. If you find the usability of submodules to be counter-productive you can vendor the code into the project.

Many frameworks allow the use of "vendored" code which simply copies the source of the reference library into the application's source tree:

    :::term
    $ git clone <remote repo> /path/to/some/directory 
    $ cp -R /path/to/some/directory /app/vendor/directory
    $ git add app/vendor/directory

A downside of this approach is that it requires a manual download and copy process when the external library is updated. However, for a external resource that changes very slowly, or that you don't want to introduce changes from, this is an option.

## Private dependency repositories

A very robust and scalable approach to dependency management is to use a private _package_ repository. For Ruby, Python and Node.js this is available on Heroku with the [Gemfury add-on](https://devcenter.heroku.com/articles/gemfury). For JVM-based languages it's easy to use a private S3 bucket with the [s3-wagon-private](https://github.com/technomancy/s3-wagon-private/) tool. It may also be possible to [host your dependencies](https://github.com/hashicorp/heroku-buildpack-rubygem-server) on Heroku using custom [buildpack](https://devcenter.heroku.com/articles/buildpacks#using-a-custom-buildpack) functionality.

Private package repositories allow you to use your language's  dependency management tools while limiting access to only your application or organization. While this does incur the overhead of having to properly package your referenced libraries for broader distribution it is a much more scalable approach that takes advantage of your language's well supported and vetted dependency toolset.