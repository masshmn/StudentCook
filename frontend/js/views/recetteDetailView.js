// Écran détail d'une recette (F1) — à venir.
import { el } from '../dom.js';

export function afficher(conteneur, params) {
    conteneur.append(
        el('h1', {}, `Recette n° ${params.id}`),
        el('p', { class: 'a-venir' }, 'Fonctionnalité à venir.'),
        el('a', { href: '#/recettes' }, '← Retour au catalogue'),
    );
}
