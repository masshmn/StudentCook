# StudentCook

Application web locale pour étudiant·e : catalogue de recettes économiques, filtres (régime, budget, temps), planning des repas (jour / semaine / mois) et liste de courses par rayon.

Un seul utilisateur, sans compte, sans connexion internet requise.

## Lancer l'application

Prérequis : Docker.

```bash
docker compose up --build
```

Puis ouvrir http://localhost:8000.

- Au démarrage, `database/init.php` initialise la base. **S'il échoue, le conteneur s'arrête** (voir les logs : `docker compose logs app`).
- Une base créée avec un ancien schéma est refusée (version dans `PRAGMA user_version`) : la recréer avec `docker compose run --rm app php database/init.php --reset`.
- Le code (`backend/`, `frontend/`, `database/`) est monté dans le conteneur : une modification est visible au rechargement de la page, sans rebuild.
- La base SQLite est stockée dans le volume Docker `db-data` (`database/data/student_cook.db`), jamais dans le dépôt.

| Action | Commande |
|--------|----------|
| Arrêter | `docker compose down` |
| Réinitialiser la base | `docker compose exec app php database/init.php --reset` |
| Supprimer la base (volume) | `docker compose down -v` |
| Vérifier la syntaxe d'un fichier | `docker compose exec app php -l <fichier>` |

Sans Docker (PHP 8.3 avec `pdo_sqlite`) :

```bash
php database/init.php
php -S localhost:8000 -t backend/public backend/public/index.php
```

## Stack

- **Back** : PHP 8.3 natif, aucun framework, aucune dépendance Composer
- **Front** : HTML / CSS / JS natif, servi par PHP (pas de build)
- **Base** : SQLite via PDO

## Architecture

```
backend/public/index.php   point d'entrée : sert frontend/ ou route /api/... vers un Controller
backend/src/Http/          Controllers (réponses JSON) et Validation
backend/src/Domain/        Services (règles métier), Repositories (seul endroit avec du SQL), Exceptions
backend/src/Infrastructure Database.php (connexion PDO unique)
frontend/                  index.html, css/, js/ (api.js est le seul fichier qui appelle fetch)
database/                  schema.sql, seed.sql, init.php
docs/                      SPEC, modèle de données, cas de test
```

Autoload PSR-4 maison : `StudentCook\` → `backend/src/`. Fuseau horaire : `Europe/Paris`.

## Conventions de l'API

- Code (classes, méthodes, variables, routes) **en anglais** ; textes affichés et messages d'erreur **en français**.
- Routes au pluriel : `/api/recipes`, `/api/recipes/{id}`, `/api/ingredients`…
- `{id}` n'accepte qu'un entier strictement positif.
- Pour `POST` / `PUT` / `PATCH`, le corps doit être un **objet JSON**, validé côté serveur.
- Montants en **centimes** (entiers).

Ajouter une route : une ligne dans `API_ROUTES` (`backend/public/index.php`) :

```php
['GET', '/api/recipes/{id}', RecipeController::class, 'show'],
```

Le Controller reçoit les `{id}` en `int`, puis le corps JSON (tableau) en dernier argument pour `POST` / `PUT` / `PATCH`.

### Format des erreurs

```json
{"erreurs": {"champ": "message"}}
```

| Code | Cas |
|------|-----|
| 404 | Route ou ressource introuvable (y compris mauvaise méthode HTTP) |
| 409 | Doublon ou suppression refusée (recette planifiée) |
| 422 | Validation échouée ou corps JSON invalide |
| 500 | Erreur imprévue (message générique, détail uniquement dans les logs serveur) |

## Documentation

- `docs/SPEC.md` : fonctionnalités et critères d'acceptation
- `docs/MODELE_DONNEES.md` : schéma SQL
- `docs/TESTS.md` : cas de test manuels
- `AGENTS.md` : règles pour les agents IA
