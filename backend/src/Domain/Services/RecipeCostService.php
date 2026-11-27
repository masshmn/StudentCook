<?php

declare(strict_types=1);

namespace StudentCook\Domain\Services;

// Coût d'une recette, SPEC §4 : ligne = quantité × prix / 1000 (kg, L) ou quantité × prix (unité).
final class RecipeCostService
{
    /**
     * @param list<array<string, int|string>> $lines lignes avec 'quantity', 'price_per_unit' (centimes) et 'unit'
     * @return int coût par portion en centimes
     */
    public function costPerServingCents(array $lines, int $servings): int
    {
        // Somme en millièmes de centime : reste entière, donc aucun arrondi intermédiaire.
        $totalThousandthsOfCent = 0;
        foreach ($lines as $line) {
            $lineCost = (int) $line['quantity'] * (int) $line['price_per_unit'];
            $totalThousandthsOfCent += $line['unit'] === 'unité' ? $lineCost * 1000 : $lineCost;
        }

        // Un seul arrondi, au résultat final (règle de la SPEC).
        return (int) round($totalThousandthsOfCent / (1000 * $servings));
    }
}
