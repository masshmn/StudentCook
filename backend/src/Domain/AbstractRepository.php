<?php

declare(strict_types=1);

namespace StudentCook\Domain;

use PDO;
use StudentCook\Infrastructure\Database;

abstract class AbstractRepository
{
    protected PDO $pdo;

    public function __construct()
    {
        // Database::getConnection() active PRAGMA foreign_keys = ON (ticket #4).
        $this->pdo = Database::getConnection();
    }
}
