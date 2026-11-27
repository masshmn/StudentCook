<?php

declare(strict_types=1);

namespace StudentCook\Domain\Repositories;

use StudentCook\Domain\AbstractRepository;

// Référentiel en lecture seule (F0) : rempli par seed.sql, aucune méthode d'écriture.
final class IngredientRepository extends AbstractRepository
{
    /**
     * Rayons dans l'ordre de la SPEC (pas alphabétique), puis nom.
     * Le nom est comparé octet par octet : un nom accentué en tête (« Œufs ») passe
     * en fin de rayon (intl absent de l'image Docker) ; l'écran re-trie en français.
     *
     * @return list<array{id: int, name: string, aisle: string, price_per_unit: int, unit: string}>
     */
    public function findAll(): array
    {
        $statement = $this->pdo->prepare(
            "SELECT id, name, aisle, price_per_unit, unit
             FROM ingredients
             ORDER BY CASE aisle
                          WHEN 'Fruits & Légumes' THEN 1
                          WHEN 'Épicerie' THEN 2
                          WHEN 'Frais' THEN 3
                          WHEN 'Surgelés' THEN 4
                          WHEN 'Viandes & Poissons' THEN 5
                          WHEN 'Autres' THEN 6
                      END,
                      name"
        );
        $statement->execute();

        return $statement->fetchAll();
    }
}
