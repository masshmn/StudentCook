# Prompt : Revue adverse (sécurité et bugs)

## Contexte
Projet Student Cook : PHP 8.3 natif + SQLite.
Code à relire : [fichiers concernés ou fonctionnalité]

## Objectif
Relis le code en adoptant une posture critique pour détecter les bugs et failles de sécurité.

## Consigne
Analyse le code ligne par ligne et cherche :

### 1. Sécurité (OWASP Top 10)
- [ ] **Injection SQL** : `query()` avec concaténation, pas de `prepare()`
- [ ] **XSS** : `innerHTML` avec données utilisateur
- [ ] **Validation** : champs requis non vérifiés, types non validés
- [ ] **Erreurs exposées** : messages d'erreur avec infos sensibles (ex : requête SQL)

### 2. Base de données
- [ ] **PRAGMA foreign_keys** : oubliée ?
- [ ] **Transactions** : multi-tables sans `beginTransaction()` / `commit()`
- [ ] **Contraintes** : UNIQUE, CHECK, FOREIGN KEY respectées ?
- [ ] **Doublons** : INSERT sans vérifier l'existence (doublon silencieux)

### 3. Calculs et logique métier
- [ ] **Arrondis** : arrondi multiple (perte de précision)
- [ ] **Division par zéro** : servings = 0, quantité = 0
- [ ] **Unités** : confusion g/kg, mL/L
- [ ] **Montants** : REAL au lieu de INTEGER (centimes)

### 4. Architecture
- [ ] **SQL dans Controller** : violation de la règle 1
- [ ] **Calcul métier dans Repository** : violation de la règle 3
- [ ] **$_GET dans Service** : violation de la règle 2

### 5. Qualité
- [ ] **Noms de variables** : `$a`, `$tmp`, `$data` sans contexte
- [ ] **Code commenté** : ancien code laissé en commentaire
- [ ] **Erreurs gérées** : try/catch sans gestion, erreur silencieuse

## Format de sortie attendu
```markdown
## Revue adverse : [Nom de la fonctionnalité]

### ✅ Points positifs
- [Ce qui est bien fait]

### ⚠️ Vulnérabilités détectées
#### 1. [Catégorie] : [Titre du problème]
**Fichier** : `chemin/fichier.php:ligne`
**Problème** : [Description]
**Impact** : [Gravité : faible/moyen/critique]
**Solution** : [Comment corriger]

#### 2. [...]

### 🐛 Bugs potentiels
[Même format]

### 📝 Améliorations qualité (optionnel)
[Même format]

### Verdict global
- [ ] ✅ Code sûr et prêt
- [ ] ⚠️ Corrections mineures nécessaires
- [ ] ❌ Blocage majeur (sécurité ou architecture)
```

## Exemple
```markdown
### ⚠️ Vulnérabilités détectées

#### 1. Injection SQL : Requête non préparée
**Fichier** : `RecipeRepository.php:42`
**Problème** :
```php
$sql = "SELECT * FROM recipes WHERE name = '" . $_GET['name'] . "'";
$this->pdo->query($sql);
```
**Impact** : Critique (injection SQL directe)
**Solution** : Utiliser `prepare()` + `execute()`
```php
$stmt = $this->pdo->prepare('SELECT * FROM recipes WHERE name = :name');
$stmt->execute(['name' => $name]);
```

#### 2. XSS : innerHTML avec données utilisateur
**Fichier** : `frontend/js/views/recipe-detail.js:23`
**Problème** :
```js
element.innerHTML = recipe.name; // Si name contient <script>...
```
**Impact** : Moyen (XSS possible)
**Solution** : Utiliser `textContent`
```js
element.textContent = recipe.name;
```
```

## Contre-exemple
❌ Ne propose pas de refactoring complet (focus sur sécurité et bugs)
❌ Ne cherche pas à optimiser le code (performance = hors scope)
