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

SELECT * FROM categoria;

-- Cadastro de tipos de mídia
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "DVD"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "Blu-ray"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "VHS"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "Digital"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "4K Blu-ray"}');
SELECT f_cadastrar_json('tipo_midia', '{"nome_formato": "Streaming"}');

-- Cadastro de fornecedores
SELECT f_cadastrar_json('fornecedor', '{"nome": "Fornecedor 1", "telefone": "1111-1111", "email": "forn1@email.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Fornecedor 2", "telefone": "2222-2222", "email": "forn2@email.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Fornecedor 3", "telefone": "3333-3333", "email": "forn3@email.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Fornecedor 4", "telefone": "4444-4444", "email": "forn4@email.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Fornecedor 5", "telefone": "5555-5555", "email": "forn5@email.com"}');
SELECT f_cadastrar_json('fornecedor', '{"nome": "Fornecedor 6", "telefone": "6666-6666", "email": "forn6@email.com"}');

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

-- Cadastro de títulos
SELECT f_cadastrar_json('titulo', '{"nome": "Filme A", "classificacao_ind": 14, "ano_lancamento": 2020}');
SELECT f_cadastrar_json('titulo', '{"nome": "Filme B", "classificacao_ind": 12, "ano_lancamento": 2018}');
SELECT f_cadastrar_json('titulo', '{"nome": "Filme C", "classificacao_ind": 16, "ano_lancamento": 2021}');
SELECT f_cadastrar_json('titulo', '{"nome": "Filme D", "classificacao_ind": 10, "ano_lancamento": 2019}');
SELECT f_cadastrar_json('titulo', '{"nome": "Filme E", "classificacao_ind": 18, "ano_lancamento": 2022}');
SELECT f_cadastrar_json('titulo', '{"nome": "Filme F", "classificacao_ind": 12, "ano_lancamento": 2017}');

-- Cadastro de compras
SELECT f_cadastrar_json('compra', '{"cod_fornecedor": 1, "total": 300.00, "dt_compra": "2023-01-10 10:00:00"}');
SELECT f_cadastrar_json('compra', '{"cod_fornecedor": 2, "total": 500.00, "dt_compra": "2023-02-15 15:30:00"}');
SELECT f_cadastrar_json('compra', '{"cod_fornecedor": 3, "total": 700.00, "dt_compra": "2023-03-10 11:00:00"}');
SELECT f_cadastrar_json('compra', '{"cod_fornecedor": 4, "total": 900.00, "dt_compra": "2023-04-12 12:30:00"}');
SELECT f_cadastrar_json('compra', '{"cod_fornecedor": 5, "total": 1200.00, "dt_compra": "2023-05-15 13:45:00"}');
SELECT f_cadastrar_json('compra', '{"cod_fornecedor": 6, "total": 1500.00, "dt_compra": "2023-06-18 09:20:00"}');

-- Cadastro de mídias
SELECT f_cadastrar_json('midia', '{"valor_unid": 30.00, "qtd_estoque": 10, "cod_tipo_midia": 1, "cod_titulo": 1}');
SELECT f_cadastrar_json('midia', '{"valor_unid": 50.00, "qtd_estoque": 5, "cod_tipo_midia": 2, "cod_titulo": 2}');
SELECT f_cadastrar_json('midia', '{"valor_unid": 40.00, "qtd_estoque": 8, "cod_tipo_midia": 3, "cod_titulo": 3}');
SELECT f_cadastrar_json('midia', '{"valor_unid": 60.00, "qtd_estoque": 12, "cod_tipo_midia": 4, "cod_titulo": 4}');
SELECT f_cadastrar_json('midia', '{"valor_unid": 25.00, "qtd_estoque": 20, "cod_tipo_midia": 5, "cod_titulo": 5}');
SELECT f_cadastrar_json('midia', '{"valor_unid": 80.00, "qtd_estoque": 7, "cod_tipo_midia": 6, "cod_titulo": 6}');
SELECT f_cadastrar_json('midia', '{"valor_unid": 35.00, "qtd_estoque": 15, "cod_tipo_midia": 1, "cod_titulo": 1}');
SELECT f_cadastrar_json('midia', '{"valor_unid": 55.00, "qtd_estoque": 9, "cod_tipo_midia": 2, "cod_titulo": 2}');

SELECT * FROM midia;

-- Cadastro de vendas
SELECT f_cadastrar_json('venda', '{"cod_funcionario": 9, "cod_cliente": 1, "dt_hora_venda": "2023-03-01 14:00:00", "total": 60.00}');
SELECT f_cadastrar_json('venda', '{"cod_funcionario": 10, "cod_cliente": 2, "dt_hora_venda": "2023-03-02 16:00:00", "total": 100.00}');
SELECT f_cadastrar_json('venda', '{"cod_funcionario": 11, "cod_cliente": 3, "dt_hora_venda": "2023-03-05 10:00:00", "total": 80.00}');
SELECT f_cadastrar_json('venda', '{"cod_funcionario": 12, "cod_cliente": 4, "dt_hora_venda": "2023-03-06 11:00:00", "total": 120.00}');
SELECT f_cadastrar_json('venda', '{"cod_funcionario": 13, "cod_cliente": 5, "dt_hora_venda": "2023-03-07 12:00:00", "total": 200.00}');
SELECT f_cadastrar_json('venda', '{"cod_funcionario": 14, "cod_cliente": 6, "dt_hora_venda": "2023-03-08 13:00:00", "total": 300.00}');

SELECT * FROM venda

-- ========================= RELACIONAMENTOS =========================

-- Relacionamentos título-categoria (usando INSERT direto pois são chaves compostas)
INSERT INTO titulo_categoria (cod_categoria, cod_titulo) VALUES
  (1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (1, 2), (2, 1);

-- Itens de compra (usando INSERT direto pois são chaves compostas)
INSERT INTO item_compra (cod_compra, cod_midia, quantidade, subtotal) VALUES
  (1, 1, 5, 150.00), (2, 2, 5, 250.00), (3, 3, 10, 400.00), (4, 4, 15, 900.00),
  (5, 5, 20, 500.00), (6, 6, 7, 560.00), (1, 2, 3, 150.00), (2, 1, 2, 60.00);

-- Itens de venda (usando INSERT direto pois são chaves compostas)
INSERT INTO item_venda (cod_midia, cod_venda, subtotal, qtd_item) VALUES
  (1, 3, 60.00, 2), (2, 4, 100.00, 2), (3, 5, 80.00, 2), (4, 6, 120.00, 3),
  (5, 7, 200.00, 4), (6, 8, 300.00, 5);
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

-- Verificar algumas relações importantes
SELECT 
    t.nome as titulo,
    c.nome as categoria,
    tm.nome_formato as formato,
    m.valor_unid,
    m.qtd_estoque
FROM titulo t
JOIN titulo_categoria tc ON t.cod_titulo = tc.cod_titulo
JOIN categoria c ON tc.cod_categoria = c.cod_categoria
JOIN midia m ON t.cod_titulo = m.cod_titulo
JOIN tipo_midia tm ON m.cod_tipo_midia = tm.cod_tipo_midia
ORDER BY t.nome;

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