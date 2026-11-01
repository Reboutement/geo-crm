# Deploiement du CRM Geo Engineering sur Coolify

Stack independante du projet FRB : base, Redis, volumes et domaine propres.

## 1. Preparer geo_leads
Poussez le dossier `geo_leads` dans un depot git accessible (prive ou public), puis remplacez `VOTRE-ORGANISATION` dans `apps.json`. Pour un depot prive, utilisez une URL avec jeton de lecture.

## 2. Construire l'image
```bash
IMAGE=ghcr.io/votre-organisation/geo-crm TAG=v1 ./build.sh
```
Connectez-vous d'abord au registre (`docker login ghcr.io`).

## 3. Creer la ressource dans Coolify
1. Nouveau projet « Geo CRM », ressource **Docker Compose** (collez `docker-compose.yml`).
2. Variables d'environnement : reprenez `.env.example` avec de vrais mots de passe.
3. Domaine : affectez `https://crm.votre-domaine.fr` au service **frontend** sur le port **8080**.
4. Declenchez le deploiement. Le service `create-site` cree le site et installe `crm` et `geo_leads` au premier demarrage.
5. Connexion : utilisateur `Administrator`, mot de passe `ADMIN_PASSWORD`.

## 4. Brancher la landing
Dans `index.html`, renseignez :
```js
endpoint: 'https://crm.votre-domaine.fr/api/method/geo_leads.api.create_lead'
```
`ALLOW_CORS` doit contenir l'adresse exacte du site qui heberge la landing.

## 5. Apres le deploiement
- Creez vos commerciaux comme utilisateurs, puis une **Assignment Rule** (Round Robin) sur `CRM Lead`.
- Activez les sauvegardes planifiees de la base `db` dans Coolify et testez une restauration.
- Mises a jour : reconstruisez l'image avec un nouveau `TAG`, changez `CUSTOM_TAG`, redeployez, puis `bench --site <site> migrate`.

## Points a verifier
Ce fichier suit la structure de frappe_docker (pwd.yml) et n'a pas ete execute ici. Controlez les versions d'images, la branche de `crm` compatible avec Frappe v15, et que `ALLOW_CORS` est bien ecrit dans `site_config.json` apres creation du site.

## Sans registre : construire l'image avec GitHub Actions

1. Créez un dépôt GitHub (ex. `geo-crm`) contenant ce dossier (`apps.json`, `docker-compose.yml`, `.github/workflows/build.yml`).
2. Vérifiez dans `apps.json` que l'adresse de `geo_leads` est la bonne.
3. Si `geo_leads` est privé : Settings > Secrets > Actions > ajoutez `GEO_LEADS_TOKEN` (jeton en lecture seule).
4. Onglet Actions > « Build image Geo CRM » > Run workflow (tag `v1`).
5. L'image est publiée sur `ghcr.io/<votre-compte>/geo-crm:v1`. Si le paquet est privé, ajoutez ce registre dans Coolify (Sources > Container registries, identifiant GitHub + jeton `read:packages`), ou rendez le paquet public.
6. Dans Coolify : `CUSTOM_IMAGE=ghcr.io/<votre-compte>/geo-crm`, `CUSTOM_TAG=v1`.
