# Uso de Neo4j Existente

Este projeto foi modificado para detectar automaticamente se há uma instância do Neo4j já em execução e utilizá-la em vez de baixar e instalar uma nova instância local.

## Como Funciona

O sistema verifica automaticamente:

1. **Detecção de Processo**: Verifica se há um processo ouvindo na porta 7474 (HTTP) do Neo4j
2. **Conectividade HTTP**: Testa se consegue se conectar ao endpoint HTTP do Neo4j
3. **Autenticação**: Se uma senha foi fornecida, testa se consegue autenticar com as credenciais

## Variáveis de Ambiente para Controle

### `USE_EXISTING_NEO4J`
- **Padrão**: `true` (detecção automática ativada)
- **Valores**: `true|false|1|0`
- **Uso**: `export USE_EXISTING_NEO4J=false` para forçar instalação local

### `FORCE_USE_EXISTING_NEO4J`
- **Padrão**: `false`
- **Valores**: `true|false`
- **Uso**: `export FORCE_USE_EXISTING_NEO4J=true` para usar Neo4j existente mesmo se houver problemas de autenticação

### `NEO4J_INITIAL_PASSWORD`
- **Necessário**: Sim
- **Uso**: `export NEO4J_INITIAL_PASSWORD="sua-senha"`
- **Descrição**: Senha usada para testar conectividade com Neo4j existente

## Cenários de Uso

### 1. Neo4j Existente Detectado e Compatível
```bash
# O sistema automaticamente detecta e usa o Neo4j existente
./quickstart-rest-api-sample.sh
```

**Saída esperada:**
```
✅ Neo4j detectado e acessível com credenciais fornecidas
   - HTTP: http://localhost:7474
   - Bolt: bolt://localhost:7687
   - Usuário: neo4j
🎉 Usando Neo4j existente encontrado
```

### 2. Forçar Instalação Local
```bash
# Forçar instalação local mesmo se Neo4j existente for detectado
export USE_EXISTING_NEO4J=false
./quickstart-rest-api-sample.sh
```

### 3. Neo4j Existente com Problemas de Autenticação
```bash
# Forçar uso mesmo com problemas de autenticação
export FORCE_USE_EXISTING_NEO4J=true
./quickstart-rest-api-sample.sh
```

### 4. Neo4j Existente em Porta Diferente
```bash
# Se o Neo4j estiver rodando em portas diferentes
export NEO4J_HTTP_PORT=7475
export NEO4J_BOLT_PORT=7688
./quickstart-rest-api-sample.sh
```

## Scripts Modificados

### `scripts/detectExistingNeo4j.sh` (NOVO)
- Script principal que implementa a lógica de detecção
- Função `should_use_existing_neo4j()` retorna 0 se deve usar existente
- Função `detect_existing_neo4j()` testa conectividade

### `scripts/setupNeo4j.sh`
- **Modificação**: Verifica se há Neo4j existente antes de baixar/instalar
- **Comportamento**: Se Neo4j existente detectado, pula instalação completamente

### `scripts/startNeo4j.sh`
- **Modificação**: Verifica se há Neo4j existente antes de iniciar instância local
- **Comportamento**: Se Neo4j existente detectado, não inicia instância local

### `scripts/stopNeo4j.sh`
- **Modificação**: Verifica se está usando Neo4j existente antes de parar
- **Comportamento**: Se usando Neo4j existente, não tenta pará-lo (deixa rodando)

### `quickstart-rest-api-sample.sh`
- **Modificação**: Adicionadas mensagens informativas sobre detecção automática
- **Comportamento**: Informa ao usuário se Neo4j existente foi detectado e usado

## Logs e Debugging

Para debug detalhado, execute os scripts individualmente:

```bash
# Testar detecção
./scripts/detectExistingNeo4j.sh

# Testar setup com verbose
./scripts/setupNeo4j.sh

# Testar start com verbose
./scripts/startNeo4j.sh
```

## Casos de Erro Comuns

### 1. "Neo4j encontrado mas não acessível com as credenciais fornecidas"
**Solução**: Verificar a senha em `NEO4J_INITIAL_PASSWORD` ou usar `FORCE_USE_EXISTING_NEO4J=true`

### 2. "Nenhum processo detectado na porta HTTP 7474"
**Solução**: O Neo4j não está rodando ou está em porta diferente. Verificar com `netstat -an | grep :7474`

### 3. "Não foi possível conectar via HTTP na porta 7474"
**Solução**: O processo na porta pode não ser Neo4j ou pode estar com problemas. Verificar logs do Neo4j.

## Vantagens

1. **Economia de Tempo**: Não precisa baixar/instalar Neo4j se já existir
2. **Economia de Espaço**: Evita instalações duplicadas 
3. **Flexibilidade**: Permite usar Neo4j existente (Docker, instalação nativa, etc.)
4. **Compatibilidade**: Mantém comportamento original quando Neo4j não existe
5. **Controle**: Variáveis de ambiente permitem override do comportamento automático

## Limitações

1. **Porta Fixa**: Por padrão detecta apenas na porta 7474 (configurável via `NEO4J_HTTP_PORT`)
2. **Credenciais**: Requer que o Neo4j existente use as mesmas credenciais configuradas
3. **Versão**: Não verifica se a versão do Neo4j existente é compatível com os plugins usados
