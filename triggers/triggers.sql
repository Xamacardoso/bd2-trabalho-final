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
    NEW.subtotal := (SELECT valor_unid FROM midia WHERE cod_midia = NEW.cod_midia) * NEW.qtd_item;
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calcular_subtotal_venda
BEFORE INSERT OR UPDATE ON item_venda
FOR EACH ROW
EXECUTE FUNCTION calcular_subtotal_venda();

-- Trigger 3: Atualizar total da venda quando um item for manipulado

CREATE OR REPLACE FUNCTION recalcular_subtotal()
RETURNS TRIGGER AS
$$
BEGIN
    -- Recalcula o total da venda somando todos os subtotais dos itens
    IF (TG_OP = 'DELETE') THEN
        UPDATE venda
        SET total = (
            SELECT COALESCE(SUM(subtotal), 0)
            FROM item_venda
            WHERE cod_venda = OLD.cod_venda
        )
        WHERE cod_venda = OLD.cod_venda;
    ELSE
        UPDATE venda
        SET total = (
            SELECT COALESCE(SUM(subtotal), 0)
            FROM item_venda
            WHERE cod_venda = NEW.cod_venda
        )
        WHERE cod_venda = NEW.cod_venda;
    END IF;
    
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recalcular_subtotal
AFTER INSERT OR UPDATE OR DELETE ON item_venda
FOR EACH ROW
EXECUTE FUNCTION recalcular_subtotal();

-- Trigger 4:  Impedir Venda de Item Sem Estoque

CREATE OR REPLACE FUNCTION impedir_venda_sem_estoque()
RETURNS TRIGGER AS
$$
BEGIN
    -- Verificar se tem estoque disponível e pesquisa do título correspondente para a mídia selecionada
    IF (NEW.qtd_item > (SELECT qtd_estoque FROM midia WHERE cod_midia = NEW.cod_midia)) THEN
        RAISE EXCEPTION 'Estoque insuficiente para o título "%"', 
                        (SELECT t.nome 
                         FROM midia m 
                         JOIN titulo t ON m.cod_titulo = t.cod_titulo
                         WHERE m.cod_midia = NEW.cod_midia);
    END IF;

    -- Verificar quantidade positiva do pedido
    IF (NEW.qtd_item <= 0) THEN
        RAISE EXCEPTION 'Quantidade inválida: %. Deve ser maior que zero.', NEW.qtd_item;
    END IF;
    
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_impedir_venda_sem_estoque
BEFORE INSERT OR UPDATE ON item_venda
FOR EACH ROW
EXECUTE FUNCTION impedir_venda_sem_estoque();

-- Trigger 6: 

CREATE OR REPLACE FUNCTION atualizar_estoque_compra()
RETURNS TRIGGER AS
$$
	DECLARE
	quantidade_nova_compra int;
	BEGIN
		-- Atualiza o estoque da mídia
		SELECT coalesce(sum(quantidade), 0) into quantidade_nova_compra from item_compra AS ic
		WHERE ic.cod_compra = new.cod_compra;

		UPDATE midia 
		SET qtd_estoque = qtd_estoque + quantidade_nova_compra
		WHERE midia.cod_midia = new.cod_midia;

		-- Atualiza o total da compra baseado na soma dos subtotais dos itens
		UPDATE compra
		SET total = (
			SELECT COALESCE(SUM(subtotal), 0)
			FROM item_compra
			WHERE cod_compra = new.cod_compra
		)
		WHERE cod_compra = new.cod_compra;

		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER tr_atualizar_estoque_compra
AFTER INSERT ON item_compra
FOR EACH ROW
EXECUTE FUNCTION atualizar_estoque_compra();

-- Trigger para recalcular total da compra quando itens são modificados
CREATE OR REPLACE FUNCTION recalcular_total_compra()
RETURNS TRIGGER AS
$$
BEGIN
    -- Recalcula o total da compra somando todos os subtotais dos itens
    IF (TG_OP = 'DELETE') THEN
        UPDATE compra
        SET total = (
            SELECT COALESCE(SUM(subtotal), 0)
            FROM item_compra
            WHERE cod_compra = OLD.cod_compra
        )
        WHERE cod_compra = OLD.cod_compra;
    ELSE
        UPDATE compra
        SET total = (
            SELECT COALESCE(SUM(subtotal), 0)
            FROM item_compra
            WHERE cod_compra = NEW.cod_compra
        )
        WHERE cod_compra = NEW.cod_compra;
    END IF;
    
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recalcular_total_compra
AFTER UPDATE OR DELETE ON item_compra
FOR EACH ROW
EXECUTE FUNCTION recalcular_total_compra();

