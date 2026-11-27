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
│   ├── bootstrap.php   # amorçage commun : autoload, fuseau, réglages d'erreurs
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
├── .github/            # PULL_REQUEST_TEMPLATE.md
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

Toutes héritent de `AppException`, qui porte ses erreurs au format de l'API (`['champ' => 'message']`).

```php
<?php
namespace StudentCook\Domain\Exceptions;

abstract class AppException extends \Exception { /* getErrors(): array<string, string> */ }
class ValidationException extends AppException {}          // 422
class RecipeNotFoundException extends AppException { … }   // 404, champ « recette »
class RecipeIsPlannedException extends AppException { … }  // 409, message de D6
```

**Usage** :
- Validation, Service ou Repository **lancent** l'exception ; **aucun Controller n'écrit de `try/catch`**.
- Le `catch (AppException)` de `public/index.php` la traduit une seule fois, via `ErrorController::appError()`.
- Le code HTTP de chaque exception est défini à un seul endroit : `ErrorController::STATUS_BY_EXCEPTION`. Une nouvelle exception métier = une classe + une ligne dans cette table.

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

## Règles de code

### Principes
- **KISS** : la solution la plus simple et directe qui répond à la SPEC ; pas de construction « au cas où ».
- **DRY** : une règle, une valeur ou un message n'existe qu'à un seul endroit (ex. fuseau dans `backend/bootstrap.php`, codes HTTP dans `ErrorController`) ; sinon, une fonction ou un module partagé.
- **YAGNI** : n'ajoute rien sans besoin immédiat (fonction, option, paramètre, fichier). Le périmètre est celui de `docs/SPEC.md`.
- **Séparation des responsabilités** : voir « Architecture en couches » (SQL dans les Repositories, métier dans les Services, HTTP dans les Controllers, DOM dans les vues).

### Conventions et portée
- Respecte strictement l'architecture et les conventions **du code existant**. Si la documentation contredit le code sur une **convention de code**, suis le code et signale l'incohérence à la fin de ta réponse. Pour le **comportement fonctionnel**, `docs/SPEC.md` et `docs/DECISIONS.md` font foi : signale l'écart au lieu de le reproduire.
- Ne modifie que les fichiers liés à la demande. Pas de refactorisation globale sans accord préalable.

### Lisibilité et style
- **Nommage explicite**, une seule langue par couche (convention existante) : **anglais** en PHP et SQL, **français** en JS et CSS. Ne mélange jamais les deux dans un même fichier. Portée des variables limitée au strict nécessaire.
- **Formatage constant** : PSR-12 en PHP (4 espaces), même style en JS ; pas d'imbrication profonde (retour anticipé).
- **Commentaires utiles** : explique le *pourquoi* (choix, contrainte, piège, décision Dx), jamais une paraphrase du code. Pas de commentaire s'il n'apporte rien.

### Typage
- PHP : `declare(strict_types=1);` en tête de chaque fichier ; types sur **tous** les paramètres, retours et propriétés. `mixed` est interdit, sauf s'il est réellement inévitable (seul cas actuel : `AbstractController::json()`). Le contenu des tableaux est précisé en PHPDoc (`@param array<string, string> $errors`).
- JS (pas de TypeScript, pas de build) : comparaisons strictes (`===`), aucune conversion implicite, JSDoc sur les fonctions exportées.

### Fiabilité et sécurité
- Valide toute donnée reçue (Http/Validation) et traite explicitement les erreurs et les cas limites (vide, zéro, négatif, id inexistant, format invalide). Les erreurs métier passent par `AppException` (voir plus haut).
- Ne mets jamais de secret, de clé API ni d'identifiant en dur. S'il en faut un, lis-le avec `getenv()` et documente-le dans un `.env.example` (jamais de `.env` réel).
- Références : OWASP pour la sécurité web (XSS, injection SQL, traversée de chemin), recommandations de l'ANSSI.

### Vérification avant de conclure
Aucun linter ni test automatisé n'est installé (zéro dépendance). Le minimum avant de conclure :
1. `php -l` sur chaque fichier PHP modifié, `node --check` sur chaque fichier JS modifié.
2. Si `schema.sql` ou `seed.sql` change : les exécuter sur une base en mémoire et vérifier `PRAGMA foreign_key_check`. Ne lance jamais `init.php --reset` sur la base de l'utilisateur sans son accord.
3. Lancer le serveur et tester les routes touchées (`curl`).
4. Lister les cas de `docs/TESTS.md` à vérifier manuellement, et dire honnêtement ce qui n'a pas été testé.

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
- **~25 recettes, ~35 ingrédients** dans `database/seed.sql`.
- Chaque filtre (régime, budget, temps) doit écarter au moins une recette.
- Vérifier manuellement chaque drapeau et chaque prix avant de valider le seed.

## Dépassement possible (hors MVP)
- Un script d'import hors ligne depuis Open Food Facts / Open Prices (licence ODbL, source à citer).
- Recherche dans la liste déroulante d'ingrédients du formulaire de recette.