# Spécification fonctionnelle — Student Cook

> Version 2.1 — 15 novembre 2026
> Changements v2.1 : ingrédients en référentiel fixe (plus de création), filtre halal, planning en vues jour/semaine/mois, liste de courses par jour/semaine/mois courant.
> Auteurs : [vos noms]

## 1. Vision générale

**Objectif** : Aider un étudiant à planifier ses repas à petit prix.

**Utilisateur** : Un seul utilisateur local, sans compte (pas d'authentification).

**Cas d'usage principal** :
1. Je consulte des recettes économiques adaptées à mes contraintes (régime, budget, temps)
2. Je planifie mes repas (midi et soir) et je les consulte par jour, par semaine ou par mois
3. Je génère automatiquement ma liste de courses du jour, de la semaine ou du mois, organisée par rayon

## 2. Fonctionnalités du MVP

### F0 — Référentiel d'ingrédients (lecture seule)

**En tant qu'** utilisateur
**je veux** consulter la liste des ingrédients disponibles
**afin de** les sélectionner dans mes recettes

Les ingrédients forment un **référentiel fixe** fourni par `database/seed.sql`. L'utilisateur ne crée, ne modifie et ne supprime **aucun** ingrédient : il les **sélectionne dans une liste** lorsqu'il compose une recette.

**Écran** : Liste des ingrédients (consultation) avec :
- Nom
- Rayon (Fruits & Légumes, Épicerie, Frais, Surgelés, Viandes & Poissons, Autres)
- Prix au kilo/litre (en centimes)
- Unité (kg, L, unité)

**Actions** :
- Consulter la liste
- Sélectionner un ingrédient dans le formulaire de recette (liste déroulante, voir F1)

**Critères d'acceptation** :
- [ ] La liste affiche tous les ingrédients triés par rayon puis par nom
- [ ] Les prix sont affichés en euros avec 2 décimales
- [ ] Aucune action de création, modification ou suppression n'est proposée (ni à l'écran, ni dans l'API)

**Hors périmètre** : Création, modification ou suppression d'ingrédient (depuis n'importe quel écran).

---

### F1 — Catalogue de recettes (CRUD)

**En tant qu'** utilisateur
**je veux** gérer un catalogue de recettes
**afin de** choisir mes plats de la semaine

**Écran principal** : Liste des recettes avec :
- Nom de la recette
- Temps de préparation (en minutes)
- Nombre de portions
- Coût par portion (calculé automatiquement)
- Drapeaux régime : végétarien, végan, sans gluten, halal

