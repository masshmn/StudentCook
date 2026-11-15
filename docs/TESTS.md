# Cas de test — Student Cook

> 10 cas à vérifier manuellement avant la soutenance : 6 normaux, 3 limites, 1 piège.
> **Ces cas sont figés avant de coder. Toute modification doit être justifiée et versionnée.**
>
> **v2.1 (15/11/2026)** — alignement sur SPEC v2.1 :
> - CL1 et CP1 remplacés : ils testaient la création/suppression d'ingrédients, retirée du périmètre (référentiel fixe).
> - Tests indépendants : chacun se joue sur une base réinitialisée ; CN4, CL2 et CP1 utilisent les recettes du seed « Pâtes au pesto » et « Salade de pâtes » au lieu de la recette créée en CN1.
> - CN1 : ingrédients choisis dans une liste. CN2 : ajout du filtre halal. CN4 : listes jour/semaine/mois. CN6 : vues jour/mois.

---

## Cas normaux (6)

### CN1 — Créer une recette complète et la voir dans le catalogue

**Pré-requis** : Base initialisée avec le seed.

**Actions** :
1. Aller sur l'écran Catalogue
2. Cliquer sur « Nouvelle recette »
3. Saisir :
   - Nom : « Pâtes carbonara »
   - Temps : 20 minutes
   - Portions : 2
   - Végétarien : Non, Végan : Non, Sans gluten : Non, Halal : Non
   - Ingrédients, **choisis dans la liste déroulante** : Pâtes (200g), Lardons (100g), Œufs (2 unités), Parmesan (50g)
   - Étapes : « 1. Cuire les pâtes », « 2. Faire revenir les lardons », « 3. Mélanger »
4. Valider

**Résultat attendu** :
- La recette apparaît dans le catalogue
- Le coût par portion est calculé et affiché
- Les drapeaux régime sont corrects (aucun actif)
- Le formulaire ne propose aucun champ pour créer un nouvel ingrédient

---

### CN2 — Filtrer les recettes par régime (végétarien, puis halal)

**Pré-requis** : Dans le seed, au moins 1 recette végétarienne, 1 non-végétarienne, 1 halal et 1 non halal.

**Actions** :
1. Aller sur l'écran Catalogue
2. Activer le filtre « Végétarien »
3. Activer en plus le filtre « Halal »
4. Cliquer sur « Réinitialiser »

**Résultat attendu** :
- Étape 2 : seules les recettes végétariennes sont affichées, le nombre de résultats est correct
- Étape 3 : seules les recettes à la fois végétariennes **et** halal restent affichées
- Étape 4 : toutes les recettes sont réaffichées

---

### CN3 — Planifier un repas et le voir dans le planning

**Pré-requis** : Au moins 1 recette dans le catalogue.

**Actions** :
1. Aller sur l'écran Planning
2. Sélectionner « Lundi Midi »
3. Choisir une recette dans la liste
4. Valider

**Résultat attendu** :
- La recette apparaît dans la case « Lundi Midi »
- Un rafraîchissement de page conserve le planning
- Le nom de la recette est cliquable et ouvre le détail

---

### CN4 — Générer une liste de courses (jour, semaine, mois courants)

**Pré-requis** : Base réinitialisée (planning vide). Recettes du seed « Pâtes au pesto » (200g pâtes) et « Salade de pâtes » (150g pâtes).

**Actions** :
1. Planifier « Pâtes au pesto » **aujourd'hui** au Midi
2. Planifier « Salade de pâtes » un **autre jour de la semaine courante** au Soir
3. Aller sur l'écran Liste de courses (période par défaut : « Cette semaine »)
4. Choisir « Aujourd'hui »
5. Choisir « Ce mois »

**Résultat attendu** :
- Étape 3 : les pâtes apparaissent avec 350g (agrégation correcte), ingrédients groupés par rayon, coût total en euros, toutes les cases décochées
- Étape 4 : seuls les ingrédients de « Pâtes au pesto » apparaissent (pâtes : 200g)
- Étape 5 : les pâtes apparaissent avec 350g (si les deux jours sont dans le mois courant — sinon voir CP1)
- La période affichée est indiquée en haut de la liste

---

### CN5 — Cocher des ingrédients dans la liste et retrouver l'état

**Pré-requis** : Liste de courses générée (CN4).

**Actions** :
1. Sur « Cette semaine », cocher 3 ingrédients
2. Rafraîchir la page
3. Basculer sur « Ce mois »

