# Entorno de ML/DL con JupyterLab (NVIDIA / Apple Silicon)

Este repositorio provee un entorno estandarizado de JupyterLab con soporte completo de aceleración por hardware tanto para usuarios con **GPUs de NVIDIA (CUDA)** en Windows/Linux, como para usuarios con **Apple Silicon (MPS/Metal)** en macOS.

- **Para GPUs NVIDIA (Windows/Linux):** Utiliza Docker para encapsular un entorno CUDA.
- **Para GPUs Mac (M1-M5):** Utiliza un script de configuración local, ya que Docker en Mac no permite acceso a la GPU.

**Python Base:** 3.11 | **JupyterLab:** 4.x

---

## Requisitos Previos según tu Sistema

### Windows (GPU NVIDIA)
- Instalar [Docker Desktop](https://www.docker.com/products/docker-desktop/).
- Habilitar **WSL2** como backend (Settings > General > Use WSL 2) y asegurarte de tener la integración activada en tu distribución.
- Tener los últimos drivers instalados en Windows (el soporte de GPU dentro de WSL usa el driver principal nativo).

### Linux (GPU NVIDIA)
- Instalar [Docker Engine](https://docs.docker.com/engine/install/).
- Instalar el kit **NVIDIA Container Toolkit** para conectar Docker a la tarjeta gráfica:
   ```bash
   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
   curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
     sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
     sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```

### macOS (Apple Silicon M1-M5)
> **Nota:** A diferencia de Windows/Linux, usarás un entorno nativo sin Docker.
- Constar **únicamente** de tener instalado **Python 3.11**. (Puedes hacerlo mediante [python.org](https://www.python.org/downloads/macos/) o con `brew install python@3.11`).

---

## Instalación y Uso

Lo primero para cualquier plataforma es clonar este repositorio:

```bash
git clone https://github.com/ISCOUTB/jupyterlab_cuda.git
cd jupyterlab_cuda
```

A partir de aquí, sigue la ruta dependiendo de tu configuración:

### Ruta A: Windows / Linux (Vía Docker con NVIDIA)

1. **Construir la imagen:**
   ```bash
   docker compose build
   ```
   *(La primera vez puede tardar unos minutos descargando la imagen base de CUDA de ~5GB e instalando las librerías).*

2. **Iniciar JupyterLab:**
   ```bash
   docker compose up
   ```
   *(Usa `docker compose up -d` para correr en segundo plano. Para detener todo: `docker compose down`).*

### Ruta B: macOS (Vía Nativa con Apple Silicon)

1. **Ejecutar el instalador nativo:**
   El script creará un entorno virtual e instalará dinámicamente PyTorch y los paquetes oficiales de TensorFlow MPS para Mac (*tensorflow-macos* y *tensorflow-metal*).
   ```bash
   chmod +x setup_mac.sh
   ./setup_mac.sh
   ```

2. **Iniciar JupyterLab:**
   Cada vez que quieras usar el entorno, simplemente activa el entorno virtual en la terminal y ejecuta Jupyter indicándole la carpeta de trabajo:
   ```bash
   source venv_mac/bin/activate
   jupyter lab --notebook-dir=notebooks
   ```

---

## Acceder a JupyterLab

Ambas rutas inicializarán un servidor local. Abre tu navegador en:

**http://localhost:8888**
*(El entorno viene preconfigurado para no solicitar contraseñas ni tokens).*

---

## Verificar Aceleración Gráfica (GPU)

El proyecto incluye dos notebooks de comprobación dentro de la carpeta `notebooks/` que incluyen un benchmark comparando cálculos de la CPU contra la GPU.

Dentro de JupyterLab ingresa a la carpeta `notebooks/` y ejecuta:

- **`gpu_check.ipynb`** → Si usas Windows o Linux (Valida que CUDA reconozca tu tarjeta NVIDIA y memoria).
- **`gpu_check_mac.ipynb`** → Si usas macOS (Valida la interfaz de Metal Performance Shaders - MPS de Apple).

*(Nota: Los archivos que crees y guardes dentro de esa carpeta persistirán aunque apagues Jupyter o detengas tu contenedor).*

---

## 📦 Paquetes base y extensiones

Este entorno viene aprovisionado inicialmente con (`requirements.txt`):

| Categoría      | Paquetes                                      |
|----------------|-----------------------------------------------|
| Deep Learning  | PyTorch, torchvision, torchaudio, TensorFlow |
| Data Science   | NumPy, Pandas, Scikit-learn, SciPy            |
| Visualización  | Matplotlib, Seaborn, Pillow                   |
| Utilidades     | tqdm, PyYAML, requests, ipywidgets            |

Para extender el entorno, simplemente edita el `requirements.txt` añadiendo las nuevas dependencias. 
- En Docker (Win/Linux), deberás reconstruir imagen usando `docker compose build`. 
- En macOS, simplemente instálalas con el entorno encendido mediante `pip install -r requirements.txt`.
