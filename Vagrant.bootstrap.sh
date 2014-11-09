#!/usr/bin/env bash

# https://gist.github.com/asmerkin/df919a6a79b081512366#file-vagrant-bootstrap-sh
# Modifications by Tim Jones <tdjones74021@yahoo.com>

# ---------------------------------------
# Virtual Machine Setup
# ---------------------------------------

# Set environment variables for Ubuntu version
. /etc/lsb-release

# Adding multiverse sources.
cat > /etc/apt/sources.list.d/multiverse.list << EOF
deb http://archive.ubuntu.com/ubuntu ${DISTRIB_CODENAME} multiverse
deb http://archive.ubuntu.com/ubuntu ${DISTRIB_CODENAME}-updates multiverse
deb http://security.ubuntu.com/ubuntu ${DISTRIB_CODENAME}-security multiverse
EOF

# Settings for installing/upgrading 'grub-pc' package
debconf-set-selections <<< 'grub-pc grub2/kfreebsd_cmdline  string'
debconf-set-selections <<< 'grub-pc grub2/device_map_regenerated    note'
debconf-set-selections <<< 'grub-pc grub2/linux_cmdline     string'
debconf-set-selections <<< 'grub-pc grub-pc/install_devices_failed  boolean false'
debconf-set-selections <<< 'grub-pc grub-pc/chainload_from_menu.lst boolean true'
debconf-set-selections <<< 'grub-pc grub-pc/kopt_extracted  boolean true'
debconf-set-selections <<< 'grub-pc grub-pc/postrm_purge_boot_grub  boolean false'
debconf-set-selections <<< 'grub-pc grub2/kfreebsd_cmdline_default  string  quiet'
debconf-set-selections <<< 'grub-pc grub2/linux_cmdline_default     string'
debconf-set-selections <<< 'grub-pc grub-pc/install_devices_empty   boolean false'
debconf-set-selections <<< 'grub-pc grub-pc/install_devices multiselect     /dev/sda'
debconf-set-selections <<< 'grub-pc grub-pc/install_devices_failed_upgrade  boolean true'
debconf-set-selections <<< 'grub-pc grub-pc/install_devices_disks_changed   multiselect     /dev/sda'
debconf-set-selections <<< 'grub-pc grub-pc/mixed_legacy_and_grub2  boolean true'

apt-get update -y
apt-get upgrade -y

# Configure use of PHP 5.4
# Add add-apt-repository binary
apt-get install -y python-software-properties software-properties-common
# Install PHP 5.4
# *** ONLY applicable for Ubuntu 13.10 or earlier
add-apt-repository -y ppa:ondrej/php5-oldstable
 
# Updating packages
apt-get update -y

# Install some useful packages
apt-get install -y debconf vim tmux mc curl make g++ libsqlite3-dev graphviz libxml2-utils lynx links

# ---------------------------------------
# Apache Setup
# ---------------------------------------
 
# Installing Packages
apt-get install -y apache2 

# linking Vagrant directory to Apache 2.4 public directory
rm -rf /var/www
ln -fs /vagrant /var/www
 
# Add ServerName to httpd.conf
#echo "ServerName localhost" > /etc/apache2/httpd.conf



# Setup Apache virtual host
APACHE_LOG_DIR=/

VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/var/www/laravel/public/"
  ServerName local.dev
  ServerAlias local
  
  RewriteEngine On

  <Directory "/var/www/laravel/public/">
    Options FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>
  
  LogLevel info
  ErrorLog /var/log/apache2/error.log
  CustomLog /var/log/apache2/access.log combined  
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/laravel.conf

# Loading needed modules to make apache work
a2enmod rewrite
service apache2 reload

# Enable the new Laravel site (and disable the 'default' site)
a2dissite 000-default
a2ensite laravel.conf
service apache2 reload

# ---------------------------------------
# PHP Setup
# ---------------------------------------
 
# Installing packages
apt-get install -y php5 php5-cli curl php5-curl php5-mcrypt php5-xdebug

# Enabling php modules
php5enmod mcrypt

# ---------------------------------------
# MySQL Setup
# ---------------------------------------
 
# Setting MySQL root user password root/root
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
 
# Installing packages
apt-get install -y mysql-server mysql-client php5-mysql
 
# ---------------------------------------
# PHPMyAdmin setup
# ---------------------------------------

# Default PHPMyAdmin Settings
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
 
# Install PHPMyAdmin
apt-get install -y phpmyadmin
 
# Make Composer available globally
ln -s /etc/phpmyadmin/apache.conf /etc/apache2/sites-enabled/phpmyadmin.conf
 
# Restarting apache to make changes
service apache2 restart

# ---------------------------------------
# Tools Setup
# ---------------------------------------

# Installing nodejs and npm
apt-get install -y nodejs npm
 
# Installing Bower and Grunt
#npm install -g bower grunt-cli
 
# Installing Git
apt-get install -y git
 
# Install Composer
curl -s https://getcomposer.org/installer | php
 
# Make Composer available globally
mv composer.phar /usr/local/bin/composer

# Install Laravel 4.2
cd /vagrant
composer create-project laravel/laravel laravel --prefer-dist 4.2.*

# Add packages to Laravel (We do *NOT* install them at this time.)
# https://github.com/JeffreyWay/Laravel-4-Generators
composer require "way/generators":"3.*" --prefer-dist --no-update
# https://github.com/laravelbook/ardent
composer require "laravelbook/ardent":"2.*" --prefer-dist --no-update
# http://packalyst.com/packages/package/aws/aws-sdk-php-laravel
composer require "aws/aws-sdk-php-laravel":"1.*@dev" --prefer-dist --no-update
# http://anahkiasen.github.io/former/
composer require "anahkiasen/former":"1.*@dev" --prefer-dist --no-update
# https://github.com/patricktalmadge/bootstrapper
composer require "patricktalmadge/bootstrapper":"5.*@dev" --prefer-dist --no-update

# Run Composer 'update' to install the added packages
composer update