# Oracle Java Puppet Module
This module manages Oracle Java. It's a fork of https://github.com/softek/puppet-java7 with the following goals:

* add support for java 6,7,...
* automatically import root CAs to java's keystore
* set default java if more than one is installed

This module has been tested on Ubuntu 12.04.

*NOTE:* This module may only be used if you agree to the Oracle license: http://www.oracle.com/technetwork/java/javase/terms/license/

### Usage

    include java::java6
    include java::java7

### Author
* Scott Smerchek <scott.smerchek@softekinc.com>

### Contributors:
* flosell: Added Debian 6 support
