-- Teste da formatação automática na função f_cadastrar_json
-- Este arquivo demonstra como a função aplica formatação antes das consultas

-- ========================================
-- PREPARAÇÃO: Inserir dados com formatação
-- ========================================

-- Inserir cliente com formatação automática
INSERT INTO cliente (nome, telefone, email, cep) 
VALUES ('joão silva santos', '(11) 99999-9999', 'joao@email.com', '01234-567');

-- Inserir funcionário com formatação automática
INSERT INTO funcionario (nome, telefone, cep, salario) 
VALUES ('maria oliveira costa', '(11) 88888-8888', '04567-890', 3000.00);

-- Inserir fornecedor com formatação automática
INSERT INTO fornecedor (nome, telefone, email) 
VALUES ('distribuidora abc ltda', '(11) 77777-7777', 'contato@distribuidora.com');

-- Inserir título com formatação automática
INSERT INTO titulo (nome, classificacao_ind, ano_lancamento) 
VALUES ('o senhor dos anéis', 12, 2001);

-- Inserir tipo de mídia com formatação automática
INSERT INTO tipo_midia (nome_formato) 
VALUES ('dvd');

-- Inserir categoria com formatação automática
INSERT INTO categoria (nome) 
VALUES ('aventura');

-- ========================================
-- TESTE: Buscar usando nomes sem formatação
-- ========================================

-- Teste 1: Buscar cliente usando nome sem formatação
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "maria oliveira costa",
    "nome_cliente": "joão silva santos",
    "dt_hora_venda": "2024-01-15 14:30:00",
    "total": "89.70"
}');

-- Teste 2: Buscar fornecedor usando nome sem formatação
SELECT f_cadastrar_json('compra', '{
    "nome_fornecedor": "distribuidora abc ltda",
    "total": "150.00",
    "dt_compra": "2024-01-15 10:00:00"
}');

-- Teste 3: Buscar mídia usando título sem formatação
SELECT f_cadastrar_json('item_venda', '{
    "nome_midia": "o senhor dos anéis",
    "cod_venda": "1",
    "subtotal": "29.90",
    "qtd_item": "1"
}');

-- Teste 4: Buscar categoria usando nome sem formatação
SELECT f_cadastrar_json('titulo_categoria', '{
    "nome_categoria": "aventura",
    "nome_titulo": "o senhor dos anéis"
}');

-- ========================================
-- TESTE: Buscar usando nomes com formatação mista
-- ========================================

-- Teste 5: Buscar com formatação mista
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "MARIA OLIVEIRA COSTA",
    "nome_cliente": "joão silva santos",
    "dt_hora_venda": "2024-01-16 15:45:00",
    "total": "120.00"
}');

-- Teste 6: Buscar com formatação mista
SELECT f_cadastrar_json('compra', '{
    "nome_fornecedor": "DISTRIBUIDORA ABC LTDA",
    "total": "200.00",
    "dt_compra": "2024-01-16 11:30:00"
}');

-- ========================================
-- VERIFICAÇÃO DOS RESULTADOS
-- ========================================

-- Verificar se as vendas foram criadas corretamente
SELECT v.cod_venda, f.nome as funcionario, c.nome as cliente, v.dt_hora_venda, v.total
FROM venda v
JOIN funcionario f ON v.cod_funcionario = f.cod_funcionario
JOIN cliente c ON v.cod_cliente = c.cod_cliente
ORDER BY v.cod_venda;

-- Verificar se as compras foram criadas corretamente
SELECT c.cod_compra, f.nome as fornecedor, c.total, c.dt_compra
FROM compra c
JOIN fornecedor f ON c.cod_fornecedor = f.cod_fornecedor
ORDER BY c.cod_compra;

-- Verificar se os itens de venda foram criados corretamente
SELECT iv.cod_venda, t.nome as titulo, iv.qtd_item, iv.subtotal
FROM item_venda iv
JOIN midia m ON iv.cod_midia = m.cod_midia
JOIN titulo t ON m.cod_titulo = t.cod_titulo
ORDER BY iv.cod_venda, t.nome;

-- Verificar se as relações título-categoria foram criadas corretamente
SELECT tc.cod_categoria, cat.nome as categoria, t.nome as titulo
FROM titulo_categoria tc
JOIN categoria cat ON tc.cod_categoria = cat.cod_categoria
JOIN titulo t ON tc.cod_titulo = t.cod_titulo
ORDER BY cat.nome, t.nome;

-- ========================================
-- TESTE DE ERRO: Nomes que não existem
-- ========================================

-- Este comando deve gerar erro (cliente não existe)
-- SELECT f_cadastrar_json('venda', '{
--     "nome_funcionario": "maria oliveira costa",
--     "nome_cliente": "cliente inexistente",
--     "dt_hora_venda": "2024-01-15 14:30:00",
--     "total": "50.00"
-- }');

-- ========================================
-- LIMPEZA DOS DADOS DE TESTE
-- ========================================

-- Descomente as linhas abaixo para limpar os dados de teste
-- DELETE FROM item_venda WHERE cod_venda IN (1, 2);
-- DELETE FROM venda WHERE cod_venda IN (1, 2);
-- DELETE FROM compra WHERE cod_compra IN (1, 2);
-- DELETE FROM titulo_categoria WHERE cod_titulo IN (SELECT cod_titulo FROM titulo WHERE nome = 'O Senhor Dos Anéis');
-- DELETE FROM midia WHERE cod_titulo IN (SELECT cod_titulo FROM titulo WHERE nome = 'O Senhor Dos Anéis');
-- DELETE FROM titulo WHERE nome = 'O Senhor Dos Anéis';
-- DELETE FROM categoria WHERE nome = 'Aventura';
-- DELETE FROM tipo_midia WHERE nome_formato = 'Dvd';
-- DELETE FROM fornecedor WHERE nome = 'Distribuidora Abc Ltda';
-- DELETE FROM funcionario WHERE nome = 'Maria Oliveira Costa';
-- DELETE FROM cliente WHERE nome = 'João Silva Santos'; 