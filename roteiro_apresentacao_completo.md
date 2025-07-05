# ROTEIRO DE APRESENTAÇÃO COMPLETO - SISTEMA DE LOCADORA DE MÍDIAS
## Banco de Dados 2 - IFPI ADS 2025.1

---

## 📋 **ESTRUTURA DA APRESENTAÇÃO (20-25 minutos)**

### **1. INTRODUÇÃO E CONTEXTO (3-4 minutos)**
- **Tema:** Sistema Completo de Locadora de Mídias com Automação Avançada
- **Problema Resolvido:** Gestão automatizada de locadora com controle de estoque, vendas, compras e segurança
- **Tecnologias:** PostgreSQL, Docker, PL/pgSQL, JSON, Triggers, Views, Roles
- **Destaque:** Sistema real com 15 filmes famosos (O Poderoso Chefão, Matrix, Titanic, etc.)

### **2. ARQUITETURA COMPLETA DO BANCO (4-5 minutos)**

#### **2.1 Estrutura das Tabelas (11 tabelas)**
```sql
-- Entidades principais
categoria, tipo_midia, fornecedor, cliente, funcionario, titulo
-- Transações
compra, venda, midia
-- Relacionamentos
titulo_categoria, item_compra, item_venda
```

#### **2.2 Relacionamentos Complexos**
- **1:N:** Fornecedor → Compra, Cliente → Venda, Funcionário → Venda
- **N:N:** Título ↔ Categoria (via titulo_categoria)
- **1:N:** Título → Mídia, Compra → Item_Compra, Venda → Item_Venda
- **Herança:** Um título pode ter múltiplas mídias (DVD, Blu-ray, 4K)

#### **2.3 Características Avançadas**
- **Auditoria Completa:** Log de todas as operações em todas as tabelas
- **Validações Multi-nível:** Triggers + Funções + Constraints
- **Formatação Automática:** Padronização de texto em tempo real
- **Integridade Referencial:** Verificações programáticas nas funções JSON

### **3. SISTEMA DE FUNÇÕES JSON AVANÇADO (4-5 minutos)**

#### **3.1 Função Universal f_cadastrar_json**
```sql
-- Interface amigável usando nomes em vez de códigos
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "João Silva",
    "nome_cliente": "Maria Santos", 
    "dt_hora_venda": "2024-01-15 14:30:00",
    "total": "89.70"
}');
```

#### **3.2 Validação Inteligente de Tipos**
- **Verificação automática:** String vs Numérico
- **Prevenção de erros:** Campos obrigatórios e tipos corretos
- **Mensagens personalizadas:** Erros específicos por tipo de problema
- **Formatação automática:** `initcap()` aplicado antes das consultas

#### **3.3 Demonstração com Filmes Reais**
```sql
-- Cadastrar mídia usando nomes
SELECT f_cadastrar_json('midia', '{
    "valor_unid": "45.00",
    "qtd_estoque": "10", 
    "nome_tipo_midia": "Blu-ray",
    "nome_titulo": "O Poderoso Chefão"
}');
```

### **4. SISTEMA DE TRIGGERS AVANÇADO (4-5 minutos)**

#### **4.1 Triggers de Negócio (8 triggers principais)**
1. **Controle de Estoque:** Atualização automática em vendas/compras
2. **Cálculo de Totais:** Subtotal e total automáticos
3. **Validações de Negócio:** Estoque insuficiente, valores negativos
4. **Auditoria Completa:** Log de todas as alterações
5. **Padronização de Texto:** Formatação automática de nomes/emails
6. **Devolução de Estoque:** Restauração automática em exclusões

#### **4.2 Demonstração Prática de Triggers**
```sql
-- Tentar vender mais que o estoque (deve dar erro)
INSERT INTO item_venda (cod_midia, cod_venda, qtd_item) VALUES (1, 1, 1000);
-- Resultado: "Estoque insuficiente para o título 'O Poderoso Chefão'"

-- Verificar auditoria automática
SELECT * FROM log_auditoria_geral ORDER BY data_alteracao DESC LIMIT 5;
```

