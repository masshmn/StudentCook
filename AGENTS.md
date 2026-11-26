# AGENTS.md — Student Cook

Application web (un seul utilisateur, sans compte) : catalogue de recettes économiques, planning (vues jour/semaine/mois), liste de courses par rayon.
Référence fonctionnelle : `docs/SPEC.md`. N'implémente rien qui n'y figure pas ; la section « Hors périmètre » est interdite.

## Projet

**Objectif** : Aider un étudiant à planifier ses repas à petit prix.

**Version minimale (4 fonctionnalités) :**
0. Référentiel d'ingrédients en lecture seule (sélectionnés dans une liste, jamais créés)
1. Catalogue de recettes (CRUD complet)
2. Filtres et suggestions (régime : végétarien, végan, sans gluten, halal ; budget par portion ; temps) — règle déterministe
3. Planning daté (midi/soir) avec vues jour, semaine et mois
4. Liste de courses du jour, de la semaine ou du mois courant (quantités agrégées, par rayon, coût, cases à cocher)

**Hors périmètre** : photo du frigo, Too Good To Go, comptes utilisateurs, prix en temps réel, nutrition, déploiement en ligne, conversion d'unités, création/modification/suppression d'ingrédients.

## Stack
- **Back** : PHP 8.3 natif (aucun framework, aucune dépendance Composer)
- **Front** : HTML / CSS / JS natif, servi par PHP (pas de compilation, pas de CORS)
- **Base** : SQLite via PDO, fichier dans un volume Docker
- **Lancement** : Docker (`docker compose up --build`)
- **Données** : `database/seed.sql` écrit manuellement, contrôlé et vérifié
- **Pas d'API externe** dans l'application (réseau, panne en démo, résultats invérifiables)
- **API interne obligatoire** : routes PHP qui répondent en JSON au front

## Choix techniques et alternatives écartées

### Backend : PHP 8.3 natif
**Pourquoi** : Zéro dépendance, tout est explicable ligne par ligne, pas de compilation.
**Alternatives refusées** : FastAPI (Python), Laravel, Symfony → dépendances lourdes, complexité inutile.

### Frontend : JS natif
**Pourquoi** : Pas de build, manipulation DOM simple suffit pour 4 écrans.
**Alternatives refusées** : React, Vue, Alpine.js → build + dépendances npm.

### Base de données : SQLite
**Pourquoi** : Fichier local, zéro config, contraintes natives (FOREIGN KEY, CHECK, transactions).
**Alternatives refusées** : PostgreSQL, MySQL (besoin de serveur), JSON en fichier (pas de contraintes).

### Architecture : Hybrid (MVC en couches)
**Pourquoi** : Structure claire par responsabilité (Http/, Domain/, Infrastructure/), Services purs (testables), séparation stricte.
**Organisation** : Http/ (Controllers, Validation), Domain/ (Services, Repositories, Exceptions), Infrastructure/ (Database).
**Alternatives refusées** :
- MVC pur → fat controllers
- Hexagonale complète → trop de fichiers
- Microservices → complexité énorme pour un utilisateur local

### Décisions fonctionnelles
- **Ingrédients** : Référentiel fixe fourni par le seed, écran de consultation (F0) ; le formulaire de recette les propose dans une liste déroulante. Aucune route d'écriture.
- **Liste de courses** : Calculée à la volée depuis le planning sur la période courante (jour, semaine ou mois), pas stockée ; seules les cases à cocher sont persistées, par période.
- **Montants** : En centimes (INTEGER), conversion en euros uniquement pour l'affichage.
- **Planning** : Une date par repas (table `meal_planning`) ; vues jour/semaine/mois avec navigation ◀ ▶ et « Aujourd'hui ». Pas de copier/coller (hors périmètre).
- **Halal** : Drapeau déclaratif sur la recette, comme les autres régimes.

**⚠️ NE PROPOSE JAMAIS** : Export PDF, import Open Prices, PWA, multi-utilisateurs, calcul nutritionnel (voir `humain/DEPASSEMENT.md` pour la liste complète, mais **interdit de les implémenter**).