--Trigger 7:

CREATE OR REPLACE FUNCTION devolucao_estoque()
RETURNS TRIGGER AS
$$
	BEGIN
		IF(OLD.qtd_item IS NOT NULL AND OLD.qtd_item > 0) THEN
			UPDATE midia
			SET qtd_estoque = qtd_estoque + OLD.qtd_item
			WHERE midia.cod_midia = OLD.cod_midia;
		END IF;
		RETURN OLD;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER tg_devolucao_estoque
AFTER DELETE ON item_venda
FOR EACH ROW 
EXECUTE FUNCTION devolucao_estoque();

-- TRIGGER 8:

CREATE OR REPLACE FUNCTION controle_valores_invalidos()
RETURNS TRIGGER AS
$$
	BEGIN
		IF(TG_TABLE_NAME = 'midia') THEN
			IF(NEW.qtd_estoque IS NULL OR NEW.qtd_estoque < 0) THEN
				RAISE EXCEPTION 'Na tabela mídia não foi possível adicionar esses valores por conta da quantidade do estoque: % ser inválido', NEW.qtd_estoque;
			END IF;

			IF(NEW.valor_unid IS NULL OR NEW.valor_unid < 0) THEN
				RAISE EXCEPTION 'O valor unitário não pode ser negativo ou nulo na tabela mídia!! Valor: %', NEW.valor_unid;
			END IF;
		END IF;
		
		IF(TG_TABLE_NAME = 'item_venda') THEN
			IF(NEW.subtotal IS NULL OR NEW.subtotal < 0) THEN
				RAISE EXCEPTION 'O subtotal em item venda não pode ser negativo ou nulo! Valor: %', NEW.subtotal;
			END IF;

			IF(NEW.qtd_item IS NULL OR NEW.qtd_item < 0) THEN
				RAISE EXCEPTION 'A quantidade de itens em item venda não pode ser negativa ou nula! Valor: %', NEW.qtd_item;
			END IF;
		END IF;

		IF(TG_TABLE_NAME = 'item_compra') THEN
			IF(NEW.quantidade IS NULL OR NEW.quantidade < 0) THEN
				RAISE EXCEPTION 'A quantidade de itens em item compra não pode ser negativa ou nula! Valor: %', NEW.quantidade;
			END IF;

			IF(NEW.subtotal IS NULL OR NEW.subtotal < 0) THEN
				RAISE EXCEPTION 'O subtotal em item compra não pode ser negativo ou nulo! Valor: %', NEW.subtotal;
			END IF;
		END IF;

		IF(TG_TABLE_NAME = 'funcionario') THEN
			IF(NEW.salario IS NULL OR NEW.salario < 0) THEN
				RAISE EXCEPTION 'O salário do funcionário não pode ser negativo ou nulo! Valor: %', NEW.salario;
			END IF;
		END IF;

		IF(TG_TABLE_NAME = 'titulo') THEN
			IF(NEW.classificacao_ind IS NULL OR NEW.classificacao_ind < 0) THEN
				RAISE EXCEPTION 'A classificação indicativa do título não pode ser negativa ou nula! Valor: %', NEW.classificacao_ind;
			END IF;
			IF(NEW.ano_lancamento IS NULL OR NEW.ano_lancamento < 0) THEN
				RAISE EXCEPTION 'O ano de lançamento do título não pode ser negativo ou nulo! Valor: %', NEW.ano_lancamento;
			END IF;
		END IF;

		IF(TG_TABLE_NAME = 'compra') THEN
			IF(NEW.total IS NULL OR NEW.total < 0) THEN
				RAISE EXCEPTION 'O total da compra não pode ser negativo ou nulo! Valor: %', NEW.total;
			END IF;
		END IF;

		IF(TG_TABLE_NAME = 'venda') THEN
			IF(NEW.total IS NULL OR NEW.total < 0) THEN
				RAISE EXCEPTION 'O total da venda não pode ser negativo ou nulo! Valor: %', NEW.total;
			END IF;
		END IF;

		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

