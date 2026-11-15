# Prompt : Aide au débogage

## Contexte
Projet Student Cook : PHP 8.3 natif + SQLite.
Problème rencontré : [DESCRIPTION_DU_BUG]

## Objectif
M'aider à identifier et corriger le bug.

## Informations à fournir
Pour que tu puisses m'aider efficacement, voici ce que j'observe :

### 1. Comportement attendu
[Ce qui devrait se passer]

### 2. Comportement observé
[Ce qui se passe réellement]

### 3. Message d'erreur (si applicable)
```
[Copier-coller exact du message d'erreur]
```

### 4. Contexte d'exécution
- [ ] Navigateur : [Chrome, Firefox, Safari...]
- [ ] Console navigateur (F12) : [erreurs JavaScript ?]
- [ ] Logs PHP : [erreur dans terminal Docker ?]
- [ ] Base de données : [état avant/après l'action]

### 5. Code concerné (optionnel)
[Fichier et ligne où le bug semble se produire]

## Consigne
Analyse le problème en suivant cette méthode :

### Étape 1 : Hypothèses
Liste 3 hypothèses possibles sur la cause du bug :
1. [Hypothèse 1]
2. [Hypothèse 2]
3. [Hypothèse 3]

### Étape 2 : Vérifications
Pour chaque hypothèse, propose une vérification :
- **Hypothèse 1** → Vérifier : [commande, requête, ou inspection]
- **Hypothèse 2** → Vérifier : [...]
- **Hypothèse 3** → Vérifier : [...]

### Étape 3 : Solution
Une fois l'hypothèse confirmée, propose une correction avec :
- Code avant (bug)
- Code après (correction)
- Explication

## Format de sortie attendu
```markdown
## Débogage : [Titre du bug]

### Analyse du problème
[Résumé de ce qui ne fonctionne pas]

### Hypothèses
1. **[Hypothèse 1]**
   - Vérification : [Commande ou inspection]
   - Probabilité : Élevée / Moyenne / Faible

2. **[Hypothèse 2]**
   - Vérification : [...]
   - Probabilité : [...]

3. **[Hypothèse 3]**
   - Vérification : [...]
   - Probabilité : [...]

### Vérifications à effectuer
```bash
# Vérification 1
[Commande ou requête SQL]

# Vérification 2
[...]
```

### Solution (si hypothèse confirmée)

#### Avant (bug)
```php
[Code actuel]
```

#### Après (correction)
```php
[Code corrigé]
```

#### Explication
[Pourquoi ça ne marchait pas, pourquoi ça marche maintenant]

### Test de non-régression
[Cas de test à vérifier après correction]
```

## Exemple
```markdown
## Débogage : Liste de courses vide alors que le planning est rempli

### Analyse du problème
La liste de courses s'affiche vide, mais le planning contient 3 recettes.

### Hypothèses
1. **`PRAGMA foreign_keys` non activé**
   - Vérification : `SELECT * FROM weekly_planning;` → Données présentes ?
   - Probabilité : Faible (problème différent)

2. **Requête SQL incorrecte (JOIN raté)**
   - Vérification : Exécuter la requête de ShoppingRepository manuellement
   - Probabilité : Élevée (symptômes cohérents)

3. **week_start_date incorrect (format de date)**
   - Vérification : Afficher `week_start_date` dans la console front
   - Probabilité : Moyenne

### Vérifications à effectuer
```bash
# Vérification 1 : Afficher le planning
sqlite3 database/student_cook.db "SELECT * FROM weekly_planning;"

# Vérification 2 : Tester la requête de liste de courses
sqlite3 database/student_cook.db "
SELECT i.name, SUM(ri.quantity) AS total_quantity
FROM weekly_planning wp
JOIN recipe_ingredients ri ON wp.recipe_id = ri.recipe_id
JOIN ingredients i ON ri.ingredient_id = i.id
WHERE wp.week_start_date = '2026-11-18'
GROUP BY i.id;
"
```

### Solution (hypothèse 2 confirmée)

#### Avant (bug)
```php
// ShoppingRepository.php
$stmt = $this->pdo->prepare('
    SELECT i.name, SUM(ri.quantity) AS total_quantity
    FROM weekly_planning wp
    INNER JOIN recipe_ingredients ri ON wp.recipe_id = ri.recipe_id
    INNER JOIN ingredients i ON ri.ingredient_id = i.id
    WHERE wp.week_start_date = :week_start_date
    GROUP BY i.id
');
$stmt->execute(['week_start_date' => $weekStartDate]);
```
**Problème** : Si `recipe_id` est NULL dans `weekly_planning`, le INNER JOIN exclut la ligne (liste vide).

#### Après (correction)
```php
$stmt = $this->pdo->prepare('
    SELECT i.name, SUM(ri.quantity) AS total_quantity
    FROM weekly_planning wp
    LEFT JOIN recipe_ingredients ri ON wp.recipe_id = ri.recipe_id
    LEFT JOIN ingredients i ON ri.ingredient_id = i.id
    WHERE wp.week_start_date = :week_start_date
      AND wp.recipe_id IS NOT NULL
    GROUP BY i.id
');
$stmt->execute(['week_start_date' => $weekStartDate]);
```
**Explication** : Ajout de `AND wp.recipe_id IS NOT NULL` pour filtrer les créneaux vides, mais garder les créneaux remplis même si le JOIN échoue (défensif).

### Test de non-régression
- Cas CN4 de TESTS.md : générer liste avec 2 recettes planifiées
- Vérifier agrégation (pâtes = 350g)
```

## Contre-exemple
❌ Ne devine pas aveuglément (propose toujours des vérifications)
❌ Ne propose pas de réécrire tout le code (cherche la cause précise)