## Design system
- Charte V1 « Cahier » : **lire `docs/DESIGN_SYSTEM.md`** avant de toucher au CSS ou de créer un composant d'interface.
- Utiliser les variables de `frontend/css/tokens.css` : **ne jamais coder une couleur en dur**.

## Structure du monorepo
```
student-cook/
├── frontend/           # index.html · css/ · js/
│   └── js/             # app.js · router.js · api.js · dom.js · views/
├── backend/
│   ├── public/         # index.php (point d'entrée)
│   └── src/
│       ├── Http/
│       │   ├── AbstractController.php
│       │   ├── Controllers/
│       │   └── Validation/
│       ├── Domain/
│       │   ├── AbstractRepository.php
│       │   ├── Exceptions/
│       │   ├── Services/
│       │   └── Repositories/
│       └── Infrastructure/
│           └── Database.php
├── database/           # schema.sql · seed.sql · init.php
├── docs/               # SPEC.md · MODELE_DONNEES.md · TESTS.md · DECISIONS.md · DESIGN_SYSTEM.md
├── humain/             # DEPASSEMENT.md · JOURNAL_PROMPTS.md (docs pour humains)
├── .github/            # PULL_REQUEST_TEMPLATE.md · ISSUE_TEMPLATE.md
└── AGENTS.md · CLAUDE.md · README.md · Dockerfile · docker-compose.yml
```

## Commandes
- Lancer : `docker compose up --build` → http://localhost:8000
- Sans Docker : `php database/init.php && php -S localhost:8000 -t backend/public backend/public/index.php`
- Réinitialiser la base : `php database/init.php --reset`
- Vérifier la syntaxe : `php -l <fichier>`

## Architecture en couches (Hybrid)

**Métaphore** : le serveur (Controller) prend la commande, le chef (Service) cuisine, le magasinier (Repository) seul a la clé de la réserve (base).

```
Vue (JS natif) → Routeur → Controller ↔ Validation
                              ↓
                           Service (règles métier pures)
                              ↓
                           Repository (seul endroit avec du SQL) → SQLite
```

**Les 3 règles d'or :**
1. Un Controller ne contient ni SQL ni calcul métier.
2. Un Service ne contient ni SQL, ni `$_GET`, ni `echo`.
3. Seuls les Repositories touchent à la base, avec `prepare()` + `execute()`.

**Quand créer un Service ?**
- Calculs (coût par portion, total courses)
- Agrégations (grouper ingrédients par rayon)
- Règles métier (vérifier si recette est planifiée)
- Orchestration multi-Repository

**Si une opération est triviale (simple CRUD), le Controller peut appeler directement le Repository.**

**Organisation des fichiers** :
- `Http/` : Controllers (valident via Validation/, appellent Services ou Repositories, répondent en JSON). Ni SQL ni calcul métier.
- `Domain/` : Services (règles métier pures), Repositories (seul endroit avec du SQL), Exceptions métier.
- `Infrastructure/` : Database.php (connexion PDO unique).
- Front : `frontend/js/api.js` est le seul fichier qui appelle `fetch` ; un fichier par écran dans `frontend/js/views/`.
- Factorisation : AbstractController (réponses JSON), AbstractRepository (connexion PDO). Pas d'injection de dépendances (simplicité volontaire).

## Optimisations et factorisation

### AbstractController (`Http/AbstractController.php`)

Classe mère pour factoriser les réponses JSON et éviter la duplication.

```php
<?php
namespace StudentCook\Http;

abstract class AbstractController {
    protected function json(mixed $data, int $status = 200): void {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE);
    }

    protected function jsonError(array $errors, int $status = 422): void {
        $this->json(['erreurs' => $errors], $status);
    }
}
```

**Usage** : tous les Controllers étendent `AbstractController` et utilisent `$this->json()` et `$this->jsonError()`.

---

### AbstractRepository (`Domain/AbstractRepository.php`)

Classe mère pour factoriser la connexion PDO.

