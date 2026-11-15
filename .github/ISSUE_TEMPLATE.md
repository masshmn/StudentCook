## [F?] Titre court de la fonctionnalité

**En tant qu'** utilisateur
**je veux** [action]
**afin de** [bénéfice]

**Hors périmètre :** [ce qui n'est PAS dans cette issue]

---

### Critères d'acceptation

- [ ] **Étant donné** [contexte] **quand** [action] **alors** [résultat observable]
- [ ] **Étant donné** [contexte] **quand** [action] **alors** [résultat observable]
- [ ] **Erreur :** **étant donné** [contexte] **quand** [action invalide] **alors** message « [texte exact] » (code HTTP [422/404/409])

---

### Fichiers concernés (estimation)

**Backend** :
- [ ] `backend/src/Repositories/[Nom]Repository.php` (créer/modifier)
- [ ] `backend/src/Services/[Nom]Service.php` (créer/modifier)
- [ ] `backend/src/Controllers/[Nom]Controller.php` (créer/modifier)
- [ ] `backend/public/index.php` (ajouter routes)

**Frontend** :
- [ ] `frontend/js/views/[nom].js` (créer/modifier)
- [ ] `frontend/js/router.js` (ajouter route)
- [ ] `frontend/index.html` (ajouter lien menu)

**Base de données** :
- [ ] `database/schema.sql` (si modification de schéma)
- [ ] `database/seed.sql` (si nouvelles données de test)

---

### Cas de test associés
Référence dans `docs/TESTS.md` :
- CN[X] : [description courte]
- CL[X] : [description courte]
- CP[X] : [description courte]

---

### Points de vigilance
- [ ] Transaction si multi-tables (ex : création de recette = 3 tables)
- [ ] PRAGMA foreign_keys activé (déjà dans Database.php)
- [ ] Validation côté serveur obligatoire
- [ ] Format erreur : `{"erreurs": {"champ": "message"}}`

---

### Définition du "fini"
- [ ] Tous les critères d'acceptation validés
- [ ] Cas de test `docs/TESTS.md` passent
- [ ] Code respecte architecture (3 règles d'or)
- [ ] PR relue et approuvée
- [ ] Branche mergée sur `main`
