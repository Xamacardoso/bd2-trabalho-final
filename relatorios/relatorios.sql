-- Relatório 1: Desempenho de Funcionários
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
    RAISE INFO 'Relatório de Mídias Mais Vendidas - %', ano;
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

