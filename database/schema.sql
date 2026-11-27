-- Schéma Student Cook — SQLite 3
-- Source : docs/MODELE_DONNEES.md
-- Exécuté par database/init.php (dans une transaction, avec PRAGMA foreign_keys = ON).
-- Montants en centimes (INTEGER), quantités entières (g, mL ou nombre de pièces).

-- ---------------------------------------------------------------------------
-- Référentiel d'ingrédients (F0) : rempli uniquement par seed.sql, lecture seule.
-- ---------------------------------------------------------------------------
CREATE TABLE ingredients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    aisle TEXT NOT NULL CHECK(aisle IN ('Fruits & Légumes', 'Épicerie', 'Frais', 'Surgelés', 'Viandes & Poissons', 'Autres')),
    price_per_unit INTEGER NOT NULL CHECK(price_per_unit >= 0), -- centimes par kg, par L ou par pièce
    unit TEXT NOT NULL CHECK(unit IN ('kg', 'L', 'unité')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ingredients_aisle ON ingredients(aisle);

-- ---------------------------------------------------------------------------
-- Recettes (F1). Le coût par portion est calculé, jamais stocké.
-- ---------------------------------------------------------------------------
CREATE TABLE recipes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    prep_time INTEGER NOT NULL CHECK(prep_time > 0), -- minutes
    servings INTEGER NOT NULL CHECK(servings > 0),
    is_vegetarian INTEGER NOT NULL DEFAULT 0 CHECK(is_vegetarian IN (0, 1)),
    is_vegan INTEGER NOT NULL DEFAULT 0 CHECK(is_vegan IN (0, 1)),
    is_gluten_free INTEGER NOT NULL DEFAULT 0 CHECK(is_gluten_free IN (0, 1)),
    is_halal INTEGER NOT NULL DEFAULT 0 CHECK(is_halal IN (0, 1)),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK(is_vegan = 0 OR is_vegetarian = 1) -- végan ⇒ végétarien
);

-- ---------------------------------------------------------------------------
-- Ingrédients d'une recette. La clé primaire composite garantit
-- UNIQUE(recipe_id, ingredient_id) : un ingrédient une seule fois par recette.
-- CASCADE côté recette : supprimer une recette supprime ses lignes d'ingrédients
-- (la suppression d'une recette planifiée reste bloquée par meal_planning).
-- RESTRICT côté ingrédient : un ingrédient utilisé ne peut pas être supprimé.
-- ---------------------------------------------------------------------------
CREATE TABLE recipe_ingredients (
    recipe_id INTEGER NOT NULL,
    ingredient_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0), -- g (kg), mL (L) ou nombre de pièces (unité)
    PRIMARY KEY (recipe_id, ingredient_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE RESTRICT
);

-- Pas d'index sur recipe_id : la clé primaire (recipe_id, ingredient_id) le couvre déjà.
CREATE INDEX idx_recipe_ingredients_ingredient ON recipe_ingredients(ingredient_id);

-- ---------------------------------------------------------------------------
-- Étapes d'une recette (ordre : step_number à partir de 1).
-- ---------------------------------------------------------------------------
CREATE TABLE recipe_steps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER NOT NULL,
    step_number INTEGER NOT NULL CHECK(step_number > 0),
    description TEXT NOT NULL,
    UNIQUE (recipe_id, step_number),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- Pas d'index sur recipe_id : UNIQUE (recipe_id, step_number) le couvre déjà.

-- ---------------------------------------------------------------------------
-- Planning (F3) : un repas = une date + un créneau. Vide après init.
-- RESTRICT : une recette planifiée ne peut pas être supprimée (409).
-- ---------------------------------------------------------------------------
CREATE TABLE meal_planning (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    meal_date TEXT NOT NULL CHECK(meal_date = date(meal_date)), -- AAAA-MM-JJ valide
    meal_slot TEXT NOT NULL CHECK(meal_slot IN ('Midi', 'Soir')),
    recipe_id INTEGER NOT NULL,
    servings INTEGER NOT NULL CHECK(servings > 0), -- portions de ce repas (D7)
    UNIQUE (meal_date, meal_slot),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE RESTRICT
);

-- Pas d'index sur meal_date : UNIQUE (meal_date, meal_slot) le couvre déjà.
CREATE INDEX idx_meal_planning_recipe ON meal_planning(recipe_id);

-- ---------------------------------------------------------------------------
-- Cases cochées de la liste de courses (F4), par période. Vide après init.
-- ---------------------------------------------------------------------------
CREATE TABLE shopping_check (
    period_type TEXT NOT NULL CHECK(period_type IN ('jour', 'semaine', 'mois')),
    period_start TEXT NOT NULL CHECK(period_start = date(period_start)), -- date, lundi ou 1er du mois
    ingredient_id INTEGER NOT NULL,
    is_checked INTEGER NOT NULL DEFAULT 0 CHECK(is_checked IN (0, 1)),
    PRIMARY KEY (period_type, period_start, ingredient_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
);
