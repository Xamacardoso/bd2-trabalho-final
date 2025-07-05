-- ========================================
-- SCRIPT DE DEMONSTRAÇÃO COMPLETA PARA APRESENTAÇÃO
-- Sistema de Locadora de Mídias - BD2
-- Abrange TODAS as funcionalidades implementadas
-- ========================================

-- ========================================
-- 1. VERIFICAÇÃO INICIAL DO SISTEMA
-- ========================================

-- Verificar versão do PostgreSQL
SELECT version();

-- Verificar todas as tabelas criadas
SELECT table_name, table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verificar estatísticas gerais do sistema
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
SELECT 'Mídias', COUNT(*) FROM midia
UNION ALL
SELECT 'Compras', COUNT(*) FROM compra
UNION ALL
SELECT 'Vendas', COUNT(*) FROM venda
UNION ALL
SELECT 'Relacionamentos Título-Categoria', COUNT(*) FROM titulo_categoria
UNION ALL
SELECT 'Itens de Compra', COUNT(*) FROM item_compra
UNION ALL
SELECT 'Itens de Venda', COUNT(*) FROM item_venda;

-- ========================================
-- 2. DEMONSTRAÇÃO DO CATÁLOGO COM FILMES FAMOSOS
-- ========================================

-- Mostrar catálogo completo com filmes reais
SELECT * FROM catalogo_midia ORDER BY titulo LIMIT 10;

-- Filtrar por categoria específica
SELECT * FROM catalogo_midia WHERE categoria = 'Ação' ORDER BY titulo;

-- Filtrar por formato de mídia
SELECT * FROM catalogo_midia WHERE formato = '4K Blu-ray' ORDER BY titulo;

-- Mostrar preços por formato
SELECT formato, 
       COUNT(*) as quantidade_titulos,
       AVG(valor_unid) as preco_medio,
       MIN(valor_unid) as preco_minimo,
       MAX(valor_unid) as preco_maximo
FROM catalogo_midia 
GROUP BY formato 
ORDER BY preco_medio DESC;

-- ========================================
-- 3. DEMONSTRAÇÃO DAS FUNÇÕES JSON AVANÇADAS
-- ========================================

-- 3.1 Cadastrar cliente usando interface amigável
SELECT f_cadastrar_json('cliente', '{
    "nome": "Ana Apresentação Silva",
    "telefone": "1111-2222",
    "email": "ana@apresentacao.com",
    "cep": "64000-123"
}');

-- Verificar se foi inserido corretamente
SELECT * FROM cliente WHERE nome = 'Ana Apresentação Silva';

-- 3.2 Cadastrar venda usando nomes em vez de códigos
SELECT f_cadastrar_json('venda', '{
    "nome_funcionario": "Carlos Lima",
    "nome_cliente": "Ana Apresentação Silva",
    "dt_hora_venda": "2024-01-15 14:30:00",
    "total": "0"
}');

-- Verificar venda criada
SELECT v.cod_venda, f.nome as funcionario, c.nome as cliente, v.dt_hora_venda, v.total
FROM venda v
JOIN funcionario f ON v.cod_funcionario = f.cod_funcionario
JOIN cliente c ON v.cod_cliente = c.cod_cliente
WHERE c.nome = 'Ana Apresentação Silva';

-- 3.3 Adicionar item de venda usando nome do filme
SELECT f_cadastrar_json('item_venda', '{
    "nome_midia": "O Poderoso Chefão",
    "cod_venda": "1",
    "qtd_item": "2"
}');

-- Verificar item adicionado e total recalculado
SELECT v.cod_venda, v.total, iv.qtd_item, t.nome as titulo, iv.subtotal
FROM venda v
JOIN item_venda iv ON v.cod_venda = iv.cod_venda
JOIN midia m ON iv.cod_midia = m.cod_midia
JOIN titulo t ON m.cod_titulo = t.cod_titulo
WHERE v.cod_venda = 1;

-- 3.4 Atualizar cliente via JSON
SELECT f_alterar_json('cliente', '{"telefone": "3333-4444", "email": "ana.nova@email.com"}', 'nome = ''Ana Apresentação Silva''');

-- Verificar atualização
SELECT * FROM cliente WHERE nome = 'Ana Apresentação Silva';

-- ========================================
-- 4. DEMONSTRAÇÃO DOS TRIGGERS AVANÇADOS
-- ========================================

-- 4.1 Verificar estoque atual de um filme
SELECT t.nome, m.qtd_estoque, m.valor_unid, tm.nome_formato
FROM midia m 
JOIN titulo t ON m.cod_titulo = t.cod_titulo
JOIN tipo_midia tm ON m.cod_tipo_midia = tm.cod_tipo_midia
WHERE t.nome = 'Matrix' AND tm.nome_formato = 'DVD';

-- 4.2 Tentar vender mais que o estoque disponível (deve dar erro)
-- Comentado para não executar automaticamente
-- INSERT INTO item_venda (cod_midia, cod_venda, qtd_item) VALUES (7, 1, 1000);