#### **4.3 Sistema de Auditoria Completo**
- **Log detalhado:** Tabela, atributo, valor anterior, valor novo
- **Rastreabilidade:** Usuário, data/hora, operação
- **Compliance:** Histórico completo para auditorias

### **5. SISTEMA DE ROLES E SEGURANÇA (3-4 minutos)**

#### **5.1 Hierarquia de Permissões**
```sql
-- role_gerente: Acesso total ao sistema
-- role_atendente: Vendas, clientes, catálogo
-- role_cliente: Auto-atendimento limitado
```

#### **5.2 Demonstração de Segurança**
```bash
# Conectar como diferentes roles
docker exec -it trabalhofinal-db-1 psql -U gerente_joao -d trabalho-final-db
docker exec -it trabalhofinal-db-1 psql -U atendente_maria -d trabalho-final-db
docker exec -it trabalhofinal-db-1 psql -U cliente_joao_silva -d trabalho-final-db
```

#### **5.3 Views Seguras e Filtradas**
- `catalogo_midia`: Catálogo público com filmes famosos
- `v_vendas_cliente`: Histórico pessoal do cliente
- `v_rel_analise_vendas_categoria`: Relatórios por categoria

### **6. SISTEMA DE RELATÓRIOS AVANÇADO (3-4 minutos)**

#### **6.1 Relatórios Implementados (7 relatórios)**
1. **Desempenho de Funcionários:** Por período específico
2. **Top Mídias Vendidas:** Ranking com limite configurável
3. **Controle de Estoque:** Alertas de estoque baixo
4. **Ranking de Clientes:** Melhores compradores
5. **Análise Temporal:** Vendas por mês/ano
6. **Análise por Tipo de Mídia:** Performance por formato
7. **Análise por Categoria:** Performance por gênero

#### **6.2 Demonstração de Relatórios**
```sql
-- Relatório de desempenho
SELECT f_rel_desempenho_vendas(3, 2023);

-- Análise por categoria
SELECT * FROM v_rel_analise_vendas_categoria;

-- Controle de estoque
SELECT f_rel_controle_estoque(10);
```

### **7. CONTAINERIZAÇÃO E DEPLOY (2-3 minutos)**

#### **7.1 Docker Compose**
```yaml
# docker-compose.yml
version: '3.8'
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: trabalho-final-db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - ./initdb:/docker-entrypoint-initdb.d
```

#### **7.2 Script de Inicialização Completo**
- **1346 linhas** de código SQL
- **Criação automática** de todas as estruturas
- **Povoamento** com dados reais
- **Configuração** de roles e permissões

---

## ❓ **POSSÍVEIS PERGUNTAS DO PROFESSOR (EXPANDIDAS)**

### **PERGUNTAS SOBRE FUNÇÕES JSON AVANÇADAS**

1. **"Como a função f_cadastrar_json resolve o problema de nomes vs códigos?"**
   - **Resposta:** A função detecta campos especiais (nome_cliente, nome_funcionario, etc.) e automaticamente busca o código correspondente usando `initcap()` para formatação. Isso permite inserções intuitivas sem conhecer IDs internos.

2. **"E se o usuário inserir um nome que não existe?"**
   - **Resposta:** A função retorna erro específico: "Cliente com nome 'Nome Inexistente' não encontrado!" com rollback automático da transação.

3. **"Como você garante a validação de tipos na função JSON?"**
   - **Resposta:** Consulta `information_schema.columns` para verificar o tipo da coluna e valida se o valor é compatível (numérico para números, texto para strings).

### **PERGUNTAS SOBRE TRIGGERS AVANÇADOS**

4. **"Quantos triggers você implementou e como eles se relacionam?"**
   - **Resposta:** 8 triggers principais que trabalham em conjunto: controle de estoque, cálculo de totais, validações, auditoria, padronização de texto, devolução de estoque.

5. **"Como você evita loops infinitos entre triggers?"**
   - **Resposta:** Triggers são específicos para operações (INSERT/UPDATE/DELETE) e tabelas específicas. Uso de condições para controlar execução e evitar recursão.

