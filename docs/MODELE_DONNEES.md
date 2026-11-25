# Modèle de données — Student Cook

> SQLite 3 · Foreign keys activées · Contraintes CHECK · Montants en centimes

## Diagramme conceptuel

```
┌──────────────────┐ 1      n ┌────────────────────┐ n      1 ┌──────────────┐
│   ingredients    │──────────│ recipe_ingredients │──────────│   recipes    │
│ (référentiel,    │          └────────────────────┘          └──────┬───────┘
│  lecture seule)  │                                            1 │       │ 1
└────────┬─────────┘                                              │       │
         │ 1                                                    n │       │ n
         │                                         ┌──────────────▼┐   ┌──▼────────────┐
         │ n                                       │ recipe_steps  │   │ meal_planning │
┌────────▼─────────┐                               └───────────────┘   └───────────────┘
│  shopping_check  │
└──────────────────┘
```

> v2.1 : `weekly_planning` (semaine + jour) est remplacée par `meal_planning` (une **date** par repas) pour servir les vues jour/semaine/mois avec la même requête par intervalle de dates. `shopping_check` est indexée par **période** (jour, semaine, mois).

## Tables

### `ingredients`

Référentiel d'ingrédients (F0), **rempli uniquement par `database/seed.sql`**. L'API n'expose qu'une lecture (`GET`) : aucun INSERT/UPDATE/DELETE depuis l'application.

```sql
CREATE TABLE ingredients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    aisle TEXT NOT NULL CHECK(aisle IN ('Fruits & Légumes', 'Épicerie', 'Frais', 'Surgelés', 'Viandes & Poissons', 'Autres')),
    price_per_unit INTEGER NOT NULL CHECK(price_per_unit >= 0), -- centimes
    unit TEXT NOT NULL CHECK(unit IN ('kg', 'L', 'unité')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ingredients_aisle ON ingredients(aisle);
```

**Règles** :
- `UNIQUE` sur `name` protège le seed contre les doublons
- Prix en centimes (INTEGER) pour éviter les problèmes d'arrondi
- Le formulaire de recette propose ces lignes dans une liste déroulante (triée par rayon puis nom)
- `RESTRICT` conservé par sécurité : même via un outil SQL, un ingrédient utilisé ne peut pas être supprimé

---

### `recipes`

Recettes du catalogue (F1).

```sql
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
```

