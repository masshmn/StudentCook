import { el } from '../dom.js';

/** @param {HTMLElement} conteneur */
export function afficher(conteneur) {
    conteneur.append(
        el('h1', {}, 'Liste de courses'),
        el('p', { class: 'a-venir' }, 'Fonctionnalité à venir.'),
    );
}
