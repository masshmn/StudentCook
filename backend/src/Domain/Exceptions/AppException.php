<?php

declare(strict_types=1);

namespace StudentCook\Domain\Exceptions;

// Le code HTTP n'est pas ici (couche Domain) : il est choisi par ErrorController.
abstract class AppException extends \Exception
{
    /** @param array<string, string> $errors */
    public function __construct(private readonly array $errors)
    {
        parent::__construct(implode(' ', $errors));
    }

    /** @return array<string, string> */
    public function getErrors(): array
    {
        return $this->errors;
    }
}
