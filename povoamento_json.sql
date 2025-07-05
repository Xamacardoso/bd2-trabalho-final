-- POVOAMENTO DE DADOS UTILIZANDO FUNÇÕES JSON
-- Este arquivo demonstra como usar as funções JSON para operações CRUD

-- ========================= POVOAMENTO BÁSICO =========================

-- Cadastro de categorias
SELECT f_cadastrar_json('categoria', '{"nome": "Ação"}');
SELECT f_cadastrar_json('categoria', '{"nome": "Comédia"}');
SELECT f_cadastrar_json('categoria', '{"nome": "Drama"}');
SELECT f_cadastrar_json('categoria', '{"nome": "Terror"}');
SELECT f_cadastrar_json('categoria', '{"nome": "Documentário"}');
SELECT f_cadastrar_json('categoria', '{"nome": "Romance"}');
SELECT f_cadastrar_json('categoria', '{"nome": "Ficção Científica"}');
SELECT f_cadastrar_json('categoria', '{"nome": "Aventura"}');
SELECT f_cadastrar_json('categoria', '{"nome": "Suspense"}');
SELECT f_cadastrar_json('categoria', '{"nome": "Animação"}');

SELECT * FROM categoria;

-- Cadastro de tipos de mídia
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "DVD"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "Blu-ray"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "VHS"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "Digital"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "4K Blu-ray"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "Streaming"}');

-- Cadastro de fornecedores
SELECT f_cadastrar_json('fornecedor', '{"nome": "Warner Bros", "telefone": "1111-1111", "email": "contato@warner.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Disney", "telefone": "2222-2222", "email": "contato@disney.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Universal Pictures", "telefone": "3333-3333", "email": "contato@universal.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Paramount", "telefone": "4444-4444", "email": "contato@paramount.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Sony Pictures", "telefone": "5555-5555", "email": "contato@sony.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "20th Century Fox", "telefone": "6666-6666", "email": "contato@fox.com"}');

SELECT * FROM fornecedor

-- Cadastro de clientes
SELECT f_cadastrar_json('cliente', '{"nome": "João Silva", "telefone": "9999-9999", "email": "joao@email.com", "cep": "64000-000"}');
SELECT f_cadastrar_json('cliente', '{"nome": "Maria Souza", "telefone": "8888-8888", "email": "maria@email.com", "cep": "64001-000"}');
SELECT f_cadastrar_json('cliente', '{"nome": "Pedro Alves", "telefone": "7777-8888", "email": "pedro@email.com", "cep": "64002-000"}');
SELECT f_cadastrar_json('cliente', '{"nome": "Luciana Dias", "telefone": "9999-7777", "email": "luciana@email.com", "cep": "64003-000"}');
SELECT f_cadastrar_json('cliente', '{"nome": "Bruno Costa", "telefone": "5555-6666", "email": "bruno@email.com", "cep": "64004-000"}');
SELECT f_cadastrar_json('cliente', '{"nome": "Fernanda Lima", "telefone": "4444-5555", "email": "fernanda@email.com", "cep": "64005-000"}');

-- Cadastro de funcionários
SELECT f_cadastrar_json('funcionario', '{"nome": "Carlos Lima", "telefone": "7777-7777", "cep": "64002-000", "salario": 2500.00}');
SELECT f_cadastrar_json('funcionario', '{"nome": "Ana Paula", "telefone": "6666-6666", "cep": "64003-000", "salario": 3200.00}');
SELECT f_cadastrar_json('funcionario', '{"nome": "Marcos Silva", "telefone": "3333-2222", "cep": "64006-000", "salario": 2800.00}');
SELECT f_cadastrar_json('funcionario', '{"nome": "Patricia Souza", "telefone": "2222-3333", "cep": "64007-000", "salario": 3500.00}');
SELECT f_cadastrar_json('funcionario', '{"nome": "Rafael Torres", "telefone": "1111-4444", "cep": "64008-000", "salario": 2700.00}');
SELECT f_cadastrar_json('funcionario', '{"nome": "Juliana Rocha", "telefone": "8888-1111", "cep": "64009-000", "salario": 4000.00}');

SELECT * FROM funcionario

