---
title: Dev Center CLI
slug: dev-center-cli
url: https://devcenter.heroku.com/articles/dev-center-cli
description: The Dev Center CLI lets authors edit and preview Dev Center articles locally.
---

The Dev Center CLI lets authors edit and preview Dev Center articles locally. 

## Installation

You'll need to [set up Ruby](http://www.ruby-lang.org/en/downloads/) on your local machine. Then install the Dev Center CLI gem:

```term
$ gem install devcenter
```

## Pull your article

Download a local copy of an article with `devcenter pull` followed by the article URL:

```term
$ devcenter pull https://devcenter.heroku.com/articles/dev-center-cli
"Dev Center CLI" article saved as ~/.../dev-center-cli.md
```

This will save a `dev-center-cli.md` text file in your local directory.

## Edit and preview locally

Open the file with your text editor: you will see that the file includes some metadata followed by the article content in markdown format.

The following command will open a preview in your default browser:

```term
$ devcenter preview dev-center-cli
Live preview for error-pages available in  http://127.0.0.1:3000/dev-center-cli
It will refresh when you save ~/.../dev-center-cli.md
Press Ctrl+C to exit...
```

Now start editing the article's content: the preview will auto-refresh whenever you save the file, so you can see the content you're editing and its preview side by side.

### Metadata

The markdown file includes some metadata fields, the following ones can be edited:

- `title`: it can be edited freely
- `markdown_flavour`: indicates which of the two markdown parsers available in Dev Center should be used to parse the content. The available values are `maruku` (applied by default if no flavour is specified) and `github` (corresponding to a new experimental parser).

> warning
> Never overwrite the id: you'll need it to save your changes in Dev Center.

## Save the article to Dev Center

At the end of the preview, you will see a button to save your changes in the Dev Center website:

![Save button](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/171-original.jpg?1367999232 'Save button')

> warning
> You need to be logged in into Dev Center to save the article.

After clicking the button you will be redirected to the editing form in Dev Center, prepopulated with your local changes, ready to save the article.

## Stop the preview

To stop the `preview` command, press Ctrl+C.

## Additional help

Get a list of all the available commands with:

```term
$ devcenter help
```

To get help for a specific command and its available options, e.g: `preview`:

```term
$ devcenter help preview
```

## Issues and pull requests

The Dev Center CLI is open source, you can access [its repo](https://github.com/heroku/devcenter-cli) to get the code, report issues or send pull requests.        