# Migração do Conda para Python venv

Este projeto foi migrado do Conda para usar o ambiente virtual nativo do Python (`.venv`). Esta migração foi feita para simplificar as dependências e permitir o uso em ambientes corporativos onde o Conda pode não estar disponível.

## 🚀 Como usar o novo ambiente

### Setup Inicial

**Bash (Linux/Mac/Git Bash no Windows):**
```bash
./scripts/setupPythonEnvironment.sh
```

### Executar Jupyter Notebooks

O comando permanece o mesmo - o script foi atualizado internamente:

```bash
./scripts/executeJupyterNotebook.sh ./jupyter/OverviewGeneral.ipynb
```

### Ativação Manual (opcional)

Se você precisar ativar o ambiente manualmente:

**Bash (incluindo Git Bash no Windows):**
```bash
source .venv/bin/activate     # Linux/Mac
source .venv/Scripts/activate # Git Bash no Windows
```

## 📁 Arquivos Criados/Modificados

### Novos Arquivos:
- `requirements.txt` - Lista de dependências Python (substitui `jupyter/environment.yml`)
- `scripts/activatePythonEnvironment.sh` - Ativa o ambiente Python venv
- `scripts/setupPythonEnvironment.sh` - Setup inicial do ambiente

### Arquivos Modificados:
- `scripts/executeJupyterNotebook.sh` - Atualizado para usar venv
- `COMMANDS.md` - Documentação atualizada
- `scripts/SCRIPTS.md` - Referência dos scripts atualizada
- `scripts/ENVIRONMENT_VARIABLES.md` - Variáveis de ambiente atualizadas

### Arquivos Deprecados (mantidos para compatibilidade):
- `scripts/activateCondaEnvironment.sh` - Marcado como DEPRECATED
- `jupyter/environment.yml` - Mantido para referência

## ⚙️ Variáveis de Ambiente

As seguintes variáveis de ambiente foram atualizadas:

| Variável | Valor Padrão | Descrição |
|----------|--------------|-----------|
| `PREPARE_PYTHON_ENVIRONMENT` | `true` | Se deve preparar o ambiente Python automaticamente |
| `VENV_NAME` | `.venv` | Nome do diretório do ambiente virtual |
| `REQUIREMENTS_FILE` | `requirements.txt` | Arquivo de dependências |

## 🔄 Processo de Migração

1. **Dependências mapeadas**: As dependências do `environment.yml` foram convertidas para `requirements.txt`
2. **Scripts atualizados**: Todos os scripts que usavam conda foram atualizados para usar venv
3. **Compatibilidade**: Scripts antigos foram mantidos mas marcados como deprecated
4. **Documentação**: Toda documentação foi atualizada para refletir as mudanças

## 🐍 Requisitos

- Python 3.8 ou superior
- pip (geralmente incluído com Python)
- Acesso à internet para baixar pacotes

## ❓ Solução de Problemas

### Erro: "Python não encontrado"
```bash
# Verifique se Python está instalado
python --version
# ou
python3 --version
```

### Erro: "pip não encontrado"
```bash
# Reinstale ou atualize pip
python -m ensurepip --upgrade
```

### Ambiente não ativa corretamente
```bash
# Recrie o ambiente
./scripts/setupPythonEnvironment.sh --reset
```

## 📋 Checklist de Migração

- [x] Criar `requirements.txt` baseado em `environment.yml`
- [x] Criar `activatePythonEnvironment.sh`
- [x] Criar versões PowerShell dos scripts
- [x] Atualizar `executeJupyterNotebook.sh`
- [x] Criar scripts de setup
- [x] Atualizar documentação
- [x] Marcar scripts conda como deprecated
- [x] Atualizar variáveis de ambiente

## 🔗 Links Úteis

- [Python venv documentation](https://docs.python.org/3/library/venv.html)
- [pip documentation](https://pip.pypa.io/en/stable/)
- [Virtual Environments and Packages](https://docs.python.org/3/tutorial/venv.html)
