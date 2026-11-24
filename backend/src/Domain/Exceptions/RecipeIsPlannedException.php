<?php

declare(strict_types=1);

namespace StudentCook\Domain\Exceptions;

class RecipeIsPlannedException extends \Exception
{
    public function __construct(string $message = 'Cette recette est planifiée : retirez-la du planning avant de la supprimer.')
    {
        parent::__construct($message);
    }
}
