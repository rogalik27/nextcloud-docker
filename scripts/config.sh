#!/bin/sh
ip="$(curl -s https://ipinfo.io/ip | tr -d '\n')"
touch scriptdone

echo "\n\n\nscriptdone\n\n\n"

cat<<PHP
<?php
\$CONFIG = array (
  'maintenance_window_start' => 2,
  'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => '$ip',
  ),
);
PHP
