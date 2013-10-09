---
title: Managing Your SSH Keys
slug: keys
url: https://devcenter.heroku.com/articles/keys
description: Create, manage and send SSH keys to Heroku for use in deploying applications.
---

If you don't already use SSH, you'll need to create a public/private key pair to deploy code to Heroku. This keypair is used for the strong cryptography and that uniquely identifies you as a developer when pushing code changes.

<div class="callout" markdown="1">
You can use DSA keys if you prefer, using the `-t dsa` option.  Heroku can use either type of key.
</div>

To generate a public key:

    :::term
    $ ssh-keygen -t rsa
    Generating public/private rsa key pair.
    Enter file in which to save the key (/Users/adam/.ssh/id_rsa):
    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 
    Your identification has been saved in /Users/adam/.ssh/id_rsa.
    Your public key has been saved in /Users/adam/.ssh/id_rsa.pub.
    The key fingerprint is:
    a6:88:0a:0b:74:90:c6:e9:d5:49:d6:e3:04:d5:6c:3e adam@workstation.local

Press enter at the first prompt to use the default file location.  You may wish
to provide a password for the key, although this is not necessary - if your
workstation is physically secure and is not used by anyone other than you,
pressing enter at both prompts to make a passwordless key is secure.  As long as
you keep the contents of `~/.ssh/id_rsa` secret, your key will be secure even
without a password.

Adding keys to Heroku
-------------------

The first time you run the `heroku` command, you'll be prompted for your
credentials. Your public key will then be automatically uploaded to Heroku.
This will allow you to deploy code to all of your apps.

<div class="callout" markdown="1">
A common key error is: `Permission denied (publickey).`
You can fix this by using `keys:add` to notify Heroku of your new key.
</div>

If you wish to add other keys, use this command:

    :::term
    $ heroku keys:add
    Found existing public key: /Users/adam/.ssh/id_rsa.pub
    Uploading SSH public key /Users/adam/.ssh/id_rsa.pub... done

Without an argument, it will look for the key in the default place
(`~/.ssh/id_rsa.pub` or `~/.ssh/id_dsa.pub`).  If you wish to use an alternate
key file, specify it as an argument.  Be certain you specify the public part of
the key (the file ending in .pub).  The private part of the key should never be
transmitted to any third party, ever.

For security purposes Heroku will email you whenever a new SSH key is
added to your account.

Revoke old keys you're no longer using or that you think might be compromised
(for example, if your workstation is lost or stolen):

    :::term
    $ heroku keys:remove adam@workstation.local
    Removing adam@workstation.local SSH key... done

<div class="callout" markdown="1">
The ASCII-armored key data is shortened for readability.  If you wish to see the full public key, use the `--long` argument.  You will probably want to redirect this to a file (`heroku keys --long > keys.txt`), since it will be easier to look at in a text editor.
</div>

The key's name is the `user@workstation` bit that appears at the end of the key line
in your public key file.  You can see a list of all keys, including the key's
name, like this:

    :::term
    $ heroku keys
    === joe@example.com Keys
    ssh-dss AAAAB8NzaC...DVj3R4Ww== joe@workstation.local
