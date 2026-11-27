<?php

declare(strict_types=1);

namespace StudentCook\Domain\Exceptions;

class RecipeNotFoundException extends \Exception
{
    public function __construct(string $message = 'Recette introuvable.')
    {
        parent::__construct($message);
    }
}
