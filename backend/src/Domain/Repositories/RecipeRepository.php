<?php

declare(strict_types=1);

namespace StudentCook\Domain\Repositories;

use StudentCook\Domain\AbstractRepository;
use StudentCook\Domain\Exceptions\RecipeNotFoundException;

final class RecipeRepository extends AbstractRepository
{
    private const RECIPE_COLUMNS = 'id, name, prep_time, servings,
        is_vegetarian, is_vegan, is_gluten_free, is_halal';

    /** @return list<array<string, int|string>> toutes les recettes, triées par nom */
    public function findAll(): array
    {
        $statement = $this->pdo->prepare(
            'SELECT ' . self::RECIPE_COLUMNS . ' FROM recipes ORDER BY name COLLATE NOCASE'
        );
        $statement->execute();
        return $statement->fetchAll();
    }

    /**
     * Lignes d'ingrédients de toutes les recettes en UNE requête (évite une requête par recette).
     *
     * @return array<int, list<array<string, int|string>>> [recipe_id => [['quantity', 'price_per_unit', 'unit'], ...]]
     */
    public function findAllIngredientLinesByRecipe(): array
    {
        $statement = $this->pdo->prepare(
            'SELECT ri.recipe_id, ri.quantity, i.price_per_unit, i.unit
             FROM recipe_ingredients ri
             JOIN ingredients i ON i.id = ri.ingredient_id'
        );
        $statement->execute();

        $linesByRecipe = [];
        foreach ($statement->fetchAll() as $line) {
            $linesByRecipe[(int) $line['recipe_id']][] = $line;
        }
        return $linesByRecipe;
    }

    /**
     * Recette avec ses ingrédients (clé 'ingredients') et ses étapes dans l'ordre (clé 'steps').
     *
     * @return array<string, mixed>
     * @throws RecipeNotFoundException si l'id n'existe pas
     */
    public function findById(int $id): array
    {
        $statement = $this->pdo->prepare(
            'SELECT ' . self::RECIPE_COLUMNS . ' FROM recipes WHERE id = :id'
        );
        $statement->execute([':id' => $id]);
        $recipe = $statement->fetch();
        if ($recipe === false) {
            throw new RecipeNotFoundException();
        }

        $statement = $this->pdo->prepare(
            'SELECT i.id, i.name, i.aisle, i.unit, i.price_per_unit, ri.quantity
             FROM recipe_ingredients ri
             JOIN ingredients i ON i.id = ri.ingredient_id
             WHERE ri.recipe_id = :id
             ORDER BY i.name COLLATE NOCASE'
        );
        $statement->execute([':id' => $id]);
        $recipe['ingredients'] = $statement->fetchAll();

        $statement = $this->pdo->prepare(
            'SELECT step_number, description FROM recipe_steps WHERE recipe_id = :id ORDER BY step_number'
        );
        $statement->execute([':id' => $id]);
        $recipe['steps'] = $statement->fetchAll();

        return $recipe;
    }
}
