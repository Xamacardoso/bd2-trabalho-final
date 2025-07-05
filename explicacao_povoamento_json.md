# EXPLICAÇÃO: Por que não usar f_cadastrar_json para todas as tabelas?

## 📋 **TABELAS QUE PODEM USAR f_cadastrar_json**

### ✅ **Tabelas com Chave Primária Simples (SERIAL)**
```sql
-- Funcionam perfeitamente com f_cadastrar_json
SELECT f_cadastrar_json('categoria', '{"nome": "Ação"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "DVD"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Warner Bros", "telefone": "1111-1111", "email": "contato@warner.com"}');
SELECT f_cadastrar_json('cliente', '{"nome": "João Silva", "telefone": "9999-9999", "email": "joao@email.com", "cep": "64000-000"}');
SELECT f_cadastrar_json('funcionario', '{"nome": "Carlos Lima", "telefone": "7777-7777", "cep": "64002-000", "salario": 2500.00}');
SELECT f_cadastrar_json('titulo', '{"nome": "O Poderoso Chefão", "classificacao_ind": 16, "ano_lancamento": 1972}');
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Warner Bros", "total": 300.00}');
SELECT f_cadastrar_json('midia', '{"valor_unid": 25.00, "qtd_estoque": 15, "cod_tipo_midia": 1, "cod_titulo": 1}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva"}');
```

**Por que funcionam?**
- ✅ Têm chave primária simples (SERIAL)
- ✅ A função pode gerar o ID automaticamente
- ✅ Não precisam de referências específicas durante inserção

## ⚠️ **TABELAS COM CHAVE COMPOSTA - LIMITAÇÕES ESPECÍFICAS**

### 🔴 **1. Tabelas com Chave Primária Composta**

#### **titulo_categoria** - ✅ PODE usar f_cadastrar_json (COM LIMITAÇÃO)
```sql
-- ✅ FUNCIONA com f_cadastrar_json (usando nomes)
SELECT f_cadastrar_json('titulo_categoria', '{
    "nome_categoria": "Ação",
    "nome_titulo": "O Poderoso Chefão"
}');

-- ❌ NÃO FUNCIONA com f_cadastrar_json (usando códigos)
-- SELECT f_cadastrar_json('titulo_categoria', '{"cod_categoria": 1, "cod_titulo": 1}');
```

**Por que funciona com nomes?**
- ✅ A função converte `nome_categoria` → `cod_categoria`
- ✅ A função converte `nome_titulo` → `cod_titulo`
- ✅ Precisa que as categorias e títulos já existam

#### **item_compra** - ✅ PODE usar f_cadastrar_json (COM LIMITAÇÃO)
```sql
-- ✅ FUNCIONA com f_cadastrar_json (usando nomes)
SELECT f_cadastrar_json('item_compra', '{
    "cod_compra": "1",
    "nome_midia": "O Senhor dos Anéis",
    "quantidade": "5",
    "subtotal": "150.00"
}');

-- ❌ NÃO FUNCIONA com f_cadastrar_json (usando códigos)
-- SELECT f_cadastrar_json('item_compra', '{"cod_compra": 1, "cod_midia": 1, "quantidade": 5, "subtotal": 150.00}');
```

**Por que funciona com nomes?**
- ✅ A função converte `nome_midia` → `cod_midia`
- ✅ Precisa que a compra e a mídia já existam
- ✅ Precisa fornecer `cod_compra` explicitamente

#### **item_venda** - ✅ PODE usar f_cadastrar_json (COM LIMITAÇÃO)
```sql
-- ✅ FUNCIONA com f_cadastrar_json (usando nomes)
SELECT f_cadastrar_json('item_venda', '{
    "nome_midia": "O Poderoso Chefão",
    "cod_venda": "3",
    "qtd_item": "2"
}');

-- ❌ NÃO FUNCIONA com f_cadastrar_json (usando códigos)
-- SELECT f_cadastrar_json('item_venda', '{"cod_midia": 1, "cod_venda": 3, "qtd_item": 2}');
```

