My Homestead
============

Alternative to [Laravel](http://www.laravel.com/) framework [Homestead](http://laravel.com/docs/homestead) development environment based on [Vagrant LAMP](https://github.com/r8/vagrant-lamp).

Installation:
-------------

See this blog post for additional details.

Download and install [VirtualBox](http://www.virtualbox.org/).

Download and install [Vagrant](http://vagrantup.com/).

Download the 'trusty32' (Ubuntu 14.04 32-bit) Vagrant box.

    $ vagrant box add ubuntu/trusty32

Clone this repository.

    $ git clone http://github.com/timothydjones/myhomestead

Go to the repository folder and launch the box.

    $ cd [repo]
    $ vagrant up

What's inside:
--------------

Installed software:

* Apache
* MySQL
* PHP
* phpMyAdmin
* Xdebug (Uses default port of 9000.)
* git, subversion
* mc, vim, screen, tmux, curl
* [MailCatcher](http://mailcatcher.me/)
* [Composer](http://getcomposer.org/)
* Node.js with following packages:
    * [CoffeeScript](http://coffeescript.org)
    * [Grunt](http://gruntjs.com/)
    * [Bower](http://bower.io)
    * [Yeoman](http://yeoman.io)
    * [LESS](http://lesscss.org)
    * [CSS Lint](http://csslint.net)

Notes
-----

### Apache virtual hosts

You can add virtual hosts to apache by adding a file to the `data_bags/sites`
directory. The docroot of the new virtual host will be a directory within the
`public/` folder matching the `host` you specified. Alternately you may specify
a docroot explicitly by adding a `docroot` key in the json file.

### MySQL

The guests local 3306 port is available on the host at port 33066. It is also available on every domain. Logging in can be done with username=root, password=vagrant.

### phpMyAdmin

phpMyAdmin is available on every domain. For example:

    http://local.dev/phpmyadmin

### XDebug and webgrind

XDebug is configured to connect back to your host machine on port 9000 when
starting a debug session from a browser running on your host. A debug session is
started by appending GET variable XDEBUG_SESSION_START to the URL (if you use an
integrated debugger like Eclipse PDT, it will do this for you).

XDebug is also configured to generate cachegrind profile output on demand by
adding GET variable XDEBUG_PROFILE to your URL. For example:

    http://local.dev/index.php?XDEBUG_PROFILE

Webgrind is available on each domain. For example:

    http://local.dev/webgrind

It looks for cachegrind files in the `/tmp` directory, where xdebug leaves them.

**Note:** xdebug uses the default value for xdebug.profiler_output_name, which
means the output filename only includes the process ID as a unique part. This
was done to prevent a real need to clean out cachgrind files. If you wish to
configure xdebug to always generate profiler output
(`xdebug.profiler_enable = 1`), you *will* need to change this setting to
something like

    xdebug.profiler_output_name = cachegrind.out.%t.%p

so your call to webgrind will not overwrite the file for the process that
happens to serve webgrind.

### Mailcatcher

All emails sent by PHP are intercepted by MailCatcher. So normally no email would be delivered outside of the virtual machine. Instead you can check messages using web frontend for MailCatcher, which is running on port 1080 and also available on every domain:

    http://local.dev:1080

### Composer

Composer binary is installed globally (to `/usr/local/bin`), so you can simply call `composer` from any directory.

References
----------
[How to Create and Share a Vagrant Base Box](http://www.sitepoint.com/create-share-vagrant-base-box/)
[ubuntu/trusty32 Vagrant Box](https://vagrantcloud.com/ubuntu/boxes/trusty32)