-- ========================================
-- TESTE DE AUTOMATIZAÇÃO DE TIMESTAMP
-- Demonstra como a função f_cadastrar_json agora
-- adiciona automaticamente campos de timestamp
-- ========================================

-- ========================================
-- TESTE 1: VENDA SEM TIMESTAMP (DEVE ADICIONAR AUTOMATICAMENTE)
-- ========================================

-- Antes: Era necessário fornecer dt_hora_venda
-- SELECT f_cadastrar_json('venda', '{
--     "nome_funcionario": "Carlos Lima",
--     "nome_cliente": "João Silva",
--     "dt_hora_venda": "2024-01-15 14:30:00",
--     "total": "0"
-- }');

-- Agora: Pode omitir dt_hora_venda (será adicionado automaticamente)
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "Carlos Lima",
    "nome_cliente": "João Silva",
    "total": "0"
}');

-- Verificar se a venda foi criada com timestamp automático
SELECT v.cod_venda, f.nome as funcionario, c.nome as cliente, v.dt_hora_venda, v.total
FROM venda v
JOIN funcionario f ON v.cod_funcionario = f.cod_funcionario
JOIN cliente c ON v.cod_cliente = c.cod_cliente
WHERE c.nome = 'João Silva'
ORDER BY v.cod_venda DESC
LIMIT 1;

-- ========================================
-- TESTE 2: COMPRA SEM TIMESTAMP (DEVE ADICIONAR AUTOMATICAMENTE)
-- ========================================

-- Antes: Era necessário fornecer dt_compra
-- SELECT f_cadastrar_json('compra', '{
--     "nome_fornecedor": "Warner Bros",
--     "dt_compra": "2024-01-15 10:00:00",
--     "total": "150.00"
-- }');

-- Agora: Pode omitir dt_compra (será adicionado automaticamente)
SELECT f_cadastrar_json('compra', '{
    "nome_fornecedor": "Warner Bros",
    "total": "150.00"
}');

-- Verificar se a compra foi criada com timestamp automático
SELECT c.cod_compra, f.nome as fornecedor, c.dt_compra, c.total
FROM compra c
JOIN fornecedor f ON c.cod_fornecedor = f.cod_fornecedor
WHERE f.nome = 'Warner Bros'
ORDER BY c.cod_compra DESC
LIMIT 1;

-- ========================================
-- TESTE 3: VENDA COM TIMESTAMP EXPLÍCITO (DEVE USAR O FORNECIDO)
-- ========================================

-- Se fornecer o timestamp explicitamente, deve usar o valor fornecido
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "Ana Paula",
    "nome_cliente": "Maria Souza",
    "dt_hora_venda": "2024-01-16 15:45:00",
    "total": "0"
}');

-- Verificar se usou o timestamp fornecido
SELECT v.cod_venda, f.nome as funcionario, c.nome as cliente, v.dt_hora_venda, v.total
FROM venda v
JOIN funcionario f ON v.cod_funcionario = f.cod_funcionario
JOIN cliente c ON v.cod_cliente = c.cod_cliente
WHERE c.nome = 'Maria Souza'
ORDER BY v.cod_venda DESC
LIMIT 1;

-- ========================================
-- TESTE 4: COMPRA COM TIMESTAMP EXPLÍCITO (DEVE USAR O FORNECIDO)
-- ========================================

-- Se fornecer o timestamp explicitamente, deve usar o valor fornecido
SELECT f_cadastrar_json('compra', '{
    "nome_fornecedor": "Disney",
    "dt_compra": "2024-01-16 11:30:00",
    "total": "200.00"
}');

-- Verificar se usou o timestamp fornecido
SELECT c.cod_compra, f.nome as fornecedor, c.dt_compra, c.total
FROM compra c
JOIN fornecedor f ON c.cod_fornecedor = f.cod_fornecedor
WHERE f.nome = 'Disney'
ORDER BY c.cod_compra DESC
LIMIT 1;

-- ========================================
-- TESTE 5: OUTRAS TABELAS (NÃO DEVE ADICIONAR TIMESTAMP)
-- ========================================

-- Para outras tabelas, não deve adicionar timestamp automaticamente
-- Deve funcionar normalmente
SELECT f_cadastrar_json('cliente', '{
    "nome": "Pedro Teste Timestamp",
    "telefone": "7777-8888",
    "email": "pedro@teste.com",
    "cep": "64000-789"
}');

-- Verificar se cliente foi criado normalmente
SELECT * FROM cliente WHERE nome = 'Pedro Teste Timestamp';

-- ========================================
-- TESTE 6: COMPARAÇÃO DE TIMESTAMPS
-- ========================================

-- Verificar diferença entre timestamps automáticos e explícitos
SELECT 
    'Automático' as tipo,
    v.dt_hora_venda,
    f.nome as funcionario,
    c.nome as cliente
FROM venda v
JOIN funcionario f ON v.cod_funcionario = f.cod_funcionario
JOIN cliente c ON v.cod_cliente = c.cod_cliente
WHERE c.nome = 'João Silva'
UNION ALL
SELECT 
    'Explícito' as tipo,
    v.dt_hora_venda,
    f.nome as funcionario,
    c.nome as cliente
FROM venda v
JOIN funcionario f ON v.cod_funcionario = f.cod_funcionario
JOIN cliente c ON v.cod_cliente = c.cod_cliente
WHERE c.nome = 'Maria Souza'
ORDER BY dt_hora_venda;

-- ========================================
-- LIMPEZA DOS TESTES
-- ========================================

-- Remover dados de teste
DELETE FROM item_venda WHERE cod_venda IN (
    SELECT cod_venda FROM venda WHERE cod_cliente IN (
        SELECT cod_cliente FROM cliente WHERE nome IN ('João Silva', 'Maria Souza', 'Pedro Teste Timestamp')
    )
);

DELETE FROM venda WHERE cod_cliente IN (
    SELECT cod_cliente FROM cliente WHERE nome IN ('João Silva', 'Maria Souza', 'Pedro Teste Timestamp')
);

DELETE FROM cliente WHERE nome IN ('João Silva', 'Maria Souza', 'Pedro Teste Timestamp');

DELETE FROM compra WHERE cod_fornecedor IN (
    SELECT cod_fornecedor FROM fornecedor WHERE nome IN ('Warner Bros', 'Disney')
);

-- ========================================
-- RESUMO DOS BENEFÍCIOS
-- ========================================
DO $$
BEGIN
    RAISE INFO '========================================';
    RAISE INFO 'AUTOMATIZAÇÃO DE TIMESTAMP IMPLEMENTADA!';
    RAISE INFO '========================================';
    RAISE INFO 'Benefícios:';
    RAISE INFO '- Vendas: dt_hora_venda adicionado automaticamente';
    RAISE INFO '- Compras: dt_compra adicionado automaticamente';
    RAISE INFO '- Reduz campos obrigatórios no JSON';
    RAISE INFO '- Mantém compatibilidade com timestamps explícitos';
    RAISE INFO '- Não afeta outras tabelas';
    RAISE INFO '- Mensagens informativas sobre campos adicionados';
    RAISE INFO '========================================';
END $$; 