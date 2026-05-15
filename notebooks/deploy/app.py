from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, validator
from typing import List, Dict
import joblib
import numpy as np

# ── Configuración ──────────────────────────────────────────────
MODEL_PATH  = "modelo_iris.joblib"
CLASS_NAMES = ["setosa", "versicolor", "virginica"]
N_FEATURES  = 4

# Cargar modelo al iniciar (una sola vez)
modelo = joblib.load(MODEL_PATH)

app = FastAPI(
    title="Iris Classifier API",
    version="1.0",
    description="Clasifica flores Iris en setosa, versicolor o virginica.",
)

# ── Esquemas de entrada/salida ─────────────────────────────────
class InputData(BaseModel):
    features: List[float]

    @validator("features")
    def validate_features(cls, v):
        if len(v) != N_FEATURES:
            raise ValueError(
                f"Se esperan exactamente {N_FEATURES} features, "
                f"se recibieron {len(v)}"
            )
        if not all(0.0 <= f <= 20.0 for f in v):
            raise ValueError("Cada feature debe estar en el rango [0, 20]")
        return v

class PredictionResponse(BaseModel):
    prediction: int
    class_name: str
    probabilities: Dict[str, float]

# ── Endpoints ──────────────────────────────────────────────────
@app.get("/health", summary="Health check")
def health():
    return {"status": "ok", "model": "RandomForestClassifier", "version": "1.0"}

@app.post("/predict", response_model=PredictionResponse, summary="Clasificar flor Iris")
def predict(data: InputData):
    try:
        X    = np.array(data.features).reshape(1, -1)
        pred = int(modelo.predict(X)[0])
        prob = modelo.predict_proba(X)[0]
        return PredictionResponse(
            prediction=pred,
            class_name=CLASS_NAMES[pred],
            probabilities={
                name: round(float(p), 4)
                for name, p in zip(CLASS_NAMES, prob)
            },
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Error de inferencia: {exc}")
