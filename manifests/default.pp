# Apache setup
class { apache:
  default_vhost => false,
  mpm_module    => prefork,
}

apache::vhost {'yourls':
  port     => 80,
  docroot  => '/var/www/yourls',
  override => [All],
}

include apache::mod::php

# MySQL setup
include mysql::server

mysql::db { yourls:
  user     => yourls,
  password => yourls,
  host     => localhost,
  grant    => [ALL],
}

class { 'mysql::bindings':
  php_enable => true
}

package { git:
  ensure => installed,
}
# YOURLS (does not run SQL, visit /admin/ to run scripts)
vcsrepo { '/var/www/yourls':
  ensure   => present,
  provider => git,
  source   => 'https://github.com/YOURLS/YOURLS.git',
  revision => '1.7',
  force    => true, #FIXME
}

# From https://github.com/YOURLS/YOURLS/blob/master/user/config-sample.php
file { '/var/www/yourls/user/config.php':
  ensure  => file,
  content => inline_template("<?php
define( 'YOURLS_DB_USER', 'yourls' );
define( 'YOURLS_DB_PASS', 'yourls' );
define( 'YOURLS_DB_NAME', 'yourls' );
define( 'YOURLS_DB_HOST', 'localhost' );
define( 'YOURLS_DB_PREFIX', 'yourls_' );

define( 'YOURLS_SITE', 'http://<%=@ipaddress%>' );
define( 'YOURLS_HOURS_OFFSET', 12 );
define( 'YOURLS_LANG', '' );
define( 'YOURLS_UNIQUE_URLS', false );
define( 'YOURLS_PRIVATE', false );
define( 'YOURLS_COOKIEKEY', '<%=@uuid%>' );

\$yourls_user_passwords = array(
  );

define( 'YOURLS_DEBUG', false );

define( 'YOURLS_URL_CONVERT', 36 );
\$yourls_reserved_URL = array(
  'porn', 'faggot', 'sex', 'nigger', 'fuck', 'cunt', 'dick', 'gay',
);
"),
}

file { '/var/www/yourls/.htaccess':
  ensure => file,
  content => 'FallBackResource yourls-loader.php',
}

file { '/var/www/yourls/user/plugins/qr-code':
  ensure => directory,
}

# From https://github.com/YOURLS/YOURLS/wiki/Plugin-%3D-QRCode-ShortURL
file { '/var/www/yourls/user/plugins/qr-code/plugin.php':
  ensure  => file,
  content => '<?php
/*
Plugin Name: QR Code Short URLS
Plugin URI: http://yourls.org/
Description: Add .qr to shorturls to display QR Code
Version: 1.0
Author: Ozh
Author URI: http://ozh.org/
*/

// Kick in if the loader does not recognize a valid pattern
yourls_add_action( \'loader_failed\', \'ozh_yourls_qrcode\' );

function ozh_yourls_qrcode( $request ) {
        // Get authorized charset in keywords and make a regexp pattern
        $pattern = yourls_make_regexp_pattern( yourls_get_shorturl_charset() );

        // Shorturl is like bleh.qr?
        if( preg_match( "@^([$pattern]+)\\.qr?/?$@", $request[0], $matches ) ) {
                // this shorturl exists?
                $keyword = yourls_sanitize_keyword( $matches[1] );
                if( yourls_is_shorturl( $keyword ) ) {
                        // Show the QR code then!
                        header(\'Location: http://chart.apis.google.com/chart?chs=200x200&cht=qr&chld=M&chl=\'.YOURLS_SITE.\'/\'.$keyword);
                        exit;
                }
        }
}',
}

vcsrepo { '/var/www/yourls/user/plugins/random-keywords':
  ensure   => present,
  provider => git,
  source   => 'https://github.com/YOURLS/random-keywords.git',
  revision => 'ff83532bd9534d8a9947664b89dfce3235dea567',
}

vcsrepo { '/var/www/yourls/user/plugins/force-lowercase':
  ensure   => present,
  provider => git,
  source   => 'https://github.com/YOURLS/force-lowercase.git',
  revision => '058aa8a2cceb7aaf52b707621c8099fa57a742f8',
}