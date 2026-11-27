// Écran Liste de courses (F4) — à venir.
import { el } from '../dom.js';

export function afficher(conteneur) {
    conteneur.append(
        el('h1', {}, 'Liste de courses'),
        el('p', { class: 'a-venir' }, 'Fonctionnalité à venir.'),
    );
}
