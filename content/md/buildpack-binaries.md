---
title: Packaging Binary Buildpack Dependencies
slug: buildpack-binaries
url: https://devcenter.heroku.com/articles/buildpack-binaries
description: How to create binaries compatible with the Heroku platform, and strategies for including them in buildpacks.
---

A buildpack is responsible for building a complete working runtime environment around the app. This may include language VMs and other runtime dependencies that are needed by the app. 

Your buildpack will need to provide these binaries and combine them with the app code. This article will cover both how to create binaries compatible with the Heroku platform and strategies for including them with your buildpack.

## Compiling binaries

<div class="callout" markdown="1">
You should try to make your dependencies self-contained. This includes both statically compiling whenever possible and assuming that there are no existing libraries or binaries on the server.
<br/>
You can safely assume the presence of `bash` and `curl`.
</div>

The [Vulcan](https://github.com/heroku/vulcan) build server gives you easy access to compile software inside a Heroku dyno. This will ensure that the binaries you create are compatible with the Heroku runtime.

You can install Vulcan with:

    $ gem install vulcan
    
You will then need to create a build server on Heroku:

    $ vulcan create vulcan-david
	Creating vulcan-david... done, stack is cedar
	http://vulcan-david.herokuapp.com/ | git@heroku.com:vulcan-david.git    

You can then use Vulcan to compile software:

    $ curl -O http://memcached.googlecode.com/files/memcached-1.4.13.tar.gz
    $ tar xzvf memcached-1.4.13.tar.gz
    $ cd memcached-1.4.13
    $ vulcan build 
	>> Packaging local directory
	>> Uploading code for build
	>> Building with: ./configure --prefix /app/vendor/memcached-1.4.13 && make install
	>> Downloading build artifacts to: /tmp/memcached-1.4.13.tgz
	   (available at http://vulcan-david.herokuapp.com/output/4082384a-dc5a-4adc-ac02-0480a6db4ba2)

	$ tar tf /tmp/memcached-1.4.13.tgz 
	bin/
	bin/memcached
	include/
	include/memcached/
	include/memcached/protocol_binary.h
	share/
	share/man/
	share/man/man1/
	share/man/man1/memcached.1

For more advanced usage of Vulcan, see the [README](https://github.com/heroku/vulcan/blob/master/README.md).

## Packaging binaries

Heroku recommends storing the binary assets needed by your buildpack on S3 and fetching them at build time as needed.

    $ cat bin/compile

	AWESOME_VM_BINARY="https://awesome-vm.s3.amazonaws.com/awesome-vm/awesome-vm-1.0.0.tgz"
	AWESOME_VM_VENDOR="vendor/awesome-vm"

    # vendor awesome-vm
    mkdir -p $1/$AWESOME_VM_VENDOR
    curl $AWESOME_VM_BINARY -o - | tar -xz -C $1/$AWESOME_VM_VENDOR -f -
    
For an example of how the Node.js buildpack uses Vulcan to package `node` binaries, see [support/package_nodejs](https://github.com/heroku/heroku-buildpack-nodejs/blob/master/support/package_nodejs) in the buildpack.

## Setting up the PATH

If you install binaries that will be needed by the app, it is helpful to add them to the `PATH` using `bin/release`:

    $ cat bin/release
    ---
    config_vars:
      PATH: "vendor/awesome-vm/bin:/usr/bin:/bin"