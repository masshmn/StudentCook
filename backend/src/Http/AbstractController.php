<?php

declare(strict_types=1);

namespace StudentCook\Http;

abstract class AbstractController
{
    protected function json(mixed $data, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE);
    }

    protected function jsonError(array $errors, int $status = 422): void
    {
        $this->json(['erreurs' => $errors], $status);
    }
}
