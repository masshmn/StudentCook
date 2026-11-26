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

## D7 — Portions par repas (26/11/2026) — version minimale, validée

**Choix** : Chaque repas planifié porte son nombre de portions (`meal_planning.servings`, entier ≥ 1), réglable par − / + dans le planning ; par défaut, celui de la recette. **Seule la liste de courses en tient compte** : `quantité × portions du repas ÷ portions de la recette`.
**Raison** : Un étudiant seul qui planifie une recette pour 4 achèterait 4 fois trop, contraire à l'objectif « petit prix ». Décidé avant de coder F3/F4 : ajouter la colonne plus tard imposerait de modifier une table déjà remplie et du code déjà écrit.
**Ce qui ne change pas** (aucune synchronisation) :
- La recette reste un modèle fixe : ses ingrédients, ses portions et sa fiche détail ne dépendent jamais du planning.
- Les étapes de préparation ne sont **pas** recalculées (texte libre, impossible à ajuster de façon fiable).
- Le coût par portion est inchangé (il est déjà ramené à 1 portion).
**Règle associée** : les étapes **n'écrivent pas de quantités** (« Cuire les pâtes », pas « Cuire 200 g de pâtes ») ; les quantités ne vivent que dans la liste d'ingrédients. S'applique au seed et est rappelée dans le formulaire.
**Arrondi** : par ingrédient, on somme les quantités exactes (fractions) de tous les repas de la période, puis on arrondit **une seule fois, au supérieur** (on n'achète pas 0,5 œuf). Le coût est calculé sur la quantité exacte et arrondi une seule fois, au total.
**Écarté** : Toujours compter la recette entière (liste fausse pour un étudiant seul) ; recalculer les étapes ou la fiche recette (fragile, sans gain pour la liste) ; arrondir repas par repas (arrondis cumulés) ; reporter en V2 (coût de migration plus élevé une fois F3/F4 codés).

## D8 — Design system V1 « Cahier » (26/11/2026)

**Choix** : Charte « cahier d'étudiant » (papier `#F6F3EC`, encre `#171512`, tomate `#E8452C`, beurre `#FFD45C`, traits 1,5 px, ombre décalée) en CSS natif : `tokens.css` (variables), `composants.css`, `style.css`. Documentation : `docs/DESIGN_SYSTEM.md`.
**Raison** : Identité visuelle cohérente sur les 4 écrans, sans dépendance ni build ; une seule source de vérité pour les couleurs.
**Polices** : système par défaut ; Bricolage Grotesque et DM Sans (OFL) prévues en fichiers locaux, jamais via Google Fonts (pas d'appel réseau externe).
**Écarté** : Framework CSS (Tailwind, Bootstrap), préprocesseur (Sass), polices en ligne.
