------------------- CREATES -------------------------
--Categoria
create table categoria(
	cod_categoria serial not null primary key,
	nome varchar(50) not null
);

--Tipo mídia
create table tipo_midia(
	nome_formato varchar(60) not null,
	cod_tipo_midia serial not null primary key
);

--Fornecedor
create table fornecedor(
	cod_fornecedor serial not null primary key,
	nome varchar(60) not null,
	telefone varchar(20) not null,
	email varchar(90) not null
);

--cliente
create table cliente(
	cod_cliente serial not null primary key,
	nome varchar(90) not null,
	telefone varchar(20) not null,
	email varchar(90),
	cep varchar(10)
);

--funcionario
create table funcionario(
	cod_funcionario serial not null primary key,
	nome varchar(90) not null,
	telefone varchar(20) not null,
	cep varchar(10),
	salario float not null
);

--Título
create table titulo(
	cod_titulo serial not null primary key,
	nome varchar(90) not null,
	classificacao_ind int not null,
	ano_lancamento int not null
);

--Compra
create table compra(
	cod_compra serial not null primary key,
	cod_fornecedor int not null,
	total float not null,
	dt_compra timestamp not null,
	foreign key(cod_fornecedor) references fornecedor(cod_fornecedor)
);

--Mídia
create table midia(
	cod_midia serial not null primary key,
	valor_unid float not null,
	qtd_estoque int,
	cod_tipo_midia int not null,
	cod_titulo int not null,
	foreign key (cod_tipo_midia) references tipo_midia(cod_tipo_midia),
	foreign key (cod_titulo) references titulo(cod_titulo)
);

--venda
create table venda(
	cod_venda serial not null primary key,
	cod_funcionario int not null,
	cod_cliente int not null,
	dt_hora_venda timestamp not null,
	total float not null,
	foreign key (cod_funcionario) references funcionario(cod_funcionario),
	foreign key (cod_cliente) references cliente(cod_cliente)
);

--titulo_categoria
create table titulo_categoria(
	cod_categoria int not null,
	cod_titulo int not null,
	primary key (cod_categoria, cod_titulo),
	foreign key(cod_categoria) references categoria(cod_categoria),
	foreign key(cod_titulo) references titulo(cod_titulo)
);

--item compra
create table item_compra(
	cod_compra int not null,
	cod_midia int not null,
	quantidade int not null,
	subtotal float not null,
	primary key(cod_compra, cod_midia),
	foreign key(cod_compra) references compra(cod_compra),
	foreign key(cod_midia) references midia(cod_midia)
);

--item-venda
create table item_venda(
	cod_midia int not null,
	cod_venda int not null,
	subtotal float not null,
	qtd_item int not null,
	primary key(cod_midia, cod_venda),
	foreign key(cod_midia) references midia(cod_midia),
	foreign key(cod_venda) references venda(cod_venda)
);

---------------------- TRIGGERS -------------------------

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

------------------------- FUNCOES IMPORTANTES -----------------------------

CREATE OR REPLACE FUNCTION tabela_existe(nome_tabela text)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = nome_tabela
    );
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION colunas_da_tabela(nome_tabela text)
RETURNS text[] AS $$
BEGIN
    RETURN ARRAY(
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = nome_tabela
    );
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION colunas_existem(nome_tabela text, colunas text)
RETURNS boolean AS $$
DECLARE
    colunas_tabela text[];
    colunas_array text[];
    coluna text;
BEGIN
    colunas_tabela := colunas_da_tabela(nome_tabela);
    colunas_array := string_to_array(colunas, ',');

    FOREACH coluna IN ARRAY colunas_array LOOP
        IF NOT (coluna = ANY(colunas_tabela)) THEN
            RETURN FALSE;
        END IF;
    END LOOP;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;


-- ========================================
-- VERSÕES COM JSON DAS FUNÇÕES PRINCIPAIS
-- ========================================

