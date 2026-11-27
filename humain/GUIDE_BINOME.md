# Guide du binôme — Student Cook

## Principe général
**Répartition par fonctionnalité complète** (base → API → écran), pas « front contre back ». Les deux doivent pouvoir expliquer n'importe quel fichier.

## Rôles
- **Pilote / relecteur** : sur chaque fonctionnalité, l'une pilote et l'autre relit la pull request. On alterne.
- Les deux participent à la conception et à la validation des décisions.

## Workflow d'une fonctionnalité

1. **Création de l'issue** : rédiger ensemble les critères d'acceptation (format Gherkin)
2. **Branche** : `feat/<nom>` ou `fix/<nom>`
3. **Plan** : le pilote propose un plan (fichiers à créer/modifier, approche), le relecteur valide
4. **Implémentation** : le pilote code, avec ou sans IA selon la complexité
5. **Vérification** : tester manuellement tous les critères de `TESTS.md` concernés
6. **Pull request** : le pilote ouvre la PR, le relecteur relit avec `REVUE_CRITIQUE.md`
7. **Merge** : après validation, merge sur `main`
8. **Journal** : une ligne au tableau de suivi de `JOURNAL_PROMPTS.md` par session IA (+ une entrée détaillée si c'est une issue)

## Format des commits
```
feat|fix|docs|test|refactor|chore: description au présent
```

Exemples :
- `feat: add recipe filtering by diet`
- `fix: prevent duplicate ingredients in recipe form`
- `docs: update SPEC with ingredient management decisions`

## Définition du « fini »

Une fonctionnalité est considérée comme terminée quand :
- [ ] Tous les critères d'acceptation de l'issue sont validés
- [ ] Les cas de test correspondants de `TESTS.md` passent
- [ ] Le code respecte l'architecture (3 règles d'or)
- [ ] Les erreurs sont gérées (messages en français, codes HTTP corrects)
- [ ] La PR est relue et approuvée
- [ ] Le journal de prompts est à jour (si IA utilisée)

## Règle IA : deux corrections ratées → conversation neuve

Si l'agent fait deux fois la même erreur sur le même point :
1. Arrêter la conversation
2. Ajouter la règle dans `AGENTS.md` section « Pièges connus »
3. Démarrer une nouvelle conversation avec le contexte mis à jour

## Rituels recommandés

- **Début de session** : vérifier ensemble la prochaine issue à traiter
- **Fin de fonctionnalité** : relecture croisée + validation des tests
- **Point hebdomadaire** : avancement, décisions à trancher, mise à jour du journal

## Résolution de désaccords

En cas de désaccord technique :
1. Lister les pour et contre de chaque approche
2. Consulter la spec et les contraintes techniques
3. Si égalité : tester rapidement les deux approches (time-box 30 min)
4. Documenter la décision finale dans `DECISIONS.md`
