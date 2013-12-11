---
title: Extensions, PostGIS and Full Text Search Dictionaries on Heroku Postgres
slug: heroku-postgres-extensions-postgis-full-text-search
url: https://devcenter.heroku.com/articles/heroku-postgres-extensions-postgis-full-text-search
description: Heroku Postgres supports many Postgres extensions as well as features such as PostGIS and full text search that are not bundled as part of the extensions system
---

Extensions allow related pieces of functionality, such as datatypes
and functions, to be bundled together and installed in a database with
a single command. Heroku Postgres supports many Postgres extensions as
well as features such as full text search that are not bundled as part
of the extensions system. A beta version of the PostGIS spatial
database extension is also available.

You can always query your database for the list of supported
extensions:

	:::term
	$ echo 'show extwlist.extensions' | heroku pg:psql
		 extwlist.extensions
	-----------------------------
	btree_gist,chkpass,cube,dblink,dict_int...

To create any supported extension, open a session with `heroku
pg:psql` and run the appropriate command:

	:::term
	$ heroku pg:psql
	Pager usage is off.
	psql (9.2.4)
	SSL connection (cipher: DHE-RSA-AES256-SHA, bits: 256)
	Type "help" for help.

	ad27m1eao6kqb1=> CREATE EXTENSION hstore;
	CREATE EXTENSION
	ad27m1eao6kqb1=>


## Data types

