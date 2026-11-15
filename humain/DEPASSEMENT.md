# Pistes de dépassement — Student Cook

> Idées d'améliorations au-delà du MVP, à explorer après validation des 4 fonctionnalités.

---

## 1. Import de prix depuis Open Food Facts

### Description
Script hors ligne pour importer les prix moyens depuis la base Open Prices (ODbL).

### Intérêt
- Prix réalistes et à jour
- Réduction du travail manuel de seed
- Apprentissage : parsing de JSON, requêtes HTTP, normalisation

### Contraintes
- **Hors ligne uniquement** : télécharger le dump, parser localement
- **Licence ODbL** : citer la source dans le README
- **Pas d'API en temps réel** : mise à jour manuelle du seed

### Fichiers concernés
- `scripts/import-openfoodprices.php` (nouveau)
- `database/seed.sql` (généré automatiquement)

### Estimation
- Temps : 3-4h (découverte API, parsing, insertion)
- Complexité : moyenne

---

## 2. Export de la liste de courses en PDF

### Description
Générer un PDF téléchargeable depuis la liste de courses (bouton « Exporter PDF »).

### Intérêt
- Utilisabilité : imprimer ou envoyer la liste
- Apprentissage : génération de PDF en PHP (FPDF, TCPDF)

### Contraintes
- **Pas de lib externe si possible** : utiliser une lib légère (FPDF = 1 fichier)
- Mise en page simple : rayons, ingrédients, quantités, cases à cocher

### Fichiers concernés
- `backend/src/Services/PdfService.php` (nouveau)
- `backend/src/Controllers/ShoppingController.php` (route GET /shopping/export)
- `frontend/js/views/shopping.js` (bouton « Télécharger PDF »)

### Estimation
- Temps : 2-3h (découverte FPDF, mise en page)
- Complexité : faible-moyenne

---

## 3. Historique des semaines planifiées

### Description
Vue « Toutes mes semaines » avec liste chronologique et accès rapide.

### Intérêt
- Voir l'évolution des plannings
- Réutiliser une semaine passée (inspiration)

### Contraintes
- Pas de copier/coller de semaine (trop complexe pour le dépassement)
- Lecture seule (pas de modification des semaines passées)

### Fichiers concernés
- `frontend/js/views/history.js` (nouvel écran)
- `backend/src/Controllers/PlanningController.php` (route GET /planning/all)
- `backend/src/Repositories/PlanningRepository.php` (requête avec GROUP BY week)

### Estimation
- Temps : 2h (requête + affichage simple)
- Complexité : faible

---

## 4. Recherche et tri dans le référentiel d'ingrédients (amélioration F0)

### Description
Améliorer l'écran Ingrédients (lecture seule) et la liste déroulante du formulaire de recette avec :
- Recherche par nom
- Tri par rayon, prix, nom
- Pagination (si > 50 ingrédients)

### Intérêt
- Utilisabilité pour une base d'ingrédients large
- Apprentissage : pagination côté serveur, tri dynamique

### Contraintes
- **Toujours en lecture seule** : aucune création/modification/suppression d'ingrédient (hors périmètre)
- Respecter l'architecture (Service pour le tri, Repository pour les requêtes)
- Pas de lib JS externe (vanilla JS)

### Fichiers concernés
- `frontend/js/views/ingredients.js` (filtres et tri)
- `backend/src/Repositories/IngredientRepository.php` (WHERE + ORDER BY + LIMIT/OFFSET)

### Estimation
- Temps : 3h (requêtes dynamiques, UX)
- Complexité : moyenne

---

## 5. Gestion de plusieurs semaines (amélioration F3)

### Description
Fonctionnalités avancées de planning :
- **Drag & drop** d'une recette vers un créneau (V2 — décision D4 : menu déroulant dans le MVP)
- Copier/coller une semaine complète
- Dupliquer un repas (lundi → mardi)

> Les vues jour et mois font désormais partie du MVP (SPEC v2.1, F3).

### Intérêt
- Gain de temps pour l'utilisateur
- Apprentissage : manipulation de données structurées, transactions complexes

### Contraintes
- Respecter les contraintes UNIQUE (pas de doublon sur un créneau)
- Transaction pour copier une semaine (atomicité)

### Fichiers concernés
- `backend/src/Services/PlanningService.php` (logique de copie)
- `backend/src/Repositories/PlanningRepository.php` (INSERT multiples)
- `frontend/js/views/planning.js` (boutons « Copier semaine », « Coller »)

