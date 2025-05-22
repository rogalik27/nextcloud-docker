#!/bin/sh
ip="$(curl -s https://ipinfo.io/ip | tr -d '\n')"
domain="${DOMAIN}"
touch scriptdone

cat<<PHP
<?php
\$CONFIG = array (
  'maintenance_window_start' => 2,
  'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => '$ip',
    2 => '$domain'
  ),
  "force_language" => "en",
);
PHP
