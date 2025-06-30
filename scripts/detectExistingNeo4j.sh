#!/usr/bin/env bash

# Detecta se há uma instância do Neo4j já em execução que pode ser utilizada
# Retorna informações sobre a instância encontrada

# Fail on any error ("-e" = exit on first error, "-o pipefail" exist on errors within piped commands)
set -o errexit -o pipefail

# Configurações padrão
NEO4J_HTTP_PORT=${NEO4J_HTTP_PORT:-"7474"}
NEO4J_BOLT_PORT=${NEO4J_BOLT_PORT:-"7687"}
NEO4J_USERNAME=${NEO4J_USERNAME:-"neo4j"}
NEO4J_PASSWORD=${NEO4J_PASSWORD:-"${NEO4J_INITIAL_PASSWORD}"}

## Get this "scripts" directory if not already set
SCRIPTS_DIR=${SCRIPTS_DIR:-$( CDPATH=. cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P )}

# Include operation system function to for example detect Windows.
source "${SCRIPTS_DIR}/operatingSystemFunctions.sh"

# Função para testar conectividade HTTP com Neo4j
test_neo4j_http_connection() {
    local port=${1:-$NEO4J_HTTP_PORT}
    local response
    
    # Tenta acessar o endpoint de status do Neo4j
    if command -v curl >/dev/null 2>&1; then
        response=$(curl -s -w "%{http_code}" -o /dev/null "http://localhost:${port}" 2>/dev/null || echo "000")
        if [[ "$response" == "200" ]]; then
            return 0
        fi
    fi
    return 1
}

# Função para testar conectividade com autenticação
test_neo4j_auth_connection() {
    local port=${1:-$NEO4J_HTTP_PORT}
    local username=${2:-$NEO4J_USERNAME}
    local password=${3:-$NEO4J_PASSWORD}
    local response
    
    if command -v curl >/dev/null 2>&1; then
        # Tenta executar uma query simples para testar autenticação
        response=$(curl -s -w "%{http_code}" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -u "${username}:${password}" \
            -d '{"statements":[{"statement":"RETURN 1 as test"}]}' \
            "http://localhost:${port}/db/neo4j/tx/commit" 2>/dev/null | tail -c 3)
        
        if [[ "$response" == "200" ]]; then
            return 0
        fi
    fi
    return 1
}

# Função para detectar processo Neo4j rodando
detect_neo4j_process() {
    local port=${1:-$NEO4J_HTTP_PORT}
    
    if isWindows; then
        # No Windows, usar netstat para detectar processos ouvindo na porta
        if command -v netstat >/dev/null 2>&1; then
            netstat -an | grep ":${port} " | grep "LISTENING" >/dev/null 2>&1 && return 0
        fi
        # Alternativa usando PowerShell
        if command -v powershell >/dev/null 2>&1; then
            powershell -Command "Get-NetTCPConnection -LocalPort ${port} -State Listen" >/dev/null 2>&1 && return 0
        fi
    else
        # Em sistemas Unix, usar lsof
        if command -v lsof >/dev/null 2>&1; then
            lsof -t -i:"${port}" -sTCP:LISTEN >/dev/null 2>&1 && return 0
        fi
        # Alternativa usando netstat
        if command -v netstat >/dev/null 2>&1; then
            netstat -ln | grep ":${port} " >/dev/null 2>&1 && return 0
        fi
    fi
    return 1
}

# Função principal para detectar Neo4j existente
detect_existing_neo4j() {
    local http_port=${1:-$NEO4J_HTTP_PORT}
    local bolt_port=${2:-$NEO4J_BOLT_PORT}
    local username=${3:-$NEO4J_USERNAME}
    local password=${4:-$NEO4J_PASSWORD}
    
    echo "detectExistingNeo4j: Verificando se há uma instância Neo4j em execução..."
    
    # 1. Verificar se há processo ouvindo na porta HTTP
    if ! detect_neo4j_process "$http_port"; then
        echo "detectExistingNeo4j: Nenhum processo detectado na porta HTTP $http_port"
        return 1
    fi
    
    echo "detectExistingNeo4j: Processo detectado na porta $http_port"
    
    # 2. Verificar conectividade HTTP básica
    if ! test_neo4j_http_connection "$http_port"; then
        echo "detectExistingNeo4j: Não foi possível conectar via HTTP na porta $http_port"
        return 1
    fi
    
    echo "detectExistingNeo4j: Conectividade HTTP confirmada na porta $http_port"
    
    # 3. Verificar autenticação (se senha fornecida)
    if [[ -n "$password" ]]; then
        if test_neo4j_auth_connection "$http_port" "$username" "$password"; then
            echo "detectExistingNeo4j: ✅ Neo4j detectado e acessível com credenciais fornecidas"
            echo "detectExistingNeo4j:    - HTTP: http://localhost:$http_port"
            echo "detectExistingNeo4j:    - Bolt: bolt://localhost:$bolt_port"
            echo "detectExistingNeo4j:    - Usuário: $username"
            return 0
        else
            echo "detectExistingNeo4j: ⚠️  Neo4j detectado mas não acessível com as credenciais fornecidas"
            echo "detectExistingNeo4j:    Pode ser necessário verificar a senha ou configurar NEO4J_INITIAL_PASSWORD"
            return 2
        fi
    else
        echo "detectExistingNeo4j: ✅ Neo4j detectado na porta $http_port (sem teste de autenticação)"
        echo "detectExistingNeo4j:    - HTTP: http://localhost:$http_port"
        echo "detectExistingNeo4j:    - Bolt: bolt://localhost:$bolt_port"
        return 0
    fi
}

# Função para verificar se devemos usar Neo4j existente
should_use_existing_neo4j() {
    local detection_result
    
    # Permitir override via variável de ambiente
    if [[ "${USE_EXISTING_NEO4J}" == "false" ]] || [[ "${USE_EXISTING_NEO4J}" == "0" ]]; then
        echo "detectExistingNeo4j: Uso de Neo4j existente desabilitado via USE_EXISTING_NEO4J"
        return 1
    fi
    
    if ! detection_result=$(detect_existing_neo4j 2>&1); then
        local exit_code=$?
        echo "$detection_result"
        
        case ${exit_code} in
            1)
                echo "detectExistingNeo4j: Nenhum Neo4j compatível encontrado, procedendo com instalação local"
                return 1
                ;;
            2)
                echo "detectExistingNeo4j: ⚠️  Neo4j encontrado mas com problemas de autenticação"
                if [[ "${FORCE_USE_EXISTING_NEO4J}" == "true" ]]; then
                    echo "detectExistingNeo4j: Forçando uso devido a FORCE_USE_EXISTING_NEO4J=true"
                    return 0
                else
                    echo "detectExistingNeo4j: Procedendo com instalação local para evitar problemas"
                    return 1
                fi
                ;;
            *)
                echo "detectExistingNeo4j: Erro desconhecido na detecção, procedendo com instalação local"
                return 1
                ;;
        esac
    else
        echo "$detection_result"
        echo "detectExistingNeo4j: 🎉 Usando Neo4j existente encontrado"
        return 0
    fi
}

# Se o script for executado diretamente (não sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    should_use_existing_neo4j
fi
