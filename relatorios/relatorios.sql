-- Relatório 1: Desempenho de Funcionários em um determinado mes e ano
CREATE OR REPLACE FUNCTION f_rel_desempenho_vendas(mes INT, ano INT)
RETURNS VOID AS $$
BEGIN
    RAISE INFO 'Relatório de Desempenho de Vendas - %/%', mes, ano;
    SELECT f.nome, SUM(v.total) AS total_vendas
    FROM funcionario f
    JOIN venda v ON f.cod_funcionario = v.cod_funcionario
    WHERE EXTRACT(MONTH FROM v.dt_hora_venda) = mes
    AND EXTRACT(YEAR FROM v.dt_hora_venda) = ano
    GROUP BY f.nome
    ORDER BY total_vendas DESC;
END
$$ LANGUAGE plpgsql;

-- Relatório 2: Mídias Mais Vendidas
CREATE OR REPLACE FUNCTION f_rel_top_x_titulos_vendidos(mes INT, ano INT, qtd_exibir INT)
RETURNS VOID AS $$
BEGIN
    RAISE INFO 'Relatório de Mídias Mais Vendidas - %/%', mes, ano;
    SELECT t.nome, SUM(iv.qtd_item) AS total_vendido
    FROM titulo t
    JOIN midia m ON t.cod_titulo = m.cod_titulo
    JOIN item_venda iv ON m.cod_midia = iv.cod_midia
    WHERE EXTRACT(MONTH FROM iv.dt_hora_venda) = mes
    AND EXTRACT(YEAR FROM iv.dt_hora_venda) = ano
    GROUP BY t.nome
    ORDER BY total_vendido DESC
    LIMIT qtd_exibir;
END
$$ LANGUAGE plpgsql;

-- Relatorio 3: Controle de estoque
CREATE OR REPLACE FUNCTION f_rel_controle_estoque(limite_minimo INT)
RETURNS VOID AS $$
BEGIN
    SELECT t.nome, m.qtd_estoque
    FROM titulo t
    JOIN midia m ON t.cod_titulo = m.cod_titulo
    WHERE m.qtd_estoque < limite_minimo;
END
$$ LANGUAGE plpgsql;

-- Relatorio 4: Ranking de clientes
CREATE OR REPLACE FUNCTION f_rel_ranking_clientes()
RETURNS VOID AS $$
BEGIN
    SELECT c.cod_cliente,c.nome, SUM(v.total) AS total_compras
    FROM cliente c
    JOIN venda v ON c.cod_cliente = v.cod_cliente
    GROUP BY c.cod_cliente, c.nome
    ORDER BY total_compras DESC;
END
$$ LANGUAGE plpgsql;

-- Relatorio 5: Analise de vendas por periodo - Qual mês (de um ano ou de todos os anos) teve o maior faturamento
CREATE OR REPLACE FUNCTION f_rel_analise_vendas_periodo(ano_filtro INT DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    SELECT
        EXTRACT(MONTH FROM v.dt_hora_venda) AS mes_numero,
        TRIM(TO_CHAR(v.dt_hora_venda, 'Month')) AS mes_nome,
        EXTRACT(YEAR FROM v.dt_hora_venda) AS ano,
        SUM(v.total) AS total_vendas
    FROM venda v
    WHERE (ano_filtro IS NULL OR EXTRACT(YEAR FROM v.dt_hora_venda) = ano_filtro)
    GROUP BY mes_numero, mes_nome, ano
    ORDER BY total_vendas DESC;
END;    
$$ LANGUAGE plpgsql;