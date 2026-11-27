// F0 : consultation seule du référentiel, aucun bouton créer / modifier / supprimer.
import { get, ApiError } from '../api.js';
import { el, afficherErreurs, formatEuros } from '../dom.js';

const COMPARER_NOMS = new Intl.Collator('fr').compare;

// Même point de rupture que le CSS (760 px, voir tokens.css) : cartes repliées sur mobile.
const ECRAN_MOBILE = '(max-width: 760px)';

/** 1 → « 1 ingrédient », 3 → « 3 ingrédients » */
function compterIngredients(nombre) {
    return `${nombre} ingrédient${nombre > 1 ? 's' : ''}`;
}

/**
 * Regroupe par rayon en gardant l'ordre des rayons de l'API (SPEC, pas alphabétique).
 * Les noms sont re-triés en français : SQLite compare les octets (« Œufs » après « Yaourt »).
 */
function grouperParRayon(ingredients) {
    const rayons = new Map();
    for (const ingredient of ingredients) {
        if (!rayons.has(ingredient.aisle)) {
            rayons.set(ingredient.aisle, []);
        }
        rayons.get(ingredient.aisle).push(ingredient);
    }
    for (const ingredientsDuRayon of rayons.values()) {
        ingredientsDuRayon.sort((a, b) => COMPARER_NOMS(a.name, b.name));
    }
    return rayons;
}

function creerLigne(ingredient) {
    return el('tr', {},
        el('th', { scope: 'row' }, ingredient.name),
        el('td', { class: 'tableau__nombre' }, `${formatEuros(ingredient.price_per_unit)} / ${ingredient.unit}`),
    );
}

// <details> natif : repliable au clic et au clavier, sans JS ni ARIA à gérer.
function creerCarteRayon(rayon, ingredients, idTitre, ouverte) {
    // data-rayon = valeur exacte de la base : la couleur de la pastille vient du CSS.
    return el('section', { class: 'boite', dataset: { rayon }, 'aria-labelledby': idTitre },
        el('details', { open: ouverte },
            el('summary', { class: 'carte-rayon__entete' },
                el('h2', { class: 'carte-rayon__titre', id: idTitre },
                    el('span', { class: 'pastille-rayon', 'aria-hidden': 'true' }),
                    rayon,
                ),
                el('span', { class: 'carte-rayon__compteur' }, compterIngredients(ingredients.length)),
            ),
            el('table', { class: 'tableau', 'aria-labelledby': idTitre },
                el('thead', {},
                    el('tr', {},
                        el('th', { scope: 'col' }, 'Nom'),
                        el('th', { scope: 'col', class: 'tableau__nombre' }, 'Prix'),
                    ),
                ),
                el('tbody', {}, ingredients.map(creerLigne)),
            ),
        ),
    );
}

/** @param {HTMLElement} conteneur */
export async function afficher(conteneur) {
    const titre = el('h1', {}, 'Ingrédients');
    conteneur.append(titre);

    let ingredients;
    try {
        ingredients = await get('/ingredients');
    } catch (erreur) {
        if (!(erreur instanceof ApiError)) {
            throw erreur;
        }
        afficherErreurs(conteneur, erreur.erreurs);
        return;
    }

    if (!Array.isArray(ingredients) || ingredients.length === 0) {
        conteneur.append(el('div', { class: 'etat-vide' },
            el('p', {}, 'Aucun ingrédient dans le référentiel.'),
        ));
        return;
    }

    titre.after(el('p', { class: 'sous-titre' },
        `${compterIngredients(ingredients.length)} · référentiel fixe, consultation uniquement`,
    ));

    // Ordinateur : tout est visible d'un coup d'œil. Mobile : les en-têtes tiennent sur un écran.
    // État fixé à l'affichage, pas suivi au redimensionnement (l'utilisateur garde la main).
    const ouvertes = !window.matchMedia(ECRAN_MOBILE).matches;
    const grille = el('div', { class: 'grille-rayons' });
    let index = 0;
    for (const [rayon, ingredientsDuRayon] of grouperParRayon(ingredients)) {
        index += 1;
        grille.append(creerCarteRayon(rayon, ingredientsDuRayon, `titre-rayon-${index}`, ouvertes));
    }
    conteneur.append(grille);
}
