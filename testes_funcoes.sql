-- Teste 1: Tentar remover registros com integridade referencial

-- Tentar remover um fornecedor que tem compras (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_remover('fornecedor', 'cod_fornecedor = 1');
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;
$$;
ROLLBACK;

-- Tentar remover uma categoria que tem títulos (deve falhar)
BEGIN;
DO $$
BEGIN
    PERFORM f_remover('categoria', 'cod_categoria = 1');
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;
$$;
ROLLBACK;

-- Teste 6: Verificar funções auxiliares básicas
-- Verificar se tabela existe
SELECT tabela_existe('balatro') as existe;

-- Verificar colunas da tabela cliente
SELECT unnest(colunas_da_tabela('cliente')) as coluna;

-- Verificar se colunas existem
SELECT colunas_existem('cliente', 'balatro, telefone') as existem;

-- =====================
-- Testes de TRIGGERS
-- =====================

-- Testes para controle_valores_invalidos (valores nulos/negativos)

-- Teste 7.1: Inserção válida em funcionario
BEGIN;
INSERT INTO funcionario (nome, telefone, cep, salario) VALUES ('Tony Stark', '9999-9999', '64000-999', 2000.00);
ROLLBACK;

-- Teste 7.2: Inserção com salário negativo (deve falhar)
BEGIN;
DO $$
BEGIN
    INSERT INTO funcionario (nome, telefone, cep, salario) VALUES ('Bruce Wayne', '9999-9999', '64000-999', -100.00);
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 7.3: Inserção com salário nulo (deve falhar)

BEGIN;
DO $$
BEGIN
    INSERT INTO funcionario (nome, telefone, cep, salario) VALUES ('Clark Kent', '9999-9999', '64000-999', NULL);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 7.4: Inserção válida em titulo
BEGIN;
INSERT INTO titulo (nome, classificacao_ind, ano_lancamento) VALUES ('Star Wars', 12, 1977);
ROLLBACK;

-- Teste 7.5: Inserção com ano_lancamento negativo (deve falhar)

BEGIN;
DO $$
BEGIN
    INSERT INTO titulo (nome, classificacao_ind, ano_lancamento) VALUES ('DeLorean', 12, -1985);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 7.6: Inserção com classificacao_ind nulo (deve falhar)
BEGIN;
DO $$
BEGIN
    INSERT INTO titulo (nome, classificacao_ind, ano_lancamento) VALUES ('Enterprise', NULL, 1966);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 7.7: Inserção válida em midia
BEGIN;
INSERT INTO midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) VALUES (10.00, 5, 1, 1);
ROLLBACK;

-- Teste 7.8: Inserção com qtd_estoque negativa (deve falhar)
BEGIN;
DO $$
BEGIN
    INSERT INTO midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) VALUES (10.00, -5, 1, 1);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 7.9: Inserção com valor_unid nulo (deve falhar)
BEGIN;
DO $$
BEGIN
    INSERT INTO midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) VALUES (NULL, 5, 1, 1);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 7.10: Inserção válida em compra
BEGIN;
INSERT INTO compra (cod_fornecedor, total, dt_compra) VALUES (1, 100.00, now());
ROLLBACK;

-- Teste 7.11: Inserção com total negativo em compra (deve falhar)
BEGIN;
DO $$
BEGIN
    INSERT INTO compra (cod_fornecedor, total, dt_compra) VALUES (1, -100.00, now());
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 7.12: Inserção válida em venda
BEGIN;
INSERT INTO venda (cod_funcionario, cod_cliente, dt_hora_venda, total) VALUES (1, 1, now(), 50.00);
ROLLBACK;

-- Teste 7.13: Inserção com total nulo em venda (deve falhar)
BEGIN;
DO $$
BEGIN
    INSERT INTO venda (cod_funcionario, cod_cliente, dt_hora_venda, total) VALUES (1, 1, now(), NULL);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;
ROLLBACK;

