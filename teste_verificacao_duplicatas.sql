-- Teste das verificações de duplicatas na função f_cadastrar_json
-- Este arquivo demonstra como a função previne inserções duplicadas

-- ========================================
-- PREPARAÇÃO: Inserir dados iniciais
-- ========================================

-- Inserir cliente inicial
SELECT f_cadastrar_json('cliente', '{
    "nome": "João Silva Santos",
    "telefone": "(11) 99999-9999",
    "email": "joao@email.com",
    "cep": "01234-567"
}');

-- Inserir funcionário inicial
SELECT f_cadastrar_json('funcionario', '{
    "nome": "Maria Oliveira Costa",
    "telefone": "(11) 88888-8888",
    "cep": "04567-890",
    "salario": "3000.00"
}');

-- Inserir fornecedor inicial
SELECT f_cadastrar_json('fornecedor', '{
    "nome": "Distribuidora ABC Ltda",
    "telefone": "(11) 77777-7777",
    "email": "contato@distribuidora.com"
}');

-- Inserir título inicial
SELECT f_cadastrar_json('titulo', '{
    "nome": "O Senhor dos Anéis",
    "classificacao_ind": "12",
    "ano_lancamento": "2001"
}');

-- Inserir tipo de mídia inicial
SELECT f_cadastrar_json('tipo_midia', '{
    "nome_formato": "DVD"
}');

-- Inserir categoria inicial
SELECT f_cadastrar_json('categoria', '{
    "nome": "Aventura"
}');

-- ========================================
-- TESTE 1: Tentar inserir cliente duplicado
-- ========================================

-- Este comando deve gerar erro (cliente com mesmo nome)
-- SELECT f_cadastrar_json('cliente', '{
--     "nome": "João Silva Santos",
--     "telefone": "(11) 11111-1111",
--     "email": "joao2@email.com",
--     "cep": "11111-111"
-- }');

-- Este comando deve gerar erro (cliente com mesmo email)
-- SELECT f_cadastrar_json('cliente', '{
--     "nome": "João Silva Santos Junior",
--     "telefone": "(11) 11111-1111",
--     "email": "joao@email.com",
--     "cep": "11111-111"
-- }');

-- ========================================
-- TESTE 2: Tentar inserir funcionário duplicado
-- ========================================

-- Este comando deve gerar erro (funcionário com mesmo nome)
-- SELECT f_cadastrar_json('funcionario', '{
--     "nome": "Maria Oliveira Costa",
--     "telefone": "(11) 11111-1111",
--     "cep": "11111-111",
--     "salario": "3500.00"
-- }');

-- ========================================
-- TESTE 3: Tentar inserir fornecedor duplicado
-- ========================================

-- Este comando deve gerar erro (fornecedor com mesmo nome)
-- SELECT f_cadastrar_json('fornecedor', '{
--     "nome": "Distribuidora ABC Ltda",
--     "telefone": "(11) 11111-1111",
--     "email": "vendas@distribuidora.com"
-- }');

-- Este comando deve gerar erro (fornecedor com mesmo email)
-- SELECT f_cadastrar_json('fornecedor', '{
--     "nome": "Distribuidora XYZ Ltda",
--     "telefone": "(11) 11111-1111",
--     "email": "contato@distribuidora.com"
-- }');

-- ========================================
-- TESTE 4: Tentar inserir título duplicado
-- ========================================

-- Este comando deve gerar erro (título com mesmo nome)
-- SELECT f_cadastrar_json('titulo', '{
--     "nome": "O Senhor dos Anéis",
--     "classificacao_ind": "16",
--     "ano_lancamento": "2002"
-- }');

-- ========================================
-- TESTE 5: Tentar inserir tipo de mídia duplicado
-- ========================================

-- Este comando deve gerar erro (tipo de mídia com mesmo nome)
-- SELECT f_cadastrar_json('tipo_midia', '{
--     "nome_formato": "DVD"
-- }');

-- ========================================
-- TESTE 6: Tentar inserir categoria duplicada
-- ========================================

-- Este comando deve gerar erro (categoria com mesmo nome)
-- SELECT f_cadastrar_json('categoria', '{
--     "nome": "Aventura"
-- }');

-- ========================================
-- TESTE 7: Inserir mídia e testar duplicata
-- ========================================

-- Inserir mídia inicial
SELECT f_cadastrar_json('midia', '{
    "valor_unid": "29.90",
    "qtd_estoque": "10",
    "nome_tipo_midia": "DVD",
    "nome_titulo": "O Senhor dos Anéis"
}');

-- Este comando deve gerar erro (mídia com mesmo título e tipo)
-- SELECT f_cadastrar_json('midia', '{
--     "valor_unid": "39.90",
--     "qtd_estoque": "5",
--     "nome_tipo_midia": "DVD",
--     "nome_titulo": "O Senhor dos Anéis"
-- }');

-- ========================================
-- TESTE 8: Inserir relação título-categoria e testar duplicata
-- ========================================

-- Inserir relação inicial
SELECT f_cadastrar_json('titulo_categoria', '{
    "nome_categoria": "Aventura",
    "nome_titulo": "O Senhor dos Anéis"
}');

-- Este comando deve gerar erro (relação já existe)
-- SELECT f_cadastrar_json('titulo_categoria', '{
--     "nome_categoria": "Aventura",
--     "nome_titulo": "O Senhor dos Anéis"
-- }');

