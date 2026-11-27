<?php

declare(strict_types=1);

// Amorçage commun à public/index.php et database/init.php.

// Aucune erreur PHP ni stack trace ne doit atteindre le client : on journalise seulement.
ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);

// Source unique du fuseau : « aujourd'hui », lundi de la semaine, 1er du mois (F3/F4).
date_default_timezone_set('Europe/Paris');

// Autoload PSR-4 maison : StudentCook\X\Y → backend/src/X/Y.php
spl_autoload_register(function (string $className): void {
    $prefix = 'StudentCook\\';
    if (!str_starts_with($className, $prefix)) {
        return;
    }
    $relativePath = str_replace('\\', '/', substr($className, strlen($prefix)));
    $filePath = __DIR__ . '/src/' . $relativePath . '.php';
    if (is_file($filePath)) {
        require $filePath;
    }
});
