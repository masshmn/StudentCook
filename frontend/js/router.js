// Routeur par hash : #/recettes, #/recettes/12… Affiche la vue sans rechargement.
import { afficherErreurs, vider } from './dom.js';

const ENTIER_POSITIF = /^[1-9][0-9]*$/;

/** « #/recettes/12/ » → ['recettes', '12'] ; null si l'encodage est invalide. */
function lireSegments(hash) {
    const chemin = hash.replace(/^#\/?/, '').replace(/\/+$/, '');
    if (chemin === '') {
        return [];
    }
    try {
        return chemin.split('/').map(decodeURIComponent);
    } catch {
        return null; // ex. « #/%E0 »
    }
}

/** Compare les segments à un motif (« recettes/:id ») ; renvoie les paramètres ou null. */
function correspondre(motif, segments) {
    const parties = motif.split('/');
    if (parties.length !== segments.length) {
        return null;
    }
    const params = {};
    for (let i = 0; i < parties.length; i++) {
        if (parties[i] === ':id') {
            const id = Number(segments[i]);
            if (!ENTIER_POSITIF.test(segments[i]) || !Number.isSafeInteger(id)) {
                return null;
            }
            params.id = id;
        } else if (parties[i] !== segments[i]) {
            return null;
        }
    }
    return params;
}

/** Allume le lien du menu dont le premier segment correspond (null = aucun). */
function marquerLienActif(premierSegment) {
    document.querySelectorAll('nav a[href^="#/"]').forEach((lien) => {
        const segmentLien = lien.getAttribute('href').replace(/^#\//, '').split('/')[0];
        const actif = premierSegment !== null && segmentLien === premierSegment;
        lien.classList.toggle('actif', actif);
        if (actif) {
            lien.setAttribute('aria-current', 'page');
        } else {
            lien.removeAttribute('aria-current');
        }
    });
}

/**
 * routes : [{ motif: 'recettes/:id', vue: { afficher(conteneur, params) } }]
 * routeParDefaut : cible quand le hash est vide (« / » ou « #/ »)
 */
export function demarrerRouteur({ conteneur, routes, vueIntrouvable, routeParDefaut }) {
    async function naviguer() {
        const segments = lireSegments(location.hash);

        if (segments !== null && segments.length === 0) {
            // replace : pas d'entrée parasite dans l'historique ; déclenche hashchange.
            location.replace(`#/${routeParDefaut}`);
            return;
        }

        let vue = vueIntrouvable;
        let params = {};
        if (segments !== null) {
            for (const route of routes) {
                const trouve = correspondre(route.motif, segments);
                if (trouve !== null) {
                    vue = route.vue;
                    params = trouve;
                    break;
                }
            }
        }

        // Page introuvable : aucun lien allumé.
        marquerLienActif(vue === vueIntrouvable ? null : segments[0]);
        vider(conteneur);
        window.scrollTo(0, 0);

        try {
            await vue.afficher(conteneur, params);
        } catch (erreur) {
            console.error(erreur);
            afficherErreurs(conteneur, { vue: "Impossible d'afficher cet écran." });
        }
    }

    window.addEventListener('hashchange', naviguer);
    naviguer();
}
