// Écran « Page introuvable » pour tout hash qui ne correspond à aucune route.
import { el } from '../dom.js';

export function afficher(conteneur) {
    conteneur.append(
        el('h1', {}, 'Page introuvable'),
        // location.hash vient de l'URL : affiché en texte uniquement (textContent).
        el('p', {}, `Aucun écran ne correspond à l'adresse « ${location.hash} ».`),
        el('a', { class: 'bouton', href: '#/recettes' }, 'Retour au catalogue'),
    );
}
