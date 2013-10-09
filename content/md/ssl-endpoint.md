---
title: SSL Endpoint
slug: ssl-endpoint
url: https://devcenter.heroku.com/articles/ssl-endpoint
description: Enabling and configuring SSL on custom domains using the SSL endpoint add-on.
---

SSL is a cryptographic protocol that provides end-to-end encryption and integrity for all web requests. Apps that transmit sensitive data should enable SSL to ensure all information is transmitted securely.

To enable SSL on a custom domain, e.g., `www.example.com`, use the SSL Endpoint add-on. ([SSL Endpoint](https://addons.heroku.com/ssl) is a paid add-on service. Please keep this in mind when provisioning the service).

## Overview

Because of the unique nature of SSL validation, provisioning SSL for your application is a multi-step process that involves several third-parties. You will need to:

1. Purchase an SSL certificate from your SSL provider
1. Provision an SSL Endpoint from Heroku
1. Upload the cert to Heroku
1. Update your DNS settings to reference the new SSL Endpoint URL

## Acquire SSL certificate

> callout
> Staging, and other non-production, apps can use a free [self-signed SSL certificate] (https://devcenter.heroku.com/articles/ssl-certificate-self) instead of purchasing one.

Purchasing an SSL cert varies in cost and process depending on the vendor. [DNSimple](https://dnsimple.com/) offers the simplest way to purchase a certificate and is highly recommended. If you're able to use DNSimple, see [purchasing an SSL cert with DNSimple](https://devcenter.heroku.com/articles/ssl-certificate) for instructions.

Otherwise, using other SSL providers will require some or all of the following steps.

### Generate private key

Before requesting an SSL cert, you need to generate a private key in your local environment using the `openssl` tool. If you aren't able to execute the `openssl` command from the terminal you may need to install it.

<table>
  <tr>
    <th width="25%">If you have...</th>
    <th>Install with...</th>
  </tr>
  <tr>
    <td>Mac OS X</td>
    <td style="text-align: left"><a href="http://mxcl.github.com/homebrew/">Homebrew</a>: <code>brew install openssl</code></td>
  </tr>
  <tr>
    <td>Windows</td>
    <td style="text-align: left"><a href="http://gnuwin32.sourceforge.net/packages/openssl.htm">Windows complete package .exe installer</a></td>
  </tr>
  <tr>
    <td>Ubuntu Linux</td>
    <td style="text-align: left"><code>apt-get install openssl</code></td>
  </tr>
</table>

Use `openssl` to generate a new private key.

> callout
> When prompted, enter an easy password value as it will only be used when generating the CSR and not by your app at runtime.


```term
$ openssl genrsa -des3 -out server.pass.key 2048
...
Enter pass phrase for server.pass.key:
Verifying - Enter pass phrase for server.pass.key:
```

The private key needs to be stripped of its password so it can be loaded without manually entering the password.

```term
$ openssl rsa -in server.pass.key -out server.key
```

You now have a `server.key` private key file in your current working directory.

### Generate CSR

A CSR is a certificate signing request and is also required when purchasing an SSL cert. Using the private key from the previous step, generate the CSR. This will require you to enter identifying information about your organization and domain.

Though most fields are self-explanatory, pay close attention to the following:

<table>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
<tr>
<td>Country Name</td>
<td style="text-align: left;">The two letter code, in <a href="http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm">ISO 3166-1 format</a>, of the country in which your organization is based.</td>
</tr>
<tr>
<td>Common Name</td>
<td style="text-align: left;">This is the <em>fully qualified domain name</em> that you wish to secure.
<ul>
<li>For a single subdomain: <code>www.example.com</code></li>
<li>For all subdomains, specify the wildcard URL: <code>*.example.com</code></li>
<li>For the root domain: <code>example.com</code></li></td>
</tr>
</table>

> warning
> The `Common Name` field must match the secure domain. You cannot purchase a certificate for the root domain, e.g., `example.com`, and expect to secure `www.example.com`. The inverse is also true.
> Additionally, SSL Endpoint only supports one certificate per app. Please keep this in mind for multi-domain applications and specify a `Common Domain` that matches all required domains.

Generate the CSR:

```term
$ openssl req -nodes -new -key server.key -out server.csr
...
Country Name (2 letter code) [AU]:US
Common Name (eg, YOUR name) []:www.example.com
...
```

The result of this operation will be a `server.csr` file in your local directory (alongside the `server.key` private key file from the previous step).

### Submit CSR to SSL provider

Next, begin the process of creating a new SSL certificate with your chosen certificate provider. This will vary depending on your provider, but at some point you will need to upload the CSR generated in the previous step.

You may also be asked for what web server to create the certificate. If so, select Nginx as the web server for use on Heroku. If Nginx is not an option, Apache 2.x will also suffice.

If you're given an option of what certificate format to use (PKCS, X.509 etc...) choose X.509.

If you want to secure more than one subdomain you will need to purchase a wildcard certificate from your provider. While these certificates are typically more expensive, they allow you to serve requests for all subdomains of `*.example.com` over SSL.

On completion of the SSL certificate purchase process you should  have several files including:

* The SSL certificate for the domain specified in your CSR, downloaded from your certificate provider. This file will have either a `.pem` or `.crt` extension.
* The private key you generated in the first step, `server.key`.

If your certificate provider requires, you may also have an intermediate certificate or certificate bundle. This file usually has a `.pem` extension.

## Provision the add-on

Once you have the SSL certificate file, private key and any additional intermediate certificate bundles you are ready to configure SSL Endpoint for your app. First, provision an endpoint.

```term
$ heroku addons:add ssl:endpoint
Adding ssl:endpoint on example... done, v1 ($20/mo)
```

Next add your certificate, any intermediate certificates, and private key to the endpoint with the `certs:add` command.

> callout
> Heroku automatically strips out unnecessary parts of the certificate chain as part of the `certs:add` command. In some scenarios, this may not be desired. To avoid this automatic manipulation of the chain, include the `--bypass` flag.

```term
$ heroku certs:add server.crt bundle.pem server.key
Adding SSL Endpoint to example... done
example now served by tokyo-2121.herokussl.com.
Certificate details:
Expires At: 2012-10-31 21:53:18 GMT
Issuer: C=US; ST=CA; L=SF; O=Heroku; CN=www.example.com
Starts At: 2011-11-01 21:53:18 GMT
...
```

The endpoint URL assigned to your app will be listed in the output, `tokyo-2121.herokussl.com` in this example. Visiting this URL will result in a "no such app" message -- this is expected. Read further for proper verification steps.

> note
> Apps located in a non-default [region](regions), e.g., Europe, will not have a distinct `herokussl.com` SSL endpoint URL. Instead, the endpoint URL will just be your app's `herokuapp` domain, e.g., `example.herokuapp.com`. The output of the `certs:add` command will accurately reflect this.

## Endpoint details

You can verify the details of the SSL endpoint configuration with `heroku certs`.

```term
$ heroku certs
Endpoint                    Common Name         Expires                    Trusted
------------------------    ----------------    -----------------------    -------
tokyo-2121.herokussl.com    www.example.com    2012-10-31 21:53:18 GMT    False
```

To get the detailed information about a certificate at any time use `certs:info`.

```term
$ heroku certs:info
Fetching SSL Endpoint tokyo-2121.herokussl.com info for example... done
Certificate details:
Expires At: 2012-10-31 21:53:18 GMT
Issuer: C=US; ST=CA; L=SF; O=Heroku; CN=www.example.com
Starts At: 2011-11-01 21:53:18 GMT
Subject: C=US; ST=CA; L=SF; O=Heroku; CN=www.example.com
...
```

> callout
> In rare circumstances, it can take an SSL endpoint up to 30 minutes before it's provisioned. If you are unable to hit the endpoint URL, please wait that amount of time before proceeding.

If you have a `herokussl.com` endpoint URL, visit it via https, e.g., `https://tokyo-2121.herokussl.com`. This should throw a cert error saying that the certificate at www.example.com doesn't match tokyo-2121.herokussl.com. This means that you are serving up the cert that you'd expect to serve (just not for the requested `herokussl.com` domain).

## DNS and domain configuration

Once the SSL Endpoint is provisioned and your cert confirmed, you must route requests for you secure domain through the endpoint URL. Unless you've already done so, add the domain specified when generating the CSR to your app with:

```term
$ heroku domains:add www.example.com
Added www.example.com to example... done
```

> note
> Assuming proper [custom domain DNS configuration](https://devcenter.heroku.com/articles/custom-domains#custom-subdomains) already, apps located in a non-default [region](regions), e.g., Europe, will not have to make any additional DNS modifications. Such apps can skip the remainder of this DNS section.

### Subdomain

If you're securing a subdomain, e.g., `www.example.com`, modify your DNS settings and create a CNAME record to the endpoint.

<table>
  <tr>
    <th>Record</th>
    <th>Name</th>
    <th>Target</th>
  </tr>
  <tr>
    <td><code>CNAME</code></td>
    <td><code>www</code></td>
    <td><code>tokyo-2121.herokussl.com.</code></td>
  </tr>
</table>

If you're using a wildcard certificate your DNS setup will look similar.

<table>
  <tr>
    <th>Record</th>
    <th>Name</th>
    <th>Target</th>
  </tr>
  <tr>
    <td><code>CNAME</code></td>
    <td><code>*</code></td>
    <td><code>tokyo-2121.herokussl.com.</code></td>
  </tr>
</table>

### Root domain

If you're securing a root domain, e.g., `example.com`, you must be using a [DNS provider that provides CNAME-like functionality at the zone apex](https://devcenter.heroku.com/articles/custom-domains#cname-functionality-at-the-apex).

Modify your DNS settings and create an ALIAS or ANAME record to the endpoint.

<table>
  <tr>
    <th>Record</th>
    <th>Name</th>
    <th>Target</th>
  </tr>
  <tr>
    <td><code>ALIAS</code> or <code>ANAME</code></td>
    <td>&lt;empty&gt; or <code>@</code></td>
    <td><code>tokyo-2121.herokussl.com.</code></td>
  </tr>
</table>

## Testing SSL

Use a command line utility like `curl` to test that everything is configured correctly for your secure domain.

> callout
> The `-k` option tells curl to ignore untrusted certificates.

```term
$ curl -kvI https://www.example.com
* About to connect() to www.example.com port 443 (#0)
*   Trying 50.16.234.21... connected
* Connected to www.example.com (50.16.234.21) port 443 (#0)
* SSLv3, TLS handshake, Client hello (1):
* SSLv3, TLS handshake, Server hello (2):
* SSLv3, TLS handshake, CERT (11):
* SSLv3, TLS handshake, Server finished (14):
* SSLv3, TLS handshake, Client key exchange (16):
* SSLv3, TLS change cipher, Client hello (1):
* SSLv3, TLS handshake, Finished (20):
* SSLv3, TLS change cipher, Client hello (1):
* SSLv3, TLS handshake, Finished (20):
* SSL connection using AES256-SHA
* Server certificate:
* 	 subject: C=US; ST=CA; L=SF; O=SFDC; OU=Heroku; CN=www.example.com
* 	 start date: 2011-11-01 17:18:11 GMT
* 	 expire date: 2012-10-31 17:18:11 GMT
* 	 common name: www.example.com (matched)
* 	 issuer: C=US; ST=CA; L=SF; O=SFDC; OU=Heroku; CN=www.heroku.com
* 	 SSL certificate verify ok.
> GET / HTTP/1.1
> User-Agent: curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8r zlib/1.2.3
> Host: www.example.com
> Accept: */*
...
```

Pay attention to the output. It should print `SSL certificate verify ok`. If it prints something like `common name: www.example.com (does not match 'www.somedomain.com')` then something is not configured correctly.

## Update certificate

> callout
> Heroku automatically strips out unnecessary parts of the certificate chain as part of the `certs:update` command. In some scenarios, this may not be desired. To avoid this automatic manipulation of the chain, include the `--bypass` flag.

You can update a certificate using the `certs:update` command with the new cert and existing private key:

```term
$ heroku certs:update server.crt server.key
Updating SSL Endpoint endpoint tokyo-2121.herokussl.com for example... done
```

### Undo

If, for some reason, the new certificate is not working properly and traffic to your app is being disrupted, you can roll back to the previous certificate:

```term
$ heroku certs:rollback
Rolling back SSL Endpoint endpoint tokoy-2121.herokussl.com on example... done
```

If there is no previous certificate, this command will fail.

## Remove certificate

You can remove a certificate using the `certs:remove` command:

```term
$ heroku certs:remove
Removing SSL Endpoint endpoint tokyo-2121.herokussl.com on example... done
```

> warning
> Removing an endpoint does not stop billing. To stop billing, you must remove the SSL endpoint add-on. Remove the add-on with `heroku addons:remove ssl:endpoint`.

If you try to remove the SSL endpoint add-on before the certificate is removed, you will receive an error.

## Client IP address

When an end-client (often the browser) initiates an SSL request, the request must be decrypted before being sent to your app. This extra SSL termination step obfuscates the originating IP address of the request. As a workaround, the IP address of the external client is added to the [`X-Forwarded-For` HTTP request header](http://en.wikipedia.org/wiki/X-Forwarded-For).

## Performance

SSL Endpoint infrastructure is elastic and scales automatically based on historical traffic levels. However, if you plan to switch a lot of traffic to a newly created SSL endpoint or if you expect large spikes, [contact Heroku support](https://devcenter.heroku.com/articles/support-channels#heroku-help) so we can help with preemptive scaling.

An initial request rate of greater than 150 requests/sec or a doubling of the existing requests/second within a 5 minute period are the thresholds at which you should consider contacting support to pre-warm your endpoint. Please give us at least 1 day advanced notice for these types of requests.

## Troubleshooting

### Untrusted certificate

In some cases, when running `heroku certs` it may list your certificate as untrusted. 

```term
$ heroku certs
Endpoint                    Common Name         Expires                    Trusted
------------------------    ----------------    -----------------------    -------
tokyo-2121.herokussl.com    www.example.com    2012-10-31 21:53:18 GMT    False
```

If this occurs it may be because it is not trusted by Mozilla's list of [root CA's](http://www.mozilla.org/projects/security/certs/included/). If this is the case your certificate should work as you expect for many browsers. 

If you have uploaded a certificate that was signed by a root authority but you get the message that it is not trusted, then something is wrong with the certificate. For example, it may be missing [intermediary certificates](http://en.wikipedia.org/wiki/Intermediate_certificate_authorities). If so, download the intermediary certificates from your SSL provider and re-run the `certs:add` command.

### Internal server error

If you get an `Internal server error` when adding your cert it may be that you have an outdated version of the [Heroku Toolbelt](https://toolbelt.heroku.com/).

```term
$ heroku certs:add server.crt server.key 
Adding SSL endpoint to example... failed 
! Internal server error. 
! Run 'heroku status' to check for known platform issues.
```

 [Verify your toolbelt installation](https://devcenter.heroku.com/articles/heroku-command#installing-the-heroku-cli) and update it to the latest version with `heroku update`.

## SSL file types

Many different file types are produced and consumed when creating an SSL certificate.

* A `.csr` file is a certificate signing request which initiates your certificate request with a certificate provider and contains administrative information about your organization.
* A `.key` file is the private key used for your site's SSL-enabled requests.
* `.pem` and `.crt` extensions are often used interchangeably and are both base64 ASCII encoded files. The technical difference is that `.pem` files contain both the certificate _and_ key whereas a `.crt` file only contains the certificate. In reality this distinction is often ignored.