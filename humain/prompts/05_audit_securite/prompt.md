# Prompt : Audit de sécurité

## Contexte
Projet Student Cook : application web PHP 8.3 natif + SQLite.
Portée de l'audit : [tout le projet ou fichiers spécifiques]

## Objectif
Effectuer un audit de sécurité complet selon OWASP Top 10.

## Consigne
Analyse le code et vérifie systématiquement :

### 1. A01:2021 - Broken Access Control
- [ ] Routes protégées (si auth ajoutée en dépassement)
- [ ] Validation des IDs (ex : accès à `/recipes/999` d'un autre utilisateur)

### 2. A02:2021 - Cryptographic Failures
- [ ] Mots de passe hashés (si auth ajoutée)
- [ ] Pas de données sensibles en clair (ex : .env committé)

### 3. A03:2021 - Injection
- [ ] **SQL** : tous les `prepare()` + `execute()` avec paramètres nommés
- [ ] Aucun `query()` avec concaténation
- [ ] Aucune interpolation de variables dans requêtes

### 4. A04:2021 - Insecure Design
- [ ] Logique métier validée côté serveur (pas uniquement front)
- [ ] Contraintes en base (UNIQUE, CHECK, FOREIGN KEY)

### 5. A05:2021 - Security Misconfiguration
- [ ] Pas de `display_errors = On` en production
- [ ] Pas de `.env` réel committé (uniquement `.env.example`)
- [ ] `PRAGMA foreign_keys = ON` activé

### 6. A06:2021 - Vulnerable Components
- [ ] Aucune dépendance externe (Composer, npm)
- [ ] Version PHP >= 8.3 (supportée)

### 7. A07:2021 - Authentication Failures
- [ ] (Non applicable si monoposte sans auth)

### 8. A08:2021 - Data Integrity Failures
- [ ] Transactions pour opérations multi-tables
- [ ] Rollback en cas d'erreur

### 9. A09:2021 - Logging Failures
- [ ] Pas de `var_dump` ou `print_r` en production
- [ ] Pas de stack traces exposées à l'utilisateur

### 10. A10:2021 - Server-Side Request Forgery (SSRF)
- [ ] Aucune requête HTTP sortante (hors périmètre)

### Supplémentaire : XSS
- [ ] Front : `textContent` ou `createElement`, jamais `innerHTML`
- [ ] Pas de `eval()` ou `Function()`

## Format de sortie attendu
```markdown
## Audit de sécurité — Student Cook

### Résumé
- Fichiers analysés : [X]
- Vulnérabilités critiques : [X]
- Vulnérabilités moyennes : [X]
- Vulnérabilités faibles : [X]

### Vulnérabilités détectées

#### [CRITIQUE] A03 : Injection SQL dans RecipeRepository
**Fichier** : `backend/src/Repositories/RecipeRepository.php:42`
**Code** :
```php
$sql = "SELECT * FROM recipes WHERE id = " . $id;
$this->pdo->query($sql);
```
**Impact** : Injection SQL directe
**Recommandation** :
```php
$stmt = $this->pdo->prepare('SELECT * FROM recipes WHERE id = :id');
$stmt->execute(['id' => $id]);
```

#### [MOYEN] A09 : Erreurs exposées
**Fichier** : `backend/src/Controllers/RecipeController.php:78`
**Code** :
```php
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]); // Stack trace visible
}
```
**Impact** : Exposition d'informations techniques
**Recommandation** :
```php
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['erreurs' => ['general' => 'Une erreur est survenue.']]);
    error_log($e->getMessage()); // Log serveur uniquement
}
```

### Bonnes pratiques détectées
- ✅ Utilisation de `prepare()` + `execute()` dans IngredientRepository
- ✅ `textContent` utilisé systématiquement dans views/
- ✅ Transactions pour modifications de recettes

### Verdict global
- [ ] ✅ Aucune vulnérabilité critique
- [ ] ⚠️ Corrections nécessaires avant déploiement
- [ ] ❌ Vulnérabilités critiques bloquantes

### Recommandations prioritaires
1. [Action 1]
2. [Action 2]
3. [Action 3]
```

## Contre-exemple
❌ Ne propose pas de fonctionnalités (ex : « ajouter un WAF »)
❌ Ne suggère pas de dépendances externes (ex : « installer Helmet.js »)
