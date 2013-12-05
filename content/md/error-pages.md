---
title: Error Pages
slug: error-pages
url: https://devcenter.heroku.com/articles/error-pages
description: When your app is crashed, out of resources, or misbehaving in some other way, Heroku serves an error page, which can be customized for each application.
---

<p class="callout" markdown="1">
To learn more about tracking down errors that may lead to the error pages being generated, visit the article on [Logging](logging).
</p>
Heroku's [HTTP router](http-routing) serves unstyled HTML with HTTP status code 503 (Service Unavailable) when your app encounters a system-level error, or while maintenance mode is enabled.  Customizing these pages allows you to present a more consistent UI to your users.  

<p class="note">
Other errors, such as application errors (a 404 or 500), will display your application's error page and not the Heroku error page. Only system-level errors that result in no response, or a malformed one, will display the Heroku error page discussed here.
</p>

## Debugging

Logs are the first place to look when your users report seeing the Heroku error pages. Use the `heroku logs` command to view the unified event stream for your application and the state of the Heroku platform components supporting your application.

    :::term
    $ heroku logs
    2011-03-01T16:16:29-08:00 heroku[web.1]: State changed from starting to crashed
    2011-03-01T16:16:59-08:00 heroku[router]: at=error code=H10 desc="App crashed" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=

In this example, the router tried to serve a page for the app, but the web process is crashed. The `Error H10` log entry contains the [error code](error-codes) (H10) that identifies the cause of this particular issue. Refer to the full list of [error codes](error-codes) to determine the cause of the error you're seeing.

## Customize pages

The pages displayed to your users when the application encounters a system error or is placed in the maintenance state can be customized.

### Create and store the custom pages

Create your custom pages as static HTML.  You may wish to use the default HTML served by Heroku as a template:

* [http://s3.amazonaws.com/heroku_pages/error.html](http://s3.amazonaws.com/heroku_pages/error.html)
* [http://s3.amazonaws.com/heroku_pages/maintenance.html](http://s3.amazonaws.com/heroku_pages/maintenance.html)

You can reference images or CSS from the HTML as long as you use relative paths (e.g., `<img src="error.png">`) and you upload the other assets into the same place as the HTML.

You can host the pages anywhere that can serve web pages; we recommend uploading to Amazon S3.  If you use S3, don't forget to set the HTML and all assets to be publicly readable.

### Configure application

Set the `ERROR_PAGE_URL` and `MAINTENANCE_PAGE_URL` [config vars](config-vars) to the publicly accessible URLs of your custom pages:

    :::term
    $ heroku config:set \
      ERROR_PAGE_URL=http://s3.amazonaws.com/your_bucket/your_error_page.html \
      MAINTENANCE_PAGE_URL=http://s3.amazonaws.com/your_bucket/your_maintenance_page.html

### Testing

To test your maintenance page:

    :::term
    $ heroku maintenance:on
    $ heroku open

The custom page will be served and your application logs will show an [H80 code](error-codes#h80-maintenance-mode) for that web hit indicating that a maintenance page was served to the user:

    :::term
    $ heroku logs -p router -n 1
    2010-10-08T17:44:18-07:00 heroku[router]: at=info code=H80 desc="Maintenance mode" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno= connect= service= status=503 bytes=

To test your error page, you can push a bad deploy such as putting a syntax error into a key configuration file, or by creating a path on your app that sleeps for 35 seconds (thereby triggering the error [H12 Request Timeout](error-codes#h12-request-timeout).  Visit an app or path with such an error, while watching the logs:

    :::term
    $ heroku logs --tail
    2010-10-08T18:04:40-07:00 app[web.1]: Sleeping 35 seconds before I serve this page
    2010-10-08T18:05:10-07:00 heroku[router]: at=error code=H12 desc="Request timeout" method=GET path=/ host=myapp.herokuapp.com fwd=17.17.17.17 dyno=web.1 connect=6ms service=30001ms status=503 bytes=0
    2010-10-08T18:05:15-07:00 app[web.1]: Done sleeping

The custom error page will be displayed in your browser.

## SSL

If your site is accessed via SSL, some browsers will display a warning or error if the maintenance and error pages do not also utilize an https URL. Be sure to use matching application and error page protocols.