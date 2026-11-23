<?php

declare(strict_types=1);

namespace StudentCook\Domain\Exceptions;

// Porte les erreurs de validation au format ['champ' => 'message'] (réponse 422).
class ValidationException extends \Exception
{
    public function __construct(private readonly array $errors)
    {
        parent::__construct('Validation échouée.');
    }

    public function getErrors(): array
    {
        return $this->errors;
    }
}
