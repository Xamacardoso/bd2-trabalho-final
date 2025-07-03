-- POVOAMENTO DE DADOS PARA TESTES E USO GERAL

-- Cadastro de cliente
SELECT f_cadastrar('cliente', 'nome, telefone, email, cep', 
                   '''Teste Cliente'', ''1111-2222'', ''teste@email.com'', ''64000-001''');

-- Cadastro de funcionário
SELECT f_cadastrar('funcionario', 'nome, telefone, cep, salario', 
                   '''Teste Funcionário'', ''3333-4444'', ''64000-002'', 2800.00');

-- Verificar se foram inseridos
SELECT * FROM cliente WHERE nome = 'Teste Cliente';
SELECT * FROM funcionario WHERE nome = 'Teste Funcionário';

-- Alterar dados do cliente
SELECT f_alterar('cliente', 'nome = ''Teste Cliente Atualizado'', telefone = ''5555-6666''', 
                 'nome = ''Teste Cliente''');

-- Alterar salário do funcionário
SELECT f_alterar('funcionario', 'salario = 3200.00', 'nome = ''Teste Funcionário''');

-- Verificar alterações
SELECT * FROM cliente WHERE nome LIKE 'Teste Cliente%';
SELECT * FROM funcionario WHERE nome = 'Teste Funcionário';

-- Remover os registros de teste criados
SELECT f_remover('cliente', 'nome LIKE ''Teste Cliente%''');
SELECT f_remover('funcionario', 'nome = ''Teste Funcionário''');

-- Verificar se foram removidos
SELECT COUNT(*) as total FROM cliente WHERE nome LIKE 'Teste Cliente%';
SELECT COUNT(*) as total FROM funcionario WHERE nome = 'Teste Funcionário';

-- Cadastrar nova categoria
SELECT f_cadastrar('categoria', 'nome', '''Categoria Teste''');

-- Cadastrar novo tipo de mídia
SELECT f_cadastrar('tipo_midia', 'nome_formato', '''Formato Teste''');

-- Alterar categoria
SELECT f_alterar('categoria', 'nome = ''Categoria Teste Alterada''', 'nome = ''Categoria Teste''');

-- Remover registros de teste
SELECT f_remover('categoria', 'nome = ''Categoria Teste Alterada''');
SELECT f_remover('tipo_midia', 'nome_formato = ''Formato Teste''');

-- ========================= POVOAMENTO DAS TABELAS =========================

-- categoria
insert into categoria (nome) values ('Ação'), ('Comédia');

-- tipo_midia
insert into tipo_midia (nome_formato) values ('DVD'), ('Blu-ray');

-- fornecedor
insert into fornecedor (nome, telefone, email) values
  ('Fornecedor 1', '1111-1111', 'forn1@email.com'),
  ('Fornecedor 2', '2222-2222', 'forn2@email.com');

-- cliente
insert into cliente (nome, telefone, email, cep) values
  ('João Silva', '9999-9999', 'joao@email.com', '64000-000'),
  ('Maria Souza', '8888-8888', 'maria@email.com', '64001-000');

-- funcionario
insert into funcionario (nome, telefone, cep, salario) values
  ('Carlos Lima', '7777-7777', '64002-000', 2500.00),
  ('Ana Paula', '6666-6666', '64003-000', 3200.00);

-- titulo
insert into titulo (nome, classificacao_ind, ano_lancamento) values
  ('Filme A', 14, 2020),
  ('Filme B', 12, 2018);

-- compra
insert into compra (cod_fornecedor, total, dt_compra) values
  (1, 300.00, '2023-01-10 10:00:00'),
  (2, 500.00, '2023-02-15 15:30:00');

-- midia
insert into midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) values
  (30.00, 10, 1, 1),
  (50.00, 5, 2, 2);

-- venda
insert into venda (cod_funcionario, cod_cliente, dt_hora_venda, total) values
  (1, 1, '2023-03-01 14:00:00', 60.00),
  (2, 2, '2023-03-02 16:00:00', 100.00);

-- titulo_categoria
insert into titulo_categoria (cod_categoria, cod_titulo) values
  (1, 1),
  (2, 2);