CREATE OR REPLACE FUNCTION f_cadastrar_json(
    nome_tabela text,
    dados json
)
RETURNS void AS $$
DECLARE
    colunas_v text[];
    valores_v text[];
    coluna_v text;
    valor_v text;
    comando_v text;
    i_v integer := 0;
    tipo_coluna_v text;
    cod_cliente_v int;
    cod_funcionario_v int;
    cod_fornecedor_v int;
    cod_titulo_v int;
    cod_tipo_midia_v int;
    cod_categoria_v int;
    cod_midia_v int;
    cod_compra_v int;
    cod_venda_v int;
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RAISE EXCEPTION 'A tabela % não existe!', nome_tabela;
    END IF;

    -- Extrai colunas e valores do JSON
    FOR coluna_v, valor_v IN SELECT * FROM json_each_text(dados)
    LOOP
        i_v := i_v + 1;
        colunas_v[i_v] := coluna_v;
        
        -- Verifica o tipo da coluna para formatar o valor adequadamente
        SELECT data_type INTO tipo_coluna_v 
        FROM information_schema.columns 
        WHERE table_name = nome_tabela AND column_name = coluna_v;
        
        -- Tratamento especial para campos que usam nomes em vez de códigos
        IF coluna_v = 'nome_cliente' THEN
            -- Busca o código do cliente pelo nome (aplicando formatação)
            SELECT cod_cliente INTO cod_cliente_v FROM cliente WHERE nome = initcap(valor_v);
            IF cod_cliente_v IS NULL THEN
                RAISE EXCEPTION 'Cliente com nome "%" não encontrado!', valor_v;
            END IF;
            valores_v[i_v] := cod_cliente_v::text;
            colunas_v[i_v] := 'cod_cliente';
            
        ELSIF coluna_v = 'nome_funcionario' THEN
            -- Busca o código do funcionário pelo nome (aplicando formatação)
            SELECT cod_funcionario INTO cod_funcionario_v FROM funcionario WHERE nome = initcap(valor_v);
            IF cod_funcionario_v IS NULL THEN
                RAISE EXCEPTION 'Funcionário com nome "%" não encontrado!', valor_v;
            END IF;
            valores_v[i_v] := cod_funcionario_v::text;
            colunas_v[i_v] := 'cod_funcionario';
            
        ELSIF coluna_v = 'nome_fornecedor' THEN
            -- Busca o código do fornecedor pelo nome (aplicando formatação)
            SELECT cod_fornecedor INTO cod_fornecedor_v FROM fornecedor WHERE nome = initcap(valor_v);
            IF cod_fornecedor_v IS NULL THEN
                RAISE EXCEPTION 'Fornecedor com nome "%" não encontrado!', valor_v;
            END IF;
            valores_v[i_v] := cod_fornecedor_v::text;
            colunas_v[i_v] := 'cod_fornecedor';
            
        ELSIF coluna_v = 'nome_titulo' THEN
            -- Busca o código do título pelo nome (aplicando formatação)
            SELECT cod_titulo INTO cod_titulo_v FROM titulo WHERE nome = initcap(valor_v);
            IF cod_titulo_v IS NULL THEN
                RAISE EXCEPTION 'Título com nome "%" não encontrado!', valor_v;
            END IF;
            valores_v[i_v] := cod_titulo_v::text;
            colunas_v[i_v] := 'cod_titulo';
            
        ELSIF coluna_v = 'nome_tipo_midia' THEN
            -- Busca o código do tipo de mídia pelo nome (aplicando formatação)
            SELECT cod_tipo_midia INTO cod_tipo_midia_v FROM tipo_midia WHERE nome_formato = valor_v;
            IF cod_tipo_midia_v IS NULL THEN
                RAISE EXCEPTION 'Tipo de mídia com nome "%" não encontrado!', valor_v;
            END IF;
            valores_v[i_v] := cod_tipo_midia_v::text;
            colunas_v[i_v] := 'cod_tipo_midia';
            
        ELSIF coluna_v = 'nome_categoria' THEN
            -- Busca o código da categoria pelo nome (aplicando formatação)
            SELECT cod_categoria INTO cod_categoria_v FROM categoria WHERE nome = initcap(valor_v);
            IF cod_categoria_v IS NULL THEN
                RAISE EXCEPTION 'Categoria com nome "%" não encontrada!', valor_v;
            END IF;
            valores_v[i_v] := cod_categoria_v::text;
            colunas_v[i_v] := 'cod_categoria';
            
        ELSIF coluna_v = 'nome_midia' THEN
            -- Busca o código da mídia pelo título (aplicando formatação)
            SELECT m.cod_midia INTO cod_midia_v 
            FROM midia m 
            JOIN titulo t ON m.cod_titulo = t.cod_titulo 
            WHERE t.nome = initcap(valor_v);
            IF cod_midia_v IS NULL THEN
                RAISE EXCEPTION 'Mídia com título "%" não encontrada!', valor_v;
            END IF;
            valores_v[i_v] := cod_midia_v::text;
            colunas_v[i_v] := 'cod_midia';
            
        ELSIF coluna_v = 'cod_compra' AND valor_v ~ '^[0-9]+$' THEN
            -- Se for um número, mantém como está
            valores_v[i_v] := valor_v;
            
        ELSIF coluna_v = 'cod_venda' AND valor_v ~ '^[0-9]+$' THEN
            -- Se for um número, mantém como está
            valores_v[i_v] := valor_v;
            
        ELSE
            -- Formata o valor baseado no tipo da coluna
            IF tipo_coluna_v IN ('character varying', 'text', 'date', 'timestamp', 'timestamp without time zone') THEN
                -- Para strings, datas e timestamps, adiciona aspas simples
                valores_v[i_v] := quote_literal(valor_v);
            ELSE
                -- Para números e outros tipos, usa o valor diretamente
                valores_v[i_v] := valor_v;
            END IF;
        END IF;
    END LOOP;

    -- Verifica se as colunas existem
    IF NOT colunas_existem(nome_tabela, array_to_string(colunas_v, ',')) THEN
        RAISE EXCEPTION 'Uma ou mais colunas não existem na tabela %!', nome_tabela;
    END IF;

    -- Monta e executa o INSERT
    comando_v := format('INSERT INTO %I (%s) VALUES (%s)', 
                     nome_tabela, 
                     array_to_string(colunas_v, ','), 
                     array_to_string(valores_v, ','));
    EXECUTE comando_v;

    RAISE INFO 'Registro incluído com sucesso na tabela %!', nome_tabela;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION f_alterar_json(
    nome_tabela text,
    dados json,
    condicao text
)
RETURNS void AS $$
DECLARE
    sets text[];
    coluna text;
    valor text;
    comando text;
    colunas_json text[];
    i integer := 0;
    tipo_coluna text;
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RAISE EXCEPTION 'A tabela % não existe!', nome_tabela;
    END IF;

    -- Extrai colunas do JSON
    FOR coluna, valor IN SELECT * FROM json_each_text(dados)
    LOOP
        i := i + 1;
        colunas_json[i] := coluna;
        
        -- Verifica o tipo da coluna para formatar o valor adequadamente
        SELECT data_type INTO tipo_coluna 
        FROM information_schema.columns 
        WHERE table_name = nome_tabela AND column_name = coluna;
        
        -- Formata o valor baseado no tipo da coluna
        IF tipo_coluna IN ('character varying', 'text', 'date', 'timestamp', 'timestamp without time zone') THEN
            -- Para strings, datas e timestamps, adiciona aspas simples
            sets := array_append(sets, format('%I = %s', coluna, quote_literal(valor)));
        ELSE
            -- Para números e outros tipos, usa o valor diretamente
            sets := array_append(sets, format('%I = %s', coluna, valor));
        END IF;
    END LOOP;

    -- Verifica se as colunas existem
    IF NOT colunas_existem(nome_tabela, array_to_string(colunas_json, ',')) THEN
        RAISE EXCEPTION 'Uma ou mais colunas não existem na tabela %!', nome_tabela;
    END IF;

    -- Monta e executa o comando UPDATE
    comando := format('UPDATE %I SET %s WHERE %s', 
                     nome_tabela, 
                     array_to_string(sets, ', '), 
                     condicao);
    EXECUTE comando;

    RAISE INFO 'Registro atualizado com sucesso na tabela %!', nome_tabela;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION f_remover_json(
    nome_tabela text,
    condicoes json
)
RETURNS void AS $$
DECLARE
    comando text;
    condicao_final text;
    coluna text;
    valor text;
    condicoes_array text[];
    qtd_relacionados INTEGER;
    tipo_coluna text;
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RAISE EXCEPTION 'A tabela % não existe!', nome_tabela;
    END IF;

    -- Constrói condições a partir do JSON
    FOR coluna, valor IN SELECT * FROM json_each_text(condicoes)
    LOOP
        -- Verifica o tipo da coluna para formatar o valor adequadamente
        SELECT data_type INTO tipo_coluna 
        FROM information_schema.columns 
        WHERE table_name = nome_tabela AND column_name = coluna;
        
        -- Formata o valor baseado no tipo da coluna
        IF tipo_coluna IN ('character varying', 'text', 'date', 'timestamp', 'timestamp without time zone') THEN
            -- Para strings, datas e timestamps, adiciona aspas simples
            condicoes_array := array_append(condicoes_array, format('%I = %s', coluna, quote_literal(valor)));
        ELSE
            -- Para números e outros tipos, usa o valor diretamente
            condicoes_array := array_append(condicoes_array, format('%I = %s', coluna, valor));
        END IF;
    END LOOP;

    condicao_final := array_to_string(condicoes_array, ' AND ');

    -- Verificações de integridade por tabela (mesma lógica da função original)
    IF nome_tabela = 'fornecedor' THEN
        EXECUTE 'SELECT COUNT(*) FROM compra WHERE cod_fornecedor IN (SELECT cod_fornecedor FROM fornecedor WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o fornecedor, pois ele possui % compras registradas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'categoria' THEN
        EXECUTE 'SELECT COUNT(*) FROM titulo_categoria WHERE cod_categoria IN (SELECT cod_categoria FROM categoria WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a categoria, pois existem % títulos associados.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'cliente' THEN
        EXECUTE 'SELECT COUNT(*) FROM venda WHERE cod_cliente IN (SELECT cod_cliente FROM cliente WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o cliente, pois ele possui % vendas registradas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'funcionario' THEN
        EXECUTE 'SELECT COUNT(*) FROM venda WHERE cod_funcionario IN (SELECT cod_funcionario FROM funcionario WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o funcionário, pois ele possui % vendas registradas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'titulo' THEN
        EXECUTE 'SELECT COUNT(*) FROM midia WHERE cod_titulo IN (SELECT cod_titulo FROM titulo WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o título, pois existem % mídias associadas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'tipo_midia' THEN
        EXECUTE 'SELECT COUNT(*) FROM midia WHERE cod_tipo_midia IN (SELECT cod_tipo_midia FROM tipo_midia WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o tipo de mídia, pois existem % mídias associadas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'compra' THEN
        EXECUTE 'SELECT COUNT(*) FROM item_compra WHERE cod_compra IN (SELECT cod_compra FROM compra WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a compra, pois ela possui % itens registrados.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'midia' THEN
        EXECUTE 'SELECT COUNT(*) FROM item_compra WHERE cod_midia IN (SELECT cod_midia FROM midia WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a mídia, pois ela possui % itens de compra registrados.', qtd_relacionados;
        END IF;
        EXECUTE 'SELECT COUNT(*) FROM item_venda WHERE cod_midia IN (SELECT cod_midia FROM midia WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a mídia, pois ela possui % itens de venda registrados.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'venda' THEN
        EXECUTE 'SELECT COUNT(*) FROM item_venda WHERE cod_venda IN (SELECT cod_venda FROM venda WHERE ' || condicao_final || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a venda, pois ela possui % itens registrados.', qtd_relacionados;
        END IF;
    END IF;

    -- Monta e executa o comando DELETE
    comando := format('DELETE FROM %I WHERE %s', nome_tabela, condicao_final);
    EXECUTE comando;

    RAISE INFO 'Registro(s) removido(s) com sucesso da tabela %!', nome_tabela;