6. **"O que acontece se um trigger de validação falhar?"**
   - **Resposta:** Transação completa é revertida (ROLLBACK), garantindo consistência. Mensagem de erro específica é exibida ao usuário.

### **PERGUNTAS SOBRE AUDITORIA E SEGURANÇA**

7. **"Como funciona o sistema de auditoria?"**
   - **Resposta:** Tabela `log_auditoria_geral` registra todas as alterações com: tabela, atributo, valor anterior, valor novo, usuário, data/hora. Triggers automáticos capturam todas as operações.

8. **"Como você testaria a segurança do sistema de roles?"**
   - **Resposta:** Conectando como diferentes roles e tentando operações não autorizadas. Verificando se views filtram dados corretamente e se permissões são respeitadas.

### **PERGUNTAS SOBRE PERFORMANCE E OTIMIZAÇÃO**

9. **"Como você otimizou as consultas dos relatórios?"**
   - **Resposta:** Uso de índices nas colunas de JOIN e WHERE, views para consultas complexas, funções com parâmetros para evitar recompilação.

10. **"E se a locadora crescesse para milhares de clientes?"**
    - **Resposta:** Implementaria particionamento por data, cache Redis, arquivamento de dados antigos, índices otimizados, replicação para leitura.

### **PERGUNTAS SOBRE MANUTENIBILIDADE**

11. **"Como você organizou o código para facilitar manutenção?"**
    - **Resposta:** Arquivos separados por funcionalidade: funções, triggers, relatórios, roles. Documentação completa e exemplos de uso.

12. **"Como você testaria todas as funcionalidades?"**
    - **Resposta:** Arquivo `testes_funcoes.sql` com 376 linhas de testes automatizados, incluindo casos de erro e validações.

### **PERGUNTAS SOBRE ESCALABILIDADE**

13. **"Como adaptaria para múltiplas filiais?"**
    - **Resposta:** Tabela `filial` com chave estrangeira nas transações, views específicas por filial, replicação de dados, roles por filial.

14. **"E se precisasse de uma API REST?"**
    - **Resposta:** As funções JSON já facilitam a integração. Implementaria endpoints que chamam as funções existentes, mantendo a lógica de negócio no banco.

### **PERGUNTAS SOBRE DOCKER E DEPLOY**

15. **"Por que usar Docker para este projeto?"**
    - **Resposta:** Reprodução exata do ambiente, isolamento de dependências, facilita demonstração, deploy consistente, backup/restore simplificado.

16. **"Como garantiria a persistência dos dados?"**
    - **Resposta:** Volumes Docker para persistir dados PostgreSQL, scripts de backup automatizados, replicação para alta disponibilidade.

### **PERGUNTAS SOBRE DADOS REAIS**

17. **"Por que escolheu esses filmes específicos?"**
    - **Resposta:** Filmes clássicos reconhecidos mundialmente (O Poderoso Chefão, Matrix, Titanic) tornam o sistema mais atrativo e realista para demonstração.

18. **"Como os dados estão estruturados para diferentes tipos de mídia?"**
    - **Resposta:** Um título pode ter múltiplas mídias (DVD, Blu-ray, 4K) com preços e estoques diferentes, simulando realidade de locadora.

### **PERGUNTAS SOBRE VALIDAÇÕES**

19. **"Como você previne inserção de dados inválidos?"**
    - **Resposta:** Múltiplas camadas: constraints de banco, triggers de validação, funções com verificação de tipos, formatação automática.

20. **"E se alguém tentar inserir valores negativos?"**
    - **Resposta:** Trigger `controle_valores_invalidos` verifica valores negativos/nulos e retorna erro específico com rollback automático.

---

## 🎯 **DICAS PARA APRESENTAÇÃO COMPLETA**

### **Preparação Avançada**
- **Teste todos os cenários:** Funções JSON, triggers, roles, relatórios
- **Prepare exemplos práticos:** Tenha dados de teste prontos
- **Backup completo:** Ambiente limpo para reiniciar se necessário
- **Conheça os números:** 1346 linhas de código, 8 triggers, 7 relatórios, 15 filmes

