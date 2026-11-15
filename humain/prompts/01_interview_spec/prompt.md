# Prompt : Interview de spécification

## Contexte
Projet Student Cook : application locale PHP 8.3 natif + SQLite.
Architecture : Controllers → Services → Repositories.

## Objectif
Clarifier la fonctionnalité [NOM_FONCTIONNALITE] avant de commencer à coder.

## Consigne
Pose-moi exactement 5 questions pour clarifier :
1. Les cas d'usage précis (qui fait quoi, quand, pourquoi)
2. Les cas limites et erreurs possibles
3. Les règles métier à appliquer
4. Les contraintes techniques spécifiques
5. Les critères d'acceptation

Ne propose aucune solution, pose uniquement des questions ouvertes.

## Format de sortie attendu
```markdown
### Question 1 : [Cas d'usage]
[Question ouverte]

### Question 2 : [Cas limites]
[Question ouverte]

### Question 3 : [Règles métier]
[Question ouverte]

### Question 4 : [Contraintes techniques]
[Question ouverte]

### Question 5 : [Critères de succès]
[Question ouverte]
```

## Exemple
Pour la fonctionnalité « Filtrer les recettes par budget » :

**Question 1** : Quel est le comportement attendu si aucune recette ne correspond au budget saisi ?
**Question 2** : Doit-on filtrer par budget par portion ou par budget total de la recette ?
**Question 3** : Le budget de 0€ est-il valide ? Si oui, que doit-on afficher ?
**Question 4** : Les recettes sans ingrédients (coût = 0) doivent-elles apparaître dans tous les filtres ?
**Question 5** : Comment saura-t-on que le filtre fonctionne correctement lors de la démo ?

## Contre-exemple
❌ Ne propose pas de solution (ex : « Je vais créer un slider pour le budget »)
❌ Ne pose pas de questions fermées (ex : « Le budget est en euros ? Oui/Non »)
