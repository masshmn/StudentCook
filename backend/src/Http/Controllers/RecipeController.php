<?php

declare(strict_types=1);

namespace StudentCook\Http\Controllers;

use StudentCook\Domain\Repositories\RecipeRepository;
use StudentCook\Domain\Services\RecipeCostService;
use StudentCook\Http\AbstractController;

final class RecipeController extends AbstractController
{
    private RecipeRepository $recipes;
    private RecipeCostService $costs;

    public function __construct()
    {
        $this->recipes = new RecipeRepository();
        $this->costs = new RecipeCostService();
    }

    // GET /api/recipes
    public function index(): void
    {
        $linesByRecipe = $this->recipes->findAllIngredientLinesByRecipe();

        $catalogue = array_map(
            fn (array $recipe): array => $this->formatSummary($recipe, $linesByRecipe[(int) $recipe['id']] ?? []),
            $this->recipes->findAll(),
        );

        $this->json($catalogue);
    }

    // GET /api/recipes/{id} — id inexistant : RecipeNotFoundException, convertie en 404 par index.php.
    public function show(int $id): void
    {
        $recipe = $this->recipes->findById($id);

        $detail = $this->formatSummary($recipe, $recipe['ingredients']);
        $detail['ingredients'] = array_map(fn (array $ingredient): array => [
            'id' => (int) $ingredient['id'],
            'name' => $ingredient['name'],
            'aisle' => $ingredient['aisle'],
            'unit' => $ingredient['unit'],
            'quantity' => (int) $ingredient['quantity'],
        ], $recipe['ingredients']);
        $detail['steps'] = array_map(fn (array $step): array => [
            'step_number' => (int) $step['step_number'],
            'description' => $step['description'],
        ], $recipe['steps']);

        $this->json($detail);
    }

    /**
     * Champs communs à la liste et au détail, typés pour le JSON (int, bool).
     *
     * @param array<string, mixed> $recipe
     * @param list<array<string, int|string>> $lines
     * @return array<string, int|string|bool>
     */
    private function formatSummary(array $recipe, array $lines): array
    {
        $servings = (int) $recipe['servings'];

        return [
            'id' => (int) $recipe['id'],
            'name' => (string) $recipe['name'],
            'prep_time' => (int) $recipe['prep_time'],
            'servings' => $servings,
            'cost_per_serving_cents' => $this->costs->costPerServingCents($lines, $servings),
            'is_vegetarian' => (bool) $recipe['is_vegetarian'],
            'is_vegan' => (bool) $recipe['is_vegan'],
            'is_gluten_free' => (bool) $recipe['is_gluten_free'],
            'is_halal' => (bool) $recipe['is_halal'],
        ];
    }
}
