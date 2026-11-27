<?php

declare(strict_types=1);

namespace StudentCook\Domain\Exceptions;

class RecipeNotFoundException extends AppException
{
    public function __construct()
    {
        parent::__construct(['recette' => 'Recette introuvable.']);
    }
}
