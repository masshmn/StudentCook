<?php

declare(strict_types=1);

namespace StudentCook\Domain\Exceptions;

// Message imposé par D6 et vérifié par le test CL2.
class RecipeIsPlannedException extends AppException
{
    public function __construct()
    {
        parent::__construct(['recette' => 'Impossible de supprimer cette recette car elle est planifiée dans un repas.']);
    }
}
