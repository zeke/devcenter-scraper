---
title: Dev Center CLI
slug: dev-center-cli
url: https://devcenter.heroku.com/articles/dev-center-cli
description: The Dev Center CLI lets authors edit and preview Dev Center articles locally.
---

The Dev Center CLI lets authors edit and preview Dev Center articles locally.

## Installation

[Set up Ruby](http://www.ruby-lang.org/en/downloads/) on your local machine. Then install the Dev Center CLI gem:

```term
$ gem install devcenter
```

You'll also need the [Heroku toolbelt](https://toolbelt.heroku.com) if you want to [save your articles](#save-the-article-to-dev-center) to Dev Center.

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
> Never overwrite the `id`: you'll need it to save your changes in Dev Center.

## Stop the preview

To stop the `preview` command, press Ctrl+C.

## Save the article to Dev Center

Save your local changes to Dev Center using the `devcenter push` command:

```term
$ devcenter push dev-center-cli.md
```

> warning
> Your local heroku account will be used to push the article. Use `heroku auth:whoami` to see which account will be used to push the article and `heroku auth:login` if you need to login with a different account.

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
 