# Design system V1 « Cahier » — Student Cook

> Décision : D8 (`docs/DECISIONS.md`). CSS natif, sans dépendance ni build.
> Fichiers : `frontend/css/tokens.css` (variables) · `frontend/css/composants.css` (composants) · `frontend/css/style.css` (base, mise en page, import des deux autres).

## 1. Principes

- **Cahier d'étudiant** : fond papier, encre noire, traits de 1,5 px, ombre décalée pleine (pas de flou), un seul accent fort (tomate) et un surligneur (beurre) réservé aux **prix**.
- **Lisible avant d'être joli** : contraste AA partout, focus toujours visible, cibles tactiles ≥ 2 rem.
- **Une seule source de vérité** : toute couleur, taille, espacement ou rayon passe par une variable de `tokens.css`.
- **Sobriété** : pas d'image, pas d'icône externe, pas de police téléchargée depuis Internet.

## 2. Variables (`tokens.css`)

### Couleurs

| Variable | Valeur | Usage |
|---|---|---|
| `--papier` | `#F6F3EC` | Fond de page |
| `--papier-fonce` | `#ECE7DB` | En-têtes de tableau, jours hors mois |
| `--carte` | `#FFFDF8` | Fond des boîtes, champs, lignes |
| `--encre` | `#171512` | Texte, bordures, bouton principal |
| `--encre-douce` | `#5C574F` | Texte secondaire (6,46:1 sur papier) |
| `--trait-doux` | `#D9D2C3` | Séparateurs internes, créneaux vides |
| `--tomate` | `#E8452C` | Fond d'accent (bouton tomate) — **texte encre dessus** |
| `--tomate-fonce` | `#B3311B` | Liens et focus (5,62:1 sur papier) |
| `--beurre` / `--beurre-clair` | `#FFD45C` / `#FFF1C2` | Prix, aujourd'hui, survol |
| `--succes` / `--succes-fond` | | Notification de succès |
| `--erreur` / `--erreur-fond` | | Erreurs, bouton danger |
| `--regime-*` | pastels | `vegetarien`, `vegan`, `sans-gluten`, `halal` |
| `--rayon-*` | | `fruits-legumes`, `epicerie`, `frais`, `surgeles`, `viandes-poissons`, `autres` |

### Autres variables

