// Helpers DOM : tout passe par createElement / textContent, jamais innerHTML (XSS).

// Attributs qui contiennent une URL : seuls #, chemins relatifs, http(s) et mailto sont acceptés.
const ATTRIBUTS_URL = new Set(['href', 'src', 'action', 'formaction', 'xlink:href']);
const SCHEMAS_AUTORISES = /^(https?|mailto):/i;
const AVEC_SCHEMA = /^[a-z][a-z0-9+.-]*:/i;

/** Faux pour « javascript: », « data: »… y compris déguisés (« java\tscript: ») */
function urlSure(valeur) {
    // Le navigateur ignore espaces et caractères de contrôle dans un schéma : on les retire aussi.
    const nettoyee = String(valeur).replace(/[\u0000-\u0020\u007F]/g, '');
    return !AVEC_SCHEMA.test(nettoyee) || SCHEMAS_AUTORISES.test(nettoyee);
}

const PREFIXE_ERREUR = 'erreur-';

/**
 * Crée un élément.
 * el('a', { href: '#/recettes', class: 'bouton' }, 'Catalogue')
 * - attributs : class, dataset (objet), onXxx (fonction → écouteur), booléens, sinon setAttribute
 * - enfants : Node, texte (→ nœud texte), tableaux ; null / undefined / false sont ignorés
 */
export function el(tag, attributs = {}, ...enfants) {
    const element = document.createElement(tag);

    for (const [nom, valeur] of Object.entries(attributs ?? {})) {
        if (valeur === null || valeur === undefined || valeur === false) {
            continue;
        }
        if (nom === 'class') {
            element.className = valeur;
        } else if (nom === 'dataset') {
            Object.assign(element.dataset, valeur);
        } else if (nom.startsWith('on')) {
            // Un écouteur doit être une fonction : un texte serait du JS inline exécuté.
            if (typeof valeur !== 'function') {
                throw new Error(`el() : « ${nom} » doit être une fonction.`);
            }
            element.addEventListener(nom.slice(2).toLowerCase(), valeur);
        } else if (ATTRIBUTS_URL.has(nom) && !urlSure(valeur)) {
            throw new Error(`el() : URL interdite dans « ${nom} » (seuls #, /, http(s) et mailto).`);
        } else if (valeur === true) {
            element.setAttribute(nom, '');
        } else {
            element.setAttribute(nom, String(valeur));
        }
    }

    ajouterEnfants(element, enfants);
    return element;
}

function ajouterEnfants(parent, enfants) {
    for (const enfant of enfants) {
        if (enfant === null || enfant === undefined || enfant === false) {
            continue;
        }
        if (Array.isArray(enfant)) {
            ajouterEnfants(parent, enfant);
        } else if (enfant instanceof Node) {
            parent.append(enfant);
        } else {
            parent.append(document.createTextNode(String(enfant)));
        }
    }
}

/** Vide un conteneur sans innerHTML. */
export function vider(conteneur) {
    conteneur.replaceChildren();
}

/** Retire bandeau d'erreurs et messages sous les champs. */
export function viderErreurs(conteneur) {
    conteneur.querySelectorAll('.notification--erreur, .erreur-champ').forEach((noeud) => noeud.remove());
    conteneur.querySelectorAll('[aria-invalid="true"]').forEach((champ) => {
        champ.removeAttribute('aria-invalid');
        // On ne retire que l'id ajouté par afficherErreursChamps (une aide du gabarit reste liée).
        const restants = (champ.getAttribute('aria-describedby') ?? '')
            .split(/\s+/)
            .filter((id) => id !== '' && !id.startsWith(PREFIXE_ERREUR));
        if (restants.length > 0) {
            champ.setAttribute('aria-describedby', restants.join(' '));
        } else {
            champ.removeAttribute('aria-describedby');
        }
    });
}

/**
 * Affiche un bandeau d'erreurs globales en haut du conteneur.
 * erreurs : { champ: message } (format de l'API)
 */
export function afficherErreurs(conteneur, erreurs) {
    conteneur.querySelectorAll(':scope > .notification--erreur').forEach((noeud) => noeud.remove());

    const messages = Object.values(erreurs ?? {}).map(String);
    if (messages.length === 0) {
        return;
    }

    const bandeau = el('div', { class: 'notification notification--erreur', role: 'alert' },
        messages.length === 1
            ? el('p', {}, messages[0])
            : el('ul', {}, messages.map((message) => el('li', {}, message))),
    );
    conteneur.prepend(bandeau);
}

/**
 * Affiche chaque erreur sous le champ de même `name` dans le formulaire.
 * Les erreurs sans champ correspondant vont dans le bandeau du formulaire.
 */
export function afficherErreursChamps(formulaire, erreurs) {
    viderErreurs(formulaire);
    const sansChamp = {};

    for (const [nom, message] of Object.entries(erreurs ?? {})) {
        let champ = formulaire.elements.namedItem(nom);
        if (champ instanceof RadioNodeList) {
            champ = champ[0] ?? null;
        }
        if (!(champ instanceof HTMLElement)) {
            sansChamp[nom] = message;
            continue;
        }

        const idMessage = `${PREFIXE_ERREUR}${nom}`;
        const aideExistante = champ.getAttribute('aria-describedby');
        champ.setAttribute('aria-invalid', 'true');
        champ.setAttribute('aria-describedby', aideExistante ? `${aideExistante} ${idMessage}` : idMessage);
        champ.after(el('p', { class: 'erreur-champ', id: idMessage }, String(message)));
    }

    afficherErreurs(formulaire, sansChamp);
}

const FORMAT_EUROS = new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' });

/**
 * Centimes entiers → « 12,34 € » (espaces insécables, comme le veut fr-FR).
 * Valeur non entière : arrondie une seule fois ici. null / non numérique : « — ».
 */
export function formatEuros(centimes) {
    if (typeof centimes !== 'number' || !Number.isFinite(centimes)) {
        return '—';
    }
    return FORMAT_EUROS.format(Math.round(centimes) / 100);
}
