---
title: Dataclips
slug: dataclips
url: https://devcenter.heroku.com/articles/dataclips
description: Dataclips allow the results of SQL queries on a Heroku Postgres database to be easily shared.
---

Dataclips allow the results of SQL queries on a Heroku Postgres database to be easily shared. Simply create a query on [dataclips.heroku.com](https://dataclips.heroku.com), and then share the resulting URL with co-workers, colleagues, or the world. The recipients of a dataclip are able to view the data in their browser or download it in JSON, CSV, XML, or Microsoft Excel formats.

## Creating dataclips

1.  From within the [dataclips dashboard](https://dataclips.heroku.com), when logged in, click create clip.
    ![](https://s3.amazonaws.com/f.cl.ly/items/3W0l3u1d0e323p0j3531/Screenshot_1_15_13_9_16_AM-2.png)

2. Enter your query into the area
    ![](https://s3.amazonaws.com/f.cl.ly/items/062X1p3g1n342x2j1u2F/Screenshot_1_15_13_11_32_AM.png)
3. Click create clip


## Formats

Dataclips can be accessed in several forms:

* JSON
* CSV
* XLS

You may access each format by selecting the format from the dataclips menu, or by appending the file format to the URL of the dataclip. 

The JSON endpoint is handy for prototyping APIs but should not be used as a replacement for a production API. The JSON endpoint also supports [Cross-Origin Resource Sharing](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing) (CORS) on GET requests to a clip's JSON URL.

## Interacting with dataclips

Dataclips provides the ability to access all previous versions of your query and previous result sets as well. You can access previous versions and results from within the menu on a specific dataclip. You may also access previous versions and results if you have a direct URL to a dataclip as well, including with specific file formats. 

Given an example dataclip - [https://dataclips.heroku.com/vgyygvzqtezwpmwpcmmjlluamjlk](https://dataclips.heroku.com/vgyygvzqtezwpmwpcmmjlluamjlk) you could access it in several forms when getting the csv format:

* The latest results in csv by adding .csv to the url

```
https://dataclips.heroku.com/vgyygvzqtezwpmwpcmmjlluamjlk.csv
```

* The first version of the dataclip created by adding .csv and ?version=1

```
https://dataclips.heroku.com/xqzzcwmlubhblavdipydzzqmlmbm.csv?version=1
```

* The first version of the dataclip and its first result set by adding the above and result=1

```
https://dataclips.heroku.com/xqzzcwmlubhblavdipydzzqmlmbm.csv?result=1&version=1
```

### Data Refresh

When visiting a dataclip it will immediately show the last run results and alert you if there is a new result set available. Queries that take longer than 10 minutes to run are automatically cancelled.

When connecting your dataclips to google docs your data is refreshed on an hourly basis.

## Security

All dataclips are secured through unique un-guessable URLs. [Standard, Premium and Enterprise tier] (https://devcenter.heroku.com/articles/heroku-postgres-plans#standard-tier) databases also have the ability to secure dataclips to a heroku user account. 

## Limits

* Dataclips may return up to 29,999 rows
* Dataclips can only be secured via authentication on [Standard, Premium and Enterprise tier] (https://devcenter.heroku.com/articles/heroku-postgres-plans#standard-tier) databases
* By default, Dataclips will cancel queries after 10 minutes.  