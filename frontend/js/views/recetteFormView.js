// Formulaire de création (#/recettes/nouvelle) ou de modification (#/recettes/{id}/modifier) — à venir.
import { el } from '../dom.js';

/**
 * @param {HTMLElement} conteneur
 * @param {{ id?: number }} params paramètres de l'URL (id absent pour une création)
 */
export function afficher(conteneur, params) {
    const titre = params.id === undefined ? 'Nouvelle recette' : `Modifier la recette n° ${params.id}`;
    conteneur.append(
        el('h1', {}, titre),
        el('p', { class: 'a-venir' }, 'Fonctionnalité à venir.'),
        el('a', { href: '#/recettes' }, '← Retour au catalogue'),
    );
}