END;
$$ LANGUAGE plpgsql;

-- Função Universal com JSON para todas as operações
CREATE OR REPLACE FUNCTION f_operacao_json(
    operacao text, -- 'INSERT', 'UPDATE', 'DELETE'
    nome_tabela text,
    dados json DEFAULT NULL,
    condicao text DEFAULT NULL
)
RETURNS void AS $$
DECLARE
    comando text;
    colunas text[];
    valores text[];
    sets text[];
    condicoes_array text[];
    coluna text;
    valor text;
    i integer := 0;
    qtd_relacionados INTEGER;
    condicao_final text;
    tipo_coluna text;
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RAISE EXCEPTION 'A tabela % não existe!', nome_tabela;
    END IF;

    CASE operacao
        WHEN 'INSERT' THEN
            -- Extrai colunas e valores do JSON
            FOR coluna, valor IN SELECT * FROM json_each_text(dados)
            LOOP
                i := i + 1;
                colunas[i] := coluna;
                
                -- Verifica o tipo da coluna para formatar o valor adequadamente
                SELECT data_type INTO tipo_coluna 
                FROM information_schema.columns 
                WHERE table_name = nome_tabela AND column_name = coluna;
                
                -- Formata o valor baseado no tipo da coluna
                IF tipo_coluna IN ('character varying', 'text', 'date', 'timestamp', 'timestamp without time zone') THEN
                    -- Para strings, datas e timestamps, adiciona aspas simples
                    valores[i] := quote_literal(valor);
                ELSE
                    -- Para números e outros tipos, usa o valor diretamente
                    valores[i] := valor;
                END IF;
            END LOOP;

            -- Verifica se as colunas existem
            IF NOT colunas_existem(nome_tabela, array_to_string(colunas, ',')) THEN
                RAISE EXCEPTION 'Uma ou mais colunas não existem na tabela %!', nome_tabela;
            END IF;

            comando := format('INSERT INTO %I (%s) VALUES (%s)', 
                             nome_tabela, 
                             array_to_string(colunas, ','), 
                             array_to_string(valores, ','));

        WHEN 'UPDATE' THEN
            -- Constrói a cláusula SET
            FOR coluna, valor IN SELECT * FROM json_each_text(dados)
            LOOP
                -- Verifica o tipo da coluna para formatar o valor adequadamente
                SELECT data_type INTO tipo_coluna 
                FROM information_schema.columns 
                WHERE table_name = nome_tabela AND column_name = coluna;
                
                -- Formata o valor baseado no tipo da coluna
                IF tipo_coluna IN ('character varying', 'text', 'date', 'timestamp', 'timestamp without time zone') THEN
                    -- Para strings, datas e timestamps, adiciona aspas simples
                    sets := array_append(sets, format('%I = %s', coluna, quote_literal(valor)));
                ELSE
                    -- Para números e outros tipos, usa o valor diretamente
                    sets := array_append(sets, format('%I = %s', coluna, valor));
                END IF;
            END LOOP;

            comando := format('UPDATE %I SET %s WHERE %s', 
                             nome_tabela, 
                             array_to_string(sets, ', '), 
                             condicao);

        WHEN 'DELETE' THEN
            -- Constrói condições a partir do JSON
            FOR coluna, valor IN SELECT * FROM json_each_text(dados)
            LOOP
                -- Verifica o tipo da coluna para formatar o valor adequadamente
                SELECT data_type INTO tipo_coluna 
                FROM information_schema.columns 
                WHERE table_name = nome_tabela AND column_name = coluna;
                
                -- Formata o valor baseado no tipo da coluna
                IF tipo_coluna IN ('character varying', 'text', 'date', 'timestamp', 'timestamp without time zone') THEN
                    -- Para strings, datas e timestamps, adiciona aspas simples
                    condicoes_array := array_append(condicoes_array, format('%I = %s', coluna, quote_literal(valor)));
                ELSE
                    -- Para números e outros tipos, usa o valor diretamente
                    condicoes_array := array_append(condicoes_array, format('%I = %s', coluna, valor));
                END IF;
            END LOOP;

            condicao_final := array_to_string(condicoes_array, ' AND ');

            -- Verificações de integridade por tabela (mesma lógica da função original)
            IF nome_tabela = 'fornecedor' THEN
                EXECUTE 'SELECT COUNT(*) FROM compra WHERE cod_fornecedor IN (SELECT cod_fornecedor FROM fornecedor WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover o fornecedor, pois ele possui % compras registradas.', qtd_relacionados;
                END IF;
            ELSIF nome_tabela = 'categoria' THEN
                EXECUTE 'SELECT COUNT(*) FROM titulo_categoria WHERE cod_categoria IN (SELECT cod_categoria FROM categoria WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover a categoria, pois existem % títulos associados.', qtd_relacionados;
                END IF;
            ELSIF nome_tabela = 'cliente' THEN
                EXECUTE 'SELECT COUNT(*) FROM venda WHERE cod_cliente IN (SELECT cod_cliente FROM cliente WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover o cliente, pois ele possui % vendas registradas.', qtd_relacionados;
                END IF;
            ELSIF nome_tabela = 'funcionario' THEN
                EXECUTE 'SELECT COUNT(*) FROM venda WHERE cod_funcionario IN (SELECT cod_funcionario FROM funcionario WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover o funcionário, pois ele possui % vendas registradas.', qtd_relacionados;
                END IF;
            ELSIF nome_tabela = 'titulo' THEN
                EXECUTE 'SELECT COUNT(*) FROM midia WHERE cod_titulo IN (SELECT cod_titulo FROM titulo WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover o título, pois existem % mídias associadas.', qtd_relacionados;
                END IF;
            ELSIF nome_tabela = 'tipo_midia' THEN
                EXECUTE 'SELECT COUNT(*) FROM midia WHERE cod_tipo_midia IN (SELECT cod_tipo_midia FROM tipo_midia WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover o tipo de mídia, pois existem % mídias associadas.', qtd_relacionados;
                END IF;
            ELSIF nome_tabela = 'compra' THEN
                EXECUTE 'SELECT COUNT(*) FROM item_compra WHERE cod_compra IN (SELECT cod_compra FROM compra WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover a compra, pois ela possui % itens registrados.', qtd_relacionados;
                END IF;
            ELSIF nome_tabela = 'midia' THEN
                EXECUTE 'SELECT COUNT(*) FROM item_compra WHERE cod_midia IN (SELECT cod_midia FROM midia WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover a mídia, pois ela possui % itens de compra registrados.', qtd_relacionados;
                END IF;
                EXECUTE 'SELECT COUNT(*) FROM item_venda WHERE cod_midia IN (SELECT cod_midia FROM midia WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover a mídia, pois ela possui % itens de venda registrados.', qtd_relacionados;
                END IF;
            ELSIF nome_tabela = 'venda' THEN
                EXECUTE 'SELECT COUNT(*) FROM item_venda WHERE cod_venda IN (SELECT cod_venda FROM venda WHERE ' || condicao_final || ')' INTO qtd_relacionados;
                IF qtd_relacionados > 0 THEN
                    RAISE EXCEPTION 'Não é possível remover a venda, pois ela possui % itens registrados.', qtd_relacionados;
                END IF;
            END IF;

            comando := format('DELETE FROM %I WHERE %s', 
                             nome_tabela, 
                             condicao_final);

        ELSE
            RAISE EXCEPTION 'Operação % não suportada!', operacao;
    END CASE;

    EXECUTE comando;
    RAISE INFO 'Operação % executada com sucesso na tabela %!', operacao, nome_tabela;
END;
$$ LANGUAGE plpgsql;

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