-- Teste 7.14: Padronização de texto (nome e email)
BEGIN;
INSERT INTO cliente (nome, telefone, email, cep) VALUES ('Leia Organa', '1234-5678', 'LEIA@REBELLION.COM', '64000-000');
SELECT nome, email FROM cliente WHERE email = 'leia@rebellion.com';
ROLLBACK;

-- Teste 7.15: Atualização de nome e email (deve padronizar)
BEGIN;
INSERT INTO cliente (nome, telefone, email, cep) VALUES ('Peter Parker', '1111-2222', 'euiglesio@gmail.com', '65636-774');
UPDATE cliente SET nome = 'PETER PARKER', email = 'SPIDEY@MARVEL.COM' WHERE nome = 'Peter Parker';
SELECT nome, email, cep FROM cliente WHERE nome = 'Peter Parker';
ROLLBACK;

-- Teste 7.16: Auditoria de UPDATE
BEGIN;
INSERT INTO fornecedor (nome, telefone, email) VALUES ('Wayne Enterprises', '0000-0000', 'BRUCE@WAYNE.COM');
UPDATE fornecedor SET nome = 'Stark Industries' WHERE nome = 'Wayne Enterprises';
SELECT * FROM log_auditoria_geral WHERE tabela = 'fornecedor' AND atributo = 'nome' ORDER BY data_alteracao DESC LIMIT 1;
ROLLBACK;

-- Teste 7.17: Atualização de estoque após venda
BEGIN;
INSERT INTO midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) VALUES (20.00, 10, 1, 1);
INSERT INTO venda (cod_funcionario, cod_cliente, dt_hora_venda, total) VALUES (1, 1, now(), 0);
INSERT INTO item_venda (cod_midia, cod_venda, subtotal, qtd_item) VALUES (currval('midia_cod_midia_seq'), currval('venda_cod_venda_seq'), 40.00, 2);
SELECT qtd_estoque FROM midia WHERE cod_midia = currval('midia_cod_midia_seq');
ROLLBACK;

-- Teste 7.18: Impedir venda sem estoque (deve falhar)
BEGIN;
DO $$
DECLARE
    v_cod_midia int;
    v_cod_venda int;
BEGIN
    INSERT INTO midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) VALUES (30.00, 1, 1, 1) RETURNING cod_midia INTO v_cod_midia;
    INSERT INTO venda (cod_funcionario, cod_cliente, dt_hora_venda, total) VALUES (1, 1, now(), 0) RETURNING cod_venda INTO v_cod_venda;
    BEGIN
        INSERT INTO item_venda (cod_midia, cod_venda, subtotal, qtd_item) VALUES (v_cod_midia, v_cod_venda, 60.00, 2);
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro esperado: %', SQLERRM;
    END;
END;$$;
ROLLBACK;

-- Teste 7.19: Devolução de estoque após exclusão de item_venda
BEGIN;
INSERT INTO midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) VALUES (40.00, 5, 1, 1);
INSERT INTO venda (cod_funcionario, cod_cliente, dt_hora_venda, total) VALUES (1, 1, now(), 0);
INSERT INTO item_venda (cod_midia, cod_venda, subtotal, qtd_item) VALUES (currval('midia_cod_midia_seq'), currval('venda_cod_venda_seq'), 80.00, 2);
DELETE FROM item_venda WHERE cod_midia = currval('midia_cod_midia_seq') AND cod_venda = currval('venda_cod_venda_seq');
SELECT qtd_estoque FROM midia WHERE cod_midia = currval('midia_cod_midia_seq');
ROLLBACK;

-- Teste 7.20: Atualização de estoque após compra
BEGIN;
INSERT INTO midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) VALUES (50.00, 2, 1, 1);
INSERT INTO compra (cod_fornecedor, total, dt_compra) VALUES (1, 100.00, now());
INSERT INTO item_compra (cod_compra, cod_midia, quantidade, subtotal) VALUES (currval('compra_cod_compra_seq'), currval('midia_cod_midia_seq'), 3, 150.00);
SELECT qtd_estoque FROM midia WHERE cod_midia = currval('midia_cod_midia_seq');
ROLLBACK;

