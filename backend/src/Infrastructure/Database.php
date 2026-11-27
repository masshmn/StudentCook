<?php

declare(strict_types=1);

namespace StudentCook\Infrastructure;

use PDO;

/**
 * Connexion PDO unique à la base SQLite.
 *
 * Toute l'application (Repositories et database/init.php) passe par
 * Database::getConnection() : la configuration n'est écrite qu'ici.
 */
final class Database
{
    private static ?PDO $connection = null;

    // Classe utilitaire : on ne l'instancie pas.
    private function __construct()
    {
    }

    /**
     * Chemin du fichier SQLite : database/data/student_cook.db
     * (dossier monté en volume Docker, fichier non versionné).
     */
    public static function getPath(): string
    {
        return dirname(__DIR__, 3) . '/database/data/student_cook.db';
    }

    /**
     * Renvoie toujours la même connexion (créée au premier appel).
     */
    public static function getConnection(): PDO
    {
        if (self::$connection === null) {
            $pdo = new PDO('sqlite:' . self::getPath());

            // Toute erreur SQL lève une PDOException (pas d'échec silencieux).
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            // Les lignes sont renvoyées en tableaux associatifs ['colonne' => valeur].
            $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

            // CRITIQUE : désactivé par défaut dans SQLite, à activer à chaque connexion.
            // Sans lui, RESTRICT et CASCADE sont ignorés silencieusement.
            $pdo->exec('PRAGMA foreign_keys = ON');

            self::$connection = $pdo;
        }

        return self::$connection;
    }

    /**
     * Ferme la connexion (utilisé par init.php avant de supprimer le fichier).
     */
    public static function close(): void
    {
        self::$connection = null;
    }
}