-- Cadastro de títulos (FILMES FAMOSOS)
SELECT f_cadastrar_json('titulo', '{"nome": "O Poderoso Chefão", "classificacao_ind": 16, "ano_lancamento": 1972}');
SELECT f_cadastrar_json('titulo', '{"nome": "Pulp Fiction", "classificacao_ind": 18, "ano_lancamento": 1994}');
SELECT f_cadastrar_json('titulo', '{"nome": "Forrest Gump", "classificacao_ind": 12, "ano_lancamento": 1994}');
SELECT f_cadastrar_json('titulo', '{"nome": "Matrix", "classificacao_ind": 14, "ano_lancamento": 1999}');
SELECT f_cadastrar_json('titulo', '{"nome": "Titanic", "classificacao_ind": 12, "ano_lancamento": 1997}');
SELECT f_cadastrar_json('titulo', '{"nome": "O Senhor dos Anéis: A Sociedade do Anel", "classificacao_ind": 12, "ano_lancamento": 2001}');
SELECT f_cadastrar_json('titulo', '{"nome": "Interestelar", "classificacao_ind": 10, "ano_lancamento": 2014}');
SELECT f_cadastrar_json('titulo', '{"nome": "Vingadores: Ultimato", "classificacao_ind": 12, "ano_lancamento": 2019}');
SELECT f_cadastrar_json('titulo', '{"nome": "O Rei Leão", "classificacao_ind": 0, "ano_lancamento": 1994}');
SELECT f_cadastrar_json('titulo', '{"nome": "Jurassic Park", "classificacao_ind": 12, "ano_lancamento": 1993}');
SELECT f_cadastrar_json('titulo', '{"nome": "O Silêncio dos Inocentes", "classificacao_ind": 16, "ano_lancamento": 1991}');
SELECT f_cadastrar_json('titulo', '{"nome": "Clube da Luta", "classificacao_ind": 18, "ano_lancamento": 1999}');
SELECT f_cadastrar_json('titulo', '{"nome": "O Resgate do Soldado Ryan", "classificacao_ind": 16, "ano_lancamento": 1998}');
SELECT f_cadastrar_json('titulo', '{"nome": "Os Bons Companheiros", "classificacao_ind": 16, "ano_lancamento": 1990}');
SELECT f_cadastrar_json('titulo', '{"nome": "Um Sonho de Liberdade", "classificacao_ind": 14, "ano_lancamento": 1994}');

-- Cadastro de compras (com timestamp automático)
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Warner Bros", "total": 300.00}');
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Disney", "total": 500.00}');
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Universal Pictures", "total": 700.00}');
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Paramount", "total": 900.00}');
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "Sony Pictures", "total": 1200.00}');
SELECT f_cadastrar_json('compra', '{"nome_fornecedor": "20th Century Fox", "total": 1500.00}');

