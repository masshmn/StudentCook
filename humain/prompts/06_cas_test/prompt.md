# Prompt : Génération de cas de test

## Contexte
Projet Student Cook : PHP 8.3 natif + SQLite.
Fonctionnalité à tester : [NOM_FONCTIONNALITE]

## Objectif
Générer des cas de test manuels pour valider la fonctionnalité.

## Consigne
Propose 3 cas de test au format Gherkin :
1. **1 cas normal** : parcours utilisateur classique
2. **1 cas limite** : valeurs extrêmes, états vides, contraintes
3. **1 cas piège** : erreur que l'utilisateur peut facilement faire

Chaque cas doit inclure :
- Pré-requis (état de la base avant le test)
- Actions (étapes utilisateur)
- Résultat attendu (observable)

## Format de sortie attendu
```markdown
## Cas de test : [NOM_FONCTIONNALITE]

### CN — [Titre du cas normal]

**Pré-requis** : [État de la base]

**Actions** :
1. [Action 1]
2. [Action 2]
3. [Action 3]

**Résultat attendu** :
- [Résultat observable 1]
- [Résultat observable 2]
- [Résultat observable 3]

---

### CL — [Titre du cas limite]

**Pré-requis** : [État de la base]

**Actions** :
1. [Action 1]
2. [Action 2]

**Résultat attendu** :
- [Résultat observable, souvent un message d'erreur ou un état vide]

---

### CP — [Titre du cas piège]

**Pré-requis** : [État de la base]

**Actions** :
1. [Action 1]
2. [Action 2]

**Résultat attendu** :
- [Message d'erreur clair en français]
- [Code HTTP correct : 422, 404, 409]

**Justification** : [Pourquoi c'est un piège]
```

## Exemple
Pour « Supprimer un ingrédient » :

### CN — Supprimer un ingrédient non utilisé

**Pré-requis** : Ingrédient « Sel » existe et n'est utilisé dans aucune recette.

**Actions** :
1. Aller sur l'écran Ingrédients
2. Cliquer sur « Supprimer » à côté de « Sel »
3. Confirmer la suppression

**Résultat attendu** :
- L'ingrédient « Sel » n'apparaît plus dans la liste
- Message de succès : « Ingrédient supprimé. »
- La base ne contient plus l'ingrédient

---

### CL — Tenter de supprimer un ingrédient utilisé dans une recette

**Pré-requis** : Ingrédient « Tomate » utilisé dans la recette « Salade tomate-mozza ».

**Actions** :
1. Aller sur l'écran Ingrédients
2. Cliquer sur « Supprimer » à côté de « Tomate »

**Résultat attendu** :
- Message d'erreur : « Impossible de supprimer cet ingrédient car il est utilisé dans des recettes. »
- Code HTTP 409
- L'ingrédient n'est pas supprimé

---

### CP — Supprimer deux fois le même ingrédient (race condition simulée)

**Pré-requis** : Ingrédient « Poivre » existe et n'est utilisé dans aucune recette.

**Actions** :
1. Ouvrir deux onglets du navigateur
2. Dans l'onglet 1 : cliquer sur « Supprimer » pour « Poivre »
3. Dans l'onglet 2 : cliquer sur « Supprimer » pour « Poivre » (avant refresh)

**Résultat attendu** :
- Onglet 1 : suppression réussie
- Onglet 2 : message d'erreur « Ingrédient introuvable. »
- Code HTTP 404 pour l'onglet 2

**Justification** : Test de robustesse (double suppression)

## Critères de qualité
- [ ] Le résultat attendu est **observable** (pas juste « ça marche »)
- [ ] Le cas piège est **réaliste** (pas un hack improbable)
- [ ] Tous les cas sont **reproductibles** (pré-requis clairs)

## Contre-exemple
❌ Résultat trop vague : « La suppression fonctionne »
❌ Cas piège irréaliste : « L'utilisateur envoie une requête SQL directement »
