import { get } from '../api.js';
import { el, formatEuros } from '../dom.js';

// data-regime correspond aux couleurs de composants.css.
const REGIMES = [
    { champ: 'is_vegetarian', regime: 'vegetarien', libelle: 'Végétarien' },
    { champ: 'is_vegan', regime: 'vegan', libelle: 'Végan' },
    { champ: 'is_gluten_free', regime: 'sans-gluten', libelle: 'Sans gluten' },
    { champ: 'is_halal', regime: 'halal', libelle: 'Halal' },
];

/**
 * Badges des régimes cochés (aussi utilisés par l'écran détail).
 * @param {Record<string, unknown>} recette
 * @returns {HTMLElement[]}
 */
export function pucesRegimes(recette) {
    return REGIMES
        .filter(({ champ }) => recette[champ] === true)
        .map(({ regime, libelle }) => el('span', { class: 'puce', dataset: { regime } }, libelle));
}

/**
 * « 15 min · 2 portions »
 * @param {{ prep_time: number, servings: number }} recette
 * @returns {string}
 */
export function resumeRecette(recette) {
    const portions = recette.servings > 1 ? 'portions' : 'portion';
    return `${recette.prep_time} min · ${recette.servings} ${portions}`;
}

function ligneRecette(recette) {
    return el('li', { class: 'ligne-recette' },
        el('span', { class: 'assiette', 'aria-hidden': 'true' }, recette.name.charAt(0).toUpperCase()),
        el('div', { class: 'ligne-recette__corps' },
            el('h2', { class: 'ligne-recette__nom' },
                el('a', { href: `#/recettes/${recette.id}` }, recette.name),
            ),
            el('div', { class: 'ligne-recette__meta' },
                el('span', {}, resumeRecette(recette)),
                pucesRegimes(recette),
            ),
        ),
        el('div', { class: 'ligne-recette__prix' },
            el('span', { class: 'prix' }, formatEuros(recette.cost_per_serving_cents)),
            el('small', {}, 'par portion'),
        ),
    );
}

/** @param {HTMLElement} conteneur */
export async function afficher(conteneur) {
    const recettes = await get('/recipes');

    conteneur.append(
        el('h1', {}, 'Catalogue de recettes'),
        el('a', { class: 'bouton bouton--tomate', href: '#/recettes/nouvelle' }, 'Nouvelle recette'),
    );

    if (recettes.length === 0) {
        conteneur.append(el('div', { class: 'etat-vide' }, el('p', {}, 'Aucune recette pour le moment.')));
        return;
    }

    conteneur.append(el('ul', { class: 'liste-recettes' }, recettes.map(ligneRecette)));
}
