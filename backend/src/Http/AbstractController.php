<?php

declare(strict_types=1);

namespace StudentCook\Http;

abstract class AbstractController
{
    // mixed : seule exception à la règle de typage, json_encode accepte tout type sérialisable.
    protected function json(mixed $data, int $status = 200): void
    {
        // Encodé avant tout en-tête : un UTF-8 invalide lève une exception (journalisée, 500)
        // au lieu d'envoyer un corps vide avec le code de succès.
        $body = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        echo $body;
    }

    /** @param array<string, string> $errors ['champ' => 'message'] */
    protected function jsonError(array $errors, int $status = 422): void
    {
        // (object) : un tableau vide doit rester un objet JSON {} (contrat { champ: message }).
        $this->json(['erreurs' => (object) $errors], $status);
    }
}