### Estimation
- Temps : 4-5h (logique complexe, tests)
- Complexité : élevée

---

## 6. Mode hors ligne (Progressive Web App)

### Description
Transformer l'application en PWA pour utilisation sans connexion.

### Intérêt
- Utilisabilité : accès même sans réseau
- Apprentissage : Service Workers, Cache API, manifest.json

### Contraintes
- SQLite en fichier = déjà « local », mais besoin de cache pour les assets
- Pas de synchronisation (monoposte)

### Fichiers concernés
- `frontend/manifest.json` (nouveau)
- `frontend/sw.js` (Service Worker, nouveau)
- `frontend/index.html` (lien vers manifest)

### Estimation
- Temps : 3-4h (découverte PWA, configuration)
- Complexité : moyenne

---

## 7. Tests automatisés (backend)

### Description
Ajouter des tests unitaires pour les Services et Repositories.

### Intérêt
- Qualité : non-régression
- Apprentissage : PHPUnit, tests de base de données

### Contraintes
- Pas de framework de tests lourd → PHPUnit minimal ou tests manuels en PHP
- Base de test séparée (`:memory:` SQLite)

### Fichiers concernés
- `tests/Services/RecipeServiceTest.php` (nouveau)
- `tests/Repositories/RecipeRepositoryTest.php` (nouveau)
- `phpunit.xml` (config, nouveau)

### Estimation
- Temps : 5-6h (setup PHPUnit, écriture tests)
- Complexité : moyenne-élevée

---

## 8. Calcul nutritionnel (protéines, calories)

### Description
Afficher les infos nutritionnelles par recette (calories, protéines, glucides, lipides).

### Intérêt
- Valeur ajoutée : santé en plus du budget
- Apprentissage : enrichissement du modèle de données

### Contraintes
- Données nutritionnelles par ingrédient (à ajouter manuellement ou importer)
- Calcul proportionnel aux quantités

### Fichiers concernés
- `database/schema.sql` (ajout colonnes nutrition dans `ingredients`)
- `backend/src/Services/RecipeService.php` (calcul total)
- `frontend/js/views/recipe-detail.js` (affichage)

### Estimation
- Temps : 4h (modèle + calcul + affichage)
- Complexité : moyenne

---

## 9. Mode multi-utilisateurs (authentification)

### Description
Transformer l'application monoposte en multi-utilisateurs avec comptes.

### Intérêt
- Partage de recettes entre utilisateurs
- Apprentissage : authentification, sessions, sécurité avancée

### Contraintes
- **Hors périmètre initial** : changement majeur d'architecture
- Besoin de sessions PHP, cookies, tokens
- Ajout de `user_id` dans toutes les tables

### Fichiers concernés
- `database/schema.sql` (table `users`, ajout `user_id` partout)
- `backend/src/Middleware/AuthMiddleware.php` (nouveau)
- `backend/src/Controllers/AuthController.php` (nouveau)
- Front : écran de connexion / inscription

### Estimation
- Temps : 10-12h (changement majeur)
- Complexité : élevée

**⚠️ Recommandation** : À éviter si le MVP n'est pas terminé (trop de changements).

---

## Critères de priorisation

Pour choisir une piste de dépassement :

1. **Intérêt pédagogique** : qu'est-ce qu'on apprend ?
2. **Valeur ajoutée** : améliore-t-il vraiment l'expérience utilisateur ?
3. **Temps disponible** : peut-on le faire en X heures ?
4. **Complexité** : risque de casser le MVP ?

**Ordre recommandé** :
1. Export PDF (facile, utile)
2. Historique des semaines (facile, UX)
3. Import Open Prices (apprentissage, gain de temps)
4. Interface ingrédients améliorée (UX, apprentissage)
5. PWA (apprentissage moderne, utile)
6. Calcul nutritionnel (valeur ajoutée)
7. Tests automatisés (qualité, mais chronophage)
8. Gestion avancée du planning (complexe)
9. Multi-utilisateurs (changement majeur, à éviter)

---

## Checklist avant de démarrer un dépassement

- [ ] Le MVP (F0 à F4) est **100% terminé et testé**
- [ ] Tous les cas de `TESTS.md` passent
- [ ] Le `JOURNAL_PROMPTS.md` est à jour
- [ ] La branche `main` est stable (pas de bugs connus)
- [ ] La piste de dépassement est documentée dans ce fichier
- [ ] On a estimé le temps nécessaire et on l'a disponible

**⚠️ Ne jamais sacrifier le MVP pour un dépassement.**
