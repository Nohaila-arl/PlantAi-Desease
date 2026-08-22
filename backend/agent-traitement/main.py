from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
import os
import time

app = FastAPI(
    title="PlantAI - Agent Traitement",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
# GEMINI
# ============================================================

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

# Garde ici le modèle Gemini que tu utilises actuellement
GEMINI_MODEL = os.environ.get(
    "GEMINI_MODEL",
    "gemini-3.6-flash"
)

GEMINI_URL = (
    f"https://generativelanguage.googleapis.com/"
    f"v1beta/models/{GEMINI_MODEL}:generateContent"
)


# ============================================================
# REQUEST MODEL
# ============================================================

class DemandeTraitement(BaseModel):
    maladie: str
    plante: str = ""
    langue: str = "fr"


# ============================================================
# HOME
# ============================================================

@app.get("/")
def home():
    return {
        "status": "online",
        "agent": "Agent Traitement",
        "service": "PlantAI"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "agent": "treatment"
    }


# ============================================================
# PROMPT GEMINI
# ============================================================

def construire_prompt(
    maladie: str,
    plante: str,
    langue: str
):

    langue_nom = (
        "français"
        if langue == "fr"
        else "anglais"
    )

    contexte = ""

    if plante:
        contexte = f"""
La plante concernée est : {plante}.
"""

    prompt = f"""
Tu es un agent agronome spécialisé
dans les maladies des plantes.

Une autre IA vient de détecter :

Maladie : {maladie}

{contexte}

Donne une recommandation claire et pratique.

La réponse doit contenir :

1. Une courte explication de la maladie.
2. Le traitement recommandé.
3. Une mesure de prévention.
4. Les précautions importantes.

Réponds en {langue_nom}.

Sois clair, concis et facile à comprendre.
"""

    return prompt


# ============================================================
# APPEL GEMINI
# ============================================================

def appeler_gemini(prompt: str):

    if not GEMINI_API_KEY:
        raise RuntimeError(
            "GEMINI_API_KEY manquante."
        )

    response = requests.post(
        f"{GEMINI_URL}?key={GEMINI_API_KEY}",
        headers={
            "Content-Type": "application/json"
        },
        json={
            "contents": [
                {
                    "parts": [
                        {
                            "text": prompt
                        }
                    ]
                }
            ]
        },
        timeout=30
    )

    response.raise_for_status()

    data = response.json()

    candidates = data.get(
        "candidates",
        []
    )

    if not candidates:
        raise RuntimeError(
            "Aucune réponse Gemini."
        )

    parts = (
        candidates[0]
        .get("content", {})
        .get("parts", [])
    )

    if not parts:
        raise RuntimeError(
            "Réponse Gemini vide."
        )

    texte = parts[0].get(
        "text",
        ""
    )

    if not texte:
        raise RuntimeError(
            "Texte Gemini vide."
        )

    return texte


# ============================================================
# TRAITEMENT
# ============================================================

@app.post("/traitement")
def generer_traitement(
    demande: DemandeTraitement
):

    debut = time.time()

    print("\n" + "=" * 60)
    print("AGENT TRAITEMENT")
    print("=" * 60)

    print(
        f"Maladie : {demande.maladie}"
    )

    print(
        f"Plante : {demande.plante}"
    )

    # ========================================================
    # PLANTE SAINE
    # ========================================================

    if "healthy" in demande.maladie.lower():

        traitement = (
            "Aucune maladie détectée. "
            "La plante semble saine. "
            "Continuez une surveillance régulière "
            "et un arrosage adapté."
        )

        return {
            "maladie": demande.maladie,
            "plante": demande.plante,
            "traitement": traitement,
            "genere_par": "Agent Traitement",
            "gemini_utilise": False,
            "temps_traitement_secondes":
                round(time.time() - debut, 4)
        }

    # ========================================================
    # GEMINI NON CONFIGURE
    # ========================================================

    if not GEMINI_API_KEY:

        return {
            "maladie": demande.maladie,
            "plante": demande.plante,
            "traitement": (
                "Clé Gemini non configurée."
            ),
            "genere_par": "Fallback",
            "gemini_utilise": False,
            "erreur":
                "GEMINI_API_KEY manquante"
        }

    # ========================================================
    # APPEL GEMINI
    # ========================================================

    try:

        prompt = construire_prompt(
            demande.maladie,
            demande.plante,
            demande.langue
        )

        print("Appel Gemini...")

        traitement = appeler_gemini(
            prompt
        )

        temps = round(
            time.time() - debut,
            4
        )

        print(
            f"Gemini terminé : {temps}s"
        )

        return {
            "maladie": demande.maladie,
            "plante": demande.plante,
            "traitement": traitement,
            "genere_par":
                "Agent Traitement (Gemini)",
            "gemini_utilise": True,
            "temps_traitement_secondes":
                temps
        }

    except Exception as e:

        print(
            f"Erreur Gemini : {e}"
        )

        return {
            "maladie": demande.maladie,
            "plante": demande.plante,
            "traitement": (
                "Impossible de générer "
                "le traitement actuellement."
            ),
            "genere_par": "Fallback",
            "gemini_utilise": False,
            "erreur": str(e)
        }