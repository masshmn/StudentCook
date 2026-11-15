# Décisions — Student Cook

> Chaque décision : date, choix, raison, alternatives écartées.

---

## D1 — Ingrédients en référentiel fixe (15/11/2026)

**Choix** : Les ingrédients sont fournis par `database/seed.sql` et sélectionnés dans une liste déroulante du formulaire de recette. Aucune création, modification ni suppression depuis l'application.
**Raison** : Prix et rayons contrôlés et vérifiés une fois pour toutes ; moins d'écrans et de routes ; pas de doublons de saisie.
**Écarté** : CRUD des ingrédients (ancienne F0).

## D2 — Filtre halal (15/11/2026)

**Choix** : Drapeau déclaratif `is_halal` sur la recette, au même titre que végétarien/végan/sans gluten.
**Raison** : Cohérent avec les autres régimes, règle de filtrage déterministe.
**Écarté** : Déduction automatique à partir des ingrédients, certification.

## D3 — Planning daté avec vues jour / semaine / mois (15/11/2026)

**Choix** : Une date par repas (`meal_planning.meal_date`), trois vues sur les mêmes données ; liste de courses du jour, de la semaine ou du mois courant, cases à cocher par période.
**Raison** : Une seule requête par intervalle `[debut, fin]` sert toutes les vues.
**Écarté** : Garder `week_start_date + day_of_week` (vue mois impossible sans calculs croisés).

## D4 — Interface du planning : menu déroulant (15/11/2026)

**Choix** : Un menu déroulant par créneau, dans les trois vues.
**Raison** : Simple en JS natif, utilisable au clavier et sur mobile, tient dans les cases de la vue Mois.
**Écarté pour le MVP** : Drag & drop → prévu en V2 (voir `humain/DEPASSEMENT.md`).

## D5 — Quantités entières, 0 décimale (15/11/2026)

**Choix** : `quantity INTEGER > 0` : grammes pour `kg`, millilitres pour `L`, nombre de pièces pour `unité`.
**Raison** : Pas d'arrondi flottant, cohérent avec les montants en centimes.
**Écarté** : 1 ou 2 décimales (0,5 œuf) → REAL ou stockage ×10, agrégation plus fragile.

## D6 — Suppression d'une recette planifiée : bloquée (15/11/2026)

**Choix** : Refus en 409 avec le message « Impossible de supprimer cette recette car elle est planifiée dans un repas. » (`ON DELETE RESTRICT`).
**Raison** : Évite de vider des créneaux en silence ; l'utilisateur retire d'abord la recette du planning.
**Écarté** : `ON DELETE CASCADE` sur le planning.