### **Durante a Apresentação**
- **Comece pelo contexto:** Problema real que o sistema resolve
- **Demonstre na prática:** Execute comandos reais
- **Mostre os erros:** Demonstre validações funcionando
- **Conecte conceitos:** Relacione com teoria de BD2
- **Destaque inovações:** Interface JSON, auditoria completa, filmes reais

### **Demonstrações Específicas**
1. **Função JSON:** Cadastrar venda usando nomes
2. **Triggers:** Tentar vender sem estoque
3. **Roles:** Conectar como cliente vs gerente
4. **Relatórios:** Executar análise por categoria
5. **Auditoria:** Verificar log de alterações

### **Possíveis Problemas e Soluções**
- **Erro de conexão:** Verificar Docker e container
- **Dados corrompidos:** `docker-compose down -v && docker-compose up -d`
- **Permissão negada:** Verificar role correto
- **Trigger não funciona:** Verificar se script foi executado

### **Conclusão Impactante**
- **Resuma inovações:** Interface JSON, auditoria completa, segurança avançada
- **Mencione escalabilidade:** Preparado para crescimento
- **Demonstre conhecimento:** Confiança no trabalho realizado
- **Agradeça e abra perguntas:** Postura profissional

---

## 📊 **MÉTRICAS COMPLETAS DO PROJETO**

### **Código e Estrutura**
- **Linhas de código:** 1346 linhas no script principal
- **Tabelas:** 11 tabelas principais
- **Triggers:** 8 triggers de negócio
- **Funções:** 15+ funções (JSON, relatórios, segurança)
- **Views:** 5 views para relatórios e segurança
- **Roles:** 3 roles com permissões específicas
- **Relatórios:** 7 relatórios diferentes

### **Dados e Conteúdo**
- **Filmes:** 15 filmes famosos no catálogo
- **Categorias:** 10 categorias (Ação, Comédia, Drama, etc.)
- **Tipos de mídia:** 6 formatos (DVD, Blu-ray, 4K, etc.)
- **Fornecedores:** 6 estúdios reais (Warner, Disney, Universal, etc.)

### **Funcionalidades Avançadas**
- **Interface JSON:** Cadastro usando nomes em vez de códigos
- **Validação de tipos:** Prevenção automática de erros
- **Auditoria completa:** Log de todas as operações
- **Formatação automática:** Padronização de texto
- **Controle de estoque:** Atualização automática
- **Cálculo de totais:** Subtotal e total automáticos
- **Segurança por roles:** 3 níveis de acesso
- **Containerização:** Docker para deploy

**Tempo estimado de apresentação:** 20-25 minutos + 15-20 minutos para perguntas

---

## 🚀 **COMANDOS RÁPIDOS PARA APRESENTAÇÃO**

```bash
# Subir o sistema completo
docker-compose up -d

# Conectar ao banco
docker exec -it trabalhofinal-db-1 psql -U postgres -d trabalho-final-db

# Executar demonstração completa
\i demonstracao_apresentacao.sql

# Verificar estrutura
\dt
\d+ cliente
\d+ venda

# Testar função JSON
SELECT f_cadastrar_json('cliente', '{"nome": "Teste", "telefone": "1234-5678"}');

# Verificar catálogo
SELECT * FROM catalogo_midia LIMIT 5;

# Executar relatórios
SELECT f_rel_ranking_clientes();
SELECT * FROM v_rel_analise_vendas_categoria;
```

---

## 🏆 **PONTOS FORTES PARA DESTACAR**

1. **Sistema Realista:** Filmes famosos, dados realistas, cenários práticos
2. **Interface Inovadora:** JSON com nomes em vez de códigos
3. **Segurança Avançada:** Roles, views filtradas, auditoria completa
4. **Automação Total:** Triggers para todas as operações críticas
5. **Escalabilidade:** Preparado para crescimento
6. **Manutenibilidade:** Código organizado e documentado
7. **Testes Completos:** 376 linhas de testes automatizados
8. **Containerização:** Deploy simplificado com Docker 