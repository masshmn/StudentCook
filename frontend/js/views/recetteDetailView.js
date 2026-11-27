import { get, ApiError } from '../api.js';
import { el, formatEuros, afficherErreurs } from '../dom.js';
import { pucesRegimes, resumeRecette } from './recettesView.js';

// Quantités stockées en g (kg), mL (L) ou nombre de pièces (unité) : décision D5.
function formatQuantite({ unit, quantity }) {
    if (unit === 'kg') {
        return `${quantity} g`;
    }
    if (unit === 'L') {
        return `${quantity} mL`;
    }
    return `${quantity} ${quantity > 1 ? 'pièces' : 'pièce'}`;
}

const lienRetour = () => el('a', { href: '#/recettes' }, '← Retour au catalogue');

/**
 * @param {HTMLElement} conteneur
 * @param {{ id: number }} params id de la recette, déjà validé par le routeur
 */
export async function afficher(conteneur, params) {
    let recette;
    try {
        recette = await get(`/recipes/${params.id}`);
    } catch (erreur) {
        // Id inexistant : on affiche le message de l'API (« Recette introuvable. »).
        if (erreur instanceof ApiError && erreur.status === 404) {
            conteneur.append(el('h1', {}, 'Recette introuvable'), lienRetour());
            afficherErreurs(conteneur, erreur.erreurs);
            return;
        }
        throw erreur;
    }

    conteneur.append(
        lienRetour(),
        el('h1', {}, recette.name),
        el('p', {}, resumeRecette(recette)),
        el('div', { class: 'liste-puces' }, pucesRegimes(recette)),
        el('p', {}, el('span', { class: 'prix' }, formatEuros(recette.cost_per_serving_cents)), ' par portion'),
        el('section', { class: 'boite' },
            el('h2', {}, 'Ingrédients'),
            el('ul', {}, recette.ingredients.map((ingredient) =>
                el('li', {}, `${ingredient.name} — ${formatQuantite(ingredient)}`),
            )),
        ),
        el('section', { class: 'boite' },
            el('h2', {}, 'Étapes'),
            el('ol', {}, recette.steps.map((etape) => el('li', {}, etape.description))),
        ),
    );
}