-- item_compra
insert into item_compra (cod_compra, cod_midia, quantidade, subtotal) values
  (1, 1, 5, 150.00),
  (2, 2, 5, 250.00);

-- item_venda
insert into item_venda (cod_midia, cod_venda, subtotal, qtd_item) values
  (1, 1, 60.00, 2),
  (2, 2, 100.00, 2);

-- categoria (adicionais)
insert into categoria (nome) values ('Drama'), ('Terror'), ('Documentário'), ('Romance');

-- tipo_midia (adicionais)
insert into tipo_midia (nome_formato) values ('VHS'), ('Digital'), ('4K Blu-ray'), ('Streaming');

-- fornecedor (adicionais)
insert into fornecedor (nome, telefone, email) values
  ('Fornecedor 3', '3333-3333', 'forn3@email.com'),
  ('Fornecedor 4', '4444-4444', 'forn4@email.com'),
  ('Fornecedor 5', '5555-5555', 'forn5@email.com'),
  ('Fornecedor 6', '6666-6666', 'forn6@email.com');

-- cliente (adicionais)
insert into cliente (nome, telefone, email, cep) values
  ('Pedro Alves', '7777-8888', 'pedro@email.com', '64002-000'),
  ('Luciana Dias', '9999-7777', 'luciana@email.com', '64003-000'),
  ('Bruno Costa', '5555-6666', 'bruno@email.com', '64004-000'),
  ('Fernanda Lima', '4444-5555', 'fernanda@email.com', '64005-000');

-- funcionario (adicionais)
insert into funcionario (nome, telefone, cep, salario) values
  ('Marcos Silva', '3333-2222', '64006-000', 2800.00),
  ('Patricia Souza', '2222-3333', '64007-000', 3500.00),
  ('Rafael Torres', '1111-4444', '64008-000', 2700.00),
  ('Juliana Rocha', '8888-1111', '64009-000', 4000.00);

-- titulo (adicionais)
insert into titulo (nome, classificacao_ind, ano_lancamento) values
  ('Filme C', 16, 2021),
  ('Filme D', 10, 2019),
  ('Filme E', 18, 2022),
  ('Filme F', 12, 2017);

-- compra (adicionais)
insert into compra (cod_fornecedor, total, dt_compra) values
  (3, 700.00, '2023-03-10 11:00:00'),
  (4, 900.00, '2023-04-12 12:30:00'),
  (5, 1200.00, '2023-05-15 13:45:00'),
  (6, 1500.00, '2023-06-18 09:20:00');

-- midia (adicionais)
insert into midia (valor_unid, qtd_estoque, cod_tipo_midia, cod_titulo) values
  (40.00, 8, 3, 3),
  (60.00, 12, 4, 4),
  (25.00, 20, 5, 5),
  (80.00, 7, 6, 6),
  (35.00, 15, 7, 1),
  (55.00, 9, 8, 2);

-- venda (adicionais)
insert into venda (cod_funcionario, cod_cliente, dt_hora_venda, total) values
  (3, 3, '2023-03-05 10:00:00', 80.00),
  (4, 4, '2023-03-06 11:00:00', 120.00),
  (5, 5, '2023-03-07 12:00:00', 200.00),
  (6, 6, '2023-03-08 13:00:00', 300.00);

-- titulo_categoria (adicionais)
insert into titulo_categoria (cod_categoria, cod_titulo) values
  (3, 3),
  (4, 4),
  (5, 5),
  (6, 6),
  (1, 2),
  (2, 1);

-- item_compra (adicionais)
insert into item_compra (cod_compra, cod_midia, quantidade, subtotal) values
  (3, 3, 10, 400.00),
  (4, 4, 15, 900.00),
  (5, 5, 20, 500.00),
  (6, 6, 7, 560.00),
  (1, 2, 3, 150.00),
  (2, 1, 2, 60.00);

-- item_venda (adicionais)
insert into item_venda (cod_midia, cod_venda, subtotal, qtd_item) values
  (3, 3, 80.00, 2),
  (4, 4, 120.00, 3),
  (5, 5, 200.00, 4),
  (6, 6, 300.00, 5),
  (1, 2, 30.00, 1),
  (2, 1, 50.00, 1); 