-- Triggers para controle de valores inválidos (um para cada tabela)
CREATE TRIGGER trg_controle_valores_invalidos_midia
BEFORE INSERT OR UPDATE ON midia
FOR EACH ROW
EXECUTE FUNCTION controle_valores_invalidos();

CREATE TRIGGER trg_controle_valores_invalidos_item_venda
BEFORE INSERT OR UPDATE ON item_venda
FOR EACH ROW
EXECUTE FUNCTION controle_valores_invalidos();

CREATE TRIGGER trg_controle_valores_invalidos_item_compra
BEFORE INSERT OR UPDATE ON item_compra
FOR EACH ROW
EXECUTE FUNCTION controle_valores_invalidos();

CREATE TRIGGER trg_controle_valores_invalidos_funcionario
BEFORE INSERT OR UPDATE ON funcionario
FOR EACH ROW
EXECUTE FUNCTION controle_valores_invalidos();

CREATE TRIGGER trg_controle_valores_invalidos_titulo
BEFORE INSERT OR UPDATE ON titulo
FOR EACH ROW
EXECUTE FUNCTION controle_valores_invalidos();

CREATE TRIGGER trg_controle_valores_invalidos_compra
BEFORE INSERT OR UPDATE ON compra
FOR EACH ROW
EXECUTE FUNCTION controle_valores_invalidos();

CREATE TRIGGER trg_controle_valores_invalidos_venda
BEFORE INSERT OR UPDATE ON venda
FOR EACH ROW
EXECUTE FUNCTION controle_valores_invalidos();

-- Trigger 9: Manutenção da Integridade Textual (Uppercase/Lowercase)

-- Função para padronizar campos de texto em CLIENTE, FUNCIONARIO e FORNECEDOR
CREATE OR REPLACE FUNCTION padronizar_texto_campos()
RETURNS TRIGGER AS $$
DECLARE
    valor_antigo_nome text;
    valor_antigo_email text;
    valor_antigo_telefone text;
    valor_antigo_cep text;
    alteracoes text := '';
BEGIN
    -- Armazena valores antigos para comparação
    valor_antigo_nome := NEW.nome;
	IF TG_TABLE_NAME IN ('cliente', 'fornecedor') THEN
    	valor_antigo_email := NEW.email;
	END IF;
    valor_antigo_telefone := NEW.telefone;
	IF TG_TABLE_NAME IN ('cliente', 'funcionario') THEN
    	valor_antigo_cep := NEW.cep;
	END IF;

    -- Padroniza o campo nome: apenas iniciais maiúsculas
    IF NEW.nome IS NOT NULL THEN
        NEW.nome := initcap(NEW.nome);
        IF valor_antigo_nome != NEW.nome THEN
            alteracoes := alteracoes || 'Nome: "' || valor_antigo_nome || '" → "' || NEW.nome || '" | ';
        END IF;
    END IF;

    -- Padroniza o campo email: tudo minúsculo (apenas se o campo existir)
    IF TG_TABLE_NAME IN ('cliente', 'fornecedor') THEN
        IF NEW.email IS NOT NULL THEN
            NEW.email := lower(NEW.email);
            IF valor_antigo_email != NEW.email THEN
                alteracoes := alteracoes || 'Email: "' || valor_antigo_email || '" → "' || NEW.email || '" | ';
            END IF;
        END IF;
    END IF;

    -- Padroniza o campo telefone: remove espaços e caracteres especiais
    IF NEW.telefone IS NOT NULL THEN
        NEW.telefone := regexp_replace(NEW.telefone, '[^0-9-]', '', 'g');
        IF valor_antigo_telefone != NEW.telefone THEN
            alteracoes := alteracoes || 'Telefone: "' || valor_antigo_telefone || '" → "' || NEW.telefone || '" | ';
        END IF;
    END IF;

    -- Padroniza o campo CEP: remove espaços e caracteres especiais
	IF TG_TABLE_NAME IN ('cliente', 'funcionario') THEN
	    IF NEW.cep IS NOT NULL THEN
	        NEW.cep := regexp_replace(NEW.cep, '[^0-9-]', '', 'g');
	        IF valor_antigo_cep != NEW.cep THEN
	            alteracoes := alteracoes || 'CEP: "' || valor_antigo_cep || '" → "' || NEW.cep || '" | ';
	        END IF;
	    END IF;
	END IF;
    -- Exibe mensagem informativa se houve alterações
    IF alteracoes != '' THEN
        RAISE NOTICE 'Padronização realizada na tabela %: %', TG_TABLE_NAME, rtrim(alteracoes, ' |');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para CLIENTE
