---
title: Add-on Operations
slug: addon-operations
url: https://devcenter.heroku.com/articles/addon-operations
description: The most common operational issues encountered by add-on providers, and how to deal with them appropriately.
---

Your add-on service is now launched, and users are signing up and getting going. In the first phase, your focus was on integration and testing. Now that your add-on is launched, your focus will shift to the ongoing operation of your cloud service. 

The following sections cover the most common operational issues encountered by our providers, and outlines how to deal with them appropriately.

## Support
As an add-on provider you are responsible for supporting your service, and need to be set up to do so. Users will be asking questions and reporting problems, and you must respond to such inquiries in a timely and helpful manner. 

While Heroku users are encouraged to submit requests through the Heroku support portal, you must be prepared to receive requests directly as well.

### Dealing with support tickets from Heroku
Heroku operates a ticket-based helpdesk system. Every add-on provider gets an agent account in the system that will forward inquiries to a designated email address (ie. support@yourcompany.com). The flow of an add-on related support ticket looks like this:

* User submits a ticket at http://support.heroku.com
* Heroku Support determines it's related to a specific add-on.
* Ticket is assigned to the your agent account, and the you are automatically notified.
* You log in to the support portal and respond via the web interface, or by email.
* Finally, you mark the ticket "solved", once a resolution or workaround has been determined.

### Direct support requests
Most add-on providers operate their own support ticket systems. At an absolute minimum, you need to provide a clearly advertised email address (such as support@yourcompany.com) through which Heroku users can contact you.

## User Notifications
Occasionally, you will find it necessary to directly notify an add-on user. Under the terms of the Add-ons License Agreement, Heroku can provide you email addresses of your add-on users. You may use this information exclusively for issues related to the operation of your add-on. 

Examples of acceptable notifications are:

* Scheduled maintenance notifications
* Information service interruptions and subsequent follow-ups on service status
* Plan overages
* Terms of Service (TOS) violations
* Product feature updates
* Product survey/feedback

All non-critical notifications must contain opt-out instructions or links.

## Stability
Reliable and transparent operation is key to the success of any cloud service, including those powering Heroku add-ons. That said, any service will occasionally experience operational issues that affect customers. Acting and communicating appropriately around such events is critical to emerging with the customer's trust and patronage intact.

### Service status
Maintaining a service status page or blog is a simple way to inform users of any operational issues that could affect their usage. Having an always-up-to-date status provides a great starting point for any customer experience a problem, and can alleviate unnecessary load on your team in situations where all hands are required to fix a problem.

### Scheduled maintenance
Always provide advance notice on any scheduled maintenance that will affect the operation of your service. In general, 24 hours is the least notice you should give your customers. Post maintenance notice on your status blog and notify users by email.

### Interruptions and downtime
Unexpected downtime happens. When it does, it's critical that you:

* Acknowledge the problem as soon as you know of it. Use the status page and email notifications.
* Restore service as quickly as possible, and notify using the same channels.
* Provide a post-mortem analysis explaining what went wrong, and what is being done to prevent a similar outage in the future. 