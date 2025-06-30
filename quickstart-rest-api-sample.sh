#!/usr/bin/env bash

# Script automatizado para análise do projeto rest-api-sample
# Execute este script no diretório raiz do code-graph-analysis-pipeline

set -o errexit -o pipefail

echo "🚀 Iniciando análise automatizada do rest-api-sample..."
echo ""
echo "💡 DICA: Se você já tem um Neo4j rodando:"
echo "   - O script detectará automaticamente e o utilizará"
echo "   - Para forçar instalação local: export USE_EXISTING_NEO4J=false"
echo "   - Para forçar uso do existente: export FORCE_USE_EXISTING_NEO4J=true"
echo ""

# Configurações
PROJECT_NAME="rest-api-sample"
PROJECT_PATH="/c/Users/xxx/Documents/projects/modernization/grafo-analisys/rest-api-sample"
NEO4J_PASSWORD="codegraph123"

# Verificar se estamos no diretório correto
if [ ! -f "./init.sh" ]; then
    echo "❌ Erro: Execute este script no diretório raiz do code-graph-analysis-pipeline"
    exit 1
fi

# Verificar se o projeto fonte existe
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Erro: Projeto não encontrado em $PROJECT_PATH"
    exit 1
fi

echo "📁 Projeto encontrado: $PROJECT_PATH"

# Passo 1: Configurar ambiente Python se necessário
echo "🐍 Verificando ambiente Python..."
if [ ! -d ".venv" ]; then
    echo "🔧 Configurando ambiente Python..."
    ./scripts/setupPythonEnvironment.sh
else
    echo "✅ Ambiente Python já configurado"
fi

# Passo 2: Definir senha do Neo4j
echo "🔑 Configurando senha do Neo4j..."
export NEO4J_INITIAL_PASSWORD="$NEO4J_PASSWORD"

# Passo 3: Inicializar projeto de análise
echo "🏗️ Inicializando projeto de análise..."
./init.sh "$PROJECT_NAME"

# Passo 4: Navegar para o diretório da análise
cd "./temp/$PROJECT_NAME"
echo "📂 Mudou para: $(pwd)"

# Passo 5: Copiar projeto fonte
echo "📋 Copiando projeto fonte..."
# Limpar diretório source se existir
if [ -d "./source" ]; then
    rm -rf "./source/*" 2>/dev/null || true
fi

# Copiar arquivos do projeto (exceto .git e .gradle)
# Para Git Bash no Windows, usar cp é mais confiável
if cp -r "$PROJECT_PATH"/* "./source/" 2>/dev/null; then
    echo "✅ Arquivos copiados com cp"
else
    echo "⚠️ cp falhou, tentando rsync..."
    if rsync -av --exclude='.git' --exclude='.gradle' "$PROJECT_PATH/" "./source/" 2>/dev/null; then
        echo "✅ Arquivos copiados com rsync"
    else
        echo "⚠️ rsync não disponível, tentando robocopy (Windows)..."
        if command -v robocopy &> /dev/null; then
            robocopy "$PROJECT_PATH" "./source" /E /XD .git .gradle /NFL /NDL /NJH /NJS || true
            echo "✅ Arquivos copiados com robocopy"
        else
            echo "❌ Erro: Não foi possível copiar os arquivos. Copie manualmente:"
            echo "   cp -r \"$PROJECT_PATH\"/* ./source/"
            exit 1
        fi
    fi
fi

# Remover arquivos indesejados se existirem (mantendo build com artifacts compilados)
rm -rf "./source/.git" 2>/dev/null || true
rm -rf "./source/.gradle" 2>/dev/null || true

echo "✅ Projeto copiado para ./source/"

# Passo 6: Verificar estrutura
echo "📊 Estrutura do projeto:"
ls -la "./source/"

# Passo 6.5: Copiar artifacts compilados para análise
echo "📦 Copiando artifacts compilados para análise..."

# Criar diretório artifacts se não existir
mkdir -p "./artifacts"

# Variável para controlar se encontrou artifacts
found_artifacts=false

# Verificar e copiar do diretório bin (Eclipse/IDE compilado)
if [ -d "./source/bin" ]; then
    echo "🔍 Encontrado diretório bin com classes compiladas"
    if cp -r "./source/bin"/* "./artifacts/" 2>/dev/null; then
        echo "✅ Classes do bin copiadas para ./artifacts/"
        found_artifacts=true
    fi
fi

# Verificar e copiar do diretório build/classes (Gradle compilado)
if [ -d "./source/build/classes" ]; then
    echo "🔍 Encontrado diretório build/classes com classes compiladas"
    if cp -r "./source/build/classes"/* "./artifacts/" 2>/dev/null; then
        echo "✅ Classes do build/classes copiadas para ./artifacts/"
        found_artifacts=true
    fi
fi

# Verificar se existem JARs compilados no build/libs
if [ -d "./source/build/libs" ] && [ "$(ls -A ./source/build/libs 2>/dev/null)" ]; then
    echo "🔍 Encontrados JARs em build/libs"
    cp "./source/build/libs"/*.jar "./artifacts/" 2>/dev/null || true
    echo "✅ JARs copiados para ./artifacts/"
    found_artifacts=true
fi

if [ "$found_artifacts" = true ]; then
    echo "📊 Conteúdo do diretório artifacts:"
    ls -la "./artifacts/"
    echo "📈 Total de arquivos .class encontrados:"
    find "./artifacts/" -name "*.class" | wc -l
else
    echo "⚠️ Nenhum artifact compilado encontrado!"
    echo "   Verifique se o projeto foi compilado corretamente."
    echo "   Para compilar o projeto Spring Boot, execute:"
    echo "   cd \"$PROJECT_PATH\" && ./gradlew build"
    echo "   Ou compile no IDE e execute o script novamente."
fi

# Passo 7: Executar análise
echo "🔍 Iniciando análise completa..."
echo "   Isso pode levar alguns minutos..."

# Executar o script de análise
./analyze.sh

echo ""
echo "🎉 ==============================================="
echo "🎉 ANÁLISE CONCLUÍDA COM SUCESSO!"
echo "🎉 ==============================================="
echo ""
echo "📊 Resultados disponíveis em:"
echo "   - Neo4j Browser: http://localhost:7474"
echo "   - Relatórios Jupyter: ./reports/"
echo ""
echo "🔑 Credenciais Neo4j:"
echo "   - Usuário: neo4j"
echo "   - Senha: $NEO4J_PASSWORD"
echo ""
echo "🚀 Para explorar os dados:"
echo "   1. Abra http://localhost:7474 no navegador"
echo "   2. Faça login com as credenciais acima"
echo "   3. Execute consultas Cypher ou"
echo "   4. Verifique os relatórios em ./reports/"
echo ""
echo "ℹ️  NOTA: Se foi usado um Neo4j existente, ele permanecerá"
echo "   rodando após o fim da análise para permitir exploração."
