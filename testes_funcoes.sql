-- Teste 1: Cadastrar novos registros
SELECT f_cadastrar('cliente', 'nome, telefone, email, cep', 
                   '''Teste Cliente'', ''1111-2222'', ''teste@email.com'', ''64000-001''');

-- Cadastrar um novo funcionário
SELECT f_cadastrar('funcionario', 'nome, telefone, cep, salario', 
                   '''Teste Funcionário'', ''3333-4444'', ''64000-002'', 2800.00');

-- Verificar se foram inseridos
SELECT * FROM cliente WHERE nome = 'Teste Cliente';
SELECT * FROM funcionario WHERE nome = 'Teste Funcionário';

-- Teste 2: Alterar registros

-- Alterar dados do cliente
SELECT f_alterar('cliente', 'nome = ''Teste Cliente Atualizado'', telefone = ''5555-6666''', 
                 'nome = ''Teste Cliente''');

-- Alterar salário do funcionário
SELECT f_alterar('funcionario', 'salario = 3200.00', 'nome = ''Teste Funcionário''');

-- Verificar alterações
SELECT * FROM cliente WHERE nome LIKE 'Teste Cliente%';
SELECT * FROM funcionario WHERE nome = 'Teste Funcionário';

-- Teste 3: Tentar remover registros com integridade referencial

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

-- Teste 4: Remover registros sem dependências

-- Remover os registros de teste criados
SELECT f_remover('cliente', 'nome LIKE ''Teste Cliente%''');
SELECT f_remover('funcionario', 'nome = ''Teste Funcionário''');

-- Verificar se foram removidos
SELECT COUNT(*) as total FROM cliente WHERE nome LIKE 'Teste Cliente%';
SELECT COUNT(*) as total FROM funcionario WHERE nome = 'Teste Funcionário';

-- Teste 5: Testar com tabelas diferentes

-- Cadastrar nova categoria
SELECT f_cadastrar('categoria', 'nome', '''Categoria Teste''');

-- Cadastrar novo tipo de mídia
SELECT f_cadastrar('tipo_midia', 'nome_formato', '''Formato Teste''');

-- Alterar categoria
SELECT f_alterar('categoria', 'nome = ''Categoria Teste Alterada''', 'nome = ''Categoria Teste''');

-- Remover registros de teste
SELECT f_remover('categoria', 'nome = ''Categoria Teste Alterada''');
SELECT f_remover('tipo_midia', 'nome_formato = ''Formato Teste''');

-- Teste 6: Verificar funções auxiliares básicas
-- Verificar se tabela existe
SELECT tabela_existe('cliente') as existe;

-- Verificar colunas da tabela cliente
SELECT unnest(colunas_da_tabela('cliente')) as coluna;

-- Verificar se colunas existem
SELECT colunas_existem('cliente', 'nome, telefone') as existem;