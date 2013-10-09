---
title: Custom Domains on Bamboo
slug: custom-domains-bamboo
url: https://devcenter.heroku.com/articles/custom-domains-bamboo
description: Assign additional custom and wildcard DNS domain names to your Heroku applications.
---

<div class="deprecated" markdown="1">This article applies to apps on the [Bamboo](bamboo) stack. For the most recent stack, [Cedar](cedar), see [Custom Domains](custom-domains).</div>

All Bamboo apps on Heroku are accessible via their per-app subdomain:
 `example.heroku.com`. In addition, you can assign custom domains to an app.

After assigning a custom domain to your app, you must also point DNS to Heroku. You can use one of the [DNS management add-ons](https://addons.heroku.com/?q=dns), or use your own DNS provider and manually configure the records for your domains.


Heroku setup
------------

The first step is to tell Heroku to route requests for your domain to your app:

    :::term
    $ heroku domains:add www.example.com
    Adding www.example.com to example... done

You can add any number of domains to a single app by repeating the add command with different values.

Remove domains with:

    :::term
    $ heroku domains:remove www.example.com
    Removing www.example.com from example... done

You can also clear all domains at once:

    :::term
    $ heroku domains:clear
    Removing all domains from example... done

## DNS setup

Next, you must configure your DNS to point your application hostnames to Heroku.

### Subdomains (www.example.com)

For each subdomain you want to set up, configure your DNS with a CNAME record pointing the subdomain to the applicable Heroku hostname, for example `example.heroku.com`.

You can confirm that your DNS is configured correctly with the `host` command:

    :::term
    $ host www.example.com
    www.example.com is an alias for example.heroku.com.
    example.heroku.com is an alias for proxy.heroku.com.
    ...

Output of this command varies by Unix flavor, but it should indicate that
your host name is a CNAME of `example.heroku.com`.

### Apex domains (example.com)

Zone apex domains (aka "naked" domains or "bare" domains), for example `example.com`, are not supported on Heroku apps, because DNS forbids CNAME records on the zone apex. However, some DNS hosts provide a way to get CNAME-like functionality at the zone apex. Known providers:

- [ANAME at DNS Made Easy](http://www.dnsmadeeasy.com/technology/aname-records/)
- [ALIAS at DNSimple](http://support.dnsimple.com/questions/32826-What-is-an-ALIAS-record)

For each provider, the setup is similar: point the ALIAS or ANAME entry for your apex domain to `example.heroku.com`, just as you would with a CNAME record.

## Wildcard domains

If you'd like your app to respond to any subdomain under your custom domain name (as in `*.example.com`), you can set up a wildcard domain.

First, add the wildcard domain on Heroku:

    :::term
    $ heroku domains:add *.example.com
    Adding *.example.com to example... done
    

Then, configure your DNS registrar to point `*.example.com` at `example.heroku.com`.

If things are set up correctly you should be able to look up any subdomain:

    :::term
    $ host any-subdomain.example.com
    any-subdomain.example.com is an alias for example.heroku.com.
    ...

    $ curl http://any-subdomain.example.com/
    HTTP/1.1 200 OK

## IP addresses

The Heroku routing stack uses a collection of IP addresses that can change at any time, and using `A` records to point to your app is not supported.  Instead, use `CNAME` records as described above.