---
title: EV SSL Certificates and Heroku-owned Applications
slug: ev-ssl-certificates-and-heroku-owned-apps
url: https://devcenter.heroku.com/articles/ev-ssl-certificates-and-heroku-owned-apps
description: Heroku uses Extended Validation SSL Certificates on its major web properties, distinguishing them from any other application that may be running on Heroku.
---

Heroku uses Extended Validation SSL Certificates on its major web properties. When you see this certificate, the web application is run and maintained by Heroku itself, distinguishing it from any other application that may be running on the Heroku platform.

## Overview
Heroku-owned applications (e.g. `id.heroku.com`, `dashboard.heroku.com`, `devcenter.heroku.com`) are protected using Extended Validation SSL certificates, also known as EV certs or Fancy Pants certs.  If you see a green box on the left-hand side of your browser's navigation bar saying "Heroku, Inc.", it's us.  If you don't, it's probably a customer of ours.  In Chrome on MacOS, a site with a Fancy Pants cert looks like:

![Heroku-owned Application](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/227-original.jpg)

Compare this with a customer-owned Bamboo app which uses our regular wildcard `*.heroku.com` cert:

![Customer application running on Heroku, but not owned by Heroku](https://s3.amazonaws.com/heroku.devcenter/heroku_assets/images/226-original.jpg)

## Caveats
Despite being Heroku-owned, we use non-EV, regular certs for `api.heroku.com` and other API-ish applications which aren't intended for viewing in a browser.  We also have a number of purely internal Heroku applications that use regular certs.  The intent of our Fancy Pants cert usage is to help differentiate between Heroku-owned and customer-owned applications.  A motivating example is determining if the link you just clicked is due to a phishing attack.  In the event of an HTML-displaying bug on `api.heroku.com`, where an attacker could display phishing content or otherwise deceive users, the lack of a Fancy Pants cert would actually be an advantage.

If we've overlooked any Heroku-owned sites with browser UI, [please let us know](https://www.heroku.com/policy/security#vuln_report).  Please note that reports of this nature are *not* eligible for our Security Hall of Fame.

Cryptographically, our Fancy Pants certs are no different from our regular certs.  Currently (October 2013), both contain 2048-bit RSA keys with SHA-1 for hashing.  For compatibility with older clients (I'm looking at you, IE 6!), and due to the lack of practical attacks on SHA-1 as used for certificates, we're still holding off on ECC and SHA-2.

## Guidance on Customer use of Fancy Pants Certificates
While Heroku believes this standard is a good fit for our specific use case, we neither encourage nor discourage you from obtaining Fancy Pants certs for your own custom DNS domains.  These certificates are fully supported on our [SSL Endpoints](https://devcenter.heroku.com/articles/ssl-endpoint).  Indeed, all of our self-hosted apps identified by Fancy Pants certs use the same SSL Endpoint mechanism as our customers.

```
tmaher@bananaweizen:~$ host www.heroku.com
www.heroku.com is an alias for miyagi-7942.herokussl.com.
miyagi-7942.herokussl.com is an alias for elb029931-26494784.us-east-1.elb.amazonaws.com.
elb029931-26494784.us-east-1.elb.amazonaws.com has address 54.243.76.97
elb029931-26494784.us-east-1.elb.amazonaws.com has address 23.21.198.2
elb029931-26494784.us-east-1.elb.amazonaws.com has address 174.129.17.173
```

However, there are very good reasons to not use them.  As indicated by our use of the gently mocking term "Fancy Pants", EV certs are usually much more expensive, and provide exactly the same cryptographic mechanisms as regular certificates.  The only user-perceivable difference is the green indicator in the browser navigation bar.  For our needs, that's a good fit.  In many other use cases, it isn't.  For example, for mobile applications and other systems using a non-browser client, we encourage [Certificate Pinning](https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning).

## Background
[Fancy Pants Certificates](http://en.wikipedia.org/wiki/Fancy_Pants_Certificates) are a sometimes-controversial feature of the SSL CA system.  The problem Fancy Pants certificates try to solve is that SSL certificates in general have become too easy to spoof.  The democratization of SSL certificates on the whole is absolutely a good thing.  It encourages the use of ubiquitous encryption, which significantly reduces the amount of useful information available to an attacker able to observe major Internet backbone traffic.  However, it has resulted in Certificate Authorities and their resellers automating the generation of certs.  Consequently the due diligence they perform on the client has diminished, which leads to attackers being able to occasionally get a cert issued inappropriately.

With Fancy Pants certs, the CAs agree to a minimum standard of validating that the cert requester is who they purport to be.  This can include reviewing legal records and humans talking to each other.  In exchange, the cert issued contains special metadata indicating this heightened review process, which is displayed to the end-user as a green box in the navigation bar.  It's certainly foreseeable that Fancy Pants certs will see a similar race to the bottom as with regular certs, and also be issued inappropriately on occasion.  For Heroku's specific problem - indicating our ownership of a website when we host potentially malicious sites in the same DNS domain - we believe Fancy Pants certs will be useful.

Long-term, all new customer applications are hosted in `herokuapp.com`, and we no longer allow customers to create new applications hosted under `heroku.com` itself.