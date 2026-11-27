// Seul fichier du front autorisé à appeler fetch.

const PREFIXE = '/api';

/** Erreur d'appel à l'API : le front affiche `erreurs` tel quel (format { champ: message }). */
export class ApiError extends Error {
    /**
     * @param {number} status code HTTP, 0 si le serveur est injoignable
     * @param {Record<string, string>} erreurs
     */
    constructor(status, erreurs) {
        super(Object.values(erreurs).join(' '));
        this.name = 'ApiError';
        this.status = status;
        this.erreurs = erreurs;
    }
}

const ERREUR_RESEAU = { reseau: 'Serveur injoignable.' };
const ERREUR_SERVEUR = { serveur: 'Erreur du serveur, réessayez.' };

function estObjetErreurs(valeur) {
    return typeof valeur === 'object' && valeur !== null && !Array.isArray(valeur)
        && Object.keys(valeur).length > 0;
}

async function requete(methode, chemin, corps) {
    const options = { method: methode, headers: { Accept: 'application/json' } };
    if (corps !== undefined) {
        options.headers['Content-Type'] = 'application/json';
        options.body = JSON.stringify(corps);
    }

    let reponse;
    try {
        reponse = await fetch(PREFIXE + chemin, options);
    } catch {
        throw new ApiError(0, ERREUR_RESEAU);
    }

    if (reponse.status === 204) {
        return null;
    }

    let donnees;
    try {
        donnees = await reponse.json();
    } catch {
        // Réponse vide ou non JSON (page HTML, erreur PHP…)
        throw new ApiError(reponse.status, ERREUR_SERVEUR);
    }

    if (reponse.ok) {
        return donnees;
    }

    const erreurs = estObjetErreurs(donnees?.erreurs) ? donnees.erreurs : ERREUR_SERVEUR;
    throw new ApiError(reponse.status, erreurs);
}

// Renvoient le JSON (null si 204) ou lèvent une ApiError. chemin sans /api : '/recipes/12'.

/** @param {string} chemin @returns {Promise<unknown>} */
export const get = (chemin) => requete('GET', chemin);
/** @param {string} chemin @param {object} [corps] @returns {Promise<unknown>} */
export const post = (chemin, corps) => requete('POST', chemin, corps ?? {});
/** @param {string} chemin @param {object} [corps] @returns {Promise<unknown>} */
export const put = (chemin, corps) => requete('PUT', chemin, corps ?? {});
/** @param {string} chemin @returns {Promise<unknown>} */
export const supprimer = (chemin) => requete('DELETE', chemin);