* [HStore](http://www.postgresql.org/docs/9.1/static/hstore.html): Key
  value store inside Postgres. `create extension hstore`

* [Case Insensitve
  Text](http://www.postgresql.org/docs/9.1/static/citext.html): Case
  insenstive text datatype. Although strings stored in citext do
  retain case information, they are case insensitive when used in
  queries. `create extension citext`.

* [Label Tree](http://www.postgresql.org/docs/9.1/static/ltree.html):
  Tree-like hierachies, with associated functions. `create extension
  ltree`

* [Product Numbering](http://www.postgresql.org/docs/9.1/static/isn.html):
  Store product IDs and serial numbers such as
  [UPC](http://en.wikipedia.org/wiki/Universal_Product_Code)
  [ISBN](http://en.wikipedia.org/wiki/ISBN) and
  [ISSN](http://en.wikipedia.org/wiki/International_Standard_Serial_Number). `create
  extension isn`

* [Cube](http://www.postgresql.org/docs/9.1/static/cube.html):
  Multi-dimensional cubes. `create extension cube`

## Functions

* [PGCrypto](http://www.postgresql.org/docs/9.1/static/pgcrypto.html):
  Cyptographic functions allow for encryption within the database
  `create extension pgcrypto`.

* [Table Functions & Pivot Tables](http://www.postgresql.org/docs/9.1/static/tablefunc.html):
  Functions returning full tables, including the ability to manipulate
  query results in a manner similar to spreadsheet pivot tables
  `create extension tablefunc`.

* [UUID Generation](http://www.postgresql.org/docs/9.1/static/uuid-ossp.html):
  Generate v1, v3, v4, and v5 UUIDs in-database. Works great with the
  existing
  [UUID datatype](http://www.postgresql.org/docs/9.1/static/datatype-uuid.html)
  `create extension "uuid-ossp"`.

* [Earth Distance](http://www.postgresql.org/docs/9.1/static/earthdistance.html):
  Functions for calculating the distance between points on the
  earth. `create extension earthdistance`

* [Trigram](http://www.postgresql.org/docs/9.1/static/pgtrgm.html):
  Determine the similarity (or lack thereof) of alphanumeric string
  based on
  [trigram matching](http://en.wikipedia.org/wiki/N-gram). Useful for
  natural language processing problems such as search. `create
  extension pg_trgm`.

* [Fuzzy Match](http://www.postgresql.org/docs/9.1/static/fuzzystrmatch.html):
  Another method for determining the similarity between
  strings. Limited UTF-8 support. `create extension fuzzystrmatch`

## Statistics

* [Row Locking](http://www.postgresql.org/docs/9.1/static/pgrowlocks.html):
  Show row lock information for a table. `create extension pgrowlocks`

* [Tuple Statistics](http://www.postgresql.org/docs/9.1/static/pgstattuple.html):
  Database tuple-level statistics such as physical length and
  aliveness. `create extension pgstattuple`

## Index types

* [btree-gist](http://www.postgresql.org/docs/current/static/btree-gist.html):
  A [GiST](http://en.wikipedia.org/wiki/GiST) index operator. It is
  generally inferior to the standard btree index, except for
  multi-column indexes that can't be used with btree and
  [exclusion constrations](http://www.postgresql.org/docs/current/static/sql-createtable.html#SQL-CREATETABLE-EXCLUDE). `create
  extension btree_gist`

## Languages

* [PLV8](https://code.google.com/p/plv8js/wiki/PLV8): The full V8 engine embedded within Postgres allowing you to create full JavaScript functions. `create extension PLV8`. PLV8 is only available on non-hobby tier databases currently.

## Full text search dictionaries

* [dict-int](http://www.postgresql.org/docs/9.1/static/dict-int.html) -
  A full-text search dictionary for full-text search which controls
  how integers are indexed. `create extension dict_int`

* [dict-xsyn](http://www.postgresql.org/docs/9.1/static/dict-xsyn.html) -
  A full-text search dictionary for that makes it possible to search
  for a word using any of its synonyms. `create extension dict_xsyn`

* [unaccent](http://www.postgresql.org/docs/9.1/static/unaccent.html) -
  A filtering text dictionary which removes accents from
  characters. `create extension unaccent`

Additionally, the following dictionaries are installed by default and
don't require creation via the extension system:

	:::term
	$ heroku pg:psql
	=> \dFd
								 List of text search dictionaries
	   Schema   |      Name       |                        Description
	------------+-----------------+-------------------------------
	 pg_catalog | danish_stem     | snowball stemmer for danish language
	 pg_catalog | dutch_stem      | snowball stemmer for dutch language
	 pg_catalog | english_stem    | snowball stemmer for english language
	 pg_catalog | finnish_stem    | snowball stemmer for finnish language
	 pg_catalog | french_stem     | snowball stemmer for french language
	 pg_catalog | german_stem     | snowball stemmer for german language
	 pg_catalog | hungarian_stem  | snowball stemmer for hungarian language
	 pg_catalog | italian_stem    | snowball stemmer for italian language
	 pg_catalog | norwegian_stem  | snowball stemmer for norwegian language
	 pg_catalog | portuguese_stem | snowball stemmer for portuguese language
	 pg_catalog | romanian_stem   | snowball stemmer for romanian language
	 pg_catalog | russian_stem    | snowball stemmer for russian language
	 pg_catalog | simple          | simple dictionary: just lower case and check for stopword
	 pg_catalog | spanish_stem    | snowball stemmer for spanish language
	 pg_catalog | swedish_stem    | snowball stemmer for swedish language
	 pg_catalog | turkish_stem    | snowball stemmer for turkish language


## dblink

[dblink](http://www.postgresql.org/docs/9.1/static/dblink.html) Adds
support for querying between Postgres databases. With dblink you can
query between separate Heroku Postgres databases or to/from external
Postgres databases.

## pg_stat_statements

[pg_stat_statements](http://www.postgresql.org/docs/9.2/static/pgstatstatements.html):

> The pg_stat_statements module provides a means for
> tracking execution statistics of all SQL statements executed
> by a server.

<p class="warning" markdown="1">
pg_stat_statements support on Heroku Postgres is currently limited to Postgres 9.2 databases.
</p>

### Usage

pg_stat_statements can be used to [track performance problems] (http://www.craigkerstiens.com/2013/01/10/more-on-postgres-performance/). It provides a view called pg_stat_statements that displays each query that has been executed, and associated costs, including the number of times the query was executed, the total system time execution has taken in aggregate, and the total number of blocks in shared memory hit in aggregate.

## PostGIS

[PostGIS](http://postgis.refractions.net/):

> adds support for geographic objects to the PostgreSQL
> object-relational database. In effect, PostGIS "spatially enables"
> the PostgreSQL server, allowing it to be used as a backend spatial
> database for geographic information systems (GIS)

<p class="warning" markdown="1">
PostGIS support on Heroku Postgres is in beta and is subject to change in the future.
</p>

### Requirements

Currently, PostGIS can only be used on Production tier [Heroku Postgres
plans](https://addons.heroku.com/heroku-postgresql). It is not available
on non-hobby tier databases. Additionally, PostGIS is only
available as v2.1 with Postgres 9.3 or as v2.0 with Postgres v9.2.

### Provisioning

PostGIS support can be added like any other extension, as long as your
database meets the requirements above

	:::term
	$ heroku addons:add heroku-postgresql:ronin --version=9.3

and then simply run `create extension postgis`. Note also that this
functionality is only availble on newer databases. If your database
meets the requirements above but you still receive an error when
running `create extension postgis`, you can use the
[fast changeover](/articles/heroku-postgres-follower-databases#database-upgrades-and-migrations-with-changeovers)
procedure to move to a fresh database with PostGIS support.


To detect if PostGIS is installed on a database, execute the following
query from psql:

	:::sql
	=> SELECT postgis_version();
			postgis_version
	---------------------------------------
	 2.1 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
	(1 row)
                