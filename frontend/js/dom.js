// Helpers DOM : tout passe par createElement / textContent, jamais innerHTML (XSS).

const PROPRIETES_INTERDITES = new Set(['innerHTML', 'outerHTML']);

/**
 * Crée un élément.
 * el('a', { href: '#/recettes', class: 'bouton' }, 'Catalogue')
 * - attributs : class, dataset (objet), onXxx (fonction → écouteur), booléens, sinon setAttribute
 * - enfants : Node, texte (→ nœud texte), tableaux ; null / undefined / false sont ignorés
 */
export function el(tag, attributs = {}, ...enfants) {
    const element = document.createElement(tag);

    for (const [nom, valeur] of Object.entries(attributs ?? {})) {
        if (PROPRIETES_INTERDITES.has(nom)) {
            throw new Error(`el() : « ${nom} » est interdit, utiliser des enfants texte.`);
        }
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
        } else if ((nom === 'href' || nom === 'src') && /^\s*javascript:/i.test(String(valeur))) {
            throw new Error(`el() : URL « javascript: » interdite dans « ${nom} ».`);
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
    conteneur.querySelectorAll('.bandeau-erreur, .erreur-champ').forEach((noeud) => noeud.remove());
    conteneur.querySelectorAll('[aria-invalid="true"]').forEach((champ) => {
        champ.removeAttribute('aria-invalid');
        champ.removeAttribute('aria-describedby');
    });
}

/**
 * Affiche un bandeau d'erreurs globales en haut du conteneur.
 * erreurs : { champ: message } (format de l'API)
 */
export function afficherErreurs(conteneur, erreurs) {
    conteneur.querySelectorAll(':scope > .bandeau-erreur').forEach((noeud) => noeud.remove());

    const messages = Object.values(erreurs ?? {}).map(String);
    if (messages.length === 0) {
        return;
    }

    const bandeau = el('div', { class: 'bandeau-erreur', role: 'alert' },
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

        const idMessage = `erreur-${nom}`;
        champ.setAttribute('aria-invalid', 'true');
        champ.setAttribute('aria-describedby', idMessage);
        champ.after(el('p', { class: 'erreur-champ', id: idMessage }, String(message)));
    }

    afficherErreurs(formulaire, sansChamp);
}

/**
 * Centimes entiers → « 12,34 € ».
 * Valeur non entière : arrondie une seule fois ici. null / non numérique : « — ».
 */
export function formatEuros(centimes) {
    if (typeof centimes !== 'number' || !Number.isFinite(centimes)) {
        return '—';
    }
    const arrondi = Math.round(centimes);
    const signe = arrondi < 0 ? '-' : '';
    const absolu = Math.abs(arrondi);
    const euros = Math.trunc(absolu / 100);
    const reste = String(absolu % 100).padStart(2, '0');
    return `${signe}${euros},${reste} €`;
}