CREATE OR REPLACE TRIGGER trg_padronizar_texto_cliente
BEFORE INSERT OR UPDATE ON cliente
FOR EACH ROW
EXECUTE FUNCTION padronizar_texto_campos();

-- Trigger para FUNCIONARIO
CREATE OR REPLACE TRIGGER trg_padronizar_texto_funcionario
BEFORE INSERT OR UPDATE ON funcionario
FOR EACH ROW
EXECUTE FUNCTION padronizar_texto_campos();

-- Trigger para FORNECEDOR
CREATE OR REPLACE TRIGGER trg_padronizar_texto_fornecedor
BEFORE INSERT OR UPDATE ON fornecedor
FOR EACH ROW
EXECUTE FUNCTION padronizar_texto_campos();


-- Criação da tabela de auditoria geral
CREATE TABLE IF NOT EXISTS log_auditoria_geral (
    id_log serial PRIMARY KEY,
    tabela varchar(100) NOT NULL,
    atributo varchar(100) NOT NULL,
    valor_antigo text,
    valor_novo text,
    data_alteracao timestamp NOT NULL DEFAULT now(),
    usuario text NOT NULL
);

-- Função de auditoria geral para UPDATE
CREATE OR REPLACE FUNCTION fn_auditoria_geral_update()
RETURNS TRIGGER AS $$
DECLARE
    coluna text;
    valor_antigo text;
    valor_novo text;
BEGIN
    -- Percorre todas as colunas da tabela modificada
    FOR coluna IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = TG_TABLE_NAME
    LOOP
        EXECUTE format('SELECT ($1).%I::text', coluna) INTO valor_antigo USING OLD;
        EXECUTE format('SELECT ($1).%I::text', coluna) INTO valor_novo USING NEW;

        -- Se o valor antigo for diferente do novo, registra no log
        IF valor_antigo IS DISTINCT FROM valor_novo THEN
            INSERT INTO log_auditoria_geral (tabela, atributo, valor_antigo, valor_novo, data_alteracao, usuario)
            VALUES (TG_TABLE_NAME, coluna, valor_antigo, valor_novo, now(), current_user);
        END IF;
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Exemplo de como criar triggers para todas as tabelas do banco
-- Para cada tabela, crie o trigger de auditoria de UPDATE
-- Exemplo para a tabela FUNCIONARIO:

CREATE TRIGGER trg_auditoria_funcionario_update
AFTER UPDATE ON funcionario
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();

CREATE TRIGGER trg_auditoria_cliente_update
AFTER UPDATE ON cliente
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();


CREATE TRIGGER trg_auditoria_fornecedor_update
AFTER UPDATE ON fornecedor
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();


CREATE TRIGGER trg_auditoria_titulo_update
AFTER UPDATE ON titulo
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();


CREATE TRIGGER trg_auditoria_compra_update
AFTER UPDATE ON compra
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();

CREATE TRIGGER trg_auditoria_venda_update
AFTER UPDATE ON venda
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();

CREATE TRIGGER trg_auditoria_item_compra_update
AFTER UPDATE ON item_compra
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();

CREATE TRIGGER trg_auditoria_item_venda_update
AFTER UPDATE ON item_venda
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();

CREATE TRIGGER trg_auditoria_categoria_update
AFTER UPDATE ON categoria
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();

CREATE TRIGGER trg_auditoria_tipo_midia_update
AFTER UPDATE ON tipo_midia
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();

CREATE TRIGGER trg_auditoria_midia_update
AFTER UPDATE ON midia
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_geral_update();







