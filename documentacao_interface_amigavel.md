# Documentação da Interface Amigável - f_cadastrar_json

## Visão Geral

A função `f_cadastrar_json` foi melhorada para permitir inserções usando nomes em vez de códigos, tornando a interface muito mais amigável ao usuário. Agora você pode inserir dados de forma mais intuitiva, sem precisar conhecer os códigos internos das tabelas.

## Campos Especiais Suportados

### 1. **nome_cliente** → **cod_cliente**
- Busca automaticamente o código do cliente pelo nome
- Exemplo: `"nome_cliente": "João Silva"`

### 2. **nome_funcionario** → **cod_funcionario**
- Busca automaticamente o código do funcionário pelo nome
- Exemplo: `"nome_funcionario": "Maria Santos"`

### 3. **nome_fornecedor** → **cod_fornecedor**
- Busca automaticamente o código do fornecedor pelo nome
- Exemplo: `"nome_fornecedor": "Distribuidora ABC"`

### 4. **nome_titulo** → **cod_titulo**
- Busca automaticamente o código do título pelo nome
- Exemplo: `"nome_titulo": "O Senhor dos Anéis"`

### 5. **nome_tipo_midia** → **cod_tipo_midia**
- Busca automaticamente o código do tipo de mídia pelo nome
- Exemplo: `"nome_tipo_midia": "DVD"`

### 6. **nome_categoria** → **cod_categoria**
- Busca automaticamente o código da categoria pelo nome
- Exemplo: `"nome_categoria": "Aventura"`

### 7. **nome_midia** → **cod_midia**
- Busca automaticamente o código da mídia pelo título
- Exemplo: `"nome_midia": "O Senhor dos Anéis"`

## Exemplos de Uso

### Inserir Mídia
```sql
-- Antes (usando códigos):
INSERT INTO midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) 
VALUES (29.90, 10, 1, 1);

-- Agora (usando nomes):
SELECT f_cadastrar_json('midia', '{
    "valor_unid": "29.90",
    "qtd_estoque": "10",
    "nome_tipo_midia": "DVD",
    "nome_titulo": "O Senhor dos Anéis"
}');
```

### Inserir Venda
```sql
-- Antes (usando códigos):
INSERT INTO venda (cod_funcionario, cod_cliente, dt_hora_venda, total) 
VALUES (1, 2, '2024-01-15 14:30:00', 89.70);

-- Agora (usando nomes):
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "João Silva",
    "nome_cliente": "Maria Santos",
    "dt_hora_venda": "2024-01-15 14:30:00",
    "total": "89.70"
}');
```

### Inserir Item de Venda
```sql
-- Antes (usando códigos):
INSERT INTO item_venda (cod_midia, cod_venda, subtotal, qtd_item) 
VALUES (1, 1, 29.90, 1);

-- Agora (usando nomes):
SELECT f_cadastrar_json('item_venda', '{
    "nome_midia": "O Senhor dos Anéis",
    "cod_venda": "1",
    "subtotal": "29.90",
    "qtd_item": "1"
}');
```

### Inserir Compra
```sql
-- Antes (usando códigos):
INSERT INTO compra (cod_fornecedor, total, dt_compra) 
VALUES (1, 150.00, '2024-01-15 10:00:00');

-- Agora (usando nomes):
SELECT f_cadastrar_json('compra', '{
    "nome_fornecedor": "Distribuidora ABC",
    "total": "150.00",
    "dt_compra": "2024-01-15 10:00:00"
}');
```

## Validações e Formatação Automáticas

A função agora inclui validações e formatação automáticas:

1. **Formatação de Texto**: Aplica `initcap()` automaticamente antes de buscar nomes
2. **Verificação de Existência**: Se um nome não for encontrado, a função retorna um erro específico
3. **Mensagens Claras**: Erros informativos indicam exatamente qual entidade não foi encontrada
4. **Integridade**: Mantém a integridade referencial automaticamente
5. **Flexibilidade**: Aceita nomes em qualquer formato (minúsculo, maiúsculo, misto)

### Exemplos de Erro
```sql
-- Erro se cliente não existir:
-- ERRO: Cliente com nome "Cliente Inexistente" não encontrado!

-- Erro se título não existir:
-- ERRO: Título com nome "Título Inexistente" não encontrado!
```

## Vantagens da Nova Interface

### 1. **Facilidade de Uso**
- Não precisa conhecer códigos internos
- Interface mais intuitiva
- Menos propenso a erros
- Aceita nomes em qualquer formato

### 2. **Manutenibilidade**
- Código mais legível
- Menos dependente de IDs específicos
- Mais fácil de entender e modificar

### 3. **Flexibilidade**
- Pode usar nomes ou códigos (para códigos, use números)
- Compatível com a interface anterior
- Suporte a todos os tipos de dados
- Formatação automática de texto

### 4. **Integração com Triggers**
- Funciona perfeitamente com todos os triggers existentes
- Mantém a consistência dos dados
- Calcula totais automaticamente

### 5. **Formatação Inteligente**
- Aplica formatação antes das consultas
- Compatível com dados já formatados pelos triggers
- Aceita entrada em qualquer formato

## Casos de Uso Comuns

### 1. **Cadastro de Vendas**
```sql
-- Cadastrar venda completa
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "Ana Costa",
    "nome_cliente": "Pedro Oliveira",
    "dt_hora_venda": "2024-01-16 16:45:00",
    "total": "0"
}');

-- Adicionar itens (total calculado automaticamente)
SELECT f_cadastrar_json('item_venda', '{
    "nome_midia": "Matrix",
    "cod_venda": "2",
    "subtotal": "19.90",
    "qtd_item": "1"
}');
```

### 2. **Cadastro de Compras**
```sql
-- Cadastrar compra
SELECT f_cadastrar_json('compra', '{
    "nome_fornecedor": "Distribuidora XYZ",
    "total": "0",
    "dt_compra": "2024-01-15 10:00:00"
}');

-- Adicionar itens (estoque atualizado automaticamente)
SELECT f_cadastrar_json('item_compra', '{
    "cod_compra": "1",
    "nome_midia": "O Senhor dos Anéis",
    "quantidade": "5",
    "subtotal": "150.00"
}');
```

### 3. **Cadastro de Mídias**
```sql
-- Cadastrar mídia com tipo e título
SELECT f_cadastrar_json('midia', '{
    "valor_unid": "24.90",
    "qtd_estoque": "8",
    "nome_tipo_midia": "Blu-ray",
    "nome_titulo": "Pulp Fiction"
}');
```

## Compatibilidade

- ✅ Funciona com todos os triggers existentes
- ✅ Mantém integridade referencial
- ✅ Suporte a todos os tipos de dados
- ✅ Compatível com funções JSON existentes
- ✅ Funciona com auditoria e logs

## Dicas de Uso

1. **Flexibilidade de entrada**: Pode usar nomes em minúsculo, maiúsculo ou misto
2. **Formatação automática**: A função aplica `initcap()` automaticamente
3. **Compatibilidade**: Funciona com dados já formatados pelos triggers
4. **Teste primeiro**: Sempre teste com dados pequenos antes de inserções em massa
5. **Monitore logs**: Use as mensagens de erro para identificar problemas
6. **Combine com triggers**: Aproveite os triggers para cálculos automáticos 