-- ========================================
-- TESTE 9: Inserções válidas (não duplicadas)
-- ========================================

-- Inserir cliente válido (nome diferente)
SELECT f_cadastrar_json('cliente', '{
    "nome": "Pedro Oliveira",
    "telefone": "(11) 66666-6666",
    "email": "pedro@email.com",
    "cep": "06666-666"
}');

-- Inserir funcionário válido (nome diferente)
SELECT f_cadastrar_json('funcionario', '{
    "nome": "Ana Costa",
    "telefone": "(11) 55555-5555",
    "cep": "05555-555",
    "salario": "2800.00"
}');

-- Inserir título válido (nome diferente)
SELECT f_cadastrar_json('titulo', '{
    "nome": "Matrix",
    "classificacao_ind": "16",
    "ano_lancamento": "1999"
}');

-- ========================================
-- VERIFICAÇÃO DOS RESULTADOS
-- ========================================

-- Verificar clientes inseridos
SELECT 'CLIENTES' as info, cod_cliente, nome, email FROM cliente ORDER BY cod_cliente;

-- Verificar funcionários inseridos
SELECT 'FUNCIONARIOS' as info, cod_funcionario, nome, salario FROM funcionario ORDER BY cod_funcionario;

-- Verificar fornecedores inseridos
SELECT 'FORNECEDORES' as info, cod_fornecedor, nome, email FROM fornecedor ORDER BY cod_fornecedor;

-- Verificar títulos inseridos
SELECT 'TITULOS' as info, cod_titulo, nome, classificacao_ind, ano_lancamento FROM titulo ORDER BY cod_titulo;

-- Verificar tipos de mídia inseridos
SELECT 'TIPOS_MIDIA' as info, cod_tipo_midia, nome_formato FROM tipo_midia ORDER BY cod_tipo_midia;

-- Verificar categorias inseridas
SELECT 'CATEGORIAS' as info, cod_categoria, nome FROM categoria ORDER BY cod_categoria;

-- Verificar mídias inseridas
SELECT 'MIDIAS' as info, m.cod_midia, t.nome as titulo, tm.nome_formato as tipo, m.valor_unid, m.qtd_estoque
FROM midia m
JOIN titulo t ON m.cod_titulo = t.cod_titulo
JOIN tipo_midia tm ON m.cod_tipo_midia = tm.cod_tipo_midia
ORDER BY m.cod_midia;

-- Verificar relações título-categoria inseridas
SELECT 'TITULO_CATEGORIA' as info, tc.cod_titulo, t.nome as titulo, c.nome as categoria
FROM titulo_categoria tc
JOIN titulo t ON tc.cod_titulo = t.cod_titulo
JOIN categoria c ON tc.cod_categoria = c.cod_categoria
ORDER BY t.nome, c.nome;

-- ========================================
-- MENSAGENS DE ERRO ESPERADAS
-- ========================================

/*
Mensagens de erro que devem aparecer quando descomentar os comandos acima:

1. Cliente duplicado por nome:
   ERRO: Cliente com nome "João Silva Santos" já está cadastrado!

2. Cliente duplicado por email:
   ERRO: Cliente com email "joao@email.com" já está cadastrado!

3. Funcionário duplicado:
   ERRO: Funcionário com nome "Maria Oliveira Costa" já está cadastrado!

4. Fornecedor duplicado por nome:
   ERRO: Fornecedor com nome "Distribuidora ABC Ltda" já está cadastrado!

5. Fornecedor duplicado por email:
   ERRO: Fornecedor com email "contato@distribuidora.com" já está cadastrado!

6. Título duplicado:
   ERRO: Título "O Senhor dos Anéis" já está cadastrado!

7. Tipo de mídia duplicado:
   ERRO: Tipo de mídia "DVD" já está cadastrado!

8. Categoria duplicada:
   ERRO: Categoria "Aventura" já está cadastrada!

9. Mídia duplicada:
   ERRO: Mídia com título "O Senhor dos Anéis" e tipo "DVD" já está cadastrada!

10. Relação título-categoria duplicada:
    ERRO: Relação entre título "O Senhor dos Anéis" e categoria "Aventura" já existe!
*/

-- ========================================
-- LIMPEZA DOS DADOS DE TESTE
-- ========================================

-- Descomente as linhas abaixo para limpar os dados de teste
-- DELETE FROM titulo_categoria WHERE cod_titulo IN (SELECT cod_titulo FROM titulo WHERE nome IN ('O Senhor dos Anéis', 'Matrix'));
-- DELETE FROM midia WHERE cod_titulo IN (SELECT cod_titulo FROM titulo WHERE nome IN ('O Senhor dos Anéis', 'Matrix'));
-- DELETE FROM titulo WHERE nome IN ('O Senhor dos Anéis', 'Matrix');
-- DELETE FROM categoria WHERE nome = 'Aventura';
-- DELETE FROM tipo_midia WHERE nome_formato = 'DVD';
-- DELETE FROM fornecedor WHERE nome = 'Distribuidora ABC Ltda';
-- DELETE FROM funcionario WHERE nome IN ('Maria Oliveira Costa', 'Ana Costa');
-- DELETE FROM cliente WHERE nome IN ('João Silva Santos', 'Pedro Oliveira'); 