-- Cadastro de mídias (com preços variados baseados no tipo de mídia)
SELECT f_cadastrar_json('midia', '{"valor_unid": 25.00, "qtd_estoque": 15, "cod_tipo_midia": 1, "cod_titulo": 1}'); -- DVD O Poderoso Chefão
SELECT f_cadastrar_json('midia', '{"valor_unid": 45.00, "qtd_estoque": 8, "cod_tipo_midia": 2, "cod_titulo": 1}'); -- Blu-ray O Poderoso Chefão
SELECT f_cadastrar_json('midia', '{"valor_unid": 30.00, "qtd_estoque": 12, "cod_tipo_midia": 1, "cod_titulo": 2}'); -- DVD Pulp Fiction
SELECT f_cadastrar_json('midia', '{"valor_unid": 50.00, "qtd_estoque": 6, "cod_tipo_midia": 2, "cod_titulo": 2}'); -- Blu-ray Pulp Fiction
SELECT f_cadastrar_json('midia', '{"valor_unid": 20.00, "qtd_estoque": 20, "cod_tipo_midia": 1, "cod_titulo": 3}'); -- DVD Forrest Gump
SELECT f_cadastrar_json('midia', '{"valor_unid": 40.00, "qtd_estoque": 10, "cod_tipo_midia": 2, "cod_titulo": 3}'); -- Blu-ray Forrest Gump
SELECT f_cadastrar_json('midia', '{"valor_unid": 35.00, "qtd_estoque": 18, "cod_tipo_midia": 1, "cod_titulo": 4}'); -- DVD Matrix
SELECT f_cadastrar_json('midia', '{"valor_unid": 55.00, "qtd_estoque": 9, "cod_tipo_midia": 2, "cod_titulo": 4}'); -- Blu-ray Matrix
SELECT f_cadastrar_json('midia', '{"valor_unid": 25.00, "qtd_estoque": 25, "cod_tipo_midia": 1, "cod_titulo": 5}'); -- DVD Titanic
SELECT f_cadastrar_json('midia', '{"valor_unid": 45.00, "qtd_estoque": 12, "cod_tipo_midia": 2, "cod_titulo": 5}'); -- Blu-ray Titanic
SELECT f_cadastrar_json('midia', '{"valor_unid": 30.00, "qtd_estoque": 16, "cod_tipo_midia": 1, "cod_titulo": 6}'); -- DVD Senhor dos Anéis
SELECT f_cadastrar_json('midia', '{"valor_unid": 60.00, "qtd_estoque": 8, "cod_tipo_midia": 5, "cod_titulo": 6}'); -- 4K Senhor dos Anéis
SELECT f_cadastrar_json('midia', '{"valor_unid": 40.00, "qtd_estoque": 14, "cod_tipo_midia": 1, "cod_titulo": 7}'); -- DVD Interestelar
SELECT f_cadastrar_json('midia', '{"valor_unid": 70.00, "qtd_estoque": 7, "cod_tipo_midia": 5, "cod_titulo": 7}'); -- 4K Interestelar
SELECT f_cadastrar_json('midia', '{"valor_unid": 35.00, "qtd_estoque": 22, "cod_tipo_midia": 1, "cod_titulo": 8}'); -- DVD Vingadores
SELECT f_cadastrar_json('midia', '{"valor_unid": 65.00, "qtd_estoque": 11, "cod_tipo_midia": 5, "cod_titulo": 8}'); -- 4K Vingadores
SELECT f_cadastrar_json('midia', '{"valor_unid": 20.00, "qtd_estoque": 30, "cod_tipo_midia": 1, "cod_titulo": 9}'); -- DVD Rei Leão
SELECT f_cadastrar_json('midia', '{"valor_unid": 40.00, "qtd_estoque": 15, "cod_tipo_midia": 2, "cod_titulo": 9}'); -- Blu-ray Rei Leão
SELECT f_cadastrar_json('midia', '{"valor_unid": 25.00, "qtd_estoque": 18, "cod_tipo_midia": 1, "cod_titulo": 10}'); -- DVD Jurassic Park
SELECT f_cadastrar_json('midia', '{"valor_unid": 45.00, "qtd_estoque": 10, "cod_tipo_midia": 2, "cod_titulo": 10}'); -- Blu-ray Jurassic Park

SELECT * FROM midia;

-- Cadastro de vendas (com timestamp e total automáticos)
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva"}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Ana Paula", "nome_cliente": "Maria Souza"}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Marcos Silva", "nome_cliente": "Pedro Alves"}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Patricia Souza", "nome_cliente": "Luciana Dias"}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Rafael Torres", "nome_cliente": "Bruno Costa"}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Juliana Rocha", "nome_cliente": "Fernanda Lima"}');

SELECT * FROM venda

-- ========================= RELACIONAMENTOS USANDO f_cadastrar_json =========================

-- Relacionamentos título-categoria (usando f_cadastrar_json com nomes)
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "O Poderoso Chefão"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Drama", "nome_titulo": "O Poderoso Chefão"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "Pulp Fiction"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Comédia", "nome_titulo": "Pulp Fiction"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Drama", "nome_titulo": "Forrest Gump"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Romance", "nome_titulo": "Forrest Gump"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ficção Científica", "nome_titulo": "Matrix"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "Matrix"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Romance", "nome_titulo": "Titanic"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Drama", "nome_titulo": "Titanic"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Aventura", "nome_titulo": "O Senhor dos Anéis: A Sociedade do Anel"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ficção Científica", "nome_titulo": "O Senhor dos Anéis: A Sociedade do Anel"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ficção Científica", "nome_titulo": "Interestelar"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Drama", "nome_titulo": "Interestelar"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "Vingadores: Ultimato"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Aventura", "nome_titulo": "Vingadores: Ultimato"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Animação", "nome_titulo": "O Rei Leão"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Aventura", "nome_titulo": "O Rei Leão"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Aventura", "nome_titulo": "Jurassic Park"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ficção Científica", "nome_titulo": "Jurassic Park"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Suspense", "nome_titulo": "O Silêncio dos Inocentes"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Drama", "nome_titulo": "O Silêncio dos Inocentes"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Suspense", "nome_titulo": "Clube da Luta"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "Clube da Luta"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "O Resgate do Soldado Ryan"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Drama", "nome_titulo": "O Resgate do Soldado Ryan"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Ação", "nome_titulo": "Os Bons Companheiros"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Drama", "nome_titulo": "Os Bons Companheiros"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Drama", "nome_titulo": "Um Sonho de Liberdade"}');
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Suspense", "nome_titulo": "Um Sonho de Liberdade"}');

