---
title: Custom Domains
slug: custom-domains
url: https://devcenter.heroku.com/articles/custom-domains
description: Assign additional custom and wildcard DNS domain names to your Heroku applications.
---

All apps on Heroku are accessible via their `herokuapp.com` app subdomain. E.g., for an app named `example` it's available at `example.herokuapp.com`. To serve traffic on a non-herokuapp.com domain, e.g., `www.example.com`, you need to configure your application with a custom domain.

The process to add a custom domain to your application can vary slightly, depending on the type of domain(s).

> note
> DNS changes can take several minutes to several days to take effect. Lowering your DNS TTL ahead of time can minimize, but not eliminate, this propagation time.

## Domain types

There are several domain configurations available to your app including:

* One or more subdomains like `www.example.com`
* A root domain like `example.com` or `example.co.uk`
* Wildcard domains that match any subdomain, represented as `*.example.com`

A single application can utilize one or more of the above domain setups using the same basic process:

1. Tell Heroku which custom domains are specific to your application
1. Configure your application's DNS to point to Heroku

Specific instructions for each configuration are detailed below.

## Custom subdomains

For each custom subdomain you want attached to your app, e.g., `www.example.com`, use the `domains:add` command from the Heroku CLI:

> callout
> See the [domain precedence](#domain-precedence) section if you receive the error message `example.com is currently in use by another app`.

```term
$ heroku domains:add www.example.com
Adding www.example.com to example... done
```

### Subdomain DNS

Next, for each subdomain, configure your DNS with a CNAME record pointing the subdomain to your app's Heroku `herokuapp.com` hostname (shown here resolving `www.example.com` to the `example` app).

> callout
> The trailing `.` on the target domain may or may not be required, depending on your DNS provider.

<table>
  <tr>
    <th>Record</th>
    <th>Name</th>
    <th>Target</th>
  </tr>
  <tr>
    <td><code>CNAME</code></td>
    <td><code>www</code></td>
    <td><code>example.herokuapp.com.</code></td>
  </tr>
</table>

You can confirm that your DNS is configured correctly with the `host` command:

```term
$ host www.example.com
www.example.com is an alias for example.herokuapp.com.
...
```

Output of this command varies by Unix flavor, but should indicate that your hostname is either an alias or CNAME of `example.herokuapp.com`.

## Root domain

If you intend to use a root domain, e.g., `example.com` or `example.co.uk`, you must add it in addition to any custom subdomains.

```term
$ heroku domains:add example.com
Adding example.com to example... done
```

Zone apex domains (aka "naked", "bare" or "root" domains), e.g., `example.com`, using conventional DNS A-records are [not supported on Heroku](apex-domains). However, there are alternative configurations that allow for root domains while still being resilient in a dynamic runtime environment.

### CNAME functionality at the apex

Some DNS hosts provide a way to get CNAME-like functionality at the zone apex using a custom record type. Such records include:

* [ALIAS at DNSimple](http://support.dnsimple.com/articles/alias-record)
* [ANAME at DNS Made Easy](http://www.dnsmadeeasy.com/technology/aname-records/)

For each provider, the setup is similar: point the ALIAS or ANAME entry for your apex domain to example.herokuapp.com, just as you would with a CNAME record.

> callout
> Depending on the DNS provider, an empty or `@` Name value identifies the zone apex.

<table>
  <tr>
    <th>Record</th>
    <th>Name</th>
    <th>Target</th>
  </tr>
  <tr>
    <td><code>ALIAS</code> or <code>ANAME</code></td>
    <td>&lt;empty&gt; or <code>@</code></td>
    <td><code>example.herokuapp.com.</code></td>
  </tr>
</table>

If your DNS provider does not support such a record-type, and you are unable to switch to one that does, you will need to use subdomain redirection to send root domain requests to your app on Heroku.

### Subdomain redirection

For users without access to a modern DNS configuration, subdomain redirection is a viable alternative. Subdomain redirection results in a [301 permanent redirect](http://en.wikipedia.org/wiki/HTTP_301) to the specified subdomain for all root domain requests.

Almost all DNS providers offer  domain redirection services -- sometimes also called domain forwarding. However, be aware that, using this method, a [secure request](ssl-endpoint) to the root domain, e.g., `https://example.com`, will result in an error or warning being displayed to the user. If you're not using SSL, or are only distributing URLs in subdomain SSL form, e.g., `https://www.example.com`, this error won't affect you.

Establish a redirect/forward from the root domain to the `www` subdomain:

> callout
> Users of AWS's Route 53 DNS should follow [these instructions](https://devcenter.heroku.com/articles/route-53#naked-root-domain) to establish proper root domain redirection.

<table>
  <tr>
    <th>Record</th>
    <th>Name</th>
    <th>Target</th>
  </tr>
  <tr>
    <td><code>URL</code> or <code>Forward</code></td>
    <td><code>example.com</code></td>
    <td><code>www.example.com.</code></td>
  </tr>
  <tr>
    <td><code>CNAME</code></td>
    <td><code>www</code></td>
    <td><code>example.herokuapp.com.</code></td>
  </tr>
</table>

If not already configured, the `www` subdomain should then be a CNAME record reference to `example.herokuapp.com`.

## Wildcard domains

Wildcard domains allow you to map any and all subdomains to your app with a single record. A common use of a wildcard domain is with applications that use a personalized subdomain for each user or account.

You can add a wildcard domain if you own all existing apps already using the same top level domain (TLD). For example if an app is already using `www.example.com` you must own it to add `*.example.com`.

Add the wildcard domain to your app as you do any other domain, but use the `*` wildcard subdomain notation:

```term
$ heroku domains:add *.example.com
Adding *.example.com to example... done
```

If one of your apps has a wildcard domain, you can still add specific subdomains of the same TLD (top level domain) to any of your other apps. Specific subdomains are evaluated before wildcard domains when routing requests.

> warning
> It's important to make sure your DNS configuration agrees with the custom domains you've added to Heroku. In particular, if you have configured your DNS for `*.example.com` to point to `example.herokuapp.com`, be sure you also run `heroku domains:add *.example.com`. Otherwise, a malicious person could add `baddomain.example.com` to their Heroku app and receive traffic intended for your application.

### Wildcard DNS

Use the `*` wildcard subdomain notation to add a CNAME record to `example.herokuapp.com` with your DNS provider.

<table>
  <tr>
    <th>Record</th>
    <th>Name</th>
    <th>Target</th>
  </tr>
  <tr>
    <td><code>CNAME</code></td>
    <td><code>*</code></td>
    <td><code>example.herokuapp.com.</code></td>
  </tr>
</table>

After your DNS changes have propagated you will be able to look up and access any subdomain:

```term
$ host any-subdomain.example.com
any-subdomain.example.com is an alias for example.herokuapp.com
...

$ curl -I http://any-subdomain.example.com/
HTTP/1.1 200 OK
...
```

## Remove domain

Remove a domain with `domains:remove`:

```term
$ heroku domains:remove www.example.com
Removing www.example.com from example... done
```

If you destroy the app, any custom domains assigned to it will be freed. You can subsequently assign them to other apps.

## Domain precedence

Any user on Heroku can attempt to add any domain to their app. Instead of explicitly verifying domain ownership, Heroku enforces these rules to ensure that domains claimed by one user aren't used by other users on different apps:

* You can only add a domain to one app. For example if `www.example.com` is added to app `example-1` you can't also add it to app `example-2`. One app, however, can have multiple domains assigned.
* You can add a [wildcard domain](#wildcard-domains) if you own all
existing apps already using a corresponding subdomain. For example if
an app is already using `www.example.com` you must own it to add
`*.example.com`.
* You can add a subdomain or apex domain if you own the app assigned
the corresponding wildcard domain. For example to add
`www.example.com` or `example.com` you must own the app with
`*.example.com`, if such a custom domain exists.

If you're unable to add a domain that you own, please [file a support ticket](https://help.heroku.com/search?utf8=%E2%9C%93&q=can%27t+add+domain).

## The herokuapp.com domain

The domain `example.herokuapp.com` will always remain active, even if you've set up a custom domain. If you want users to use the custom domain exclusively, your app should send [HTTP status 301 Moved Permanently](http://tools.ietf.org/html/rfc2616#section-10.3.2) to tell web browsers to use the custom domain. The `Host` HTTP request header field will show which domain the user is trying to access; send a redirect if that field is `example.herokuapp.com`.

## UTF-8 domain names

Domain names that contain accented, or other non-ASCII, characters should be added using [punycode](http://en.wikipedia.org/wiki/Punycode). For instance, the `éste.com` domain name should be [converted](http://www.charset.org/punycode.php?decoded=%C3%A9ste.com&encode=Normal+text+to+Punycode) to `xn--ste-9la.com` when passed to `heroku domains:add`:

```term
$ heroku domains:add xn--ste-9la.com
```