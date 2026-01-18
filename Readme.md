# TP Optimisation Docker

## Informations
- **Étudiant** : BAI YUEJIE
- **Formation** : Master 2 MIAGE IPM
- **Date** : Janvier 2025

## Objectif

Ce projet consiste à optimiser une application Node.js et son image Docker. L'objectif est de réduire la taille de l'image et d'appliquer les bonnes pratiques.

## Resultats

### Tableau des optimisations

| Etape | Description | Taille | Reduction |
|-------|-------------|--------|-----------|
| Baseline | Version initiale | 1.72 GB | - |

## Analyse de la version baseline

### Dockerfile initial

```dockerfile
FROM node:latest
WORKDIR /app
COPY node_modules ./node_modules
COPY . /app
RUN npm install
RUN apt-get update && apt-get install -y build-essential ca-certificates locales
EXPOSE 3000 4000 5000
ENV NODE_ENV=development
RUN npm run build
USER root
CMD ["node", "server.js"]
```

### Problemes identifies

**1. Image de base trop grande**
- `node:latest` utilise Debian complet (environ 1GB)
- Pas de version specifique

**2. Copie inefficace**
- node_modules est copie puis reinstalle
- Tous les fichiers sont copies sans filtre

**3. Packages inutiles**
- build-essential: 300+ MB non necessaires
- locales: pas utilise dans l'application

**4. Configuration**
- NODE_ENV=development au lieu de production
- 3 ports exposes mais seulement 1 utilise

**5. Securite**
- Execution en root

**6. Pas de .dockerignore**
- Le build context inclut tout

Taille initiale: **1.72 GB**

### Construction de l'image baseline

**Commande:**
```bash
docker build -t node-app:baseline .
```

**Resultat:**
```
[+] Building 24.3s (13/13) FINISHED                        docker:desktop-linux
 => [internal] load build definition from dockerfile                       0.0s
 => => transferring dockerfile: 371B                                       0.0s
 => [internal] load metadata for docker.io/library/node:latest             1.6s
 => [auth] library/node:pull token for registry-1.docker.io                0.0s
 => [internal] load .dockerignore                                          0.0s
 => => transferring context: 2B                                            0.0s
 => [1/7] FROM docker.io/library/node:latest@sha256:a2f09f3ab9217c692a4e  15.7s
 => => resolve docker.io/library/node:latest@sha256:a2f09f3ab9217c692a4e1  0.0s
 => => sha256:2a212c016bb275b3de38a9a4eec698bfea19ddad036d42c 447B / 447B  0.3s
 => => sha256:b91d2b90b08db99b772944f9722cc06c9f4c9a00742 1.25MB / 1.25MB  0.5s
 => => sha256:d870503b198db5d938feb962b9cf288da637b5246 56.53MB / 56.53MB  3.0s
 => => sha256:56d64d6bb217d8aa988a54744b991ba8e11cbe87ade 3.32kB / 3.32kB  0.5s
 => => sha256:f018151ab3f36e399ef489b536713197af8faa 203.01MB / 203.01MB  12.1s
 => => sha256:687ad46596f06c934001fa6d7bea3d1508b0bb61 64.48MB / 64.48MB  10.4s
 => => sha256:d72c713ab317dd7f302a6ff5a345af5b61cddc864 23.60MB / 23.60MB  2.8s
 => => sha256:1029f5ddc0d24726f1cefbb8def7a88f8ec819a1f 48.37MB / 48.37MB  2.5s
 => => extracting sha256:1029f5ddc0d24726f1cefbb8def7a88f8ec819a1fdc4c05c  0.7s
 => => extracting sha256:d72c713ab317dd7f302a6ff5a345af5b61cddc864fca2d96  0.2s
 => => extracting sha256:687ad46596f06c934001fa6d7bea3d1508b0bb616cffb710  0.8s
 => => extracting sha256:f018151ab3f36e399ef489b536713197af8faa14dce771cb  2.4s
 => => extracting sha256:56d64d6bb217d8aa988a54744b991ba8e11cbe87ade61195  0.0s
 => => extracting sha256:d870503b198db5d938feb962b9cf288da637b52461d1cdd1  0.8s
 => => extracting sha256:b91d2b90b08db99b772944f9722cc06c9f4c9a007425aae6  0.0s
 => => extracting sha256:2a212c016bb275b3de38a9a4eec698bfea19ddad036d42ca  0.0s
 => [internal] load build context                                          0.2s
 => => transferring context: 13.65MB                                       0.2s
 => [2/7] WORKDIR /app                                                     0.5s
 => [3/7] COPY node_modules ./node_modules                                 0.1s
 => [4/7] COPY . /app                                                      0.3s
 => [5/7] RUN npm install                                                  0.9s
 => [6/7] RUN apt-get update && apt-get install -y build-essential ca-cer  3.5s
 => [7/7] RUN npm run build                                                0.2s
 => exporting to image                                                     1.5s
 => => exporting layers                                                    1.1s
 => => exporting manifest sha256:5461aa024e5cb095b8749f50bf00610edae7c2c6  0.0s
 => => exporting config sha256:25eced597ef71c061f08b6880059d9e56f03351559  0.0s
 => => exporting attestation manifest sha256:c53fc655b3d05ef2e7a40aefdd14  0.0s
 => => exporting manifest list sha256:9aa186ba84eccd0594f475ac9c44367d231  0.0s
 => => naming to docker.io/library/node-app:baseline                       0.0s
 => => unpacking to docker.io/library/node-app:baseline                    0.4s

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/4xwk40wl6es9oyfim692tu8ww
```

**Explication :** Cette commande construit une image Docker a partir du Dockerfile present dans le dossier courant (.). L'option -t permet de donner un nom (node-app) et un tag (baseline) a l'image.

**Verification de la taille:**
```bash
docker images node-app
```

**Resultat:**
```
REPOSITORY   TAG        IMAGE ID       CREATED         SIZE
node-app     baseline   9aa186ba84ec   8 minutes ago   1.72GB
```

## Test de l'application

**Commande:**
```bash
docker run -d -p 3000:3000 --name test-baseline node-app:baseline
```

**Resultat:**
```
9d626b86f382059078bccf02f394711ee65833987e7f2a825141abe2bef5054d
```

**Explication :** Lance un conteneur en arriere-plan (-d) a partir de l'image node-app:baseline. L'option -p 3000:3000 mappe le port 3000 du conteneur vers le port 3000 de la machine hote. Le conteneur est nomme test-baseline.

**Commande:**
```bash
curl http://localhost:3000
```

**Resultat:**
![test-baseline](test-baseline.png)

**Explication :** Teste si l'application repond correctement en envoyant une requete HTTP au serveur qui tourne dans le conteneur.

**Commande:**
```bash
docker stop test-baseline && docker rm test-baseline
```

**Resultat:**
```
test-baseline
test-baseline
```

**Explication :** Arrete le conteneur test-baseline puis le supprime pour liberer les ressources.

L'application fonctionne correctement mais l'image est tres volumineuse.

## Optimisations realisees
