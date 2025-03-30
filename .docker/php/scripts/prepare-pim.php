<?php

if (empty($argv[1]) || empty($argv[2]) || empty($argv[3])) {
    exit("DB credentials are not set, skipping");
}

chdir(dirname(__FILE__));
set_include_path(dirname(__FILE__));

require_once 'vendor/autoload.php';

$app = new \Atro\Core\Application();

$config = $app->getContainer()->get('config');
$config->set('database', [
    'driver' => 'pdo_pgsql',
    'host' => 'db',
    'port' => '',
    'charset' => 'utf8',
    'dbname' => $argv[3],
    'user' => $argv[1],
    'password' => $argv[2],
]);
$config->save();