SELECT * FROM COMPRA ORDER BY cod_compra DESC;

SELECT * FROM midia ORDER BY cod_midia desc;

SELECT * FROM item_compra ORDER BY cod_compra DESC;
-- ========================================
-- TESTES DAS FUNÇÕES COM JSON
-- ========================================

-- Teste 8.1: Cadastrar cliente usando JSON
SELECT f_cadastrar_json('cliente', '{"nome": "Han Solo", "telefone": "9999-8888", "email": "han@falcon.com", "cep": "64000-001"}');

SELECT * FROM cliente;
-- Teste 8.2: Cadastrar funcionário usando JSON
SELECT f_cadastrar_json('funcionario', '{"nome": "Chewbacca", "telefone": "7777-6666", "cep": "64000-002", "salario": 3500.00}');

SELECT * FROM funcionario;
-- Teste 8.3: Cadastrar categoria usando JSON
SELECT f_cadastrar_json('categoria', '{"nome": "Sci-Fi"}');

SELECT * FROM categoria;

-- Teste 8.4: Verificar se foram inseridos
SELECT * FROM cliente WHERE nome = 'Han Solo';
SELECT * FROM funcionario WHERE nome = 'Chewbacca';
SELECT * FROM categoria WHERE nome = 'Sci-Fi';

-- Teste 8.5: Alterar dados usando JSON
SELECT f_alterar_json('cliente', '{"nome": "Han Solo Atualizado", "email": "han.new@falcon.com"}', 'nome = ''Han Solo''');

-- Teste 8.6: Alterar salário usando JSON
SELECT f_alterar_json('funcionario', '{"salario": 4000.00}', 'nome = ''Chewbacca''');

-- Teste 8.7: Verificar alterações
SELECT * FROM cliente WHERE nome LIKE 'Han Solo%';
SELECT * FROM funcionario WHERE nome = 'Chewbacca';

-- Teste 8.8: Remover registros usando JSON
SELECT f_remover_json('cliente', '{"nome": "Han Solo Atualizado"}');
SELECT f_remover_json('funcionario', '{"nome": "Chewbacca"}');
SELECT f_remover_json('categoria', '{"nome": "Sci-Fi"}');

-- Teste 8.9: Verificar se foram removidos
SELECT COUNT(*) as total FROM cliente WHERE nome LIKE 'Han Solo%';
SELECT COUNT(*) as total FROM funcionario WHERE nome = 'Chewbacca';
SELECT COUNT(*) as total FROM categoria WHERE nome = 'Sci-Fi';

-- Teste 8.10: Função universal - INSERT
SELECT f_operacao_json('INSERT', 'cliente', '{"nome": "Luke Skywalker", "telefone": "1234-5678", "email": "luke@rebellion.com", "cep": "64000-003"}');

-- Teste 8.11: Função universal - UPDATE
SELECT f_operacao_json('UPDATE', 'cliente', '{"nome": "Luke Skywalker Jedi"}', 'nome = ''Luke Skywalker''');

-- Teste 8.12: Função universal - DELETE
SELECT f_operacao_json('DELETE', 'cliente', '{"nome": "Luke Skywalker Jedi"}');