- Polices : `--police-titre`, `--police-texte`, `--police-chiffres` (monospace pour prix et quantités).
- Tailles : `--texte-xs` (0,75 rem) → `--texte-xxl` (2,25 rem).
- Espacements : `--espace-1` (4 px) → `--espace-7` (48 px).
- Formes : `--rayon-s|m|l|rond`, `--bordure`, `--bordure-douce`, `--ombre`, `--focus`.
- Mise en page : `--largeur-barre` (220 px), `--largeur-contenu` (960 px).
- **Point de rupture unique : 760 px** (répété en dur dans les `@media`, les variables CSS n'y sont pas lues).

### Polices

Par défaut : polices système. Les polices de la maquette (Bricolage Grotesque pour les titres, DM Sans pour le texte, licence OFL) sont prévues mais **non chargées** : déposer les fichiers dans `frontend/fonts/` (`BricolageGrotesque.woff2`, `DMSans.woff2`), puis décommenter le bloc `@font-face` en tête de `tokens.css`. Le bloc est commenté pour éviter des erreurs 404 dans la console tant que les fichiers manquent.

## 3. Composants

Les exemples sont du HTML **cible** : dans le code, on les construit avec `el()` de `dom.js` (jamais `innerHTML`).

### Boutons

```html
<button class="bouton">Enregistrer</button>                    <!-- principal : noir -->
<a class="bouton bouton--tomate" href="#/recettes/nouvelle">Nouvelle recette</a>
<button class="bouton bouton--contour">Annuler</button>
<button class="bouton bouton--danger">Supprimer</button>
<button class="bouton bouton--contour bouton--petit">Aujourd'hui</button>
<button class="bouton bouton--contour bouton--icone" aria-label="Semaine précédente">◀</button>
```

Un seul bouton tomate par écran (l'action principale). `bouton--icone` exige un `aria-label`.

### Puces de régime

```html
<span class="puce" data-regime="vegetarien">Végétarien</span>
<!-- filtre : -->
<button class="puce" data-regime="halal" aria-pressed="false">Halal</button>
```

Regrouper dans `<ul class="liste-puces">`. L'état d'un filtre passe par `aria-pressed` (lu par les lecteurs d'écran et par le CSS).

### Choix (budget, temps) et segments (Jour / Semaine / Mois)

```html
<div class="barre-filtres">
  <div class="barre-filtres__groupe">
    <span class="barre-filtres__titre">Budget / portion</span>
    <div class="segments" role="group" aria-label="Budget par portion">
      <button aria-pressed="true">Tous</button>
      <button aria-pressed="false">≤ 2 €</button>
    </div>
  </div>
</div>

<div class="segments" role="group" aria-label="Vue du planning">
  <button aria-pressed="false">Jour</button>
  <button aria-pressed="true">Semaine</button>
  <button aria-pressed="false">Mois</button>
</div>
```

### Ligne de recette (catalogue)

```html
<ul class="liste-recettes">
  <li class="ligne-recette">
    <span class="assiette" aria-hidden="true">P</span>
    <div class="ligne-recette__corps">
      <h2 class="ligne-recette__nom"><a href="#/recettes/3">Pâtes au pesto</a></h2>
      <div class="ligne-recette__meta">
        <span>15 min · 2 portions</span>
        <span class="puce" data-regime="vegetarien">Végétarien</span>
      </div>
    </div>
    <div class="ligne-recette__prix">
      <span class="prix">1,20 €</span><small>par portion</small>
    </div>
  </li>
</ul>
```

Le prix est **toujours** formaté par `formatEuros()` (centimes → euros, arrondi une seule fois).

### Boîte, prix, ticket

```html
<section class="boite boite--ombre">…</section>
<span class="prix">3,45 €</span>

<div class="ticket">
  <div class="ticket__ligne"><span>Pâtes 200 g</span><span>0,30 €</span></div>
  <div class="ticket__total"><span>Total</span><span>3,45 €</span></div>
</div>
```

### Navigation de période

```html
<div class="navigation-periode">
  <button class="bouton bouton--contour bouton--icone" aria-label="Période précédente">◀</button>
  <h2 class="navigation-periode__titre" aria-live="polite">Semaine du 16 au 22 novembre</h2>
  <button class="bouton bouton--contour bouton--icone" aria-label="Période suivante">▶</button>
  <button class="bouton bouton--contour bouton--petit">Aujourd'hui</button>
</div>
```

### Planning : tableau (jour, semaine)

```html
<div class="planning-defilement">
  <table class="planning">
    <thead><tr><th scope="col"></th><th scope="col" aria-current="date">Lun. 16</th>…</tr></thead>
    <tbody>
      <tr>
        <th scope="row">Midi</th>
        <td><div class="creneau">
          <label class="visuellement-cache" for="c-2026-11-16-Midi">Lundi 16 midi</label>
          <select id="c-2026-11-16-Midi">…</select>
          <a class="creneau__recette" href="#/recettes/3">Pâtes au pesto</a>
        </div></td>
        <td><div class="creneau creneau--vide">…</div></td>
      </tr>
    </tbody>
  </table>
</div>
```

`.planning-defilement` permet le défilement horizontal sur mobile. Le jour courant porte `aria-current="date"`.

### Planning : calendrier du mois

```html
<div class="calendrier">
  <div class="calendrier__entete">Lun</div> … <div class="calendrier__entete">Dim</div>
  <div class="calendrier__jour calendrier__jour--hors-mois"><span class="calendrier__numero">27</span></div>
  <div class="calendrier__jour" aria-current="date">
    <span class="calendrier__numero">26</span>
    <select aria-label="26 novembre, midi">…</select>
    <select aria-label="26 novembre, soir">…</select>
  </div>
</div>
```

### Compteur de portions (− / +)

Sert au réglage des portions d'un repas dans le planning (D7).

```html
<div class="compteur" role="group" aria-label="Portions">
  <button type="button" aria-label="Retirer une portion">−</button>
  <output aria-live="polite">2</output>
  <button type="button" aria-label="Ajouter une portion">+</button>
</div>
```

Le bouton − est `disabled` à 1.

### Liste de courses

```html
<section class="rayon" data-rayon="Fruits & Légumes">
  <h2 class="rayon__titre">Fruits & Légumes</h2>
  <ul class="liste-courses">
    <li class="article">
      <label>
        <input type="checkbox">
        <span class="article__nom">Tomates</span>
        <span class="article__quantite">400 g</span>
      </label>
      <span class="article__cout">1,20 €</span>
    </li>
  </ul>
</section>
```

`data-rayon` reprend **exactement** la valeur `aisle` de la base (valeurs fixées par le `CHECK`) : la couleur du liseré en découle, sans table de correspondance en JS. Un article coché est barré.

### Formulaires

```html
<form class="formulaire" novalidate>
  <div class="champ">
    <label for="nom">Nom de la recette</label>
    <input id="nom" name="name" type="text">
    <span class="champ__aide">Entre 2 et 100 caractères.</span>
  </div>
  <fieldset class="champ"><legend>Régimes</legend>…</fieldset>
  <div class="actions">
    <button class="bouton bouton--tomate">Enregistrer</button>
    <a class="bouton bouton--contour" href="#/recettes">Annuler</a>
  </div>
</form>
```

Les erreurs sont posées par `afficherErreursChamps()` (`.erreur-champ` + `aria-invalid` + `aria-describedby`) et `afficherErreurs()` (`.notification--erreur`, `role="alert"`).

### Notifications et état vide

```html
<div class="notification notification--succes" role="status">Recette enregistrée.</div>

<div class="etat-vide">
  <p>Aucun repas planifié sur cette période. Ajoutez des recettes à votre planning pour générer votre liste de courses.</p>
  <a class="bouton" href="#/planning">Aller au planning</a>
</div>
```

### Utilitaire

`.visuellement-cache` : texte lu par les lecteurs d'écran mais invisible (libellés de `<select>` dans les cases du planning).

## 4. Accessibilité

- **Contraste** (vérifié, WCAG AA ≥ 4,5:1) : encre/papier 16,4 · encre-douce/papier 6,5 · tomate-fonce/papier 5,6 · encre/tomate 4,6 · encre/beurre 12,9 · erreur/erreur-fond 6,0. **Blanc sur tomate = 3,95 : interdit** (d'où le texte encre sur `bouton--tomate`).
- **Focus** : contour `--focus` (3 px tomate foncé) sur liens, boutons et champs ; ne jamais le supprimer.
- **États** : `aria-pressed` pour les boutons bascule, `aria-current="page"` pour le menu (posé par `router.js`), `aria-current="date"` pour aujourd'hui.
- **Couleur jamais seule** : un régime a toujours son libellé, un rayon son titre.
- **Sécurité** : toute donnée affichée passe par `textContent` / `el()` ; jamais `innerHTML`.
- **Mouvement** : animation de survol désactivée si `prefers-reduced-motion`.

## 5. Responsive

| Largeur | Navigation | Contenu |
|---|---|---|
| > 760 px | Barre latérale fixe à gauche (`.entete`), logo + menu vertical | 960 px max |
| ≤ 760 px | Barre flottante en bas, menu horizontal, logo masqué | Marge basse de 6 rem ; tableau du planning défilant horizontalement |

La structure `header.entete > nav > ul.menu` est la même dans les deux cas, seul le CSS change.

**Icônes du menu** : SVG écrits directement dans `index.html` (`.menu__icone`, `aria-hidden="true"`), trait en `currentColor` (elles suivent l'état actif). Le texte (`.menu__texte`) est **toujours visible** : à droite de l'icône sur ordinateur, en dessous sur mobile. Aucune bibliothèque d'icônes.

## 6. À ne pas faire

- Coder une couleur, une taille ou un espacement en dur hors de `tokens.css`.
- Mettre du texte blanc sur `--tomate`, ou du texte `--tomate` (non foncé) sur papier.
- Utiliser `--beurre` pour autre chose que les prix et le jour courant.
- Charger une police, une icône ou une feuille de style depuis Internet.
- Ajouter un framework CSS, un préprocesseur ou une étape de build.
- Utiliser `innerHTML` pour construire un composant.
- Ajouter un second point de rupture.

## 7. Point à trancher

**Sélecteur de recette du planning.** La décision D4 prévoit un **menu déroulant natif** par créneau ; le prototype montre un sélecteur plus riche (recherche, vignettes). Pour le MVP, on **stylise le `<select>` natif**, conformément à D4. Le sélecteur riche est noté comme amélioration possible, non implémentée.