**Résultat attendu** :
- Les 3 ingrédients cochés le restent après rafraîchissement
- Les autres sont toujours décochés
- Dans la liste du mois, aucune case n'est cochée (état indépendant par période)

---

### CN6 — Changer de vue et naviguer dans le planning

**Pré-requis** : Base réinitialisée. Une recette du seed planifiée aujourd'hui au Midi, rien la semaine suivante.

**Actions** :
1. Noter la semaine affichée (ex : « Semaine du 16 au 22 novembre »)
2. Cliquer sur ▶ (semaine suivante), vérifier que le planning est vide
3. Cliquer sur ◀ (semaine précédente)
4. Passer en vue **Jour**, puis en vue **Mois**
5. En vue Mois, cliquer sur ▶ puis « Aujourd'hui »

**Résultat attendu** :
- L'indicateur de période change correctement à chaque action
- Le planning de la semaine +1 est vide ; le retour affiche à nouveau la recette
- La recette apparaît dans le créneau Midi d'aujourd'hui dans les vues Jour, Semaine et Mois
- « Aujourd'hui » ramène au mois courant

---

## Cas limites (3)

### CL1 — Envoyer à l'API un ingrédient hors référentiel

**Pré-requis** : Base initialisée avec le seed (aucun ingrédient d'id 9999).

**Actions** :
1. Depuis l'onglet Réseau du navigateur (ou `curl`), envoyer une création de recette valide mais avec un ingrédient `{"ingredient_id": 9999, "quantity": 100}`

**Résultat attendu** :
- Code HTTP 422
- Réponse : `{"erreurs": {"ingredients": "Ingrédient inconnu."}}`
- La recette n'est pas créée (ni ses étapes : rien n'est écrit en base)

**Justification** : les ingrédients ne sont saisis que via une liste ; le serveur ne doit pas faire confiance au client.

---

### CL2 — Tenter de supprimer une recette planifiée

**Pré-requis** : Base réinitialisée. Recette du seed « Pâtes au pesto » planifiée aujourd'hui au Midi (via l'écran Planning).

**Actions** :
1. Aller sur l'écran Catalogue
2. Tenter de supprimer « Pâtes au pesto »

**Résultat attendu** :
- Message d'erreur : « Impossible de supprimer cette recette car elle est planifiée dans un repas. »
- Code HTTP 409
- La recette n'est pas supprimée

---

### CL3 — Générer une liste de courses avec planning vide

**Pré-requis** : Planning vide pour la semaine courante.

**Actions** :
1. Aller sur l'écran Liste de courses

**Résultat attendu** :
- Message : « Aucun repas planifié sur cette période. Ajoutez des recettes à votre planning pour générer votre liste de courses. »
- Pas de tableau vide
- Lien vers l'écran Planning

---

## Cas piège (1)

### CP1 — Liste du mois courant et frontière de mois

**Pré-requis** : Base réinitialisée (planning vide). Recettes du seed « Pâtes au pesto » (200g pâtes) et « Salade de pâtes » (150g pâtes).

**Actions** :
1. Dans le planning, planifier « Pâtes au pesto » le **dernier jour du mois courant** au Midi
2. Planifier « Salade de pâtes » le **1er jour du mois suivant** au Midi
3. Aller sur l'écran Liste de courses, choisir « Ce mois »

**Résultat attendu** :
- Seuls les ingrédients de « Pâtes au pesto » apparaissent (pâtes : 200g, pas 350g)
- Le repas du mois suivant n'est pas compté, même s'il tombe dans la même semaine

**Justification** : piège classique des bornes de période — le mois n'est pas un multiple de semaines ; la borne de fin (`BETWEEN` inclusif, dernier jour = 28, 29, 30 ou 31) doit être calculée et non supposée.

---

## Checklist de vérification finale

Avant la soutenance, vérifier que :
- [ ] Les 10 cas passent sur une base réinitialisée (`php database/init.php --reset`)
- [ ] Tous les messages d'erreur sont en français
- [ ] Les montants sont affichés en euros avec 2 décimales
- [ ] Les codes HTTP sont corrects (422, 404, 409)
- [ ] Aucune console error dans le navigateur
- [ ] `PRAGMA foreign_keys = ON` est bien activé (tester CL2)
- [ ] Aucune route d'API ne permet de créer, modifier ou supprimer un ingrédient

