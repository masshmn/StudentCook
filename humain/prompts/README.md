# Prompts — mode d'emploi

> Comment on travaille avec l'IA sur Student Cook : quel prompt utiliser, à quel moment, et comment le remplir.
> Les 9 templates de ce dossier sont **versionnés** (référence commune du binôme). Le journal (`../JOURNAL_PROMPTS.md`) et la grille d'évaluation (`../EVAL_PROMPT.md`) restent **locaux**.

---

## 1. Le cycle d'une fonctionnalité

Chaque issue du backlog (#4 → #17) suit le même enchaînement. Un template par étape :

```
Issue GitHub
   │
   ├─ 01 Interview de spec      → clarifier avant de coder (si l'issue laisse des zones floues)
   ├─ 02 Plan d'implémentation  → fichiers à créer/modifier, SANS code — on valide à deux
   ├─ 03 Implémentation         → couche par couche, `php -l` après chaque fichier PHP
   ├─ 06 Cas de test            → compléter si l'issue n'a pas de cas dans docs/TESTS.md
   ├─ 04 Revue adverse          → avant d'ouvrir la PR
   └─ Journal                   → une entrée dans JOURNAL_PROMPTS.md
```

Prompts « à la demande », hors cycle :

| Template | Quand l'utiliser |
|----------|------------------|
| `05_audit_securite` | Avant la soutenance, ou après une grosse fonctionnalité (F1, F4) |
| `07_verification_dependances` | Avant chaque merge sur `main` (zéro Composer, zéro npm, zéro CDN) |
| `08_debogage` | Un bug qu'on ne comprend pas après 10 min de recherche seul·e |
| `09_comprendre_fichier` | Avant de relire ou modifier un fichier écrit par l'autre (ou par l'IA) |

---

## 2. Comment utiliser un template

1. **Copier** le contenu de `XX_nom/prompt.md`.
2. **Remplacer les `[PLACEHOLDERS]`** : `[NOM_FONCTIONNALITE]`, `[LIEN_ISSUE]`, `[CHEMIN_FICHIER]`, etc.
3. **Pointer vers les sources** plutôt que tout recopier : numéro d'issue, section de `docs/SPEC.md`, cas de `docs/TESTS.md`.
4. **Supprimer** les sections inutiles pour le cas présent (un prompt court et précis vaut mieux qu'un long générique).
5. **Coller** dans l'agent, puis **lire la réponse avant d'accepter quoi que ce soit**.

### Exemple rempli (étape 02, issue #9)

```markdown
## Contexte
Projet Student Cook. Fonctionnalité : créer une recette.
Issue : #9 (critères d'acceptation dans l'issue), cas de test CN1 et CL1 de docs/TESTS.md.

## Objectif
Propose un plan couche par couche, SANS écrire de code.

## Consigne
Fichiers à créer / modifier, ordre d'implémentation, points de vigilance.
Signale explicitement où une transaction est nécessaire.

## Attends ma validation avant de coder.
```

> Avec **Claude Code**, `CLAUDE.md` et `AGENTS.md` sont chargés automatiquement : inutile de recopier la stack, les 3 règles d'or ou le format d'erreur. Concentrez le prompt sur **ce qui est propre à la tâche**.

---

## 3. Les bonnes pratiques (ce qu'on a appris)

### ✅ À faire
- **Une tâche par prompt** : « plan de F1 création », pas « fais tout F1 ».
- **Plan d'abord, code ensuite** : l'agent propose, on valide, puis il code (règle de `CLAUDE.md`).
- **Donner le contexte humain** : « binôme, 2 semaines, démo locale » → l'agent choisit la bonne complexité.
- **Demander des questions plutôt que des solutions** quand le besoin est flou (template 01).
- **Exiger une vérification** : `php -l`, cas de `TESTS.md`, critères de l'issue.
- **Challenger le résultat** : « ce fichier est-il vraiment utile ? », « pourquoi pas plus simple ? ».

### ❌ À éviter

| Prompt faible | Pourquoi | Mieux |
|---------------|----------|-------|
| « Fais-moi le CRUD des recettes. » | Aucun contexte, aucune limite, aucun critère de succès (2/25 sur la grille) | Template 02 rempli avec l'issue #9 |
| « Corrige le bug. » | L'agent devine le bug | Template 08 : attendu / observé / message d'erreur exact |
| « Ajoute un export PDF. » | **Hors périmètre** (`docs/SPEC.md` §3) | Ne pas demander : noter l'idée dans `DEPASSEMENT.md` |
| « Améliore le code. » | Objectif flou → refactoring non souhaité | Template 04 : revue ciblée sécurité et bugs |

### 🔁 Règle des deux échecs
Si l'agent rate **deux fois** la même correction :
1. Arrêter la conversation.
2. Ajouter le piège dans `AGENTS.md` → « Pièges connus ».
3. Repartir d'une conversation neuve.

### 🚫 Ce que l'agent ne fait jamais
- `git commit` / `git push` : c'est nous qui relisons et commitons.
- Ajouter une dépendance, un framework ou un `.env` réel.
- Implémenter une piste de `DEPASSEMENT.md`.

---

## 4. Évaluer et améliorer un prompt

Avant de réutiliser un prompt « maison », passez-le dans la grille `../EVAL_PROMPT.md` (5 critères, / 25) :
clarté de l'intention · spécificité · exemples et contre-exemples · structure · validation.

**Objectif : ≥ 15/25.** En dessous, le prompt génère des allers-retours.

Un prompt qui a bien marché plusieurs fois ? Proposez-le comme nouveau template (`10_nom/prompt.md`) dans une PR.

---

## 5. Tenir le journal

Après chaque usage significatif de l'IA, ajouter une entrée dans `../JOURNAL_PROMPTS.md` (fichier local, non versionné) :

```markdown
## Entrée #N — [Titre] ([date])
**Contexte** : issue, fonctionnalité
**Intention** : ce qu'on voulait obtenir
**Prompts utilisés** : les formulations exactes (copier-coller)
**Gardé / modifié / refusé** : ce qu'on a accepté de la réponse, et pourquoi
**Verdict** : ✅ validé / ⚠️ partiel / ❌ abandonné
**Améliorations du prompt** : ce qu'on écrirait autrement la prochaine fois
```

C'est la matière de la soutenance : on doit pouvoir expliquer **chaque** ligne produite avec l'IA.

---

## ⚠️ À savoir sur les templates actuels

Les templates 02 et 03 ont été écrits **avant** l'architecture Hybrid. Quand vous les utilisez, corrigez à la volée :
- chemins : `backend/src/Domain/Repositories/`, `Domain/Services/`, `Http/Controllers/`, `Http/Validation/` (pas `backend/src/Repositories/`) ;
- l'exemple de `RecipeRepository` (03) reçoit un `PDO` dans son constructeur : dans le projet, il **étend `AbstractRepository`** ;
- l'exemple ne gère pas le drapeau **halal** ni la vérification des `ingredient_id`.
