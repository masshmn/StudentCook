<?php

declare(strict_types=1);

namespace StudentCook\Http\Controllers;

use StudentCook\Domain\Repositories\IngredientRepository;
use StudentCook\Http\AbstractController;

// Lecture seule : aucune action d'écriture, POST / PUT / DELETE tombent sur la 404 du routeur.
final class IngredientController extends AbstractController
{
    public function index(): void
    {
        $this->json((new IngredientRepository())->findAll());
    }
}
