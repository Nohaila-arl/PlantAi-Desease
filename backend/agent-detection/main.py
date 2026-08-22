from fastapi import FastAPI, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

import torch
import torch.nn as nn
from torchvision import models, transforms

from PIL import Image

import io
import os
import time
import psutil
import requests

from ultralytics import YOLO


# ============================================================
# CONFIGURATION AGENT TRAITEMENT
# ============================================================

AGENT_TRAITEMENT_URL = os.environ.get(
    "AGENT_TRAITEMENT_URL",
    "http://127.0.0.1:8001/traitement"
)


# ============================================================
# APPLICATION
# ============================================================

app = FastAPI(
    title="PlantAI - Agent Détection",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# PROCESS
# ============================================================

process = psutil.Process(
    os.getpid()
)


# ============================================================
# CLASSES
# ============================================================

classes = [
    "Pepper___bell___Bacterial_spot",
    "Pepper___bell___healthy",
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",
    "Tomato_Bacterial_spot",
    "Tomato_Early_blight",
    "Tomato_Late_blight",
    "Tomato_Leaf_Mold",
    "Tomato_Septoria_leaf_spot",
    "Tomato_Spider_mites_Two_spotted_spider_mite",
    "Tomato__Target_Spot",
    "Tomato__Tomato_YellowLeaf__Curl_Virus",
    "Tomato__Tomato_mosaic_virus",
    "Tomato_healthy"
]


# ============================================================
# MODELES
# ============================================================

model_files = {
    "mobilenet": "mobilenet.pth",
    "resnet": "resnet18.pth",
    "yolo": "yolo_best.pt"
}


# ============================================================
# FALLBACK
# ============================================================

def get_recommendation_fallback(
    classe: str
):

    if "healthy" in classe.lower():

        return (
            "La plante semble saine. "
            "Aucun traitement nécessaire."
        )

    return (
        "Retirez les parties affectées, "
        "améliorez la circulation de l'air "
        "et évitez l'arrosage sur les feuilles. "
        "Consultez un spécialiste pour confirmer "
        "le diagnostic."
    )


# ============================================================
# EXTRAIRE PLANTE
# ============================================================

def extraire_plante(
    classe: str
):

    classe_lower = classe.lower()

    if "tomato" in classe_lower:
        return "Tomate"

    if "potato" in classe_lower:
        return "Pomme de terre"

    if "pepper" in classe_lower:
        return "Poivron"

    return ""


# ============================================================
# COMMUNICATION AVEC AGENT TRAITEMENT
# ============================================================

def appeler_agent_traitement(
    maladie: str,
    plante: str = "",
    langue: str = "fr"
):

    print("\n" + "-" * 60)
    print("COMMUNICATION AGENT → AGENT")
    print("-" * 60)

    print(
        "URL :",
        AGENT_TRAITEMENT_URL
    )

    print(
        "Maladie :",
        maladie
    )

    print(
        "Plante :",
        plante
    )

    debut = time.time()

    try:

        response = requests.post(

            AGENT_TRAITEMENT_URL,

            json={
                "maladie": maladie,
                "plante": plante,
                "langue": langue
            },

            timeout=35
        )

        response.raise_for_status()

        data = response.json()

        temps = round(
            time.time() - debut,
            4
        )

        print(
            "Réponse reçue."
        )

        print(
            "Temps traitement :",
            temps,
            "secondes"
        )

        print("-" * 60)

        return {
            "succes": True,
            "data": data,
            "temps_secondes": temps
        }

    except Exception as e:

        print(
            "Erreur Agent Traitement :",
            e
        )

        print("-" * 60)

        return {
            "succes": False,
            "data": {
                "traitement":
                    get_recommendation_fallback(
                        maladie
                    ),
                "genere_par":
                    "Fallback",
                "gemini_utilise":
                    False
            },
            "temps_secondes": round(
                time.time() - debut,
                4
            )
        }


# ============================================================
# CHARGER MOBILENET
# ============================================================

def charger_mobilenet():

    model = models.mobilenet_v2(
        weights=None
    )

    model.classifier[1] = nn.Linear(
        model.last_channel,
        len(classes)
    )

    model.load_state_dict(
        torch.load(
            "mobilenet.pth",
            map_location="cpu"
        )
    )

    model.eval()

    return model


# ============================================================
# CHARGER RESNET
# ============================================================

def charger_resnet():

    model = models.resnet18(
        weights=None
    )

    model.fc = nn.Linear(
        model.fc.in_features,
        len(classes)
    )

    model.load_state_dict(
        torch.load(
            "resnet18.pth",
            map_location="cpu"
        )
    )

    model.eval()

    return model


# ============================================================
# CHARGER YOLO
# ============================================================

def charger_yolo():

    return YOLO(
        "yolo_best.pt"
    )


# ============================================================
# CHARGEMENT
# ============================================================

print(
    "Chargement des modèles..."
)

modeles = {

    "mobilenet":
        charger_mobilenet(),

    "resnet":
        charger_resnet(),

    "yolo":
        charger_yolo()
}

print(
    "Modèles chargés avec succès."
)


# ============================================================
# TRANSFORM
# ============================================================

transform = transforms.Compose([

    transforms.Resize(
        (224, 224)
    ),

    transforms.ToTensor(),

    transforms.Normalize(
        [0.485, 0.456, 0.406],
        [0.229, 0.224, 0.225]
    )
])


# ============================================================
# HOME
# ============================================================

@app.get("/")
def home():

    return {
        "status": "online",
        "agent": "Agent Détection",
        "treatment_agent":
            AGENT_TRAITEMENT_URL
    }


# ============================================================
# HEALTH
# ============================================================

@app.get("/health")
def health():

    return {
        "status": "healthy",
        "agent": "detection",
        "models":
            list(modeles.keys())
    }


# ============================================================
# PREDICT
# ============================================================

@app.post("/predict")
async def predict(

    file: UploadFile = File(...),

    modele_choisi: str = Form(
        "mobilenet"
    )

):

    debut_total = time.time()

    # ========================================================
    # VERIFIER MODELE
    # ========================================================

    if modele_choisi not in modeles:

        return JSONResponse(

            content={
                "erreur":
                    "Modèle inconnu",

                "modeles_disponibles":
                    list(modeles.keys())
            },

            status_code=400
        )

    # ========================================================
    # LIRE IMAGE
    # ========================================================

    try:

        image_bytes = await file.read()

        image = Image.open(
            io.BytesIO(image_bytes)
        ).convert("RGB")

    except Exception as e:

        return JSONResponse(

            content={
                "erreur":
                    "Image invalide",

                "details":
                    str(e)
            },

            status_code=400
        )

    # ========================================================
    # DEBUT DETECTION
    # ========================================================

    debut_detection = time.time()

    # ========================================================
    # YOLO
    # ========================================================

    if modele_choisi == "yolo":

        model = modeles[
            "yolo"
        ]

        results = model.predict(
            image,
            verbose=False
        )

        result = results[0]

        if result.probs is None:

            return JSONResponse(

                content={
                    "erreur":
                        "Le modèle YOLO doit être "
                        "un modèle de classification."
                },

                status_code=500
            )

        top_id = result.probs.top1

        classe_predite = (
            result.names[top_id]
        )

        confiance = round(

            result.probs.top1conf.item()
            * 100,

            2
        )

    # ========================================================
    # MOBILENET / RESNET
    # ========================================================

    else:

        model = modeles[
            modele_choisi
        ]

        image_tensor = (
            transform(image)
            .unsqueeze(0)
        )

        with torch.no_grad():

            output = model(
                image_tensor
            )

            probs = (
                torch.nn.functional
                .softmax(
                    output,
                    dim=1
                )
            )

            conf, predicted = (
                torch.max(
                    probs,
                    1
                )
            )

            classe_predite = (
                classes[
                    predicted.item()
                ]
            )

            confiance = round(
                conf.item() * 100,
                2
            )

    # ========================================================
    # FIN DETECTION
    # ========================================================

    fin_detection = time.time()

    temps_detection = (
        fin_detection
        - debut_detection
    )

    # ========================================================
    # CPU / RAM
    # ========================================================

    cpu_percent = process.cpu_percent(
        interval=None
    )

    ram_process_mb = (
        process.memory_info().rss
        / (1024 * 1024)
    )

    ram_system_percent = (
        psutil.virtual_memory().percent
    )

    # ========================================================
    # NETTOYAGE NOM MALADIE
    # ========================================================

    maladie = (
        classe_predite
        .replace("___", " ")
        .replace("__", " ")
        .replace("_", " ")
        .strip()
    )

    # ========================================================
    # PLANTE
    # ========================================================

    plante = extraire_plante(
        classe_predite
    )

    # ========================================================
    # STATUT
    # ========================================================

    est_sain = (
        "healthy"
        in classe_predite.lower()
    )

    # ========================================================
    # APPEL AGENT TRAITEMENT
    # ========================================================

    traitement_result = (
        appeler_agent_traitement(

            maladie=maladie,

            plante=plante,

            langue="fr"
        )
    )

    traitement_data = (
        traitement_result["data"]
    )

    # ========================================================
    # TEMPS TOTAL
    # ========================================================

    temps_total = (
        time.time()
        - debut_total
    )

    # ========================================================
    # TAILLE MODELE
    # ========================================================

    try:

        model_size_mb = round(

            os.path.getsize(
                model_files[
                    modele_choisi
                ]
            )

            / (1024 * 1024),

            2
        )

    except Exception:

        model_size_mb = None

    # ========================================================
    # REPONSE
    # ========================================================

    return JSONResponse({

        "detection": {

            "modele_utilise":
                modele_choisi,

            "plante":
                plante,

            "prediction":
                maladie,

            "confiance":
                confiance,

            "statut":
                (
                    "Healthy"
                    if est_sain
                    else "Infected"
                )
        },

        "traitement": {

            "recommandation":
                traitement_data.get(
                    "traitement"
                ),

            "genere_par":
                traitement_data.get(
                    "genere_par"
                ),

            "gemini_utilise":
                traitement_data.get(
                    "gemini_utilise",
                    False
                )
        },

        "performance": {

            "temps_detection_secondes":
                round(
                    temps_detection,
                    4
                ),

            "temps_traitement_secondes":
                traitement_result[
                    "temps_secondes"
                ],

            "temps_total_secondes":
                round(
                    temps_total,
                    4
                ),

            "cpu_percent":
                round(
                    cpu_percent,
                    2
                ),

            "ram_process_mb":
                round(
                    ram_process_mb,
                    1
                ),

            "ram_system_percent":
                ram_system_percent,

            "model_size_mb":
                model_size_mb
        },

        "communication": {

            "agent_traitement_contacte":
                traitement_result[
                    "succes"
                ],

            "agent_traitement_url":
                AGENT_TRAITEMENT_URL
        }
    })