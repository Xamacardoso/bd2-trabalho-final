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

-- Cadastro de vendas (com timestamp automático)
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Carlos Lima", "nome_cliente": "João Silva", "total": 70.00}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Ana Paula", "nome_cliente": "Maria Souza", "total": 95.00}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Marcos Silva", "nome_cliente": "Pedro Alves", "total": 120.00}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Patricia Souza", "nome_cliente": "Luciana Dias", "total": 85.00}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Rafael Torres", "nome_cliente": "Bruno Costa", "total": 135.00}');
SELECT f_cadastrar_json('venda', '{"nome_funcionario": "Juliana Rocha", "nome_cliente": "Fernanda Lima", "total": 200.00}');

SELECT * FROM venda

-- ========================= RELACIONAMENTOS =========================

-- Relacionamentos título-categoria (usando INSERT direto pois são chaves compostas)
INSERT INTO titulo_categoria (cod_categoria, cod_titulo) VALUES
  (1, 1), -- O Poderoso Chefão - Ação
  (3, 1), -- O Poderoso Chefão - Drama
  (1, 2), -- Pulp Fiction - Ação
  (2, 2), -- Pulp Fiction - Comédia
  (3, 3), -- Forrest Gump - Drama
  (6, 3), -- Forrest Gump - Romance
  (7, 4), -- Matrix - Ficção Científica
  (1, 4), -- Matrix - Ação
  (6, 5), -- Titanic - Romance
  (3, 5), -- Titanic - Drama
  (8, 6), -- Senhor dos Anéis - Aventura
  (7, 6), -- Senhor dos Anéis - Ficção Científica
  (7, 7), -- Interestelar - Ficção Científica
  (3, 7), -- Interestelar - Drama
  (1, 8), -- Vingadores - Ação
  (8, 8), -- Vingadores - Aventura
  (10, 9), -- Rei Leão - Animação
  (8, 9), -- Rei Leão - Aventura
  (8, 10), -- Jurassic Park - Aventura
  (7, 10), -- Jurassic Park - Ficção Científica
  (9, 11), -- Silêncio dos Inocentes - Suspense
  (3, 11), -- Silêncio dos Inocentes - Drama
  (9, 12), -- Clube da Luta - Suspense
  (1, 12), -- Clube da Luta - Ação
  (1, 13), -- Resgate do Soldado Ryan - Ação
  (3, 13), -- Resgate do Soldado Ryan - Drama
  (1, 14), -- Os Bons Companheiros - Ação
  (3, 14), -- Os Bons Companheiros - Drama
  (3, 15), -- Um Sonho de Liberdade - Drama
  (9, 15); -- Um Sonho de Liberdade - Suspense

-- Itens de compra (usando INSERT direto pois são chaves compostas)
INSERT INTO item_compra (cod_compra, cod_midia, quantidade, subtotal) VALUES
  (1, 1, 10, 250.00), (1, 3, 8, 240.00), (2, 5, 15, 300.00), (2, 7, 12, 420.00),
  (3, 9, 20, 500.00), (3, 11, 10, 300.00), (4, 13, 8, 320.00), (4, 15, 6, 390.00),
  (5, 17, 25, 500.00), (5, 19, 12, 300.00), (6, 2, 5, 225.00), (6, 4, 4, 200.00);

-- Itens de venda (usando INSERT direto pois são chaves compostas)
INSERT INTO item_venda (cod_midia, cod_venda, subtotal, qtd_item) VALUES
  (1, 3, 50.00, 2), (3, 4, 60.00, 2), (5, 5, 80.00, 2), (7, 6, 70.00, 2),
  (9, 7, 100.00, 2), (11, 8, 120.00, 2), (2, 3, 90.00, 2), (4, 4, 100.00, 2);

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