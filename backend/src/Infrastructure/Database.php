<?php

declare(strict_types=1);

namespace StudentCook\Infrastructure;

use PDO;

// Seul point de connexion à la base : la configuration (dont le PRAGMA) n'est écrite qu'ici.
final class Database
{
    private static ?PDO $connection = null;

    private function __construct()
    {
    }

    public static function getPath(): string
    {
        return dirname(__DIR__, 3) . '/database/data/student_cook.db';
    }

    public static function getConnection(): PDO
    {
        if (self::$connection === null) {
            $pdo = new PDO('sqlite:' . self::getPath());

            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

            // CRITIQUE : désactivé par défaut dans SQLite, à activer à chaque connexion.
            // Sans lui, RESTRICT et CASCADE sont ignorés silencieusement.
            $pdo->exec('PRAGMA foreign_keys = ON');

            self::$connection = $pdo;
        }

        return self::$connection;
    }

    // Utilisé par init.php : le fichier ne peut pas être supprimé tant qu'il est ouvert.
    public static function close(): void
    {
        self::$connection = null;
    }
}
