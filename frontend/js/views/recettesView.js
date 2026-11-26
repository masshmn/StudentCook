// Écran Catalogue (F1/F2) — à venir.
import { el } from '../dom.js';

export function afficher(conteneur) {
    conteneur.append(
        el('h1', {}, 'Catalogue de recettes'),
        el('p', { class: 'a-venir' }, 'Fonctionnalité à venir.'),
        el('a', { class: 'bouton', href: '#/recettes/nouvelle' }, 'Nouvelle recette'),
    );
}
