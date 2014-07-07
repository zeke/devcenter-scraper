---
title: Python Dependencies via Pip
slug: python-pip
url: https://devcenter.heroku.com/articles/python-pip
description: Understand how to declare dependencies with pip on Heroku.
---

This guide outlines how to fully utilize Heroku's support for specifying dependencies for your Python application via pip.

> note
> If you have questions about Python on Heroku, consider discussing it in the [Python on Heroku forums](https://discussion.heroku.com/category/python). Both Heroku and community-based Python experts are available.

Heroku's pip support is very transparent. Any requirements that install locally with the following command will behave as expected on Heroku:

```term
$ pip install -r requirements.txt
```

We have made a few minor fixes to pip, but these patches are actively being pushed upstream.

## The basics

To specify Python module dependencies on Heroku, add a [pip requirements file](http://www.pip-installer.org/en/latest/cookbook.html#requirements-files) named `requirements.txt` to the root of your repository.

Example `requirements.txt`:

```
Flask==0.8
Jinja2==2.6
Werkzeug==0.8.3
certifi==0.0.8
chardet==1.0.1
distribute==0.6.24
gunicorn==0.14.2
requests==0.11.1
```

## Best practices

If you follow these simple recommendations, your application builds will be deterministic:

- All package versions should be explicitly specified.
- All secondary dependencies should be explicitly specified.

This will ensure consistent build behavior when newer package versions are released.

## Git-backed distributions

Anything that works with a standard pip requirements file will work as expected on Heroku.

Thanks to pip's Git support, you can install a Python package that is hosted on a remote Git repository. 

For example:

```
git+git://github.com/kennethreitz/requests.git
```

If your package is hosted in a private Git repository, you can use HTTP Basic Authentication:

```
git+https://user:password@github.com/nsa/secret.git
```

You can also specify any Git reference (e.g. branch, tag, or commit) by appending an `@` to your URL:

```
git+git://github.com/kennethreitz/requests.git@develop
```

Optionally, you can install a dependency in "editable" mode, which will link to a full clone of the repository. This is useful for larger distributions, like Django:

> callout
> The `egg` fragment is only valid with editable requirements.

```
-e git+http://github.com/django/django.git#egg=django
```
 
## Remote file-backed distributions

You can also install packages from remote archives. 

For example:

```
https://site.org/files/package.zip
```

This can be useful in many situations. For example, you can utilize GitHub's tarball generation for repositories with large histories:

```
https://github.com/django/django/tarball/master
```

## Local file-backed distributions

Pip can also install a dependency from your local codebase. This is useful with making custom tweaks to an existing package.

> callout
> You can use Git Submodules to maintain separate repositories for your File-backed dependencies. Git modules will automatically be resolved when you push your code to Heroku.

To add a local dependency in `requirements.txt`, specify the relative path to the directory containing `setup.py`:

```
./path/to/distribution
```

If you make changes to the library without bumping the required version number, however, the changes will not be updated at runtime. You can get around this by installing the package in editable mode:

```
-e ./path/to/distribution
```

## Private indexes

In order to minimize points of failure, it is considered best practice within the Python community for development shops to host their own instances of the "Cheeseshop" containing their dependencies.

To point to a custom Cheeseshop's index, you can add the following to the top of your requirements file:

```
-i https://pypi.python.org/simple/
```

All dependencies specified in that requirements file will resolve against that index.

## Cascading requirements files

If you would like to utilize multiple requirements files in your codebase, you can *include* the contents of another requirements file with pip:

```
-r ./path/to/prod-requirements.txt
```

## Traditional distributions

Heroku also supports traditional Python package distribution, powered by  `setup.py`.

If your Python application contains a `setup.py` file but excludes a `requirements.txt` file, `python setup.py develop` will be used to install your package and resolve your dependencies.

> callout
> This works best with distribute or setuptools. Projects that use distutils directly will be installed, but not linked. The module won't get updated until there's a version bump.

If you already have a requirements file but would like to utilize this feature, you can add the following to your requirements file:

```
-e . 
```

This causes pip to run `python setup.py develop` on your application. 