-- Teste 8.13: Teste de erro - tabela inexistente
DO $$
BEGIN
    PERFORM f_cadastrar_json('tabela_inexistente', '{"nome": "teste"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- Teste 8.14: Teste de erro - coluna inexistente
DO $$
BEGIN
    PERFORM f_cadastrar_json('cliente', '{"nome": "teste", "coluna_inexistente": "valor"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- Teste 8.15: Teste de erro - operação não suportada
DO $$
BEGIN
    PERFORM f_operacao_json('SELECT', 'cliente', '{"nome": "teste"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- Teste 8.16: Cadastrar múltiplos registros com JSON
SELECT f_cadastrar_json('fornecedor', '{"nome": "Stark Industries", "telefone": "1111-2222", "email": "tony@stark.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Wayne Enterprises", "telefone": "3333-4444", "email": "bruce@wayne.com"}');

-- Teste 8.17: Alterar múltiplos campos com JSON
SELECT f_alterar_json('fornecedor', '{"nome": "Stark Industries Atualizado", "email": "tony.new@stark.com"}', 'nome = ''Stark Industries''');

-- Teste 8.18: Verificar alterações múltiplas
SELECT * FROM fornecedor WHERE nome LIKE 'Stark Industries%';

-- Teste 8.19: Remover com múltiplas condições
SELECT f_remover_json('fornecedor', '{"nome": "Stark Industries Atualizado", "email": "tony.new@stark.com"}');

-- Teste 8.20: Verificar remoção
SELECT COUNT(*) as total FROM fornecedor WHERE nome LIKE 'Stark Industries%';

-- ========================================
-- TESTES DAS FUNÇÕES COM JSON (NUMERAÇÃO CONTINUADA)
-- ========================================

-- Teste 9.1: Inserção de cliente usando f_cadastrar_json
SELECT f_cadastrar_json('cliente', '{"nome": "Bilbo Baggins", "telefone": "5555-1234", "email": "bilbo@bolseiro.com", "cep": "64000-111"}');

-- Teste 9.2: Inserção de funcionário usando f_cadastrar_json
SELECT f_cadastrar_json('funcionario', '{"nome": "Gandalf", "telefone": "5555-5678", "cep": "64000-222", "salario": 9999.99}');

-- Teste 9.3: Verificar inserção
SELECT * FROM cliente WHERE nome = 'Bilbo Baggins';
SELECT * FROM funcionario WHERE nome = 'Gandalf';

-- Teste 9.4: Atualização de cliente usando f_alterar_json
SELECT f_alterar_json('cliente', '{"email": "bilbo@shire.com"}', 'nome = ''Bilbo Baggins''');

-- Teste 9.5: Atualização de funcionário usando f_alterar_json
SELECT f_alterar_json('funcionario', '{"salario": 12345.67}', 'nome = ''Gandalf''');

-- Teste 9.6: Verificar atualização
SELECT * FROM cliente WHERE nome = 'Bilbo Baggins';
SELECT * FROM funcionario WHERE nome = 'Gandalf';

-- Teste 9.7: Remoção de cliente usando f_remover_json
SELECT f_remover_json('cliente', '{"nome": "Bilbo Baggins"}');

-- Teste 9.8: Remoção de funcionário usando f_remover_json
SELECT f_remover_json('funcionario', '{"nome": "Gandalf"}');

-- Teste 9.9: Verificar remoção
SELECT COUNT(*) as total FROM cliente WHERE nome = 'Bilbo Baggins';
SELECT COUNT(*) as total FROM funcionario WHERE nome = 'Gandalf';

-- Teste 9.10: Inserção universal com f_operacao_json
SELECT f_operacao_json('INSERT', 'categoria', '{"nome": "Fantasia"}');

-- Teste 9.11: Atualização universal com f_operacao_json
SELECT f_operacao_json('UPDATE', 'categoria', '{"nome": "Fantasia Épica"}', 'nome = ''Fantasia''');

-- Teste 9.12: Remoção universal com f_operacao_json
SELECT f_operacao_json('DELETE', 'categoria', '{"nome": "Fantasia Épica"}');

-- Teste 9.13: Verificar remoção universal
SELECT COUNT(*) as total FROM categoria WHERE nome = 'Fantasia Épica';

-- Teste 9.14: Erro esperado - tabela inexistente
DO $$
BEGIN
    PERFORM f_cadastrar_json('tabela_inexistente', '{"nome": "teste"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- Teste 9.15: Erro esperado - coluna inexistente
DO $$
BEGIN
    PERFORM f_cadastrar_json('cliente', '{"nome": "teste", "coluna_inexistente": "valor"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;

-- Teste 9.16: Erro esperado - operação não suportada
DO $$
BEGIN
    PERFORM f_operacao_json('SELECT', 'cliente', '{"nome": "teste"}');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro esperado: %', SQLERRM;
END;$$;