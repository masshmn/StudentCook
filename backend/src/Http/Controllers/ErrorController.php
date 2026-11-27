<?php

declare(strict_types=1);

namespace StudentCook\Http\Controllers;

use StudentCook\Domain\Exceptions\AppException;
use StudentCook\Domain\Exceptions\RecipeIsPlannedException;
use StudentCook\Domain\Exceptions\RecipeNotFoundException;
use StudentCook\Domain\Exceptions\ValidationException;
use StudentCook\Http\AbstractController;

final class ErrorController extends AbstractController
{
    // Seul endroit où une exception métier est associée à un code HTTP.
    private const STATUS_BY_EXCEPTION = [
        ValidationException::class      => 422,
        RecipeNotFoundException::class  => 404,
        RecipeIsPlannedException::class => 409,
    ];

    public function appError(AppException $exception): void
    {
        $status = self::STATUS_BY_EXCEPTION[$exception::class] ?? null;
        if ($status === null) {
            // Exception métier oubliée dans la table : bug à corriger, pas un message pour le client.
            error_log('Exception métier sans code HTTP : ' . $exception::class);
            $this->serverError();
            return;
        }
        $this->jsonError($exception->getErrors(), $status);
    }

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