**Por que funciona com nomes?**
- ✅ A função converte `nome_midia` → `cod_midia`
- ✅ Precisa que a venda e a mídia já existam
- ✅ Precisa fornecer `cod_venda` explicitamente

## 🔄 **ORDEM DE DEPENDÊNCIAS**

### **1ª Fase - Tabelas Independentes**
```sql
-- Primeiro: categorias, tipos_midia, fornecedores
SELECT f_cadastrar_json('categoria', '{"nome": "Ação"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "DVD"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Warner Bros", ...}');
```

### **2ª Fase - Tabelas com Dependências Simples**
```sql
-- Segundo: clientes, funcionários, títulos
SELECT f_cadastrar_json('cliente', '{"nome": "João Silva", ...}');
SELECT f_cadastrar_json('funcionario', '{"nome": "Carlos Lima", ...}');
SELECT f_cadastrar_json('titulo', '{"nome": "O Poderoso Chefão", ...}');
```

### **3ª Fase - Tabelas com Dependências Múltiplas**
```sql
-- Terceiro: compras, mídias, vendas
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Warner Bros", ...}');
SELECT f_cadastrar_json('midia', '{"cod_tipo_midia": 1, "cod_titulo": 1, ...}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva"}');
```

### **4ª Fase - Tabelas de Relacionamento (f_cadastrar_json COM NOMES)**
```sql
-- Quarto: relacionamentos usando nomes em vez de códigos
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "O Poderoso Chefão"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": 1, "nome_midia": "O Senhor dos Anéis", "quantidade": 5, "subtotal": 150.00}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "O Poderoso Chefão", "cod_venda": 3, "qtd_item": 2}');
```

## 🎯 **POR QUE NO POVOAMENTO USAMOS INSERT DIRETO?**

### **Razões Práticas:**

1. **Performance**: INSERT direto é mais rápido para grandes volumes
2. **Simplicidade**: Não precisa converter nomes para códigos
3. **Controle**: Sabemos exatamente quais códigos usar
4. **Dependências**: Evitamos erros de referência

### **Exemplo de Povoamento vs Interface Amigável:**

```sql
-- POVOAMENTO (INSERT direto - mais eficiente)
INSERT INTO titulo_categoria (cod_categoria, cod_titulo) VALUES (1, 1);
INSERT INTO item_compra (cod_compra, cod_midia, quantidade, subtotal) VALUES (1, 1, 10, 250.00);

-- INTERFACE AMIGÁVEL (f_cadastrar_json - mais intuitivo)
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "O Poderoso Chefão"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": 1, "nome_midia": "O Poderoso Chefão", "quantidade": 10, "subtotal": 250.00}');
```

## 📊 **RESUMO ATUALIZADO**

| Tabela | Chave Primária | Pode usar f_cadastrar_json | Como usar |
|--------|----------------|---------------------------|-----------|
| categoria | SERIAL | ✅ SIM | Direto |
| tipo_midia | SERIAL | ✅ SIM | Direto |
| fornecedor | SERIAL | ✅ SIM | Direto |
| cliente | SERIAL | ✅ SIM | Direto |
| funcionario | SERIAL | ✅ SIM | Direto |
| titulo | SERIAL | ✅ SIM | Direto |
| compra | SERIAL | ✅ SIM | Direto |
| midia | SERIAL | ✅ SIM | Direto |
| venda | SERIAL | ✅ SIM | Direto |
| titulo_categoria | (cod_categoria, cod_titulo) | ✅ SIM | Com nomes |
| item_compra | (cod_compra, cod_midia) | ✅ SIM | Com nomes |
| item_venda | (cod_midia, cod_venda) | ✅ SIM | Com nomes |

## 🎯 **CONCLUSÃO**

**A função `f_cadastrar_json` PODE ser usada para TODAS as tabelas**, mas:

- **Tabelas simples**: Usar diretamente
- **Tabelas com chave composta**: Usar com nomes em vez de códigos
- **Povoamento**: Preferir INSERT direto por performance
- **Interface amigável**: Usar f_cadastrar_json por simplicidade

---
**Correção**: A função é mais versátil do que inicialmente explicado!