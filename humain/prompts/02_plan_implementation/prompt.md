# Prompt : Plan d'implémentation

## Contexte
Projet Student Cook : PHP 8.3 natif + SQLite, architecture en couches.
Fonctionnalité : [NOM_FONCTIONNALITE]
Issue : [LIEN_ISSUE ou résumé des critères d'acceptation]

## Objectif
Proposer un plan d'implémentation couche par couche **sans écrire de code**.

## Consigne
Analyse la fonctionnalité et propose un plan structuré avec :

1. **Fichiers à créer** (liste exhaustive)
2. **Fichiers à modifier** (liste exhaustive avec raison)
3. **Ordre d'implémentation** (étapes séquentielles)
4. **Points de vigilance** (pièges, contraintes SQLite, transactions, validation)

**Les 3 règles d'or à respecter** :
- Controller : ni SQL ni calcul métier
- Service : ni SQL, ni `$_GET`, ni `echo`
- Repository : seul endroit avec du SQL

## Format de sortie attendu
```markdown
## Plan d'implémentation : [NOM_FONCTIONNALITE]

### 1. Fichiers à créer
- `backend/src/Repositories/[Nom]Repository.php`
- `backend/src/Services/[Nom]Service.php`
- `backend/src/Controllers/[Nom]Controller.php`
- `frontend/js/views/[nom].js`

### 2. Fichiers à modifier
- `backend/public/index.php` → ajouter routes
- `frontend/js/router.js` → ajouter route front
- `frontend/index.html` → ajouter lien menu (si nécessaire)

### 3. Ordre d'implémentation
1. **Repository** : requêtes SQL (CREATE, READ, UPDATE, DELETE)
2. **Service** : règles métier pures
3. **Controller** : validation + réponses JSON
4. **Front** : affichage + appels API

### 4. Points de vigilance
- [ ] `PRAGMA foreign_keys = ON` dans Database.php
- [ ] Transaction si modification multi-tables
- [ ] Validation côté serveur (tous les champs requis)
- [ ] Format erreur : `{"erreurs": {"champ": "message"}}`
- [ ] Codes HTTP : 200/201/404/409/422
```

## Exemple (partiel)
Pour « Créer une recette » :

**Fichiers à créer** :
- `RecipeRepository.php` → INSERT recette, ingrédients, étapes
- `RecipeService.php` → validation métier (au moins 1 ingrédient, 1 étape)
- `RecipeController.php` → validation formulaire, appel Service

**Points de vigilance** :
- Transaction pour INSERT dans 3 tables (recipes, recipe_ingredients, recipe_steps)
- Vérifier que tous les ingredient_id existent avant insertion
- UNIQUE sur recipes.name → erreur 409 si doublon

## Contre-exemple
❌ Ne code pas encore (pas de `function create()` dans le plan)
❌ Ne propose pas plusieurs approches (plan = 1 seule solution validée)

## Attends ma validation avant de coder
