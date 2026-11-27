import { el } from '../dom.js';

/** @param {HTMLElement} conteneur */
export function afficher(conteneur) {
    conteneur.append(
        el('h1', {}, 'Catalogue de recettes'),
        el('p', { class: 'a-venir' }, 'Fonctionnalité à venir.'),
        el('a', { class: 'bouton', href: '#/recettes/nouvelle' }, 'Nouvelle recette'),
    );
}