**Écran détail** :
- Tous les champs ci-dessus
- Liste des ingrédients avec quantités
- Étapes de préparation (texte libre, **sans quantités** : elles restent dans la liste d'ingrédients — D7)

**Actions** :
- Créer une recette complète (nom, temps, portions, régimes, ingrédients, étapes)
  - Chaque ingrédient est **choisi dans la liste du référentiel (F0)** puis on saisit sa quantité
- Modifier une recette (remplacement complet des ingrédients et étapes)
- Supprimer une recette (uniquement si elle n'est pas dans le planning)
- Voir le détail d'une recette

**Critères d'acceptation** :
- [ ] La liste affiche toutes les recettes avec leurs infos principales
- [ ] Le coût par portion est calculé à partir des ingrédients et prix unitaires
- [ ] Je peux créer une recette avec au moins 1 ingrédient et 1 étape
- [ ] Les ingrédients se choisissent uniquement dans une liste ; un identifiant d'ingrédient inconnu envoyé à l'API est refusé (422)
- [ ] Un même ingrédient ne peut pas être ajouté deux fois dans une recette (422)
- [ ] Je peux modifier tous les champs d'une recette existante
- [ ] La suppression d'une recette planifiée affiche un message d'erreur
- [ ] Les drapeaux régime sont clairement visibles (icônes ou badges)

---

### F2 — Filtres et suggestions

**En tant qu'** utilisateur
**je veux** filtrer les recettes selon mes contraintes
**afin de** trouver rapidement un plat adapté

**Filtres disponibles** :
- Régime alimentaire : végétarien, végan, sans gluten, halal (choix multiples)
- Budget maximum par portion (curseur ou saisie)
- Temps de préparation maximum (curseur ou saisie)

**Logique de suggestion** : règle déterministe simple
- Afficher les recettes qui respectent **tous** les filtres actifs
- Trier par coût croissant par défaut

**Critères d'acceptation** :
- [ ] Les filtres s'appliquent en temps réel (ou au clic sur « Filtrer »)
- [ ] Une recette n'apparaît que si elle respecte tous les critères
- [ ] Le nombre de résultats est affiché
- [ ] Je peux réinitialiser les filtres
- [ ] Chaque filtre écarte au moins une recette (validé dans les données de départ)

**Hors périmètre** : Algorithme de recommandation intelligent, historique des préférences.

---

### F3 — Planning (vues jour, semaine, mois)

**En tant qu'** utilisateur
**je veux** planifier mes repas et les consulter par jour, par semaine ou par mois
**afin de** m'organiser et préparer ma liste de courses

Chaque repas planifié est rattaché à une **date** (AAAA-MM-JJ) et à un **créneau** (midi, soir). Les trois vues sont trois façons d'afficher les mêmes données.

**Vues** (sélecteur « Jour | Semaine | Mois ») :
- **Jour** : 1 jour × 2 créneaux (midi, soir)
- **Semaine** : tableau 7 jours (lundi → dimanche) × 2 créneaux — **vue par défaut**
- **Mois** : calendrier du mois (semaines en lignes, lundi → dimanche en colonnes), chaque case affiche le midi et le soir du jour ; les jours hors du mois sont grisés

**Navigation** :
- Affichage par défaut : vue Semaine, semaine courante
- Boutons ◀ précédent / suivant ▶ : avancent d'un jour, d'une semaine ou d'un mois selon la vue
- Bouton « Aujourd'hui » : revient à la période courante
- Indicateur de la période affichée :
  - Jour : « Dimanche 15 novembre 2026 »
  - Semaine : « Semaine du 16 au 22 novembre »
  - Mois : « Novembre 2026 »

**Actions** (dans les trois vues) :
- Assigner une recette à un créneau via un **menu déroulant** (drag & drop prévu en V2)
- Retirer une recette d'un créneau
- Régler le nombre de portions du repas (− / +, minimum 1) ; par défaut, celui de la recette (D7)
- Voir le détail d'une recette depuis le planning

**Critères d'acceptation** :
- [ ] Le planning affiche la semaine courante au chargement
- [ ] Je peux basculer entre les vues Jour, Semaine et Mois
- [ ] Je peux naviguer avec les flèches dans chaque vue, et revenir à aujourd'hui
- [ ] Un repas planifié apparaît à la même date dans les trois vues
- [ ] Je peux assigner n'importe quelle recette à n'importe quel créneau
- [ ] Je peux retirer une recette d'un créneau
- [ ] Les modifications sont persistées en base
- [ ] Les créneaux vides sont clairement identifiables
- [ ] Le nombre de portions d'un repas est modifiable, persisté, et refusé s'il n'est pas un entier ≥ 1 (422)

**Hors périmètre** : Drag & drop (V2), copier/coller de semaine ou de jour, historique des plannings, vue année.

---

### F4 — Liste de courses

**En tant qu'** utilisateur
**je veux** générer automatiquement ma liste de courses
**afin de** faire mes achats en une seule fois

**Génération** :
- Basée sur le planning d'une **période courante** au choix (sélecteur « Aujourd'hui | Cette semaine | Ce mois ») :
  - **Jour courant** : repas planifiés aujourd'hui
  - **Semaine courante** : du lundi au dimanche de la semaine en cours — **choix par défaut**
  - **Mois courant** : du 1er au dernier jour du mois en cours
- Agrégation des quantités par ingrédient
- Quantités ajustées aux portions de chaque repas (voir § 4 « Portions par repas », D7)
- Organisation par rayon
- Calcul du coût total

**Affichage** :
- Période affichée (ex : « Courses du 16 au 22 novembre »)
- Rayon (titre de section)
- Liste des ingrédients avec quantité totale et coût
- Case à cocher pour chaque ingrédient
- Total général en bas de page

**Actions** :
- Générer la liste (bouton depuis le planning)
- Choisir la période : jour, semaine ou mois courant
- Cocher/décocher un ingrédient (persisté, **par période** : cocher dans la liste du mois ne coche pas la liste de la semaine)
- Réinitialiser toutes les cases de la période affichée

**Critères d'acceptation** :
- [ ] La liste agrège correctement les quantités (ex : 2× 200g tomates = 400g)
- [ ] Une recette pour 2 planifiée pour 1 portion compte ses quantités divisées par 2
- [ ] Je peux générer la liste du jour, de la semaine et du mois courants
- [ ] Seuls les repas dont la date est dans la période choisie sont comptés (bornes incluses)
- [ ] Les ingrédients sont groupés par rayon
- [ ] Le coût total est affiché en euros
- [ ] L'état des cases est persisté, séparément pour chaque période
- [ ] Si aucun repas n'est planifié sur la période, afficher un message explicatif

**Hors périmètre** : Liste de courses d'une période passée ou future (seule la période courante est proposée), période personnalisée, conversion d'unités, export PDF, partage.

---

## 3. Hors périmètre (interdit dans le MVP)

- Photo du frigo / reconnaissance d'ingrédients
- Calcul nutritionnel (calories, macros)
- Conversion d'unités automatique (on garde l'unité d'origine)
- Intégration Too Good To Go ou autres API externes
- Comptes utilisateurs / authentification
- Prix en temps réel (on utilise des prix fixes en base)
- Déploiement en ligne (application locale uniquement)
- Création, modification ou suppression d'ingrédients (référentiel fixe)
- Certification halal ou détection automatique du caractère halal (simple drapeau déclaratif)

---

## 4. Règles métier

### Calcul du coût d'une recette
```
Quantités entières (0 décimale) : grammes si unité = kg, millilitres si L, nombre de pièces si « unité »
Coût d'une ligne (centimes) = quantité × prix / 1000   si unité = kg ou L
                            = quantité × prix          si unité = « unité »
Coût total (centimes) = Σ coût des lignes
Coût par portion (centimes) = Coût total / nombre_portions
Affichage (euros) = arrondi(Coût par portion / 100, 2 décimales)
```

### Portions par repas (D7)
```
Quantité d'un repas (exacte) = quantité recette × portions du repas / portions de la recette
Quantité affichée (par ingrédient) = arrondi SUPÉRIEUR( Σ quantités exactes des repas de la période )
Coût d'une ligne = calculé sur la Σ exacte (même formule que ci-dessus)
Coût total (centimes) = arrondi( Σ coûts des lignes ) — une seule fois, au résultat final
```
Exemple : recette pour 4 avec 200 g de pâtes, planifiée pour 1 → 50 g ; deux repas de 1 portion → 100 g.

Les portions d'un repas n'affectent **que** la liste de courses : la recette, sa fiche détail, ses étapes et son coût par portion restent inchangés.

### Jours, créneaux et périodes
- Jours : Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi, Dimanche (le jour de la semaine se déduit de la date)
- Créneaux : Midi, Soir
- Périodes (calculées côté serveur, bornes incluses) :
  - Jour : `[date, date]`
  - Semaine : `[lundi, dimanche]` de la semaine contenant la date
  - Mois : `[1er du mois, dernier jour du mois]` (une semaine à cheval sur deux mois est découpée)
- La date « courante » est celle du serveur (fuseau `Europe/Paris`)

### Régimes
- Drapeaux déclaratifs cochés dans le formulaire : végétarien, végan, sans gluten, halal
- Cohérence validée côté serveur : végan ⇒ végétarien

### Rayons
1. Fruits & Légumes
2. Épicerie
3. Frais
4. Surgelés
5. Viandes & Poissons
6. Autres

---

## 5. Contraintes techniques

- **Base SQLite** avec contraintes RESTRICT (empêcher suppression d'ingrédient/recette si utilisé)
- **PRAGMA foreign_keys = ON** à chaque connexion
- **Transactions** pour les modifications de recettes (ingrédients + étapes)
- **Montants en centimes** en base (INTEGER), conversion en euros pour l'affichage
- **Validation côté serveur** : tous les formulaires doivent être validés par l'API
- **Format d'erreur** : `{"erreurs": {"champ": "message"}}`

---

## 6. Données de départ

Fichier `database/seed.sql` avec :
- ~35 ingrédients (couvrant tous les rayons) — c'est le référentiel définitif, aucun ajout depuis l'interface
- ~25 recettes variées :
  - Au moins 1 végétarienne, 1 végane, 1 sans gluten, 1 halal
  - Au moins 1 recette **non** halal (ex : lardons, vin) pour que le filtre écarte quelque chose
  - Au moins 1 recette écartée par chaque filtre (budget, temps, régime)
  - Prix réalistes pour un étudiant (1€ à 5€ par portion)
  - Étapes rédigées sans quantités (« Cuire les pâtes », pas « Cuire 200 g de pâtes ») — D7
  - Recettes imposées par `TESTS.md` (CN4, CL2, CP1) : « Pâtes au pesto » (200g de pâtes) et « Salade de pâtes » (150g de pâtes)
  - **Pas** de « Pâtes carbonara » (créée par le test CN1, le nom doit être libre)

---

## 7. Critères de succès du projet

- [ ] Toutes les fonctionnalités F0 à F4 sont implémentées
- [ ] Tous les cas de test de `TESTS.md` passent
- [ ] L'architecture en couches est respectée (3 règles d'or)
- [ ] Aucune dépendance externe (Composer, npm)
- [ ] Démarrage en une commande : `docker compose up --build`
- [ ] Code versionné, commits propres, journal de prompts complet

---

## 8. Décisions en suspens

Toutes tranchées le 15/11/2026, détail dans `docs/DECISIONS.md` :

- [x] Interface du planning : **menu déroulant** (drag & drop reporté en V2) — D4
- [x] Décimales des quantités : **0** (entiers : g, mL ou nombre d'unités) — D5
- [x] Suppression d'une recette planifiée : **bloquée (409)** — D6
