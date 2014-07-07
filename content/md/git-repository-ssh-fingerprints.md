---
title: Git Repository SSH Fingerprints
slug: git-repository-ssh-fingerprints
url: https://devcenter.heroku.com/articles/git-repository-ssh-fingerprints
description: In order to ensure you are pushing your code to Heroku, you can verify your SSH fingerprint of Heroku's Git endpoint.
---

In order to ensure you are pushing your code to Heroku you can verify your [SSH fingerprint](http://en.wikipedia.org/wiki/Public_key_fingerprint) of our Git endpoint.

## Manually verifying

The current Heroku SSH Git fingerprint is `8b:48:5e:67:0e:c9:16:47:32:f2:87:0c:1f:c8:60:ad`.

When you first `git push heroku master`, it will show the fingerprint of the host you're connecting to, asking you to confirm its authenticity. Check the output aganist the fingerprint above before you continue to ensure your connection is going to the right server.

Should we need to change our SSH key in the future we will keep this page updated with the latest information.

## Verifying with DNS

You can make use of our [SSHFP DNS](http://www.ietf.org/rfc/rfc4255.txt) records by adding the
following lines to your ~/.ssh/config

```
Host heroku.com
 VerifyHostKeyDNS yes
```

Because DNSSEC is not fully implemented yet our SSHFP records are not
trusted so you will be prompted to acknowledge the fingerprint the
first time you connect:

```term
$ git push heroku master
> The authenticity of host 'heroku.com (50.19.85.132)' can't be established.
> RSA key fingerprint is 8b:48:5e:67:0e:c9:16:47:32:f2:87:0c:1f:c8:60:ad.
> Matching host key fingerprint found in DNS.
> Are you sure you want to continue connecting (yes/no)?
```

Ensure that the `matching host key fingerprint` is found before continuing.

On subsequent requests you will not be prompted to confirm the fingerprint.

Please note that adding `VerifyHostKeyDNS yes` will add a slight
amount of overhead to each Git operation as the SSHFP record will be
consulted each time. 