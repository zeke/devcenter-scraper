---
title: Customizing the JDK
slug: customizing-the-jdk
url: https://devcenter.heroku.com/articles/customizing-the-jdk
description: How to include custom files in the JDK, such as Java Cryptography Extensions.
---

There are some cases where files need to be bundled with the JDK in order to expose functionality in the runtime JVM. For example, the inclusion of unlimited strength Java Cryptography Extensions (JCE) is often added to a JDK in order to utilize stronger cryptographic libraries. To handle such cases, Heroku will copy files designated by the app in a `.jdk-overlay` folder into the JDK's directory structure.

To include additional files in the JVM, follow these instructions:

##Prerequisites
* [A Java app running on Heroku.](https://devcenter.heroku.com/articles/java)

##Specify a JDK Version
Create a `system.properties` file if one does not already exist, specify the version, and commit it to git. Versions 1.6, 1.7, and 1.8 are supported.

    :::term
    $ echo "java.runtime.version=1.7" > system.properties
    $ git add system.properties
    $ git commit -m "JDK 7"

##Create a `.jdk-overlay` Folder
In your application's root directory, create a `.jdk-overlay` folder.

    :::term
    $ mkdir .jdk-overlay
    $ ls -la
    total 24
    drwxr-xr-x    9 user  staff   306 Oct 16 14:43 .
    drwxr-xr-x  202 user  staff  6868 Oct 16 14:40 ..
    drwxr-xr-x   13 user  staff   442 Oct 16 15:06 .git
    drwxr-xr-x    3 user  staff   102 Oct 16 14:43 .jdk-overlay
    -rw-r--r--    1 user  staff    45 Oct 16 14:40 Procfile
    -rw-r--r--    1 user  staff  1860 Oct 16 14:40 pom.xml
    drwxr-xr-x    3 user  staff   102 Oct 16 14:40 src
    -rw-r--r--    1 user  staff    25 Oct 16 14:40 system.properties

##Add Custom Files
Copy any custom files into the `.jdk-overlay` file. The files will be copied to their equivalent directory in the JDK.

For example, to have Java Cryptography Extensions copied correctly, the Jar files should be placed in `.jdk-overlay/jre/lib/security/`.

    :::term
    $ mkdir -p .jdk-overlay/jre/lib/security
    $ cp ~/downloads/jce/local_policy.jar .jdk-overlay/jre/lib/security/

##Commit the Custom Files

    :::term
    $ git add .jdk-overlay
    $ git commit -m "Custom JDK Files"

##Deploy to Heroku

    :::term
    $ git push heroku master
    ...

##Verify the Copy
The copies can be verified by starting a bash session on Heroku and checking the JDK directory. The JDK directory is located in `$HOME/.jdk/`.

For example, to verify Java Cryptography Extensions were copied correctly, the `$HOME/.jdk/jre/lib/security/` directory can be checked.

    :::term
    $ heroku run bash
    Running `bash` attached to terminal... up, run.1
    ~ $ ls -lah .jdk/jre/lib/security/
    total 196K
    drwxrwxr-x  2 u47919 47919 4.0K Jun  4 17:57 .
    drwxrwxr-x 11 u47919 47919 4.0K Jun  4 17:57 ..
    -rw-rw-r--  1 u47919 47919 2.5K Oct 16 21:44 US_export_policy.jar
    -rw-r--r--  1 u47919 47919 159K Jun  4 17:48 cacerts
    -rw-r--r--  1 u47919 47919 2.2K Jun  4 17:48 java.policy
    -rw-r--r--  1 u47919 47919 9.8K Jun  4 17:48 java.security
    -rw-rw-r--  1 u47919 47919 2.5K Oct 16 21:44 local_policy.jar

##Other Examples
This method can be used for [Java extensions](http://docs.oracle.com/javase/tutorial/ext/basics/index.html) when necessary. Though a dependency management tool, such as Maven, should be the preferred mechanism for introducing dependencies.