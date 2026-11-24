<?php

declare(strict_types=1);

namespace StudentCook\Http\Controllers;

use StudentCook\Http\AbstractController;

// Erreurs techniques renvoyées par le routeur (index.php), avant tout Controller métier.
final class ErrorController extends AbstractController
{
    public function routeNotFound(): void
    {
        $this->jsonError(['route' => 'Route introuvable.'], 404);
    }

    public function invalidJson(): void
    {
        $this->jsonError(['json' => 'Corps de requête invalide.'], 422);
    }

    public function serverError(): void
    {
        $this->jsonError(['serveur' => 'Erreur interne du serveur.'], 500);
    }
}
