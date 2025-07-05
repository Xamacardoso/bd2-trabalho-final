-- ========================================
-- SISTEMA DE ROLES E SEGURANÇA
-- Locadora de Mídias - BD2 Trabalho Final
-- ========================================

-- Remover roles existentes (se houver)
DROP ROLE IF EXISTS role_admin;
DROP ROLE IF EXISTS role_gerente;
DROP ROLE IF EXISTS role_atendente;
DROP ROLE IF EXISTS role_cliente;

-- ========================================
-- 1. ROLE_ADMIN - Administrador do Sistema
-- ========================================
CREATE ROLE role_gerente;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_gerente;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_gerente;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO role_gerente;
GRANT CREATE ON SCHEMA public TO role_gerente;

-- ========================================
-- 2. ROLE_ATENDENTE - Atendente de Balcão
-- ========================================
CREATE ROLE role_atendente;
-- Permissões limitadas para atendimento
GRANT SELECT ON cliente, titulo, midia, categoria, tipo_midia TO role_atendente;
GRANT SELECT ON venda, item_venda TO role_atendente;
GRANT INSERT, UPDATE ON venda, item_venda TO role_atendente;
GRANT INSERT ON cliente TO role_atendente;
GRANT USAGE ON SEQUENCE venda_cod_venda_seq TO role_atendente;
GRANT USAGE ON SEQUENCE cliente_cod_cliente_seq TO role_atendente;
GRANT EXECUTE ON FUNCTION f_cadastrar_json TO role_atendente;

-- ========================================
-- 3. ROLE_CLIENTE - Cliente da Locadora
-- ========================================
CREATE ROLE role_cliente;
-- Permissões para clientes
GRANT SELECT ON titulo, midia, categoria, tipo_midia TO role_cliente;
GRANT SELECT ON venda, item_venda TO role_cliente;
-- Cliente pode atualizar seus próprios dados
GRANT UPDATE ON cliente TO role_cliente;

-- ========================================
-- CRIAR USUÁRIOS DE EXEMPLO
-- ========================================

-- Usuário gerente
CREATE USER gerente_joao WITH PASSWORD 'gerente123';
GRANT role_gerente TO gerente_joao;

-- Usuário atendente
CREATE USER atendente_maria WITH PASSWORD 'atendente123';
GRANT role_atendente TO atendente_maria;

-- Usuário cliente (exemplo)
CREATE USER cliente_joao_silva WITH PASSWORD 'cliente123';
GRANT role_cliente TO cliente_joao_silva;

-- ========================================
-- FUNÇÕES ESPECÍFICAS PARA CLIENTES
-- ========================================

-- Função para cliente consultar seu histórico
CREATE OR REPLACE FUNCTION f_consultar_historico_cliente(p_cod_cliente INT)
RETURNS TABLE(
    cod_venda INT,
    data_venda TIMESTAMP,
    titulo TEXT,
    tipo_midia TEXT,
    quantidade INT,
    valor_total FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.cod_venda,
        v.dt_hora_venda,
        t.nome,
        tm.nome_formato,
        iv.qtd_item,
        v.total
    FROM venda v
    JOIN item_venda iv ON v.cod_venda = iv.cod_venda
    JOIN midia m ON iv.cod_midia = m.cod_midia
    JOIN titulo t ON m.cod_titulo = t.cod_titulo
    JOIN tipo_midia tm ON m.cod_tipo_midia = tm.cod_tipo_midia
    WHERE v.cod_cliente = p_cod_cliente
    ORDER BY v.dt_hora_venda DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- VIEWS ESPECÍFICAS PARA CLIENTES
-- ========================================

-- View para cliente ver apenas suas vendas
CREATE VIEW v_vendas_cliente AS
SELECT 
    v.cod_venda,
    v.dt_hora_venda,
    v.total,
    t.nome as titulo,
    tm.nome_formato as tipo_midia,
    iv.qtd_item
FROM venda v
JOIN item_venda iv ON v.cod_venda = iv.cod_venda
JOIN midia m ON iv.cod_midia = m.cod_midia
JOIN titulo t ON m.cod_titulo = t.cod_titulo
JOIN tipo_midia tm ON m.cod_tipo_midia = tm.cod_tipo_midia
WHERE v.cod_cliente = current_setting('app.current_client_id', true)::INT;

-- ========================================
-- TRIGGERS DE AUDITORIA
-- ========================================

-- Tabela de auditoria
CREATE TABLE IF NOT EXISTS auditoria_operacoes (
    id_auditoria SERIAL PRIMARY KEY,
    usuario_executou VARCHAR(50),
    operacao VARCHAR(20),
    tabela_afetada VARCHAR(50),
    dados_anteriores JSONB,
    dados_novos JSONB,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger para auditoria de vendas
CREATE OR REPLACE FUNCTION auditar_vendas()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_operacoes (usuario_executou, operacao, tabela_afetada, dados_novos)
        VALUES (current_user, 'INSERT', 'venda', to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_operacoes (usuario_executou, operacao, tabela_afetada, dados_anteriores, dados_novos)
        VALUES (current_user, 'UPDATE', 'venda', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_operacoes (usuario_executou, operacao, tabela_afetada, dados_anteriores)
        VALUES (current_user, 'DELETE', 'venda', to_jsonb(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auditoria_vendas
    AFTER INSERT OR UPDATE OR DELETE ON venda
    FOR EACH ROW EXECUTE FUNCTION auditar_vendas();

-- Conceder permissões de auditoria
GRANT SELECT ON auditoria_operacoes TO role_gerente;

-- ========================================
-- MENSAGEM DE CONFIRMAÇÃO
-- ========================================
DO $$
BEGIN
    RAISE INFO 'Sistema de roles criado com sucesso!';
    RAISE INFO 'Roles disponíveis: role_gerente, role_atendente, role_cliente';
    RAISE INFO 'Usuários de exemplo criados com suas respectivas permissões';
    RAISE INFO 'Use SELECT listar_roles_sistema(); para ver detalhes dos roles';
    RAISE INFO 'Role CLIENTE adicionado com funcionalidades de auto-atendimento!';
END $$; 


SET ROLE role_gerente;
SET ROLE role_cliente;
RESET ROLE;