```php
<?php
namespace StudentCook\Domain;

use StudentCook\Infrastructure\Database;
use PDO;

abstract class AbstractRepository {
    protected PDO $pdo;

    public function __construct() {
        $this->pdo = Database::getConnection();
    }
}
```

**Usage** : tous les Repositories étendent `AbstractRepository` et utilisent `$this->pdo`.

---

### Exceptions métier (`Domain/Exceptions/`)

Pour gérer les erreurs métier avec les bons codes HTTP.

```php
<?php
namespace StudentCook\Domain\Exceptions;

class RecipeNotFoundException extends \Exception {}
class RecipeIsPlannedException extends \Exception {}
```

**Usage** :
- Repository lance `throw new RecipeNotFoundException()` si `findById()` ne trouve rien
- Controller attrape avec `try/catch` et retourne `$this->jsonError(['recette' => 'Recette introuvable.'], 404)`
- Service lance `RecipeIsPlannedException` si on tente de supprimer une recette planifiée
- Controller attrape et retourne code 409

---

### Conventions de nommage (Repositories)

| Opération | Nom de méthode | Retour |
|-----------|----------------|--------|
| Lister toutes les lignes | `findAll()` | `array` |
| Trouver par ID | `findById(int $id)` | `array` ou `null` |
| Créer | `create(array $data)` | `int` (lastInsertId) |
| Mettre à jour | `update(int $id, array $data)` | `bool` |
| Supprimer | `delete(int $id)` | `bool` |

**Règle** : toujours `prepare()` + `execute()` avec des paramètres nommés (`:id`, `:name`, etc.).

## Règles strictes

### Base de données (SQLite)
- **CRITIQUE** : `PRAGMA foreign_keys = ON` à **chaque connexion** PDO (sinon RESTRICT et CASCADE ne s'appliquent pas).
- `COLLATE NOCASE` ne gère pas les accents : normaliser les noms côté serveur.
- Ajouter des `CHECK` en base (jour, créneau, booléens, portions, quantités positives).
- Modifier une recette = remplacer ingrédients et étapes **dans une transaction**.
- La liste de courses est **calculée** à partir du planning, jamais stockée.

### Format des réponses
- Erreurs API au format `{"erreurs": {"champ": "message"}}` :
  - 422 : validation échouée
  - 404 : ressource introuvable
  - 409 : doublon ou suppression refusée (RESTRICT)
- Montants en **centimes entiers**, arrondis **une seule fois**, au résultat final.

### Sécurité
- Front : `textContent` uniquement, **jamais `innerHTML`** avec une donnée saisie (XSS).
- Back : toujours `prepare()` + `execute()` avec des paramètres nommés (injection SQL).

### Autres
- Textes d'interface et messages d'erreur en **français**.
- N'ajoute **aucune dépendance** ni aucun framework, et ne crée jamais de `.env` réel.
- Commits : `feat|fix|docs|test|refactor|chore: description au présent`.

## Pièges connus
<!-- Ajouter une ligne dès que l'agent fait deux fois la même erreur. -->
- SQLite : sans `PRAGMA foreign_keys = ON`, les contraintes RESTRICT/CASCADE sont ignorées silencieusement.
- SQLite : `COLLATE NOCASE` ne gère pas les accents, il faut normaliser les chaînes avant comparaison.
- Transactions : ne pas oublier `beginTransaction()` / `commit()` / `rollBack()` pour les modifications complexes.
- Montants : toujours stocker en centimes (INTEGER), calculer en centimes, arrondir au tout dernier moment.
- Front : ne jamais utiliser `innerHTML` avec des données utilisateur, toujours `textContent` ou `createElement`.

## Données de départ
- **~12 recettes, ~35 ingrédients** dans `database/seed.sql`.
- Chaque filtre (régime, budget, temps) doit écarter au moins une recette.
- Vérifier manuellement chaque drapeau et chaque prix avant de valider le seed.

## Dépassement possible (hors MVP)
- Un script d'import hors ligne depuis Open Food Facts / Open Prices (licence ODbL, source à citer).
- Recherche dans la liste déroulante d'ingrédients du formulaire de recette.