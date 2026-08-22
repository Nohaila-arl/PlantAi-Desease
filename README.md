# PlantAI — Détection de maladies des plantes par IA

Application mobile de détection de maladies des plantes basée sur le deep learning, couplée à un backend multi-agents qui fournit à la fois le diagnostic et une recommandation de traitement générée par IA.

Projet réalisé dans le cadre du Master **Réseaux & Systèmes d'Information (RSI)** — FST Settat.

---

## Sommaire

- [Architecture](#architecture)
- [Fonctionnalités](#fonctionnalités)
- [Stack technique](#stack-technique)
- [Modèles d'IA](#modèles-dia)
- [Structure du projet](#structure-du-projet)
- [Installation et exécution locale](#installation-et-exécution-locale)
- [Variables d'environnement](#variables-denvironnement)
- [Déploiement](#déploiement)
- [Endpoints de l'API](#endpoints-de-lapi)

---

## Architecture

Le projet suit une architecture **multi-agents** : l'application mobile ne communique qu'avec l'agent de détection, qui orchestre lui-même l'appel vers l'agent de traitement avant de renvoyer une réponse unique et complète.

```
┌─────────────────┐        POST /predict        ┌──────────────────────┐
│                  │ ───────────────────────────▶│                      │
│  App Flutter     │                              │  Agent Détection     │
│  (mobile / web)  │                              │  FastAPI + PyTorch   │
│                  │ ◀─────────────────────────── │  (port 8000)         │
└─────────────────┘   détection + traitement      └──────────┬───────────┘
                        + métriques de perf.                  │
                                                    POST /traitement
                                                                │
                                                                ▼
                                                     ┌──────────────────────┐
                                                     │  Agent Traitement     │
                                                     │  FastAPI + Gemini API │
                                                     │  (port 8001)          │
                                                     └───────────────────────┘
```

- **App Flutter** : upload de l'image, choix du modèle, affichage du résultat, du traitement recommandé et des métriques de performance.
- **Agent Détection** : reçoit l'image, exécute l'inférence (MobileNet / ResNet / YOLO), extrait la maladie et la plante, appelle l'agent de traitement, mesure les performances (temps, CPU, RAM, taille du modèle), et renvoie une réponse JSON unique au frontend.
- **Agent Traitement** : reçoit le nom de la maladie détectée, interroge l'API Gemini pour générer une recommandation de traitement (explication, traitement, prévention, précautions), avec un mécanisme de repli (fallback) si Gemini n'est pas disponible.

## Fonctionnalités

- Sélection entre 3 modèles d'IA (MobileNet, ResNet, YOLO)
- Upload d'image (drag & drop / sélection de fichier)
- Détection de la maladie avec score de confiance
- Recommandation de traitement générée par IA (Gemini), avec repli automatique si indisponible
- Tableau de bord de métriques de performance : temps de réponse, CPU, RAM, taille du modèle, précision, rappel, F1-score
- Comparaison graphique des modèles
- Bascule de langue Français / Anglais
- Thème clair / sombre
- Bouton de téléchargement de l'application

## Stack technique

**Frontend**
- Flutter / Dart

**Backend**
- FastAPI (Python)
- PyTorch, torchvision (MobileNetV2, ResNet18)
- Ultralytics YOLO (YOLOv8-cls)
- Google Gemini API (recommandations de traitement)
- psutil (métriques CPU/RAM)

## Modèles d'IA

Entraînés par transfer learning sur Google Colab, sur le jeu de données **PlantVillage** : 15 classes (tomate, pomme de terre, poivron), environ 20 600 images.

| Modèle       | Précision approx. | Points forts              |
|--------------|--------------------|----------------------------|
| MobileNetV2  | ~91 %              | Rapide, léger               |
| ResNet18     | ~93 %              | Bonne précision globale     |
| YOLOv8-cls   | ~94 %              | Meilleure précision          |

## Structure du projet

```
plant-ai/
├── mobile_app/                 # Application Flutter
│   └── lib/
│       ├── core/                # Constantes, thème, contrôleur d'app, l10n
│       ├── data/                # Modèles de données, services API
│       └── presentation/        # Écrans et widgets
│
├── agent_detection/             # Agent de détection (FastAPI)
│   ├── main.py
│   ├── requirements.txt
│   ├── mobilenet.pth
│   ├── resnet18.pth
│   └── yolo_best.pt
│
└── agent_traitement/            # Agent de traitement (FastAPI + Gemini)
    ├── main.py
    └── requirements.txt
```

## Installation et exécution locale

### Prérequis
- Flutter SDK
- Python 3.10+
- Une clé API Google Gemini

### 1. Agent Détection (port 8000)

```bash
cd agent_detection
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

> Les fichiers `mobilenet.pth`, `resnet18.pth` et `yolo_best.pt` doivent être présents dans ce dossier : ils sont chargés au démarrage du serveur.

### 2. Agent Traitement (port 8001)

```bash
cd agent_traitement
pip install -r requirements.txt
export GEMINI_API_KEY="ta_cle_gemini"
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### 3. Application Flutter

Dans `lib/core/constants/api_constants.dart`, mettre `useLocalBackend = true` pour pointer vers `http://localhost:8000`, puis :

```bash
flutter run -d chrome --web-port=5000
```

## Variables d'environnement

| Variable               | Utilisée par       | Description                                                    |
|-------------------------|---------------------|------------------------------------------------------------------|
| `GEMINI_API_KEY`        | Agent Traitement    | Clé d'accès à l'API Google Gemini                                |
| `GEMINI_MODEL`          | Agent Traitement    | Modèle Gemini utilisé (par défaut `gemini-3.6-flash`)            |
| `AGENT_TRAITEMENT_URL`  | Agent Détection     | URL de l'agent de traitement (par défaut `http://127.0.0.1:8001/traitement`) |

## Déploiement

- **Cloud** : les deux agents sont déployés comme services indépendants sur Railway.
- **Edge** : exécution de l'agent de détection directement sur un smartphone Android (via Termux), pour une comparaison des performances entre déploiement cloud et déploiement edge.

## Endpoints de l'API

### Agent Détection

| Méthode | Route      | Description                                              |
|---------|------------|-------------------------------------------------------------|
| GET     | `/`        | Statut de l'agent                                          |
| GET     | `/health`  | Vérification de santé + liste des modèles chargés          |
| POST    | `/predict` | Upload d'image (`file`) + choix du modèle (`modele_choisi`) → détection + traitement + métriques |

### Agent Traitement

| Méthode | Route          | Description                                     |
|---------|----------------|----------------------------------------------------|
| GET     | `/`            | Statut de l'agent                                  |
| GET     | `/health`      | Vérification de santé                              |
| POST    | `/traitement`  | Reçoit `maladie`, `plante`, `langue` → recommandation générée par Gemini |
