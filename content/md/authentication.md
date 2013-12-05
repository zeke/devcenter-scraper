---
title: Heroku CLI Authentication
slug: authentication
url: https://devcenter.heroku.com/articles/authentication
description: Authentication on Heroku uses either email and password, an API token, or an SSH key. The .netrc format can also be used to store credentials.
---

Authentication on Heroku uses one of three mechanisms,
depending on the situation:

* Email and password
* API token
* SSH key

The email address and password are used by the `heroku` command
to obtain an API token. This token is used for authentication in
all other Heroku API requests, and can be regenerated at will
by the user, in the heroku.com web interface. Regenerating an
API token invalidates the current token and creates a new one.

The SSH key is used for git push authentication. When `heroku
login` first runs, it will register the user's existing SSH public key
with Heroku. If no SSH key exists, `heroku login` will create one
automatically and registers the new key.

## API token storage

The Heroku command-line tool stores API tokens in the standard
Unix file `~/.netrc`.

The netrc format is well-established and well-supported by
various network tools on unix. With Heroku credentials stored in
this file, other tools such as `curl` can access the Heroku API
with little or no extra work.

### Usage examples

Running `heroku login` (or any other `heroku` command that
requires authentication) will create or update your`~/.netrc`:

```term
$ ls .netrc
ls: .netrc: No such file or directory
$ heroku login
Enter your Heroku credentials.
Email: me@example.com
Password:
$ cat .netrc
machine api.heroku.com
  login me@example.com
  password c4cd94da15ea0544802c2cfd5ec4ead324327430
machine code.heroku.com
  login me@example.com
  password c4cd94da15ea0544802c2cfd5ec4ead324327430
$
```

## Retrieving the API token

You can display the token via the CLI:

```term
$ heroku auth:token
c4cd94da15ea0544802c2cfd5ec4ead324327430
```

## Authenticating with the API token

Having logged in, you can use `curl` to access the Heroku API:

```term
$ curl -H "Accept: application/json" -n https://api.heroku.com/apps
```

You can also create a file `~/.curlrc`, containing extra command-line
options for curl:

### ~/.curlrc

```
--netrc
--header "Accept: application/json"
```

With this file, the command is simply:

```term
$ curl https://api.heroku.com/apps
```

### File format

The file contains a list of free-form records and comments. Comments
start with a `#` (hash) symbol and continue to the end of the line.
Each record is of the form:

```
machine api.heroku.com
  login me@example.com
  password ABC123
```

One other type of record, `macdef`, can appear in `.netrc` files, but
it is not commonly used and is ignored by the `heroku` command.
