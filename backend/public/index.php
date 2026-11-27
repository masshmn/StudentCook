<?php

declare(strict_types=1);

use StudentCook\Http\Controllers\ErrorController;

// Aucune erreur PHP ni stack trace ne doit atteindre le client : on journalise seulement.
ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);
date_default_timezone_set('Europe/Paris');

// Autoload PSR-4 maison : StudentCook\X\Y → backend/src/X/Y.php
spl_autoload_register(function (string $className): void {
    $prefix = 'StudentCook\\';
    if (!str_starts_with($className, $prefix)) {
        return;
    }
    $relativePath = str_replace('\\', '/', substr($className, strlen($prefix)));
    $filePath = dirname(__DIR__) . '/src/' . $relativePath . '.php';
    if (is_file($filePath)) {
        require $filePath;
    }
});

/*
 * Table des routes API : [méthode HTTP, chemin, Controller, méthode du Controller].
 * {id} n'accepte qu'un entier strictement positif, transmis au Controller en int.
 * Pour POST / PUT / PATCH, le corps JSON décodé est passé en dernier argument.
 * Exemple : ['GET', '/api/recipes/{id}', RecipeController::class, 'show'],
 */
const API_ROUTES = [
];

const JSON_BODY_METHODS = ['POST', 'PUT', 'PATCH'];

const STATIC_MIME_TYPES = [
    'html' => 'text/html; charset=utf-8',
    'css'  => 'text/css; charset=utf-8',
    'js'   => 'text/javascript; charset=utf-8',
    'json' => 'application/json; charset=utf-8',
    'svg'  => 'image/svg+xml',
    'png'  => 'image/png',
    'jpg'  => 'image/jpeg',
    'jpeg' => 'image/jpeg',
    'webp' => 'image/webp',
    'ico'  => 'image/x-icon',
];

function routePatternToRegex(string $routePath): string
{
    $escapedPath = preg_quote($routePath, '#');
    return '#^' . str_replace(preg_quote('{id}', '#'), '([1-9][0-9]{0,17})', $escapedPath) . '$#';
}

// Renvoie le corps décodé, ou null s'il n'est pas un objet JSON valide.
function readJsonObjectBody(): ?array
{
    $rawBody = file_get_contents('php://input');
    if ($rawBody === false || !str_starts_with(ltrim($rawBody), '{')) {
        return null;
    }
    try {
        $decodedBody = json_decode($rawBody, true, 64, JSON_THROW_ON_ERROR);
    } catch (JsonException) {
        return null;
    }
    return is_array($decodedBody) ? $decodedBody : null;
}

function dispatchApi(string $httpMethod, string $requestPath): void
{
    foreach (API_ROUTES as [$routeMethod, $routePath, $controllerClass, $controllerAction]) {
        if ($routeMethod !== $httpMethod) {
            continue;
        }
        if (preg_match(routePatternToRegex($routePath), $requestPath, $matches) !== 1) {
            continue;
        }

        $arguments = array_map('intval', array_slice($matches, 1));

        if (in_array($httpMethod, JSON_BODY_METHODS, true)) {
            $requestBody = readJsonObjectBody();
            if ($requestBody === null) {
                (new ErrorController())->invalidJson();
                return;
            }
            $arguments[] = $requestBody;
        }

        (new $controllerClass())->$controllerAction(...$arguments);
        return;
    }

    (new ErrorController())->routeNotFound();
}

function serveFrontend(string $requestPath): void
{
    $frontendRoot = realpath(dirname(__DIR__, 2) . '/frontend');
    $relativePath = ltrim($requestPath, '/');
    $requestedFile = realpath($frontendRoot . '/' . ($relativePath === '' ? 'index.html' : $relativePath));

    // Fichier absent ou hors du dossier frontend/ (ex : /../backend/...) : 404.
    if (
        $requestedFile === false
        || !is_file($requestedFile)
        || !str_starts_with($requestedFile, $frontendRoot . DIRECTORY_SEPARATOR)
    ) {
        http_response_code(404);
        header('Content-Type: text/plain; charset=utf-8');
        echo 'Fichier introuvable.';
        return;
    }

    $extension = strtolower(pathinfo($requestedFile, PATHINFO_EXTENSION));
    header('Content-Type: ' . (STATIC_MIME_TYPES[$extension] ?? 'application/octet-stream'));
    readfile($requestedFile);
}

$isApiRequest = false;

// Erreur fatale (hors exception) : réponse JSON générique au lieu d'une page vide.
register_shutdown_function(function () use (&$isApiRequest): void {
    $lastError = error_get_last();
    $fatalTypes = E_ERROR | E_PARSE | E_CORE_ERROR | E_COMPILE_ERROR;
    if ($isApiRequest && $lastError !== null && ($lastError['type'] & $fatalTypes) && !headers_sent()) {
        (new ErrorController())->serverError();
    }
});

$httpMethod = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
$requestPath = rawurldecode(parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/');
$isApiRequest = $requestPath === '/api' || str_starts_with($requestPath, '/api/');

try {
    if ($isApiRequest) {
        dispatchApi($httpMethod, $requestPath);
    } else {
        serveFrontend($requestPath);
    }
} catch (Throwable $exception) {
    error_log((string) $exception);
    if (!headers_sent()) {
        (new ErrorController())->serverError();
    }
}
