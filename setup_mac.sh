#!/bin/bash
set -e

echo "========================================================"
echo " JupyterLab + Apple Silicon (MPS/Metal) Setup"
echo "========================================================"

# Detectar Python 3.11
PYTHON_CMD=""
for cmd in python3.11 /opt/homebrew/bin/python3.11 /usr/local/bin/python3.11 python3; do
    if command -v "$cmd" &> /dev/null; then
        # Verificar version
        version=$("$cmd" -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        if [ "$version" == "3.11" ]; then
            PYTHON_CMD="$cmd"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "Error: Python 3.11 no esta instalado o no se encuentra en el PATH."
    echo "Puedes instalarlo via Homebrew (brew install python@3.11) o desde el instalador oficial de python.org."
    exit 1
fi

echo "Usando $PYTHON_CMD para crear el entorno..."

if [ ! -d "venv_mac" ]; then
    echo "Creando entorno virtual 'venv_mac'..."
    "$PYTHON_CMD" -m venv venv_mac
fi

echo "Activando entorno virtual..."
source venv_mac/bin/activate

echo "Actualizando pip..."
pip install --upgrade pip

echo "Instalando paquetes desde requirements.txt..."
# PyTorch para Mac ya viene con soporte para MPS (Metal Performance Shaders) en la version estandar.
# Tensorflow requiere el paquete tensorflow-macos y tensorflow-metal para hardware acceleration.
# Por lo tanto, extraemos tensorflow de los requirements para instalar su version especifica luego.
grep -i -v "tensorflow" requirements.txt > requirements_macos_temp.txt || true
pip install -r requirements_macos_temp.txt
rm requirements_macos_temp.txt

echo "Instalando TensorFlow y el plugin de aceleracion Metal..."
pip install tensorflow-macos tensorflow-metal

echo ""
echo "========================================================"
echo "✅ Instalacion completada con soporte para GPU de Mac."
echo ""
echo "Para usar el entorno abre una terminal en esta carpeta y ejecuta:"
echo "  source venv_mac/bin/activate"
echo "  jupyter lab --notebook-dir=notebooks"
echo "========================================================"