-- 4.3 Verificar formatação automática de texto
SELECT f_cadastrar_json('cliente', '{
    "nome": "joão da silva santos",
    "telefone": "5555-6666",
    "email": "JOAO@EMAIL.COM",
    "cep": "64000-456"
}');

-- Verificar se foi formatado automaticamente
SELECT * FROM cliente WHERE email = 'joao@email.com';

-- 4.4 Verificar log de auditoria completo
SELECT 
    tabela,
    atributo,
    valor_anterior,
    valor_novo,
    usuario,
    data_alteracao
FROM log_auditoria_geral 
ORDER BY data_alteracao DESC 
LIMIT 10;

-- ========================================
-- 5. DEMONSTRAÇÃO DO SISTEMA DE ROLES
-- ========================================

-- 5.1 Listar todos os roles e suas permissões
SELECT listar_roles_sistema();

-- 5.2 Verificar usuário atual e permissões
SELECT current_user, session_user;

-- 5.3 Verificar views seguras disponíveis
SELECT schemaname, viewname 
FROM pg_views 
WHERE schemaname = 'public' 
ORDER BY viewname;

-- ========================================
-- 6. DEMONSTRAÇÃO DOS RELATÓRIOS AVANÇADOS
-- ========================================

-- 6.1 Relatório de ranking de clientes
SELECT f_rel_ranking_clientes();

-- 6.2 Relatório de análise por categoria
SELECT * FROM v_rel_analise_vendas_categoria;

-- 6.3 Relatório de análise por tipo de mídia
SELECT * FROM v_rel_analise_vendas_tipo_midia;

-- 6.4 Relatório de controle de estoque (itens com menos de 15 unidades)
SELECT f_rel_controle_estoque(15);

-- 6.5 Relatório de desempenho de vendas por período
SELECT f_rel_desempenho_vendas(3, 2023);

-- 6.6 Relatório de análise temporal
SELECT f_rel_analise_vendas_periodo(2023);

-- ========================================
-- 7. DEMONSTRAÇÃO DE CONSULTAS COMPLEXAS
-- ========================================

-- 7.1 Top 5 filmes mais vendidos com detalhes
SELECT 
    t.nome as titulo,
    c.nome as categoria,
    tm.nome_formato as formato,
    SUM(iv.qtd_item) as total_vendido,
    SUM(iv.subtotal) as faturamento,
    AVG(iv.subtotal/iv.qtd_item) as preco_medio
FROM titulo t
JOIN midia m ON t.cod_titulo = m.cod_titulo
JOIN item_venda iv ON m.cod_midia = iv.cod_midia
JOIN titulo_categoria tc ON t.cod_titulo = tc.cod_titulo
JOIN categoria c ON tc.cod_categoria = c.cod_categoria
JOIN tipo_midia tm ON m.cod_tipo_midia = tm.cod_tipo_midia
GROUP BY t.nome, c.nome, tm.nome_formato
ORDER BY total_vendido DESC, faturamento DESC
LIMIT 5;

-- 7.2 Análise de vendas por período com métricas
SELECT 
    EXTRACT(MONTH FROM v.dt_hora_venda) as mes,
    EXTRACT(YEAR FROM v.dt_hora_venda) as ano,
    COUNT(*) as total_vendas,
    SUM(v.total) as faturamento_total,
    AVG(v.total) as ticket_medio,
    COUNT(DISTINCT v.cod_cliente) as clientes_unicos,
    COUNT(DISTINCT v.cod_funcionario) as funcionarios_ativos
FROM venda v
GROUP BY mes, ano
ORDER BY ano DESC, mes DESC;

-- 7.3 Análise de estoque por categoria
SELECT 
    c.nome as categoria,
    COUNT(DISTINCT t.cod_titulo) as total_titulos,
    COUNT(m.cod_midia) as total_midias,
    SUM(m.qtd_estoque) as estoque_total,
    AVG(m.valor_unid) as preco_medio,
    SUM(m.qtd_estoque * m.valor_unid) as valor_estoque
FROM categoria c
JOIN titulo_categoria tc ON c.cod_categoria = tc.cod_categoria
JOIN titulo t ON tc.cod_titulo = t.cod_titulo
JOIN midia m ON t.cod_titulo = m.cod_titulo
GROUP BY c.nome
ORDER BY valor_estoque DESC;

-- ========================================
-- 8. DEMONSTRAÇÃO DE VALIDAÇÕES AVANÇADAS
-- ========================================

-- 8.1 Tentar inserir valor negativo (deve dar erro)
-- Comentado para não executar automaticamente
-- UPDATE midia SET valor_unid = -10 WHERE cod_midia = 1;

-- 8.2 Tentar inserir estoque negativo (deve dar erro)
-- Comentado para não executar automaticamente
-- UPDATE midia SET qtd_estoque = -5 WHERE cod_midia = 1;

-- 8.3 Tentar inserir salário negativo (deve dar erro)
-- Comentado para não executar automaticamente
-- UPDATE funcionario SET salario = -1000 WHERE cod_funcionario = 1;

-- 8.4 Verificar validação de tipos na função JSON
-- Comentado para não executar automaticamente
-- SELECT f_cadastrar_json('cliente', '{"nome": "123", "telefone": "abc"}');

