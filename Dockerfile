FROM php:8.3-cli

# pdo_sqlite est déjà compilé dans l'image officielle : aucune extension à installer.
ENV TZ=Europe/Paris

WORKDIR /app
COPY backend/ backend/
COPY frontend/ frontend/
COPY database/ database/

# Dossier du fichier SQLite, monté en volume par docker-compose.yml.
RUN mkdir -p database/data

EXPOSE 8000

# Si l'initialisation de la base échoue (ou si init.php manque), le conteneur s'arrête.
CMD ["sh", "-c", "php database/init.php || { echo 'ERREUR : initialisation de la base impossible, arrêt du conteneur.' >&2; exit 1; }; exec php -S 0.0.0.0:8000 -t backend/public backend/public/index.php"]
