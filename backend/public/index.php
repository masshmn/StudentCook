<?php

declare(strict_types=1);

use StudentCook\Domain\Exceptions\AppException;
use StudentCook\Http\Controllers\ErrorController;
use StudentCook\Http\Controllers\IngredientController;

require dirname(__DIR__) . '/bootstrap.php';

/*
 * Table des routes API : [méthode HTTP, chemin, Controller, méthode du Controller].
 * {id} n'accepte qu'un entier strictement positif, transmis au Controller en int.
 * Pour POST / PUT / PATCH, le corps JSON décodé est passé en dernier argument.
 * Exemple : ['GET', '/api/recipes/{id}', RecipeController::class, 'show'],
 */
const API_ROUTES = [
    ['GET', '/api/ingredients', IngredientController::class, 'index'],
];

const JSON_BODY_METHODS = ['POST', 'PUT', 'PATCH'];

const STATIC_MIME_TYPES = [
    'html' => 'text/html; charset=utf-8',
    'css'  => 'text/css; charset=utf-8',
    'js'   => 'text/javascript; charset=utf-8',
    'woff2' => 'font/woff2', // polices locales prévues par D8
];

function routePatternToRegex(string $routePath): string
{
    $escapedPath = preg_quote($routePath, '#');
    return '#^' . str_replace(preg_quote('{id}', '#'), '([1-9][0-9]{0,17})', $escapedPath) . '$#';
}

/** @return array<string, mixed>|null null si le corps n'est pas un objet JSON valide */
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
    // Dossier absent (montage raté) : false deviendrait le préfixe « / » et ouvrirait tout le disque.
    if ($frontendRoot === false) {
        error_log('Dossier frontend/ introuvable.');
        http_response_code(500);
        header('Content-Type: text/plain; charset=utf-8');
        echo 'Erreur interne du serveur.';
        return;
    }
    $relativePath = ltrim($requestPath, '/');
    // Un octet NUL (%00) ferait lever une ValueError à realpath() : 404 directement.
    $requestedFile = str_contains($relativePath, "\0")
        ? false
        : realpath($frontendRoot . '/' . ($relativePath === '' ? 'index.html' : $relativePath));

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

$httpMethod = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
// Pas de parse_url() : il lit « //api/x » comme un nom d'hôte et perd « /api ».
// Les « / » répétés sont fusionnés pour que « //api/x » reste une requête API (réponse JSON).
$requestUri = explode('?', $_SERVER['REQUEST_URI'] ?? '/', 2)[0];
$requestPath = preg_replace('#/{2,}#', '/', rawurldecode($requestUri === '' ? '/' : $requestUri));
$isApiRequest = $requestPath === '/api' || str_starts_with($requestPath, '/api/');

// Erreur fatale (hors exception) : réponse JSON générique au lieu d'une page vide.
register_shutdown_function(function () use ($isApiRequest): void {
    $lastError = error_get_last();
    $fatalTypes = E_ERROR | E_PARSE | E_CORE_ERROR | E_COMPILE_ERROR;
    if ($isApiRequest && $lastError !== null && ($lastError['type'] & $fatalTypes) && !headers_sent()) {
        (new ErrorController())->serverError();
    }
});

try {
    if ($isApiRequest) {
        dispatchApi($httpMethod, $requestPath);
    } else {
        serveFrontend($requestPath);
    }
} catch (AppException $exception) {
    // Exception métier (422 / 404 / 409) : les Controllers n'ont pas de try/catch à écrire.
    if (!headers_sent()) {
        (new ErrorController())->appError($exception);
    }
} catch (Throwable $exception) {
    error_log((string) $exception);
    if (!headers_sent()) {
        (new ErrorController())->serverError();
    }
}
