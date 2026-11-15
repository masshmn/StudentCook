# Prompt : Vérification des dépendances

## Contexte
Projet Student Cook : zéro dépendance externe (pas de Composer, pas de npm).

## Objectif
Vérifier qu'aucune dépendance externe n'a été ajoutée par erreur.

## Consigne
Analyse le projet et vérifie :

### 1. Fichiers de dépendances
- [ ] Aucun `composer.json` / `composer.lock`
- [ ] Aucun `package.json` / `package-lock.json` / `yarn.lock`
- [ ] Aucun dossier `vendor/` ou `node_modules/`

### 2. Imports et require
- [ ] Aucun `require 'vendor/autoload.php'`
- [ ] Aucun `import ... from 'node_modules/...'`
- [ ] Aucun CDN externe (ex : Bootstrap, jQuery) dans `index.html`

### 3. Bibliothèques inline
- [ ] Aucun fichier copié-collé d'une lib externe (ex : `bootstrap.min.css` dans le projet)
- [ ] Aucun code généré par un outil (ex : `tailwind.css` compilé)

### 4. Appels réseau
- [ ] Aucun `fetch('https://api.external.com/...')`
- [ ] Aucun `curl` vers une API externe
- [ ] Aucune balise `<script src="https://cdn.example.com/...">` dans le HTML

## Format de sortie attendu
```markdown
## Vérification des dépendances — Student Cook

### ✅ Fichiers de config absents
- Pas de `composer.json`
- Pas de `package.json`
- Pas de `vendor/` ou `node_modules/`

### ✅ Imports vérifiés
- Aucun `require 'vendor/autoload.php'`
- Aucun import npm
- Aucun CDN externe

### ⚠️ Alertes (si applicable)
#### [Fichier détecté]
**Fichier** : `chemin/fichier`
**Problème** : [Description]
**Impact** : Violation de la contrainte « zéro dépendance »
**Recommandation** : [Supprimer ou remplacer par du code natif]

### Verdict
- [ ] ✅ Aucune dépendance externe détectée
- [ ] ⚠️ Dépendances à retirer
- [ ] ❌ Dépendances critiques (frameworks, libs)
```

## Exemple
```markdown
### ⚠️ Alertes

#### CDN Bootstrap détecté
**Fichier** : `frontend/index.html:12`
**Problème** :
```html
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
```
**Impact** : Appel réseau externe, dépendance non contrôlée
**Recommandation** : Écrire le CSS nécessaire dans `frontend/css/style.css`

#### jQuery copié dans le projet
**Fichier** : `frontend/js/jquery-3.6.0.min.js`
**Problème** : Fichier lib externe copié (200 Ko)
**Impact** : Violation « zéro dépendance », code non maîtrisé
**Recommandation** : Réécrire en JS natif (`fetch`, `querySelector`, `addEventListener`)
```

## Justification de la contrainte
- **Pédagogie** : tout doit être explicable ligne par ligne
- **Démo** : pas de panne réseau, pas de bug de version
- **Simplicité** : pas de setup, pas de build

## Contre-exemple
❌ Ne suggère pas d'ajouter des dépendances (ex : « Tu devrais utiliser Axios »)
