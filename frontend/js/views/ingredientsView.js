// Écran Ingrédients (F0, lecture seule) — à venir.
import { el } from '../dom.js';

export function afficher(conteneur) {
    conteneur.append(
        el('h1', {}, 'Ingrédients'),
        el('p', { class: 'a-venir' }, 'Fonctionnalité à venir.'),
    );
}