**Règles** :
- Les drapeaux régime sont des booléens (0/1), déclaratifs (cochés par l'utilisateur)
- `is_halal` : drapeau déclaratif, pas de certification
- Suppression interdite si la recette est référencée dans `meal_planning` (RESTRICT)
- Le coût par portion est **calculé dynamiquement**, jamais stocké

---

### `recipe_ingredients`

Table de liaison entre recettes et ingrédients (quantités).

```sql
CREATE TABLE recipe_ingredients (
    recipe_id INTEGER NOT NULL,
    ingredient_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0), -- g (kg), mL (L) ou nombre de pièces (unité)
    PRIMARY KEY (recipe_id, ingredient_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE RESTRICT
);

CREATE INDEX idx_recipe_ingredients_recipe ON recipe_ingredients(recipe_id);
CREATE INDEX idx_recipe_ingredients_ingredient ON recipe_ingredients(ingredient_id);
```

**Règles** :
- Clé primaire composite (une seule quantité par ingrédient par recette) : un doublon dans le formulaire est refusé en 422 **avant** l'INSERT
- `ON DELETE CASCADE` côté recette (comme `recipe_steps`) : supprimer une recette non planifiée supprime ses lignes d'ingrédients ; une recette planifiée reste protégée par le `RESTRICT` de `meal_planning`. `RESTRICT` côté ingrédient : un ingrédient utilisé ne peut pas être supprimé
- `ingredient_id` doit exister dans le référentiel : vérifié côté serveur (422 « Ingrédient inconnu. »), la FK garantit le reste
- Quantités **entières** (0 décimale, décision D5) : g pour `kg`, mL pour `L`, nombre de pièces pour `unité` ; pas de conversion
- Modification d'une recette : **transaction** pour DELETE puis INSERT des nouveaux ingrédients

---

### `recipe_steps`

Étapes de préparation d'une recette (ordre important).

```sql
CREATE TABLE recipe_steps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER NOT NULL,
    step_number INTEGER NOT NULL CHECK(step_number > 0),
    description TEXT NOT NULL,
    UNIQUE (recipe_id, step_number),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

CREATE INDEX idx_recipe_steps_recipe ON recipe_steps(recipe_id);
```

**Règles** :
- `step_number` commence à 1 et doit être séquentiel (validé côté serveur)
- `ON DELETE CASCADE` : si on supprime une recette, ses étapes sont supprimées automatiquement
- Modification : **transaction** pour DELETE puis INSERT des nouvelles étapes

---

### `meal_planning`

Planning des repas (F3), une ligne par repas daté.

```sql
CREATE TABLE meal_planning (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    meal_date TEXT NOT NULL CHECK(meal_date = date(meal_date)), -- format YYYY-MM-DD valide
    meal_slot TEXT NOT NULL CHECK(meal_slot IN ('Midi', 'Soir')),
    recipe_id INTEGER NOT NULL,
    UNIQUE (meal_date, meal_slot),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE RESTRICT
);

CREATE INDEX idx_meal_planning_date ON meal_planning(meal_date);
CREATE INDEX idx_meal_planning_recipe ON meal_planning(recipe_id);
```

**Règles** :
- `CHECK(meal_date = date(meal_date))` refuse une date mal formée ou inexistante (ex : `2026-02-30`)
- `UNIQUE` : un seul plat par créneau et par date
- `ON DELETE RESTRICT` : impossible de supprimer une recette si elle est planifiée
- Les vues jour/semaine/mois font **la même requête** avec un intervalle `[debut, fin]` calculé par le Service
- Le format ISO `YYYY-MM-DD` permet de comparer les dates comme des chaînes (`BETWEEN`)

---

### `shopping_check`

État des cases à cocher de la liste de courses (F4), par période.

```sql
CREATE TABLE shopping_check (
    period_type TEXT NOT NULL CHECK(period_type IN ('jour', 'semaine', 'mois')),
    period_start TEXT NOT NULL CHECK(period_start = date(period_start)), -- date, lundi ou 1er du mois
    ingredient_id INTEGER NOT NULL,
    is_checked INTEGER NOT NULL DEFAULT 0 CHECK(is_checked IN (0, 1)),
    PRIMARY KEY (period_type, period_start, ingredient_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
);
```

**Règles** :
- Uniquement l'état des cases (la liste elle-même est **calculée** depuis `meal_planning`)
- Une période est identifiée par `(period_type, period_start)` : `('jour', '2026-11-15')`, `('semaine', '2026-11-16')`, `('mois', '2026-11-01')`
- Les cases sont indépendantes d'une période à l'autre (cocher dans « mois » ne coche pas « semaine »)
- `period_start` est toujours calculé par le Service (lundi pour une semaine, 1er pour un mois), jamais pris tel quel du client
- La clé primaire couvre déjà la recherche par période (pas d'index supplémentaire)

---

## Requêtes importantes

### Coût d'une recette

```sql
SELECT
    r.id,
    r.name,
    ROUND(SUM(ri.quantity * i.price_per_unit
              / CASE WHEN i.unit = 'unité' THEN 1.0 ELSE 1000.0 END) / r.servings) AS cost_per_serving_cents
FROM recipes r
LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
LEFT JOIN ingredients i ON ri.ingredient_id = i.id
WHERE r.id = ?
GROUP BY r.id;
```

**Note** : Division par 1000 car quantités en g/mL et prix au kg/L ; **pas** de division pour `unité` (quantité = nombre de pièces, prix à la pièce).

---

### Planning sur une période (jour, semaine ou mois)

```sql
SELECT mp.meal_date, mp.meal_slot, r.id AS recipe_id, r.name
FROM meal_planning mp
JOIN recipes r ON r.id = mp.recipe_id
WHERE mp.meal_date BETWEEN :debut AND :fin
ORDER BY mp.meal_date, mp.meal_slot;
```

---

### Liste de courses pour une période

```sql
SELECT
    i.id,
    i.aisle,
    i.name,
    i.unit,
    SUM(ri.quantity) AS total_quantity,
    ROUND(SUM(ri.quantity * i.price_per_unit
              / CASE WHEN i.unit = 'unité' THEN 1.0 ELSE 1000.0 END)) AS total_cost_cents,
    COALESCE(sc.is_checked, 0) AS is_checked
FROM meal_planning mp
JOIN recipe_ingredients ri ON mp.recipe_id = ri.recipe_id
JOIN ingredients i ON ri.ingredient_id = i.id
LEFT JOIN shopping_check sc
       ON sc.period_type = :type
      AND sc.period_start = :debut
      AND sc.ingredient_id = i.id
WHERE mp.meal_date BETWEEN :debut AND :fin
GROUP BY i.id, i.aisle, i.name, i.unit
ORDER BY i.aisle, i.name;
```

**Note** : `:type`, `:debut` et `:fin` sont calculés par le Service à partir de la date du jour (voir SPEC §4 « Périodes »).

---

## Points de vigilance

- [ ] **PRAGMA foreign_keys = ON** à chaque connexion (sinon RESTRICT/CASCADE ignorés)
- [ ] Normaliser les noms de recettes (accents) avant comparaison avec `COLLATE NOCASE`
- [ ] Calculer les bornes de période côté serveur (lundi, 1er du mois, dernier jour du mois)
- [ ] Toujours calculer les coûts et listes, jamais les stocker
- [ ] **Transactions** pour modifications multi-tables : `beginTransaction()` → UPDATE/DELETE/INSERT → `commit()` (ou `rollBack()` si erreur)
  - Exemple : modifier recette = UPDATE recipes + DELETE/INSERT recipe_ingredients + DELETE/INSERT recipe_steps
  - Exemple : réinitialiser les cases d'une période = un seul `DELETE` (pas de transaction nécessaire)
- [ ] Vérifier les contraintes CHECK côté serveur avant INSERT/UPDATE
- [ ] Montants : stocker en centimes, afficher en euros (2 décimales)
