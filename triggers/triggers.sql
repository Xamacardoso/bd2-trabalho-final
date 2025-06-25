-- Trigger 1: Atualizar estoque em vendas
CREATE OR REPLACE FUNCTION atualizar_estoque_venda()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE midia
    SET qtd_estoque = qtd_estoque - NEW.qtd_item
    WHERE cod_midia = NEW.cod_midia;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_estoque_venda
AFTER INSERT ON item_venda
FOR EACH ROW
EXECUTE FUNCTION atualizar_estoque_venda();

-- Trigger 2: Calcular subtotal do item_venda
CREATE OR REPLACE FUNCTION calcular_subtotal_venda()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE item_venda
    SET subtotal = (SELECT valor_unid FROM midia WHERE cod_midia = NEW.cod_midia) * NEW.qtd_item
    WHERE cod_item_venda = NEW.cod_item_venda;
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calcular_subtotal_venda
BEFORE INSERT OR UPDATE ON item_venda
FOR EACH ROW
EXECUTE FUNCTION calcular_subtotal_venda();




