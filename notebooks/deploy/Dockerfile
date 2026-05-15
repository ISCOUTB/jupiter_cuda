# ── Base ───────────────────────────────────────────────────────
FROM python:3.10-slim

WORKDIR /app

# ── Dependencias (capa cacheada; se reconstruye solo si cambia) ─
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Modelo entrenado (copiado dentro de la imagen) ─────────────
# Versión fijada durante el build — no depende de volúmenes externos
COPY modelo_iris.joblib .

# ── Aplicación ─────────────────────────────────────────────────
COPY app.py .

# ── Puerto y healthcheck ────────────────────────────────────────
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

# ── Arranque ────────────────────────────────────────────────────
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
