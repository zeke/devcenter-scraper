---
title: Regions
slug: regions
url: https://devcenter.heroku.com/articles/regions
description: Creating and managing a Heroku application in a specific geographic region.
---

>warning
>This article describes a [beta feature](heroku-beta-features). Functionality may change prior to general availability.

Heroku is available in two geographic regions: the [US and EU](#data-center-locations).  The EU region is beta.

You can choose your app's region to minimize latency for your end users. I.e. if your users are primarily in Europe your app will be faster for them if it's running in Europe.

## Heroku Toolbelt

You must have the [Heroku Toolbelt](https://toolbelt.heroku.com/) installed to use the features described in this article. [Verify your toolbelt installation](https://devcenter.heroku.com/articles/heroku-command#installing-the-heroku-cli) and update it to the latest version with `heroku update`.

## Select a region

Unless specified, all apps will be created in the `us` region. To specify a different region, use the `--region` flag when creating the app:

```term
$ heroku create --region eu
Creating calm-ocean-1234... done, region is eu
http://calm-ocean-1234.herokuapp.com/ | git@heroku.com:calm-ocean-1234.git
Git remote heroku added
```

>note
>Existing applications can be [migrated](app-migration) to a new region.

To verify the app's region, check the `Region` attribute of the `heroku info` command:

```term
$ heroku info
=== calm-ocean-1234
Git URL:       git@heroku.com:calm-ocean-1234.git
Owner Email:   user@test.com
Region:        eu
Repo Size:     164M
...
```

List all available regions with:

```term
$ heroku regions
=== regions
eu  Europe
us  United States
```

## Add-ons

Add-ons with region support will be provisioned in the same region as the app. Provision them as you normally would:

```term
$ heroku addons:add heroku-postgresql
```

Add-ons that don't require a low-latency connection to your app will be provisioned in the default region if unavailable in your app's region. If an add-on *is* latency sensitive and *is not* available in the same region as your app, provisioning will fail:

```term
$ heroku addons:add cloudcounter
Adding cloudcounter on calm-ocean-1234... failed
!     This app is in region eu, cloudcounter:basic is only available in region us.
```

### Supported add-ons

You can find add-ons supporting your app's region using both the CLI and the web interface. To find add-ons supported in the `eu` region using the CLI, run this command:

```term
$ heroku addons:list --region=eu
```

On [addons.heroku.com](https://addons.heroku.com/) you can use the search box to find add-ons that support the `eu` region by searching for ["europe"](https://addons.heroku.com/?q=europe). You can narrow your search further, for example to Redis add-ons that support the `eu` region by searching for ["Redis europe"](https://addons.heroku.com/?q=Redis%20europe).

## Deployment

Apps are deployed to the region specified on creation. [Deploy your app with git](git), as usual:

```term
$ git push heroku master
```

## Dynos

[One-off dynos](https://devcenter.heroku.com/articles/one-off-dynos) are also run in the region where the app was created. This is also true of secondary services such as [Heroku Scheduler](https://addons.heroku.com/scheduler) that provision one-off dynos to execute jobs.

[PX dynos](https://devcenter.heroku.com/articles/dyno-size) are not available in the EU region.

## Custom domains

Adding [custom domains](custom-domains) to apps running outside the `us` region is the same as addin domains to apps in the `us` region. Add the following CNAME record in your DNS provider's control panel (substituting `example` with the name of your Heroku app).

<table>
  <tr>
    <th>Type</th>
    <th>Name</th>
    <th>Target</th>
  </tr>
  <tr>
    <td>CNAME</td>
    <td>www</td>
    <td>example.herokuapp.com</td>
  </tr>
</table>

This will route all traffic addressed to `www.example.com` to `example.herokuapp.com`.

>warning
>[A-records are not supported](apex-domains) on Heroku. If you wish to host an apex domain like "example.com" on Heroku you must do so using an ALIAS or similar record from your DNS provider that allows for an apex domain to CNAME mapping.

## SSL

To utilize SSL, provision an [SSL Endpoint](ssl-endpoint) for your application and upload your SSL certs.

```term
$ heroku addons:add ssl
Adding ssl on example... done, v1 ($20/mo)
Next add your certificate with `heroku certs:add PEM KEY`.
Use `heroku addons:docs ssl` to view documentation.

$ heroku certs:add server.crt server.key
Resolving trust chain... done
Adding SSL Endpoint to example... done
example now served by example.herokuapp.com
```

If your custom domain is properly configured, no additional DNS configuration is required (this differs from the `us` region behavior, which requires using a domain like `tokyo-123.herokussl.com`). All traffic to `www.example.com` can now be served over SSL.

## Data center locations

<table>
  <tr>
    <th>Region Name</th>
    <th>Data Center Location</th>
  </tr>
  <tr>
    <td>us</td>
    <td>amazon-web-services::us-east-1</td>
  </tr>
  <tr>
    <td>eu</td>
    <td>amazon-web-services::eu-west-1</td>
  </tr>
</table>

## Safe Harbor & data residency

Although each supported region represents a geographically isolated platform runtime, no assumptions should be made about the physical residency of your application data.

Consider the following cases where data is stored in a different location than your app:

* Some non-latency sensitive add-ons can be provisioned in a different region as your app.
* Application logs are routed to [Logplex](logplex), currently hosted in the US.
* [PG Backup](https://addons.heroku.com/pgbackups) snapshots are stored in the US, and [WAL files](http://www.postgresql.org/docs/current/static/wal-intro.html) continuously sent to the US.
* No guarantees are made about the physical location of Heroku's [control surface APIs](http://www.heroku.com/how/command) through which all CLI commands and the management of your applications occur.

The public beta of Regions is not designed to address data protection issues and, for this reason, is not Safe Harbor certified. Please choose a region based on the location of your users, not the laws that govern your data.

## Migrating existing apps

Existing applications can [migrate to a new region](app-migration).
         
