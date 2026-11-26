// Écran Planning (F3) — à venir.
import { el } from '../dom.js';

export function afficher(conteneur) {
    conteneur.append(
        el('h1', {}, 'Planning des repas'),
        el('p', { class: 'a-venir' }, 'Fonctionnalité à venir.'),
    );
}
