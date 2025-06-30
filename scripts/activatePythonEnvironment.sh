#!/usr/bin/env bash

# Activates the Python virtual environment (.venv) with all packages needed to execute the Jupyter Notebooks.

# Note: This script replaces the conda-based activateCondaEnvironment.sh
# It uses Python's built-in venv module instead of conda for environment management.

# Requires operatingSystemFunctions.sh

# Fail on any error ("-e" = exit on first error, "-o pipefail" exist on errors within piped commands)
set -o errexit -o pipefail

## Get this "scripts" directory if not already set
# Even if $BASH_SOURCE is made for Bourne-like shells it is also supported by others and therefore here the preferred solution. 
# CDPATH reduces the scope of the cd command to potentially prevent unintended directory changes.
# This way non-standard tools like readlink aren't needed.
SCRIPTS_DIR=${SCRIPTS_DIR:-$( CDPATH=. cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P )} # Repository directory containing the shell scripts
echo "activatePythonEnvironment: SCRIPTS_DIR=${SCRIPTS_DIR}"

# Get the project root directory (one level up from scripts)
PROJECT_ROOT=${PROJECT_ROOT:-"${SCRIPTS_DIR}/.."} # Project root directory
echo "activatePythonEnvironment: PROJECT_ROOT=${PROJECT_ROOT}"

# Get the "jupyter" directory by taking the path of this script and going two directory up and then to "jupyter".
JUPYTER_NOTEBOOK_DIRECTORY=${JUPYTER_NOTEBOOK_DIRECTORY:-"${SCRIPTS_DIR}/../jupyter"} # Repository directory containing the Jupyter Notebooks
echo "activatePythonEnvironment: JUPYTER_NOTEBOOK_DIRECTORY=${JUPYTER_NOTEBOOK_DIRECTORY}"

# Get the file name of the requirements file that contains all dependencies and their versions.
REQUIREMENTS_FILE=${REQUIREMENTS_FILE:-"${PROJECT_ROOT}/requirements.txt"} # Requirements file path for pip
if [ ! -f "${REQUIREMENTS_FILE}" ] ; then
    echo "activatePythonEnvironment: Couldn't find requirements file ${REQUIREMENTS_FILE}."
    exit 2
fi

# Define virtual environment directory name and path
VENV_NAME=${VENV_NAME:-".venv"} # Name of the virtual environment directory
VENV_PATH="${PROJECT_ROOT}/${VENV_NAME}" # Full path to the virtual environment
echo "activatePythonEnvironment: VIRTUAL_ENV=${VIRTUAL_ENV}"
echo "activatePythonEnvironment: Target virtual environment path=${VENV_PATH}"

PREPARE_PYTHON_ENVIRONMENT=${PREPARE_PYTHON_ENVIRONMENT:-"true"} # Whether to prepare a Python environment with venv if needed (default, "true") or use an already prepared environment ("false")

if [ "${PREPARE_PYTHON_ENVIRONMENT}" = "false" ]; then
    echo "activatePythonEnvironment: Skipping activation. PREPARE_PYTHON_ENVIRONMENT is set to false."
    # "return" needs to be used here instead of "exit".
    # This script is included in another script by using "source". 
    # "exit" would end the main script, "return" just ends this sub script.
    return 0
fi 

# Include operation system function to for example detect Windows.
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
    echo "activatePythonEnvironment: Error: Python is not installed or not in PATH."
    exit 1
fi
echo "activatePythonEnvironment: Using Python command: ${PYTHON_CMD}"

# Create virtual environment if it doesn't exist
if [ ! -d "${VENV_PATH}" ]; then
    echo "activatePythonEnvironment: Creating virtual environment at ${VENV_PATH}..."
    "${PYTHON_CMD}" -m venv "${VENV_PATH}"
else
    echo "activatePythonEnvironment: Virtual environment already exists at ${VENV_PATH}"
fi

# Determine activation script path based on operating system
if isWindows; then
    ACTIVATE_SCRIPT="${VENV_PATH}/Scripts/activate"
    PIP_CMD="${VENV_PATH}/Scripts/pip.exe"
    PYTHON_VENV_CMD="${VENV_PATH}/Scripts/python.exe"
else
    ACTIVATE_SCRIPT="${VENV_PATH}/bin/activate"
    PIP_CMD="${VENV_PATH}/bin/pip"
    PYTHON_VENV_CMD="${VENV_PATH}/bin/python"
fi

echo "activatePythonEnvironment: Activation script: ${ACTIVATE_SCRIPT}"

# Check if activation script exists
if [ ! -f "${ACTIVATE_SCRIPT}" ]; then
    echo "activatePythonEnvironment: Error: Virtual environment activation script not found at ${ACTIVATE_SCRIPT}"
    exit 1
fi

# Activate virtual environment
echo "activatePythonEnvironment: Activating virtual environment..."
source "${ACTIVATE_SCRIPT}"

# Verify activation
if [ -n "${VIRTUAL_ENV}" ] && [ "${VIRTUAL_ENV}" = "${VENV_PATH}" ]; then
    echo "activatePythonEnvironment: Successfully activated virtual environment: ${VIRTUAL_ENV}"
else
    echo "activatePythonEnvironment: Warning: Virtual environment activation may have failed."
    echo "activatePythonEnvironment: VIRTUAL_ENV=${VIRTUAL_ENV}"
    echo "activatePythonEnvironment: Expected: ${VENV_PATH}"
fi

# Check if requirements are up to date by comparing modification times
REQUIREMENTS_INSTALLED_MARKER="${VENV_PATH}/.requirements_installed"
NEEDS_INSTALL=false

if [ ! -f "${REQUIREMENTS_INSTALLED_MARKER}" ]; then
    echo "activatePythonEnvironment: Requirements have never been installed."
    NEEDS_INSTALL=true
elif [ "${REQUIREMENTS_FILE}" -nt "${REQUIREMENTS_INSTALLED_MARKER}" ]; then
    echo "activatePythonEnvironment: Requirements file is newer than last installation."
    NEEDS_INSTALL=true
else
    echo "activatePythonEnvironment: Requirements are up to date."
fi

# Install/update requirements if needed
if [ "${NEEDS_INSTALL}" = true ]; then
    echo "activatePythonEnvironment: Installing/updating requirements from ${REQUIREMENTS_FILE}..."
    
    # Upgrade pip first
    "${PIP_CMD}" install --upgrade pip
    
    # Install requirements
    "${PIP_CMD}" install -r "${REQUIREMENTS_FILE}"
    
    # Create marker file
    touch "${REQUIREMENTS_INSTALLED_MARKER}"
    
    echo "activatePythonEnvironment: Successfully installed/updated requirements."
fi

echo "activatePythonEnvironment: Python environment is ready."
