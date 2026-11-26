// Point d'entrée : déclare les routes et démarre le routeur.
import { demarrerRouteur } from './router.js';
import * as recettesView from './views/recettesView.js';
import * as recetteDetailView from './views/recetteDetailView.js';
import * as recetteFormView from './views/recetteFormView.js';
import * as planningView from './views/planningView.js';
import * as coursesView from './views/coursesView.js';
import * as ingredientsView from './views/ingredientsView.js';
import * as introuvableView from './views/introuvableView.js';

const routes = [
    { motif: 'recettes', vue: recettesView },
    { motif: 'recettes/nouvelle', vue: recetteFormView },
    { motif: 'recettes/:id', vue: recetteDetailView },
    { motif: 'recettes/:id/modifier', vue: recetteFormView },
    { motif: 'planning', vue: planningView },
    { motif: 'courses', vue: coursesView },
    { motif: 'ingredients', vue: ingredientsView },
];

demarrerRouteur({
    conteneur: document.getElementById('app'),
    routes,
    vueIntrouvable: introuvableView,
    routeParDefaut: 'recettes',
});
