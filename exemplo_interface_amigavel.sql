-- Exemplos de uso da função f_cadastrar_json com interface amigável
-- Agora você pode inserir dados usando nomes em vez de códigos

-- ========================================
-- EXEMPLOS DE INSERÇÃO USANDO NOMES
-- ========================================

-- 1. Inserir uma mídia usando nomes
-- Em vez de: INSERT INTO midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) VALUES (29.90, 10, 1, 1)
-- Agora você pode fazer:

SELECT f_cadastrar_json('midia', '{
    "valor_unid": "29.90",
    "qtd_estoque": "10",
    "nome_tipo_midia": "DVD",
    "nome_titulo": "balatrao"
}');


-- 2. Inserir uma venda usando nomes
-- Em vez de: INSERT INTO venda (cod_funcionario, cod_cliente, dt_hora_venda, total) VALUES (1, 2, '2024-01-15 14:30:00', 89.70)
-- Agora você pode fazer:
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "Carlos lima",
    "nome_cliente": "peter parker",
    "dt_hora_venda": "2025-07-02 14:30:00",
    "total": "89.70"
}');

Select * from venda;
SELECT * FROM CLIENTE;
SELECT * FROM funcionario;
-- 3. Inserir uma compra usando nomes
-- Em vez de: INSERT INTO compra (cod_fornecedor, total, dt_compra) VALUES (1, 150.00, '2024-01-15 10:00:00')
-- Agora você pode fazer:
SELECT f_cadastrar_json('compra', '{
    "nome_fornecedor": "Fornecedor 1",
    "total": "150.00",
    "dt_compra": "2024-01-15 10:00:00"
}');

Select * from compra;
SELECT * FROM fornecedor;
-- 4. Inserir item de venda usando nomes
-- Em vez de: INSERT INTO item_venda (cod_midia, cod_venda, subtotal, qtd_item) VALUES (1, 1, 29.90, 1)
-- Agora você pode fazer:
SELECT f_cadastrar_json('item_venda', '{
    "nome_midia": "filme E",
    "cod_venda": "24",
    "qtd_item": "3"
}');


SELECT * FROM ITEM_VENDA;
SELECT * FROM VENDA;
-- 5. Inserir item de compra usando nomes
-- Em vez de: INSERT INTO item_compra (cod_compra, cod_midia, quantidade, subtotal) VALUES (1, 1, 5, 150.00)
-- Agora você pode fazer:
SELECT f_cadastrar_json('item_compra', '{
    "cod_compra": "1",
    "nome_midia": "O Senhor dos Anéis",
    "quantidade": "5",
    "subtotal": "150.00"
}');

-- 6. Inserir relação título-categoria usando nomes
-- Em vez de: INSERT INTO titulo_categoria (cod_categoria, cod_titulo) VALUES (1, 1)
-- Agora você pode fazer:
SELECT f_cadastrar_json('titulo_categoria', '{
    "nome_categoria": "Ação",
    "nome_titulo": "Filme E"
}');

SELECT * FROM categoria;
-- ========================================
-- EXEMPLOS MAIS COMPLEXOS
-- ========================================

-- 7. Inserir múltiplas mídias de uma vez
SELECT f_cadastrar_json('midia', '{
    "valor_unid": "19.90",
    "qtd_estoque": "15",
    "nome_tipo_midia": "DVD",
    "nome_titulo": "Filme D"
}');

SELECT * FROM titulo;

SELECT * FROM tipo_midia;
SELECT f_cadastrar_json('midia', '{
    "valor_unid": "24.90",
    "qtd_estoque": "8",
    "nome_tipo_midia": "DVD",
    "nome_titulo": "Pulp Fiction"
}');

-- 8. Inserir venda com múltiplos itens
-- Primeiro a venda
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "Chewbacca",
    "nome_cliente": "Peter parker",
    "dt_hora_venda": "2025-07-03 16:45:00",
    "total": "0"
}');

SELECT * FROM VENDA;
-- Depois os itens (o total será calculado automaticamente pelos triggers)
SELECT f_cadastrar_json('item_venda', '{
    "nome_midia": "Filme D",
    "cod_venda": "25",
    "subtotal": "19.90",
    "qtd_item": "1"
}');

SELECT f_cadastrar_json('item_venda', '{
    "nome_midia": "Pulp Fiction",
    "cod_venda": "2",
    "subtotal": "24.90",
    "qtd_item": "1"
}');

-- ========================================
-- CONSULTAS PARA VERIFICAR OS RESULTADOS
-- ========================================

-- Verificar as mídias inseridas
SELECT m.cod_midia, t.nome as titulo, tm.nome_formato as tipo_midia, m.valor_unid, m.qtd_estoque
FROM midia m
JOIN titulo t ON m.cod_titulo = t.cod_titulo
JOIN tipo_midia tm ON m.cod_tipo_midia = tm.cod_tipo_midia
ORDER BY m.cod_midia;

-- Verificar as vendas inseridas
SELECT v.cod_venda, f.nome as funcionario, c.nome as cliente, v.dt_hora_venda, v.total
FROM venda v
JOIN funcionario f ON v.cod_funcionario = f.cod_funcionario
JOIN cliente c ON v.cod_cliente = c.cod_cliente
ORDER BY v.cod_venda;

-- Verificar os itens de venda
SELECT iv.cod_venda, t.nome as titulo, iv.qtd_item, iv.subtotal
FROM item_venda iv
JOIN midia m ON iv.cod_midia = m.cod_midia
JOIN titulo t ON m.cod_titulo = t.cod_titulo
ORDER BY iv.cod_venda, t.nome;

-- ========================================
-- EXEMPLOS DE ERRO (para demonstrar validações)
-- ========================================

-- Este comando irá gerar erro porque o cliente não existe
-- SELECT f_cadastrar_json('venda', '{
--     "nome_funcionario": "João Silva",
--     "nome_cliente": "Cliente Inexistente",
--     "dt_hora_venda": "2024-01-15 14:30:00",
--     "total": "50.00"
-- }');

-- Este comando irá gerar erro porque o título não existe
-- SELECT f_cadastrar_json('midia', '{
--     "valor_unid": "29.90",
--     "qtd_estoque": "10",
--     "nome_tipo_midia": "DVD",
--     "nome_titulo": "Título Inexistente"
-- }');

-- ========================================
-- LIMPEZA DOS DADOS DE TESTE
-- ========================================

-- Descomente as linhas abaixo para limpar os dados de teste
-- DELETE FROM item_venda WHERE cod_venda IN (1, 2);
-- DELETE FROM venda WHERE cod_venda IN (1, 2);
-- DELETE FROM item_compra WHERE cod_compra = 1;
-- DELETE FROM compra WHERE cod_compra = 1;
-- DELETE FROM titulo_categoria WHERE cod_titulo IN (SELECT cod_titulo FROM titulo WHERE nome IN ('Matrix', 'Pulp Fiction'));
-- DELETE FROM midia WHERE cod_titulo IN (SELECT cod_titulo FROM titulo WHERE nome IN ('Matrix', 'Pulp Fiction')); 