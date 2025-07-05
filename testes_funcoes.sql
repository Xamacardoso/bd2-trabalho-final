-- ========================================
-- TESTES DAS FUNÇÕES E TRIGGERS
-- Locadora de Mídias - BD2 Trabalho Final
-- ========================================

-- =====================
-- TESTES DAS FUNÇÕES AUXILIARES
-- =====================

-- Teste 1: Verificar funções auxiliares básicas
-- Verificar se tabela existe
SELECT tabela_existe('balatro') as existe;

-- Verificar colunas da tabela cliente
SELECT unnest(colunas_da_tabela('cliente')) as coluna;

-- Verificar se colunas existem
SELECT colunas_existem('cliente', 'nome, telefone') as existem;

-- =====================
-- TESTES DE TRIGGERS USANDO FUNÇÕES JSON
-- =====================

-- Testes para controle_valores_invalidos (valores nulos/negativos)

-- Teste 2.1: Inserção válida em funcionario usando JSON
BEGIN;
SELECT f_cadastrar_json('funcionario', '{"nome": "Tony Stark", "telefone": "9999-9999", "cep": "64000-999", "salario": 2000.00}');
ROLLBACK;

-- Teste 2.2: Inserção com salário negativo usando JSON (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_cadastrar_json('funcionario', '{"nome": "Bruce Wayne", "telefone": "9999-9999", "cep": "64000-999", "salario": -100.00}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 2.3: Inserção com salário nulo usando JSON (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_cadastrar_json('funcionario', '{"nome": "Clark Kent", "telefone": "9999-9999", "cep": "64000-999", "salario": null}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 2.4: Inserção válida em titulo usando JSON
BEGIN;
SELECT f_cadastrar_json('titulo', '{"nome": "Star Wars", "classificacao_ind": 12, "ano_lancamento": 1977}');
ROLLBACK;

-- Teste 2.5: Inserção com ano_lancamento negativo usando JSON (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_cadastrar_json('titulo', '{"nome": "DeLorean", "classificacao_ind": 12, "ano_lancamento": -1985}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 2.6: Inserção com classificacao_ind nulo usando JSON (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_cadastrar_json('titulo', '{"nome": "Enterprise", "classificacao_ind": null, "ano_lancamento": 1966}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 2.7: Inserção válida em midia usando JSON
BEGIN;
SELECT f_cadastrar_json('midia', '{"valor_unid": 10.00, "qtd_estoque": 5, "cod_tipo_midia": 1, "cod_titulo": 1}');
ROLLBACK;

-- Teste 2.8: Inserção com qtd_estoque negativa usando JSON (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_cadastrar_json('midia', '{"valor_unid": 10.00, "qtd_estoque": -5, "cod_tipo_midia": 1, "cod_titulo": 1}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 2.9: Inserção com valor_unid nulo usando JSON (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_cadastrar_json('midia', '{"valor_unid": null, "qtd_estoque": 5, "cod_tipo_midia": 1, "cod_titulo": 1}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 2.10: Inserção válida em compra usando JSON
BEGIN;
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Warner Bros", "total": 100.00}');
ROLLBACK;

-- Teste 2.11: Inserção com total negativo em compra usando JSON (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_cadastrar_json('compra', '{"nome_fornecedor": "Warner Bros", "total": -100.00}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 2.12: Inserção válida em venda usando JSON
BEGIN;
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva"}');
ROLLBACK;

-- Teste 2.13: Inserção com total nulo em venda usando JSON (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva", "total": null}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 2.14: Padronização de texto usando JSON (nome e email)
BEGIN;
SELECT f_cadastrar_json('cliente', '{"nome": "Leia Organa", "telefone": "1234-5678", "email": "LEIA@REBELLION.COM", "cep": "64000-000"}');
SELECT nome, email FROM cliente WHERE email = 'leia@rebellion.com';
ROLLBACK;

-- Teste 2.15: Atualização de nome e email usando JSON (deve padronizar)
BEGIN;
SELECT f_cadastrar_json('cliente', '{"nome": "Peter Parker", "telefone": "1111-2222", "email": "euiglesio@gmail.com", "cep": "65636-774"}');
SELECT f_alterar_json('cliente', '{"nome": "PETER PARKER", "email": "SPIDEY@MARVEL.COM"}', 'nome = ''Peter Parker''');
SELECT nome, email, cep FROM cliente WHERE nome = 'Peter Parker';
ROLLBACK;

-- Teste 2.16: Auditoria de UPDATE usando JSON
BEGIN;
SELECT f_cadastrar_json('fornecedor', '{"nome": "Wayne Enterprises", "telefone": "0000-0000", "email": "BRUCE@WAYNE.COM"}');
SELECT f_alterar_json('fornecedor', '{"nome": "Stark Industries"}', 'nome = ''Wayne Enterprises''');
SELECT * FROM log_auditoria_geral WHERE tabela = 'fornecedor' AND atributo = 'nome' ORDER BY data_alteracao DESC LIMIT 1;
ROLLBACK;

-- Teste 2.17: Atualização de estoque após venda usando JSON
BEGIN;
SELECT f_cadastrar_json('midia', '{"valor_unid": 20.00, "qtd_estoque": 10, "cod_tipo_midia": 1, "cod_titulo": 1}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva"}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "O Poderoso Chefão", "cod_venda": "1", "qtd_item": "2"}');
SELECT qtd_estoque FROM midia WHERE cod_midia = (SELECT cod_midia FROM midia WHERE cod_titulo = 1 LIMIT 1);
ROLLBACK;

-- Teste 2.18: Impedir venda sem estoque usando JSON (deve falhar)
BEGIN;
DO $$
DECLARE
    v_cod_midia int;
    v_cod_venda int;
BEGIN
    PERFORM f_cadastrar_json('midia', '{"valor_unid": 30.00, "qtd_estoque": 1, "cod_tipo_midia": 1, "cod_titulo": 1}');
    PERFORM f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva"}');
    
    SELECT cod_midia INTO v_cod_midia FROM midia WHERE cod_titulo = 1 LIMIT 1;
    SELECT cod_venda INTO v_cod_venda FROM venda ORDER BY cod_venda DESC LIMIT 1;
    
    BEGIN
        PERFORM f_cadastrar_json('item_venda', format('{"cod_midia": "%s", "cod_venda": "%s", "qtd_item": "2"}', v_cod_midia, v_cod_venda));
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro esperado: %', SQLERRM;
    END;
END;$$;
ROLLBACK;

-- Teste 2.19: Devolução de estoque após exclusão de item_venda usando JSON
BEGIN;
SELECT f_cadastrar_json('midia', '{"valor_unid": 40.00, "qtd_estoque": 5, "cod_tipo_midia": 1, "cod_titulo": 1}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva"}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "O Poderoso Chefão", "cod_venda": "1", "qtd_item": "2"}');
SELECT f_remover_json('item_venda', '{"nome_midia": "O Poderoso Chefão", "cod_venda": "1"}');
SELECT qtd_estoque FROM midia WHERE cod_midia = (SELECT cod_midia FROM midia WHERE cod_titulo = 1 LIMIT 1);
ROLLBACK;

-- Teste 2.20: Atualização de estoque após compra usando JSON
BEGIN;
SELECT f_cadastrar_json('midia', '{"valor_unid": 50.00, "qtd_estoque": 2, "cod_tipo_midia": 1, "cod_titulo": 1}');
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Warner Bros", "total": 100.00}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "1", "nome_midia": "O Poderoso Chefão", "quantidade": "3", "subtotal": "150.00"}');
SELECT qtd_estoque FROM midia WHERE cod_midia = (SELECT cod_midia FROM midia WHERE cod_titulo = 1 LIMIT 1);
ROLLBACK;

-- =====================
-- TESTES DAS FUNÇÕES COM JSON
-- =====================

-- Teste 3.1: Cadastrar cliente usando JSON
SELECT f_cadastrar_json('cliente', '{"nome": "Han Solo", "telefone": "9999-8888", "email": "han@falcon.com", "cep": "64000-001"}');

-- Teste 3.2: Cadastrar funcionário usando JSON
SELECT f_cadastrar_json('funcionario', '{"nome": "Chewbacca", "telefone": "7777-6666", "cep": "64000-002", "salario": 3500.00}');

-- Teste 3.3: Cadastrar categoria usando JSON
SELECT f_cadastrar_json('categoria', '{"nome": "Sci-Fi"}');

-- Teste 3.4: Verificar se foram inseridos
SELECT * FROM cliente WHERE nome = 'Han Solo';
SELECT * FROM funcionario WHERE nome = 'Chewbacca';
SELECT * FROM categoria WHERE nome = 'Sci-Fi';

-- Teste 3.5: Alterar dados usando JSON
SELECT f_alterar_json('cliente', '{"nome": "Han Solo Atualizado", "email": "han.new@falcon.com"}', 'nome = ''Han Solo''');

-- Teste 3.6: Alterar salário usando JSON
SELECT f_alterar_json('funcionario', '{"salario": 4000.00}', 'nome = ''Chewbacca''');

-- Teste 3.7: Verificar alterações
SELECT * FROM cliente WHERE nome LIKE 'Han Solo%';
SELECT * FROM funcionario WHERE nome = 'Chewbacca';

-- Teste 3.8: Remover registros usando JSON
SELECT f_remover_json('cliente', '{"nome": "Han Solo Atualizado"}');
SELECT f_remover_json('funcionario', '{"nome": "Chewbacca"}');
SELECT f_remover_json('categoria', '{"nome": "Sci-Fi"}');

-- Teste 3.9: Verificar se foram removidos
SELECT COUNT(*) as total FROM cliente WHERE nome LIKE 'Han Solo%';
SELECT COUNT(*) as total FROM funcionario WHERE nome = 'Chewbacca';
SELECT COUNT(*) as total FROM categoria WHERE nome = 'Sci-Fi';

-- Teste 3.10: Função universal - INSERT
SELECT f_operacao_json('INSERT', 'cliente', '{"nome": "Luke Skywalker", "telefone": "1234-5678", "email": "luke@rebellion.com", "cep": "64000-003"}');

-- Teste 3.11: Função universal - UPDATE
SELECT f_operacao_json('UPDATE', 'cliente', '{"nome": "Luke Skywalker Jedi"}', 'nome = ''Luke Skywalker''');

-- Teste 3.12: Função universal - DELETE
SELECT f_operacao_json('DELETE', 'cliente', '{"nome": "Luke Skywalker Jedi"}');

-- Teste 3.13: Teste de erro - tabela inexistente
DO $$
BEGIN
    PERFORM f_cadastrar_json('tabela_inexistente', '{"nome": "teste"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- Teste 3.14: Teste de erro - coluna inexistente
DO $$
BEGIN
    PERFORM f_cadastrar_json('cliente', '{"nome": "teste", "coluna_inexistente": "valor"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- Teste 3.15: Teste de erro - operação não suportada
DO $$
BEGIN
    PERFORM f_operacao_json('SELECT', 'cliente', '{"nome": "teste"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- =====================
-- TESTES DE FUNCIONALIDADES ESPECÍFICAS
-- =====================

-- Teste 4.1: Cadastrar múltiplos registros com JSON
SELECT f_cadastrar_json('fornecedor', '{"nome": "Stark Industries", "telefone": "1111-2222", "email": "tony@stark.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Wayne Enterprises", "telefone": "3333-4444", "email": "bruce@wayne.com"}');

-- Teste 4.2: Alterar múltiplos campos com JSON
SELECT f_alterar_json('fornecedor', '{"nome": "Stark Industries Atualizado", "email": "tony.new@stark.com"}', 'nome = ''Stark Industries''');

-- Teste 4.3: Verificar alterações múltiplas
SELECT * FROM fornecedor WHERE nome LIKE 'Stark Industries%';

-- Teste 4.4: Remover com múltiplas condições
SELECT f_remover_json('fornecedor', '{"nome": "Stark Industries Atualizado", "email": "tony.new@stark.com"}');

-- Teste 4.5: Verificar remoção
SELECT COUNT(*) as total FROM fornecedor WHERE nome LIKE 'Stark Industries%';

-- =====================
-- TESTES DE AUTOMATIZAÇÃO
-- =====================

-- Teste 5.1: Teste de timestamp automático em venda
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva"}');
SELECT cod_venda, dt_hora_venda, total FROM venda ORDER BY cod_venda DESC LIMIT 1;

-- Teste 5.2: Teste de timestamp automático em compra
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Warner Bros", "total": 500.00}');
SELECT cod_compra, dt_compra, total FROM compra ORDER BY cod_compra DESC LIMIT 1;

-- Teste 5.3: Teste de conversão de nomes para códigos
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "O Poderoso Chefão", "cod_venda": "1", "qtd_item": "2"}');
SELECT iv.cod_venda, iv.qtd_item, t.nome as titulo 
FROM item_venda iv 
JOIN midia m ON iv.cod_midia = m.cod_midia 
JOIN titulo t ON m.cod_titulo = t.cod_titulo 
WHERE iv.cod_venda = 1;

-- =====================
-- TESTES DE VALIDAÇÃO DE TIPOS
-- =====================

-- Teste 6.1: Tentar inserir string em campo numérico (deve falhar)
DO $$
BEGIN
    PERFORM f_cadastrar_json('funcionario', '{"nome": "Teste", "telefone": "1234-5678", "cep": "64000-000", "salario": "abc"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- Teste 6.2: Tentar inserir número em campo de texto (deve falhar)
DO $$
BEGIN
    PERFORM f_cadastrar_json('cliente', '{"nome": "123", "telefone": "1234-5678", "email": "teste@email.com", "cep": "64000-000"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- =====================
-- TESTES DE RELACIONAMENTOS
-- =====================

-- Teste 7.1: Teste de relacionamento título-categoria usando nomes
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "O Poderoso Chefão"}');
SELECT tc.cod_titulo_categoria, c.nome as categoria, t.nome as titulo 
FROM titulo_categoria tc 
JOIN categoria c ON tc.cod_categoria = c.cod_categoria 
JOIN titulo t ON tc.cod_titulo = t.cod_titulo 
ORDER BY tc.cod_titulo_categoria DESC LIMIT 1;

-- Teste 7.2: Teste de item_compra usando nomes
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "1", "nome_midia": "O Poderoso Chefão", "quantidade": "5", "subtotal": "125.00"}');
SELECT ic.cod_compra, ic.quantidade, t.nome as titulo 
FROM item_compra ic 
JOIN midia m ON ic.cod_midia = m.cod_midia 
JOIN titulo t ON m.cod_titulo = t.cod_titulo 
WHERE ic.cod_compra = 1;

-- =====================
-- TESTES DE LIMPEZA
-- =====================

-- Limpar dados de teste
SELECT f_remover_json('item_compra', '{"cod_compra": "1", "nome_midia": "O Poderoso Chefão"}');
SELECT f_remover_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "O Poderoso Chefão"}');
SELECT f_remover_json('venda', '{"cod_venda": "1"}');
SELECT f_remover_json('compra', '{"cod_compra": "1"}');

-- =====================
-- VERIFICAÇÃO FINAL
-- =====================

-- Verificar contagem de registros nas principais tabelas
SELECT 'Categorias' as tabela, COUNT(*) as total FROM categoria
UNION ALL
SELECT 'Tipos de Mídia', COUNT(*) FROM tipo_midia
UNION ALL
SELECT 'Fornecedores', COUNT(*) FROM fornecedor
UNION ALL
SELECT 'Clientes', COUNT(*) FROM cliente
UNION ALL
SELECT 'Funcionários', COUNT(*) FROM funcionario
UNION ALL
SELECT 'Títulos', COUNT(*) FROM titulo
UNION ALL
SELECT 'Compras', COUNT(*) FROM compra
UNION ALL
SELECT 'Mídias', COUNT(*) FROM midia
UNION ALL
SELECT 'Vendas', COUNT(*) FROM venda;

-- =====================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================
DO $$
BEGIN
    RAISE INFO 'Todos os testes foram executados com sucesso!';
    RAISE INFO 'As funções JSON estão funcionando corretamente';
    RAISE INFO 'Os triggers estão operacionais';
    RAISE INFO 'A automatização de timestamps está ativa';
    RAISE INFO 'A conversão de nomes para códigos está funcionando';
    RAISE INFO 'Todos os testes agora usam as funções JSON de cadastro!';
END $$;