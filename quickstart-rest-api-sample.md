# 🚀 Quickstart: Análise do Projeto rest-api-sample

Este guia fornece a forma mais rápida e fácil de analisar o projeto `rest-api-sample` usando o pipeline de análise de grafos de código.

## 📋 Pré-requisitos

- **Python 3.8+** instalado
- **Java 8+** instalado (para executar Neo4j e JQAssistant)
- **Git Bash** (Windows)
- Projeto `rest-api-sample` localizado em: `/c/Users/xxx/Documents/projects/modernization/grafo-analisys/rest-api-sample`

## 🎯 Execução Rápida (1 Comando)

```bash
cd "/c/Users/xxx/Documents/projects/modernization/grafo-analisys/code-graph-analysis-pipeline"
./quickstart-rest-api-sample.sh
```

## 🔍 O que o Script Faz

O script `quickstart-rest-api-sample.sh` executa automaticamente todos os passos necessários para analisar seu projeto Java:

### 1. **Verificações Iniciais** ✅
- Verifica se está no diretório correto do pipeline
- Confirma se o projeto `rest-api-sample` existe no caminho especificado

### 2. **Configuração do Ambiente Python** 🐍
- Verifica se o ambiente virtual `.venv` já existe
- Se não existir, executa automaticamente: `./scripts/setupPythonEnvironment.sh`
- Instala todas as dependências necessárias (Jupyter, matplotlib, neo4j-driver, etc.)

### 3. **Configuração do Neo4j** 🔑
- Define a senha padrão do Neo4j: `codegraph123`
- Exporta a variável de ambiente `NEO4J_INITIAL_PASSWORD`

### 4. **Inicialização do Projeto de Análise** 🏗️
- Executa `./init.sh rest-api-sample`
- Cria a estrutura de diretórios em `./temp/rest-api-sample/`
- Gera scripts de conveniência (`analyze.sh`, `startNeo4j.sh`, `stopNeo4j.sh`)

### 5. **Cópia do Código Fonte** 📋
- Copia todo o projeto `rest-api-sample` para `./temp/rest-api-sample/source/`
- **Exclui automaticamente**:
  - `.git/` (histórico do Git)
  - `build/` (arquivos compilados)
  - `.gradle/` (cache do Gradle)
- **Métodos de cópia** (tenta em ordem, otimizado para Git Bash):
  1. `cp` (comando padrão, mais confiável no Git Bash)
  2. `rsync` (se disponível)
  3. `robocopy` (fallback para Windows)

### 6. **Verificação da Estrutura** 📊
- Lista os arquivos copiados para confirmar a estrutura
- Mostra o conteúdo do diretório `./source/`

### 7. **Execução da Análise Completa** 🔍
- Executa `./analyze.sh` que inclui:
  - **Instalação do Neo4j** (banco de dados de grafos)
  - **Instalação do JQAssistant** (ferramenta de análise de código Java)
  - **Escaneamento do código** (análise estática)
  - **Geração de grafos** (dependências, estrutura, métricas)
  - **Criação de relatórios Jupyter** (visualizações e análises)

## 📊 Resultados da Análise

Após a execução bem-sucedida, você terá acesso a:

### 🌐 Neo4j Browser
- **URL**: http://localhost:7474
- **Usuário**: `neo4j`
- **Senha**: `codegraph123`
- **Funcionalidades**:
  - Consultas Cypher interativas
  - Visualização de grafos
  - Exploração de dependências
  - Análise de métricas de código

### 📈 Relatórios Jupyter
- **Localização**: `./temp/rest-api-sample/reports/`
- **Tipos de relatórios**:
  - **Overview**: Visão geral do projeto
  - **Dependencies**: Análise de dependências
  - **Metrics**: Métricas de qualidade de código
  - **Visibility**: Análise de visibilidade de componentes
  - **Path Finding**: Caminhos entre componentes

## 🛠️ Personalização

### Alterar Projeto Analisado
Edite as variáveis no início do script:

```bash
# Configurações
PROJECT_NAME="meu-projeto"
PROJECT_PATH="/c/Users/seu-usuario/caminho/para/meu/projeto"
NEO4J_PASSWORD="minhasenha123"
```

## 🔧 Solução de Problemas

### Erro: "Python não encontrado"
```bash
# Instale Python 3.8+
# Windows: https://python.org/downloads/
# Ubuntu: sudo apt install python3 python3-pip
# Mac: brew install python3
```

### Erro: "Java não encontrado"
```bash
# Instale Java 8+
# Windows: https://adoptopenjdk.net/
# Ubuntu: sudo apt install openjdk-11-jdk
# Mac: brew install openjdk@11
```

### Erro: "Projeto não encontrado"
Verifique se o caminho está correto (use formato Git Bash):
```bash
ls -la "/c/Users/ecosta59/Documents/projects/modernization/grafo-analisys/rest-api-sample"
```

### Erro: "Falha na cópia de arquivos"
Execute manualmente:
```bash
cd ./temp/rest-api-sample
cp -r "/c/Users/ecosta59/Documents/projects/modernization/grafo-analisys/rest-api-sample"/* ./source/
```

### Neo4j não inicia
```bash
# Verificar se a porta 7474 está livre
netstat -an | findstr 7474

# Ou parar serviços conflitantes
./stopNeo4j.sh
./startNeo4j.sh
```

## 📚 Próximos Passos

### 1. Explorar Neo4j
Acesse http://localhost:7474 e experimente estas consultas:

```cypher
// Listar todos os tipos de nós
CALL db.labels()

// Contar classes Java
MATCH (c:Class) RETURN count(c)

// Visualizar dependências
MATCH (a:Artifact)-[:DEPENDS_ON]->(b:Artifact) 
RETURN a.name, b.name LIMIT 10
```

### 2. Examinar Relatórios Jupyter
```bash
cd ./temp/rest-api-sample/reports/
ls -la *.ipynb
```

### 3. Gerar Relatórios Específicos
```bash
# Relatório de overview
./scripts/executeJupyterNotebook.sh ./jupyter/OverviewJava.ipynb

# Relatório de dependências
./scripts/executeJupyterNotebook.sh ./jupyter/DependenciesGraphJava.ipynb
```

## 🎯 Resumo

| Comando | Resultado |
|---------|-----------|
| `./quickstart-rest-api-sample.sh` | Análise completa automatizada |
| `http://localhost:7474` | Interface Neo4j para consultas |
| `./temp/rest-api-sample/reports/` | Relatórios Jupyter gerados |
| `./stopNeo4j.sh` | Parar Neo4j quando terminar |

---

## 🤝 Contribuição

Este script foi criado como parte da migração do Conda para Python venv. Para melhorias ou correções, consulte o arquivo `MIGRATION_TO_VENV.md`.

**Tempo estimado de execução**: 5-15 minutos (dependendo do tamanho do projeto)
**Espaço em disco necessário**: ~500MB (Neo4j + dependências)
