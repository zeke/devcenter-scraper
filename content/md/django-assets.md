---
title: Django and Static Assets
slug: django-assets
url: https://devcenter.heroku.com/articles/django-assets
description: Learn how to configure a Django application on Heroku properly to use static assets.
---

<div class="note" markdown="1">
If you have questions about Python on Heroku, consider discussing it in the [Python on Heroku forums](https://discussion.heroku.com/category/python). Both Heroku and community-based Python experts are available.
</div>

Django settings for static assets can be a bit difficult to configure and debug. 

However, if you just add the following settings to your `settings.py`, everything should work exactly as you expect:

#### settings.py

    :::python
    # Static asset configuration
    import os
    PROJECT_PATH = os.path.dirname(os.path.abspath(__file__))
    STATIC_ROOT = 'staticfiles'
    STATIC_URL = '/static/'

    STATICFILES_DIRS = (
        os.path.join(PROJECT_PATH, 'static'),
    )

To serve static files in production, you can use the [dj-static](https://github.com/kennethreitz/dj-static) library.

    :::term
    $ pip install dj-static
    ...
    $ pip freeze > requirements.txt

Next, you can add the following code to `wsgi.py` to serve static files in production:

#### wsgi.py

    :::python
    from django.core.wsgi import get_wsgi_application
    from dj_static import Cling
 
    application = Cling(get_wsgi_application())

Your application will now serve static assets directly from Gunicorn in production. This will be perfectly adequate for most applications, but top-tier applications may want to explore using a CDN with [Django-Storages](http://django-storages.readthedocs.org/en/latest/).

## Automatic Collectstatic

When a Django application is deployed to Heroku, `collectstatic` is run automatically when it is configured properly.

### Detection

We determine if collectstatic is configured by running the following against your codebase:

    :::term
    $ python manage.py collectstatic --dry-run --noinput

If required configurations are missing, this command will fail and no collecstatic support will be applied to your application.

### Debugging

To learn more about why your application's collectstatic isn't configured, you can use `heroku run`:

    :::term
    $ heroku run python manage.py collectstatic --noinput
    ...
    django.core.exceptions.ImproperlyConfigured: You're using the staticfiles app without having set the STATIC_ROOT setting.

### Config Vars during build

Normally, [application configuration](/articles/config-vars) isn't available when your application is being compiled. This can be a problem with, for example, using `collectstatic` to upload files to S3 with [Django-Storages](http://django-storages.readthedocs.org/en/latest/).

If your application needs access to runtime configuration during the build, you can turn it on with [user-env-compile](/articles/labs-user-env-compile):

    :::term
    $ heroku labs:enable user-env-compile
    -----> Enabling user-env-compile for myapp... done
    WARNING: This feature is experimental and may change or be removed without notice.

Once enabled, your application deploys will have the latest set of runtime configurations available as environment variables.

###  Disabling Collectstatic

Sometimes, you may not want Heroku to run `collectstatic` on your behalf. You can disable collectstatic by enabling [user-env-compile](https://devcenter.heroku.com/articles/labs-user-env-compile) as well:

    :::term
    $ heroku labs:enable user-env-compile
    $ heroku config:set DISABLE_COLLECTSTATIC=1