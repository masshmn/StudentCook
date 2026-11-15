# Prompt : Comprendre un fichier

## Contexte
Projet Student Cook : PHP 8.3 natif + SQLite, architecture en couches.
Fichier à comprendre : [CHEMIN_FICHIER]

## Objectif
M'expliquer ce fichier ligne par ligne, avec les choix techniques.

## Consigne
Analyse le fichier et explique :

### 1. Vue d'ensemble
- Rôle du fichier dans le projet (Controller, Service, Repository, View)
- Responsabilités (ce qu'il fait, ce qu'il ne fait pas)
- Dépendances (fichiers ou classes utilisés)

### 2. Explication détaillée
Pour chaque fonction ou section importante :
- **Que fait-elle ?** (en une phrase simple)
- **Pourquoi c'est codé comme ça ?** (choix technique)
- **Pièges évités** (ex : transaction, validation, sécurité)

### 3. Points d'attention
- Règles d'architecture respectées (les 3 règles d'or)
- Sécurité (injection SQL, XSS)
- Contraintes SQLite (PRAGMA, transactions)

## Format de sortie attendu
```markdown
## Comprendre : [Nom du fichier]

### Vue d'ensemble
**Rôle** : [Controller / Service / Repository / View]
**Responsabilité** : [Ce que fait ce fichier]
**Dépendances** :
- [Fichier 1] → [Pourquoi]
- [Fichier 2] → [Pourquoi]

---

### Explication détaillée

#### Ligne X-Y : [Nom de la fonction/section]
```php
[Code concerné]
```

**Que fait-elle ?**
[Explication simple]

**Pourquoi c'est codé comme ça ?**
[Choix technique, contrainte]

**Pièges évités** :
- [Piège 1 et comment il est évité]
- [Piège 2 et comment il est évité]

---

### Points d'attention

#### ✅ Règles respectées
- [Règle 1] : [Exemple dans le code]
- [Règle 2] : [Exemple dans le code]

#### ⚠️ Points de vigilance
- [Point 1] : [Pourquoi c'est important]
- [Point 2] : [Pourquoi c'est important]

### Schéma de flux (si applicable)
```
[Diagramme texte du flux de données ou d'appels]
```
```

## Exemple
```markdown
## Comprendre : RecipeRepository.php

### Vue d'ensemble
**Rôle** : Repository (couche d'accès aux données)
**Responsabilité** : Gérer les requêtes SQL pour les recettes (CRUD)
**Dépendances** :
- `Database.php` → Obtenir la connexion PDO
- Aucune autre dépendance (règle 3 : Repository indépendant)

---

### Explication détaillée

#### Ligne 15-45 : `create(array $data): int`
```php
public function create(array $data): int {
    $this->pdo->beginTransaction();
    try {
        // 1. Insérer la recette
        $stmt = $this->pdo->prepare('
            INSERT INTO recipes (name, prep_time, servings, is_vegetarian, is_vegan, is_gluten_free)
            VALUES (:name, :prep_time, :servings, :is_vegetarian, :is_vegan, :is_gluten_free)
        ');
        $stmt->execute([...]);

        $recipeId = (int) $this->pdo->lastInsertId();

        // 2. Insérer les ingrédients
        foreach ($data['ingredients'] as $ingredient) { ... }

        // 3. Insérer les étapes
        foreach ($data['steps'] as $index => $step) { ... }

        $this->pdo->commit();
        return $recipeId;
    } catch (Exception $e) {
        $this->pdo->rollBack();
        throw $e;
    }
}
```

**Que fait-elle ?**
Insère une recette complète (recette + ingrédients + étapes) en une seule opération atomique.

**Pourquoi c'est codé comme ça ?**
- **Transaction** : 3 tables à modifier (recipes, recipe_ingredients, recipe_steps). Si l'une échoue, tout est annulé.
- **Paramètres nommés** : évite l'injection SQL.
- **Booléens → 0/1** : SQLite ne supporte pas les BOOLEAN natifs.

**Pièges évités** :
- ❌ Insertion partielle (recette sans ingrédients) → Transaction garantit l'atomicité
- ❌ Injection SQL (`$data['name']` directement) → `prepare()` + `execute()`
- ❌ Oubli du rollback → try/catch + rollBack()

---

### Points d'attention

#### ✅ Règles respectées
- **Règle 3** : Seul le Repository contient du SQL (aucun SQL dans Service ou Controller)
- **Sécurité** : Tous les paramètres passent par `prepare()` + `execute()`

#### ⚠️ Points de vigilance
- **PRAGMA foreign_keys** : Doit être ON dans Database.php, sinon les FOREIGN KEY ne fonctionnent pas
- **Ordre des INSERT** : Recette d'abord (pour obtenir l'ID), puis ingrédients et étapes

### Schéma de flux
```
Controller
   ↓
Service (validation métier)
   ↓
Repository.create()
   ↓
   BEGIN TRANSACTION
   ↓
   INSERT recipes → recipeId
   ↓
   INSERT recipe_ingredients (pour chaque ingrédient)
   ↓
   INSERT recipe_steps (pour chaque étape)
   ↓
   COMMIT
```
```

## Critères de qualité
- [ ] Explication accessible (pas de jargon inutile)
- [ ] Choix techniques justifiés (pourquoi X plutôt que Y)
- [ ] Pièges identifiés et expliqués
- [ ] Schéma de flux si le fichier est complexe

## Contre-exemple
❌ Ne résume pas en une phrase (« Ce fichier gère les recettes »)
❌ Ne copie pas le code sans explication (je l'ai déjà lu)
