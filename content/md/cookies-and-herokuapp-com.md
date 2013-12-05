---
title: Cookies and the Public Suffix List
slug: cookies-and-herokuapp-com
url: https://devcenter.heroku.com/articles/cookies-and-herokuapp-com
description: Applications in the `herokuapp.com` domain are unable to set cookies for `*.herokuapp.com`.
---

Applications in the `herokuapp.com` domain are unable to set cookies for `*.herokuapp.com`.  

This is enforced in Firefox, Chrome, and Opera.  `*.herokuapp.com` cookies may currently be set in Internet Explorer, but this behavior should not be relied upon and may change in the future.  

This has no effect on applications using [custom domain](https://devcenter.heroku.com/articles/custom-domains), nor does it impact applications in the `heroku.com` domain (i.e.,Bamboo applications).

## Scoping Cookies

On May 14, 2013, `herokuapp.com` was added to the Mozilla Foundation's [Public Suffix List](http://publicsuffix.org/).  This list is used in several browsers (Firefox, Chrome, Opera) to limit how broadly a cookie may be scoped.

Normally, a website may set browser cookies scoped either to its own domain, or any higher level DNS domain it belongs to.  This is controlled by the "domain" attribute in the server's Set-Cookie HTTP response header.  For example, https://www.cs.berkeley.edu/ can set a cookie in the user's browser that might be retransmitted to only itself, to all hosts ending in cs.berkeley.edu (e.g., radlab.cs.berkeley.edu), or even all hosts ending in berkeley.edu (e.g., english.berkeley.edu).  It can *NOT* set cookies scoped to all hosts ending in edu (e.g., www.stanford.edu).  This is not unique to .edu, but applies to all Top Level Domains (TLDs), including .com, .org, and .net.

The server is, of course, perfectly capable of passing a Set-Cookie header with `domain=.edu`, but it is not honored by any well-secured browser.  

This restriction on cookie setting at the TLD level has been around since the early days of the web.  It exists due to security reasons, both to prevent accidentally retransmitting cookies to 3rd parties, and to help provide some partial protection against cookie stuffing and more general types of [session fixation attacks](https://www.owasp.org/index.php/Session_fixation).  

The general reasoning is that web servers within the same DNS subdomain are usually considered to be operated by the same organization (e.g., The University of California, Berkeley), and are thus less likely to attack each other.  This is not true at the TLD level, as most TLDs allow any member of the general public to register a subdomain.

## Not just a TLD problem

This becomes more complicated when we consider many countries use second-level domains (e.g., .co.uk, .ne.jp) as pseudo TLDs, and have few or no restrictions on who may register subdomains (e.g., amazon.co.uk).  

To address that issue, for many years browser vendors used internally-maintained lists of public domains, regardless of what level they fall in the DNS hierarchy.  Inevitably this led to inconsistent behavior across browsers at a very fundamental level.

## The Public Suffix List

The Mozilla Foundation eventually began a project known as the [Public Suffix List](http://publicsuffix.org/), to record all of these public domains and share them across browser vendors.  Beyond Mozilla Firefox, Google and Opera have both incorporated this list into their browsers.  Microsoft's Internet Explorer (as of version 10) and Apple's Safari (as of version 6) do not use the Public Suffix List.

## Cedar and herokuapp.com

As Heroku applications on the Cedar stack are all hosted by default in the `herokuapp.com` domain, we also deal with the public suffix issue.  

We believe the benefit of registering ourselves with the Public Suffix List outweighed the loss of what is a dangerous and minimally useful bit of functionality (being able to share cookies across multiple apps).

While there are many legitimate use cases for sharing cookies across multiple applications in a common domain, this is done better and safer by using a [custom domain](https://devcenter.heroku.com/articles/custom-domains) for your applications.

## ssl:endpoints and herokussl.com

For various reasons, Heroku's [SSL Endpoints](https://devcenter.heroku.com/articles/ssl-endpoint) are hosted under another shared domain, herokussl.com.  As we do not encourage or support the use of  this domain as anything but a DNS record to point custom domain CNAMEs at, herokussl.com has also been added to the Public Suffix List.

## Bamboo and heroku.com

In order to minimize disruption for apps in the [Bamboo stack](https://devcenter.heroku.com/articles/bamboo) , we have decided not to add heroku.com itself to the public suffix list.

## For More Information

* The Public Suffix List project also has a partial list of other areas where the list is used.  This is available at [http://publicsuffix.org/learn/](http://publicsuffix.org/learn/) .
* The session fixation and cookie hijacking problem, including a good description of how it applies to Heroku specifically, is outlined in the paper [Origin Cookies: Session Integrity for
Web Applications](http://w2spconf.com/2011/papers/session-integrity.pdf)
* To learn more about the general browser security model, both for cookies and general, we recommend Michal Zalewski's excellent book, [The Tangled Web](http://lcamtuf.coredump.cx/tangled/) .