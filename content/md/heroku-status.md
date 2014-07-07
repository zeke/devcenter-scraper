---
title: Heroku Status
slug: heroku-status
url: https://devcenter.heroku.com/articles/heroku-status
description: A description of the Heroku Status site, what it includes, how monthly uptime figures are calculated and how to sign up for alerts.
---

[Heroku Status](https://status.heroku.com/) provides the current status and incident history report for the Heroku platform. The status site covers all stacks on the Heroku platform (Bamboo and Cedar) as well as key add-ons necessary for smooth operation of production applications.

## Accessing Heroku Status

The current status and history of platform issues is shown at:

[https://status.heroku.com](https://status.heroku.com)

The heroku client can be used to ascertain the current status:

```term
$ heroku status
=== Heroku Status
Development: No known issues at this time.
Production:  No known issues at this time.
```

## Status information

The [status site](https://status.heroku.com) includes the current status of the platform, the uptime for the last full month, and the most recent incidents, all broken down into production and development issues. The site will auto-refresh when there is an incident or update.

**Production** issues are those that affect running, stable, production applications that have at least two web dynos and use a production-grade database (or no database at all). Includes dynos, database, HTTP caching, other platform components (DelayedJob workers, scheduler, etc.), and routing.

**Development** issues are those that affect the health of deployment workflow and tools. Includes deployment (git push, gem installation, slug compilation, etc.), general git activity, command line gem/API (scaling up/down, changing configuration, etc.), and related services (attached processes etc.). Development also includes issues specific to the operation of non-production applications such as unidling free 1-dyno apps and the operation of development databases.

Note that the uptime numbers are weighted averages based on the percentage of apps affected and do not include third-party add-ons, even if they are reported as incidents on the status site.

## Getting notified when there is an incident

You can sign up for email or SMS alerts when there are issues affecting the platform. Go to the [status site](https://status.heroku.com) and click on [Subscribe to Notifications](https://status.heroku.com/#notifications). You can also follow the [twitter feed](https://twitter.com/herokustatus), [RSS feed](https://status.heroku.com/feed), or connect to the status site via its API.

## Uptime calculation

Heroku is a distributed platform spread across many different datacenters and components. During any given incident, it is rare for all applications running on the platform to be affected. For this reason, we report our uptime as an average derived from the number of affected applications.

![Heroku Status Uptime](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/177-original.jpg?1370040613 "Heroku Status Uptime")

Uptime figures are featured on the [Heroku Uptime site](https://status.heroku.com/uptime) and are
based on a calculation across our entire distributed platform. We analyze data from a variety of logging and monitoring tools, and then use it to split each incident into segments.  Each segment counts the number of affected apps for a designated period of time.  Our measurement considers:

1. The duration of each outage
2. The percentage of running applications affected in each outage,  ([applications consisting only of a single idled web dyno](dynos#the-dyno-manager) are not considered).
3. The total minutes of potential uptime in a month, and is calculated with the
following equation:

<!-- comment to work around markdown weirdness -->

    TM - SUM((OM1 * PA1) .. (OMn * PAn))
    ------------------------------------
                    TM

<!-- comment to work around markdown weirdness -->

* **TM**: `Total # of minutes in the month` 
* **OM**: `# of minutes spent in outage`
* **PA**: `% of affected applications` 

Once we have calculated the uptime for a given month, it will be displayed on our [status site](https://status.heroku.com/uptime). Gathering and tallying these numbers is a manual process so there may be a delay before the uptime for a given month is posted.

In addition to monthly uptime figures, we're also showing incident occurrences on a per-day basis. These incidents are indicated on the calendar based on length and severity of incident.
## Actions to take when you suspect an outage

Check the status site if there is a current incident. If nothing is reported, or if you are experiencing something different than what is reported, [submit a support ticket](https://help.heroku.com/tickets/new).

## Heroku Status API v3

### Get current status

>callout
>The Heroku Status API has CORS support, allowing client-side JavaScript requests.

```term
$ curl "https://status.heroku.com/api/v3/current-status"
{"status":{"Production":"green","Development":"green"},"issues":[]}
```

### Get list of issues (optionally limited by date or count)

```term
$ curl "https://status.heroku.com/api/v3/issues?since=2012-04-24&limit=1"
[{"created_at":"2014-04-01T17:16:00Z","id":604,"resolved":true,"status_dev":"green","status_prod":"green","title":"Error when deploying certain apps","upcoming":false,"updated_at":"2014-04-02T06:03:49Z","href":"https://status.heroku.com/api/v3/issues/604","full_url":"https://status.heroku.com/incidents/604","updates":[{"contents":"This change was reverted at 7:26 PM PDT (02:26 UTC).","created_at":"2014-04-01T19:26:00Z","id":1961,"incident_id":604,"status_dev":"green","status_prod":"green","title":"Error when deploying certain apps","update_type":"resolved","updated_at":"2014-04-02T06:03:55Z"},{"contents":"At 5:16 PM PDT (00:16 UTC), we deployed a change which validated the list of add-ons being returned from buildpacks. Buildpacks failing this validation would fail with the following error:\r\n\r\n```\r\nInvalid add-on specification. Buildpacks must inform addons as a string.\r\n```\r\n\r\nThis impacted some of our own buildpacks, such as Python, Clojure, and PHP, when these buildpacks did not specify any add-ons to install.","created_at":"2014-04-01T17:16:00Z","id":1960,"incident_id":604,"status_dev":"yellow","status_prod":"green","title":"Error when deploying certain apps","update_type":"issue","updated_at":"2014-04-02T06:04:32Z"}]}]
```

### Get a single issue by ID number

```term
$ curl "https://status.heroku.com/api/v3/issues/336"
{"created_at":"2012-04-24T14:02:39Z","id":336,"resolved":true,"status_dev":"green","status_prod":"green","title":"Custom Domains: Errors Adding / Updating","upcoming":false,"updated_at":"2012-06-22T23:41:08Z","href":"https://status.heroku.com/api/v3/issues/336","full_url":"https://status.heroku.com/incidents/336","updates":[{"contents":"The fix has been applied, and custom domains are functioning as expected.\r\n\r\nFurther investigation shows that custom domains created or updated after 4/23/2012 19:50 UTC were affected.","created_at":"2012-04-24T15:24:58Z","id":980,"incident_id":336,"status_dev":"green","status_prod":"green","title":null,"update_type":"resolved","updated_at":"2012-06-22T23:39:21Z"},{"contents":"All previously malfunctioning custom domains are now online.  Engineers are continuing to roll out the fix.","created_at":"2012-04-24T15:06:53Z","id":979,"incident_id":336,"status_dev":"yellow","status_prod":"green","title":null,"update_type":"update","updated_at":"2012-06-22T23:39:22Z"},{"contents":"The issue has been identified and engineers are working to fix.","created_at":"2012-04-24T14:45:49Z","id":978,"incident_id":336,"status_dev":"yellow","status_prod":"green","title":null,"update_type":"update","updated_at":"2012-06-22T23:39:22Z"},{"contents":"Engineers are still investigating the source of issues regarding custom domains. We have determined that only domains added or updated in the past 24 hours should be affected.\r\n\r\nWe'll continue to provide more information as it becomes available.","created_at":"2012-04-24T14:23:58Z","id":977,"incident_id":336,"status_dev":"yellow","status_prod":"green","title":null,"update_type":"update","updated_at":"2012-06-22T23:39:22Z"},{"contents":"Engineers are investigating issues with custom domains around applications. We will provide more information as it becomes available.","created_at":"2012-04-24T14:02:39Z","id":976,"incident_id":336,"status_dev":"yellow","status_prod":"green","title":null,"update_type":"issue","updated_at":"2012-06-22T23:39:22Z"}]}
```