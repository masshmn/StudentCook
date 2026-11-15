# Checklist de revue critique — Student Cook

> À utiliser lors de la relecture des pull requests et avant la soutenance.

---

## 1. Architecture (Les 3 règles d'or)

- [ ] **Controller** : aucun SQL, aucun calcul métier (uniquement validation + appel Service)
- [ ] **Service** : aucun SQL, aucun `$_GET`, aucun `echo` (fonctions pures)
- [ ] **Repository** : seul endroit avec du SQL, toujours `prepare()` + `execute()`

---

## 2. Sécurité (OWASP Top 10)

### Injection SQL
- [ ] Tous les paramètres utilisent `prepare()` + `execute()` avec paramètres nommés
- [ ] Aucune concaténation de variables dans les requêtes SQL
- [ ] Aucun `query()` avec des données utilisateur

### XSS (Cross-Site Scripting)
- [ ] Front : `textContent` ou `createElement`, **jamais `innerHTML`** avec données utilisateur
- [ ] Pas de `eval()`, pas de `dangerouslySetInnerHTML` (si React)

### CSRF (hors périmètre mais à noter)
- [ ] Application locale monoposte : risque CSRF limité
- [ ] Si évolution multi-utilisateurs : ajouter des tokens CSRF

---

## 3. Base de données

### Connexion
- [ ] `PRAGMA foreign_keys = ON` à **chaque connexion** PDO
- [ ] Connexion unique via `Database::getConnection()` (singleton)

### Contraintes
- [ ] `UNIQUE` sur les noms (ingrédients, recettes)
- [ ] `CHECK` sur les énumérations (jours, créneaux, rayons, unités)
- [ ] `CHECK` sur les valeurs positives (prix, quantités, temps, portions)
- [ ] `FOREIGN KEY` avec `ON DELETE RESTRICT` ou `CASCADE` selon logique métier

### Transactions
- [ ] Modification de recette = transaction (ingrédients + étapes)
- [ ] Erreur → `rollBack()`, succès → `commit()`
- [ ] Pas de transaction pour les lectures seules

### Normalisation
- [ ] Noms d'ingrédients/recettes normalisés (accents, casse) avant comparaison
- [ ] `COLLATE NOCASE` ne suffit pas pour les accents (ex : « été » ≠ « ete »)

---

## 4. Calculs et montants

- [ ] Prix stockés en **centimes** (INTEGER, pas REAL)
- [ ] Calculs en centimes jusqu'au résultat final
- [ ] Arrondi **une seule fois** avant affichage (pas d'arrondi intermédiaire)
- [ ] Affichage en euros avec 2 décimales : `number_format($cents / 100, 2, ',', ' ')`
- [ ] Agrégation des quantités dans la liste de courses (SUM correct)

---

## 5. Validation

### Côté serveur (obligatoire)
- [ ] Tous les champs requis sont vérifiés
- [ ] Les types sont validés (entiers, texte, énumérations)
- [ ] Les limites sont vérifiées (min/max, longueur)
- [ ] Les relations sont vérifiées (ingrédient existe, recette existe)

### Côté client (confort)
- [ ] `required` sur les champs obligatoires
- [ ] `type="number"` avec `min` / `max` si applicable
- [ ] Messages d'erreur clairs et en français

---

## 6. Format des réponses API

- [ ] Succès : JSON avec `200` ou `201`
- [ ] Erreur validation : `{"erreurs": {"champ": "message"}}` avec `422`
- [ ] Ressource introuvable : `{"erreurs": {"general": "message"}}` avec `404`
- [ ] Conflit (doublon, RESTRICT) : `{"erreurs": {"general": "message"}}` avec `409`
- [ ] Tous les messages d'erreur en **français**

---

## 7. Front-end

### JavaScript
- [ ] `api.js` est le seul fichier avec `fetch`
- [ ] Un fichier par écran dans `views/`
- [ ] Gestion des erreurs réseau (`catch`)
- [ ] Affichage des erreurs validation (boucle sur `data.erreurs`)

### Accessibilité minimale
- [ ] Boutons avec texte explicite (pas juste des icônes sans label)
- [ ] Formulaires avec `<label>` associés aux `<input>`
- [ ] Messages d'erreur visibles (pas juste en console)

---

## 8. Respect de la spec

- [ ] Aucune fonctionnalité « Hors périmètre » n'est implémentée
- [ ] Toutes les fonctionnalités F0 à F4 sont présentes
- [ ] Les 10 cas de test de `TESTS.md` passent
- [ ] Les règles métier sont respectées (jours, créneaux, rayons, calcul coût)

---

## 9. Qualité du code

### Lisibilité
- [ ] Noms de variables explicites (pas de `$a`, `$tmp`, `$data`)
- [ ] Fonctions courtes (idéalement < 50 lignes)
- [ ] Pas de code commenté (supprimer au lieu de commenter)
- [ ] Commentaires uniquement si logique non-évidente

### DRY (Don't Repeat Yourself)
- [ ] Pas de copier-coller de requêtes SQL
- [ ] Logique métier mutualisée dans les Services
- [ ] Validation mutualisée dans `Validation/`

### YAGNI (You Aren't Gonna Need It)
- [ ] Pas de code « au cas où »
- [ ] Pas d'abstraction prématurée (pas d'interface pour 1 implémentation)
- [ ] Pas de paramètres inutilisés

---

## 10. Git et versioning

- [ ] Commits atomiques (1 commit = 1 changement logique)
- [ ] Messages de commit au format `type: description` (présent)
- [ ] Pas de `console.log` / `var_dump` oubliés
- [ ] Pas de fichiers générés (`.DS_Store`, `Thumbs.db`)
- [ ] `.gitignore` à jour

---

## 11. Tests manuels

- [ ] Tous les cas de `TESTS.md` passent sur base réinitialisée
- [ ] Tester sur navigateur propre (cache vidé)
- [ ] Vérifier les console errors (F12)
- [ ] Tester les cas limites (champs vides, très grandes valeurs)

---

## 12. Documentation

- [ ] `README.md` à jour (commandes de démarrage, prérequis)
- [ ] `DECISIONS.md` rempli (choix techniques + alternatives)
- [ ] `JOURNAL_PROMPTS.md` à jour si IA utilisée
- [ ] Commentaires dans le code uniquement si nécessaire

---

## Checklist pré-soutenance

- [ ] `docker compose up --build` démarre sans erreur
- [ ] Tous les écrans sont accessibles
- [ ] Aucune erreur en console navigateur
- [ ] Tous les cas de `TESTS.md` passent
- [ ] Le code est poussé sur le dépôt
- [ ] La démo est répétée au moins une fois

---

## Verdict

- [ ] ✅ Prêt pour merge / soutenance
- [ ] ⚠️ Corrections mineures nécessaires
- [ ] ❌ Blocage majeur (architecture, sécurité, spec)

**Commentaire** : [À remplir par le relecteur]
