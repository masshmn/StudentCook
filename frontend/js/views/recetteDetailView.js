import { el } from '../dom.js';

/**
 * @param {HTMLElement} conteneur
 * @param {{ id: number }} params id de la recette, déjà validé par le routeur
 */
export function afficher(conteneur, params) {
    conteneur.append(
        el('h1', {}, `Recette n° ${params.id}`),
        el('p', { class: 'a-venir' }, 'Fonctionnalité à venir.'),
        el('a', { href: '#/recettes' }, '← Retour au catalogue'),
    );
}
