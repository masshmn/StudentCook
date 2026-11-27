@AGENTS.md

## Spécifique à Claude Code

### Workflow
1. **Avant de coder** : propose un plan couche par couche (fichiers à créer/modifier) et **attends validation**.
2. **Pendant le code** : après chaque fichier PHP, lance `php -l <fichier>` ; après chaque fichier JS, `node --check <fichier>`. Respecte la section « Règles de code » d'AGENTS.md.
3. **Après le code** : vérifie que les critères d'acceptation de `docs/SPEC.md` sont respectés.
4. **Vérification finale** : consulte `docs/TESTS.md` et indique quels cas de test doivent être vérifiés manuellement.
5. **Fin de session** (chaque session Claude du projet, quelle que soit la branche) : ajoute une ligne au « Tableau de suivi des sessions » de `humain/JOURNAL_PROMPTS.md` (date · session · branche · intention · prompt clé · verdict · ce qu'on a corrigé). Ajoute une « Entrée #n » détaillée seulement pour une issue ou une décision. Ce fichier est local (non versionné) : ne le commite pas.

### Fichiers de référence
- **AGENTS.md** : contexte principal (stack, archi, règles, pièges)
- **docs/SPEC.md** : fonctionnalités F0-F4, critères d'acceptation, hors périmètre
- **docs/MODELE_DONNEES.md** : schéma SQL, contraintes, requêtes importantes
- **docs/TESTS.md** : 11 cas de test manuels (7 normaux, 3 limites, 1 piège)

### Règles strictes
- **Git** : Ne fais JAMAIS `git commit` ni `git push`. Nous relisons et commitons nous-mêmes.
- **Échecs répétés** : Si une correction échoue deux fois sur le même point, arrête-toi et résume le problème au lieu de réessayer.
- **Langue** : Réponds en français, messages d'erreur en français, commentaires en français si nécessaire.

### Points de vigilance
- **PRAGMA foreign_keys** : Rappelle-le si tu crées un Repository (déjà dans Database.php).
- **Transactions** : Signale quand une transaction est nécessaire (modifications multi-tables).
- **Sécurité** : Toujours `prepare()` + `execute()`, jamais `innerHTML` avec données utilisateur.
- **Hors périmètre** : Si on te demande Export PDF, PWA, multi-utilisateurs, etc. → refuse poliment et rappelle le périmètre MVP.