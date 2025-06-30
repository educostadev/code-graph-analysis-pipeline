#!/usr/bin/env bash

# Setup Python virtual environment for Code Graph Analysis Pipeline
# This script replaces conda setup with Python's built-in venv

# Fail on any error
set -o errexit -o pipefail

## Get this "scripts" directory if not already set
SCRIPTS_DIR=${SCRIPTS_DIR:-$( CDPATH=. cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P )}
PROJECT_ROOT="${SCRIPTS_DIR}/.."

echo "setupPythonEnvironment: Setting up Python virtual environment..."
echo "setupPythonEnvironment: Project root: ${PROJECT_ROOT}"

# Include operation system functions
source "${SCRIPTS_DIR}/operatingSystemFunctions.sh"

# Check if Python is available
PYTHON_CMD=""
if command -v python &> /dev/null; then
    PYTHON_CMD="python"
elif command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v py &> /dev/null; then
    PYTHON_CMD="py"
else
    echo "setupPythonEnvironment: Error: Python is not installed or not in PATH."
    echo "setupPythonEnvironment: Please install Python 3.8 or later."
    exit 1
fi

# Check Python version
PYTHON_VERSION=$("${PYTHON_CMD}" --version 2>&1 | cut -d' ' -f2)
echo "setupPythonEnvironment: Using Python ${PYTHON_VERSION}"

# Check if Python version is at least 3.8
if ! "${PYTHON_CMD}" -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)"; then
    echo "setupPythonEnvironment: Error: Python 3.8 or later is required."
    echo "setupPythonEnvironment: Current version: ${PYTHON_VERSION}"
    exit 1
fi

# Define virtual environment path
VENV_PATH="${PROJECT_ROOT}/.venv"

# Remove existing virtual environment if requested
if [ "${1:-}" = "--reset" ] || [ "${1:-}" = "-r" ]; then
    if [ -d "${VENV_PATH}" ]; then
        echo "setupPythonEnvironment: Removing existing virtual environment..."
        rm -rf "${VENV_PATH}"
    fi
fi

# Create virtual environment
if [ ! -d "${VENV_PATH}" ]; then
    echo "setupPythonEnvironment: Creating virtual environment at ${VENV_PATH}..."
    "${PYTHON_CMD}" -m venv "${VENV_PATH}"
else
    echo "setupPythonEnvironment: Virtual environment already exists at ${VENV_PATH}"
fi

# Determine activation script path
if isWindows; then
    ACTIVATE_SCRIPT="${VENV_PATH}/Scripts/activate"
    PIP_CMD="${VENV_PATH}/Scripts/pip.exe"
else
    ACTIVATE_SCRIPT="${VENV_PATH}/bin/activate"
    PIP_CMD="${VENV_PATH}/bin/pip"
fi

# Activate virtual environment
echo "setupPythonEnvironment: Activating virtual environment..."
source "${ACTIVATE_SCRIPT}"


# Install requirements
REQUIREMENTS_FILE="${PROJECT_ROOT}/requirements.txt"
if [ -f "${REQUIREMENTS_FILE}" ]; then
    echo "setupPythonEnvironment: Installing requirements from ${REQUIREMENTS_FILE}..."
    "${PIP_CMD}" install -r "${REQUIREMENTS_FILE}"
else
    echo "setupPythonEnvironment: Warning: requirements.txt not found at ${REQUIREMENTS_FILE}"
    echo "setupPythonEnvironment: Installing basic Jupyter packages..."
    "${PIP_CMD}" install jupyter matplotlib numpy pandas nbconvert plotly neo4j
fi

# Create marker file
touch "${VENV_PATH}/.requirements_installed"

echo "setupPythonEnvironment: Python virtual environment setup completed successfully!"
echo "setupPythonEnvironment: To activate the environment manually, run:"
if isWindows; then
    echo "  source ${VENV_PATH}/Scripts/activate"
else
    echo "  source ${VENV_PATH}/bin/activate"
fi
