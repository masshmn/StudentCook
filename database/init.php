<?php

declare(strict_types=1);

/*
 * Initialisation de la base SQLite.
 *
 *   php database/init.php          crée la base (schéma + seed) seulement si elle n'existe pas
 *   php database/init.php --reset  supprime la base et la recrée à l'identique depuis le seed
 *
 * Docker lance ce script à chaque démarrage : sans --reset, il ne touche jamais
 * à une base existante (planning et cases cochées conservés).
 * Code de sortie : 0 si tout va bien, 1 en cas d'erreur (le conteneur s'arrête).
 */

use StudentCook\Infrastructure\Database;

require dirname(__DIR__) . '/backend/bootstrap.php';

// Version du schéma, écrite dans PRAGMA user_version. À incrémenter à chaque modification
// de schema.sql : une base plus ancienne est alors refusée au lieu de provoquer des 500.
const SCHEMA_VERSION = 1;

$isReset = in_array('--reset', array_slice($argv, 1), true);
$databasePath = Database::getPath();

$dataDirectory = dirname($databasePath);
if (!is_dir($dataDirectory) && !mkdir($dataDirectory, 0775, true)) {
    fwrite(STDERR, "ERREUR : impossible de créer le dossier $dataDirectory.\n");
    exit(1);
}

if ($isReset && file_exists($databasePath)) {
    if (!unlink($databasePath)) {
        fwrite(STDERR, "ERREUR : impossible de supprimer $databasePath.\n");
        exit(1);
    }
    echo "Ancienne base supprimée.\n";
}

// Si le fichier existe déjà, on ne le supprimera jamais en cas d'erreur (données de l'utilisateur).
$isNewFile = !file_exists($databasePath);

try {
    $pdo = Database::getConnection();

    $tableCount = (int) $pdo->query(
        "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = 'recipes'"
    )->fetchColumn();
    if ($tableCount > 0) {
        $databaseVersion = (int) $pdo->query('PRAGMA user_version')->fetchColumn();
        if ($databaseVersion < SCHEMA_VERSION) {
            throw new RuntimeException(
                "base créée avec un ancien schéma (version $databaseVersion, attendue " . SCHEMA_VERSION . ').'
                . " Recréez-la : php database/init.php --reset"
                . ' (Docker : docker compose run --rm app php database/init.php --reset).'
            );
        }
        echo "Base déjà initialisée : rien à faire ($databasePath).\n";
        echo "Pour la recréer depuis le seed : php database/init.php --reset\n";
        exit(0);
    }

    // Une seule transaction : soit tout est créé, soit rien.
    $pdo->beginTransaction();
    foreach (['schema.sql', 'seed.sql'] as $sqlFile) {
        $sql = file_get_contents(__DIR__ . '/' . $sqlFile);
        if ($sql === false) {
            throw new RuntimeException("fichier database/$sqlFile illisible.");
        }
        $pdo->exec($sql);
    }

    // Avant le commit, pour que l'erreur annule tout : le seed ne doit référencer aucun id inexistant.
    $foreignKeyErrors = $pdo->query('PRAGMA foreign_key_check')->fetchAll();
    if ($foreignKeyErrors !== []) {
        throw new RuntimeException('le seed contient des références invalides (PRAGMA foreign_key_check).');
    }

    $pdo->exec('PRAGMA user_version = ' . SCHEMA_VERSION);
    $pdo->commit();

    $ingredientCount = (int) $pdo->query('SELECT COUNT(*) FROM ingredients')->fetchColumn();
    $recipeCount = (int) $pdo->query('SELECT COUNT(*) FROM recipes')->fetchColumn();
    echo "Base initialisée : $ingredientCount ingrédients, $recipeCount recettes ($databasePath).\n";
    exit(0);
} catch (Throwable $exception) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    // On ne laisse pas un fichier à moitié créé : le prochain lancement repartira de zéro.
    Database::close();
    $pdo = null;
    if ($isNewFile && file_exists($databasePath)) {
        unlink($databasePath);
    }
    fwrite(STDERR, 'ERREUR : initialisation de la base impossible : ' . $exception->getMessage() . "\n");
    exit(1);
}