-- Itens de compra (usando f_cadastrar_json com nomes)
-- Nota: Os subtotais serão calculados automaticamente pelos triggers
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "1", "nome_midia": "O Poderoso Chefão", "quantidade": "10", "subtotal": "250.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "1", "nome_midia": "Pulp Fiction", "quantidade": "8", "subtotal": "240.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "2", "nome_midia": "Forrest Gump", "quantidade": "15", "subtotal": "300.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "2", "nome_midia": "Matrix", "quantidade": "12", "subtotal": "420.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "3", "nome_midia": "Titanic", "quantidade": "20", "subtotal": "500.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "3", "nome_midia": "O Senhor dos Anéis: A Sociedade do Anel", "quantidade": "10", "subtotal": "300.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "4", "nome_midia": "Interestelar", "quantidade": "8", "subtotal": "320.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "4", "nome_midia": "Vingadores: Ultimato", "quantidade": "6", "subtotal": "390.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "5", "nome_midia": "O Rei Leão", "quantidade": "25", "subtotal": "500.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "5", "nome_midia": "Jurassic Park", "quantidade": "12", "subtotal": "300.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "6", "nome_midia": "O Poderoso Chefão", "quantidade": "5", "subtotal": "225.00"}');
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "6", "nome_midia": "Pulp Fiction", "quantidade": "4", "subtotal": "200.00"}');

-- Itens de venda (usando f_cadastrar_json com nomes)
-- Nota: Os subtotais serão calculados automaticamente pelos triggers
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "O Poderoso Chefão", "cod_venda": "3", "qtd_item": "2"}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "Pulp Fiction", "cod_venda": "4", "qtd_item": "2"}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "Forrest Gump", "cod_venda": "5", "qtd_item": "2"}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "Matrix", "cod_venda": "6", "qtd_item": "2"}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "Titanic", "cod_venda": "7", "qtd_item": "2"}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "O Senhor dos Anéis: A Sociedade do Anel", "cod_venda": "8", "qtd_item": "2"}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "O Poderoso Chefão", "cod_venda": "3", "qtd_item": "2"}');
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "Pulp Fiction", "cod_venda": "4", "qtd_item": "2"}');

-- ========================= DEMONSTRAÇÃO DE OPERAÇÕES =========================

-- Demonstração de atualização usando JSON
SELECT f_alterar_json('cliente', '{"telefone": "9999-0000", "email": "joao.novo@email.com"}', 'nome = ''João Silva''');

-- Demonstração de atualização de salário
SELECT f_alterar_json('funcionario', '{"salario": 3800.00}', 'nome = ''Ana Paula''');

-- Demonstração de atualização de preço de mídia
SELECT f_alterar_json('midia', '{"valor_unid": 45.00, "qtd_estoque": 12}', 'cod_midia = 1');

-- ========================= CONSULTAS DE VERIFICAÇÃO =========================

-- Verificar dados inseridos
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
SELECT 'Vendas', COUNT(*) FROM venda
UNION ALL
SELECT 'Título-Categoria', COUNT(*) FROM titulo_categoria
UNION ALL
SELECT 'Itens de Compra', COUNT(*) FROM item_compra
UNION ALL
SELECT 'Itens de Venda', COUNT(*) FROM item_venda;

-- ========================= FUNÇÃO UNIVERSAL JSON =========================

-- Demonstração da função universal f_operacao_json
-- Inserir um novo cliente
SELECT f_operacao_json('INSERT', 'cliente', '{"nome": "Teste Universal", "telefone": "1234-5678", "email": "teste@universal.com", "cep": "64000-999"}');

-- Atualizar o cliente inserido
SELECT f_operacao_json('UPDATE', 'cliente', '{"telefone": "8765-4321"}', 'nome = ''Teste Universal''');

-- Remover o cliente de teste
SELECT f_operacao_json('DELETE', 'cliente', '{"nome": "Teste Universal"}');

-- ========================= LIMPEZA DE TESTES =========================

-- Comentado para não executar automaticamente
-- SELECT f_remover_json('cliente', '{"nome": "Teste Universal"}');

-- ========================= FIM DO POVOAMENTO ========================= 