-- ========================================
-- 9. DEMONSTRAÇÃO DE PERFORMANCE E ÍNDICES
-- ========================================

-- 9.1 Verificar índices criados automaticamente
SELECT 
    indexname, 
    tablename, 
    indexdef 
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- 9.2 Análise de estatísticas das tabelas principais
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation,
    most_common_vals
FROM pg_stats 
WHERE schemaname = 'public' 
AND tablename IN ('venda', 'item_venda', 'midia', 'cliente')
ORDER BY tablename, attname;

-- 9.3 Verificar tamanho das tabelas
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as tamanho
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ========================================
-- 10. DEMONSTRAÇÃO DE FUNCIONALIDADES ESPECIAIS
-- ========================================

-- 10.1 Verificar funções auxiliares
SELECT tabela_existe('cliente') as cliente_existe;
SELECT tabela_existe('tabela_inexistente') as tabela_inexistente;

SELECT unnest(colunas_da_tabela('venda')) as colunas_venda;

SELECT colunas_existem('cliente', 'nome,telefone,email') as colunas_validas;
SELECT colunas_existem('cliente', 'nome,telefone,coluna_inexistente') as colunas_invalidas;

-- 10.2 Verificar relacionamentos múltiplos
SELECT 
    t.nome as titulo,
    string_agg(c.nome, ', ') as categorias
FROM titulo t
JOIN titulo_categoria tc ON t.cod_titulo = tc.cod_titulo
JOIN categoria c ON tc.cod_categoria = c.cod_categoria
GROUP BY t.nome
ORDER BY t.nome;

-- 10.3 Verificar diferentes formatos de um mesmo título
SELECT 
    t.nome as titulo,
    tm.nome_formato as formato,
    m.valor_unid,
    m.qtd_estoque
FROM titulo t
JOIN midia m ON t.cod_titulo = m.cod_titulo
JOIN tipo_midia tm ON m.cod_tipo_midia = tm.cod_tipo_midia
WHERE t.nome = 'O Poderoso Chefão'
ORDER BY m.valor_unid;

-- ========================================
-- 11. LIMPEZA DE TESTES
-- ========================================

-- Remover dados de teste criados durante a demonstração
DELETE FROM item_venda WHERE cod_venda IN (
    SELECT cod_venda FROM venda WHERE cod_cliente IN (
        SELECT cod_cliente FROM cliente WHERE nome IN ('Ana Apresentação Silva', 'João Da Silva Santos')
    )
);

DELETE FROM venda WHERE cod_cliente IN (
    SELECT cod_cliente FROM cliente WHERE nome IN ('Ana Apresentação Silva', 'João Da Silva Santos')
);

DELETE FROM cliente WHERE nome IN ('Ana Apresentação Silva', 'João Da Silva Santos');

-- Verificar limpeza
SELECT COUNT(*) as clientes_restantes FROM cliente WHERE nome IN ('Ana Apresentação Silva', 'João Da Silva Santos');

-- ========================================
-- 12. RESUMO FINAL DO SISTEMA
-- ========================================

-- Estatísticas finais
SELECT 
    'RESUMO DO SISTEMA' as secao,
    'Total de Funcionalidades Implementadas' as descricao,
    'Sistema Completo de Locadora' as valor
UNION ALL
SELECT 
    'Tabelas',
    'Estruturas de Dados',
    COUNT(*)::text
FROM information_schema.tables 
WHERE table_schema = 'public'
UNION ALL
SELECT 
    'Triggers',
    'Automações de Negócio',
    '8 Triggers Principais'
UNION ALL
SELECT 
    'Funções',
    'Operações JSON e Relatórios',
    '15+ Funções'
UNION ALL
SELECT 
    'Views',
    'Relatórios e Segurança',
    '5 Views'
UNION ALL
SELECT 
    'Roles',
    'Níveis de Acesso',
    '3 Roles (Gerente, Atendente, Cliente)'
UNION ALL
SELECT 
    'Filmes',
    'Catálogo Real',
    '15 Filmes Famosos'
UNION ALL
SELECT 
    'Auditoria',
    'Rastreabilidade',
    'Log Completo de Operações'
UNION ALL
SELECT 
    'Containerização',
    'Deploy',
    'Docker + PostgreSQL 15'
ORDER BY secao;

-- ========================================
-- MENSAGEM FINAL
-- ========================================
DO $$
BEGIN
    RAISE INFO '========================================';
    RAISE INFO 'DEMONSTRAÇÃO COMPLETA CONCLUÍDA!';
    RAISE INFO '========================================';
    RAISE INFO 'Sistema funcionando com todas as funcionalidades:';
    RAISE INFO '- Funções JSON com interface amigável';
    RAISE INFO '- Triggers de automação e validação';
    RAISE INFO '- Sistema de roles e segurança';
    RAISE INFO '- Relatórios avançados';
    RAISE INFO '- Auditoria completa';
    RAISE INFO '- Catálogo com filmes famosos';
    RAISE INFO '- Containerização com Docker';
    RAISE INFO '========================================';
    RAISE INFO 'Sistema pronto para apresentação!';
    RAISE INFO '========================================';
END $$; 