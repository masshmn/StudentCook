# Prompt : Implémentation

## Contexte
Projet Student Cook : PHP 8.3 natif + SQLite, architecture en couches.
Plan validé : [lien vers plan ou résumé]

## Objectif
Implémenter la fonctionnalité selon le plan validé.

## Consigne
Implémente le code en respectant :

1. **Architecture** : les 3 règles d'or (voir AGENTS.md)
2. **Sécurité** :
   - SQL : `prepare()` + `execute()` avec paramètres nommés
   - Front : `textContent` uniquement, jamais `innerHTML`
3. **Base de données** :
   - `PRAGMA foreign_keys = ON` (déjà dans Database.php)
   - Transactions si multi-tables
   - Montants en centimes
4. **Validation** :
   - Côté serveur obligatoire
   - Format erreur : `{"erreurs": {"champ": "message"}}`
   - Codes HTTP : 200/201/404/409/422
5. **Qualité** :
   - Noms de variables explicites
   - Pas de code commenté
   - Pas de `var_dump` ou `console.log` oubliés

## Ordre d'implémentation
1. Repository (SQL)
2. Service (règles métier)
3. Controller (validation + réponses JSON)
4. Front (affichage + API)

## Après chaque fichier PHP
Lance `php -l <fichier>` pour vérifier la syntaxe.

## Format de sortie attendu
Pour chaque fichier :
```markdown
## [Nom du fichier]

[Code complet du fichier]

### Vérification
```bash
php -l backend/src/[chemin]
```

### Points d'attention
- [Explication des choix techniques]
- [Pièges évités]
```

## Exemple (partiel)
```php
// backend/src/Repositories/RecipeRepository.php

class RecipeRepository {
    private PDO $pdo;

    public function __construct(PDO $pdo) {
        $this->pdo = $pdo;
    }

    public function create(array $data): int {
        $this->pdo->beginTransaction();
        try {
            // 1. Insérer la recette
            $stmt = $this->pdo->prepare('
                INSERT INTO recipes (name, prep_time, servings, is_vegetarian, is_vegan, is_gluten_free)
                VALUES (:name, :prep_time, :servings, :is_vegetarian, :is_vegan, :is_gluten_free)
            ');
            $stmt->execute([
                'name' => $data['name'],
                'prep_time' => $data['prep_time'],
                'servings' => $data['servings'],
                'is_vegetarian' => $data['is_vegetarian'] ? 1 : 0,
                'is_vegan' => $data['is_vegan'] ? 1 : 0,
                'is_gluten_free' => $data['is_gluten_free'] ? 1 : 0,
            ]);

            $recipeId = (int) $this->pdo->lastInsertId();

            // 2. Insérer les ingrédients
            foreach ($data['ingredients'] as $ingredient) {
                $stmt = $this->pdo->prepare('
                    INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity)
                    VALUES (:recipe_id, :ingredient_id, :quantity)
                ');
                $stmt->execute([
                    'recipe_id' => $recipeId,
                    'ingredient_id' => $ingredient['id'],
                    'quantity' => $ingredient['quantity'],
                ]);
            }

            // 3. Insérer les étapes
            foreach ($data['steps'] as $index => $step) {
                $stmt = $this->pdo->prepare('
                    INSERT INTO recipe_steps (recipe_id, step_number, description)
                    VALUES (:recipe_id, :step_number, :description)
                ');
                $stmt->execute([
                    'recipe_id' => $recipeId,
                    'step_number' => $index + 1,
                    'description' => $step,
                ]);
            }

            $this->pdo->commit();
            return $recipeId;
        } catch (Exception $e) {
            $this->pdo->rollBack();
            throw $e;
        }
    }
}
```

### Points d'attention
- Transaction pour garantir l'atomicité (3 tables)
- Paramètres nommés pour éviter injection SQL
- Booléens convertis en 0/1 pour SQLite
- step_number commence à 1

## Contre-exemple
❌ Pas de `query()` avec concaténation
❌ Pas de `innerHTML` avec données utilisateur
❌ Pas de calcul métier dans le Repository (ex : calcul de coût)
