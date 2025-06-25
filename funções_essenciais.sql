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


---------------------------------------------
CREATE OR REPLACE FUNCTION f_cadastrar(
    nome_tabela text,
    colunas text,
    valores text
)
RETURNS void AS $$
DECLARE
    colunas_array text[];
    comando text;
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RAISE EXCEPTION 'A tabela % não existe!', nome_tabela;
    END IF;

    -- Converte a string de colunas para array
    colunas_array := string_to_array(colunas, ',');

    -- Verifica se as colunas existem
    IF NOT colunas_existem(nome_tabela, colunas_array) THEN
        RAISE EXCEPTION 'Uma ou mais colunas não existem na tabela %!', nome_tabela;
    END IF;

    -- Monta e executa o INSERT
    comando := format('INSERT INTO %I (%s) VALUES (%s)', nome_tabela, colunas, valores);
    EXECUTE comando;

    RAISE INFO 'Registro incluído com sucesso na tabela %!', nome_tabela;
END;
$$ LANGUAGE plpgsql;



-------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION f_alterar(
    nome_tabela TEXT,
    atributos TEXT,
    condicao TEXT
)
RETURNS void AS $$
DECLARE
    comando TEXT;
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RAISE EXCEPTION 'A tabela % não existe!', nome_tabela;
    END IF;

    -- Monta e executa o comando UPDATE
    comando := format('UPDATE %I SET %s WHERE %s', nome_tabela, atributos, condicao);
    EXECUTE comando;

    RAISE INFO 'Registro atualizado com sucesso na tabela %!', nome_tabela;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION f_remover(
    nome_tabela TEXT,
    condicao TEXT
)
RETURNS void AS $$
DECLARE
    comando TEXT;
    qtd_relacionados INTEGER;
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RAISE EXCEPTION 'A tabela % não existe!', nome_tabela;
    END IF;

    -- Verificações de integridade por tabela (simples e diretas)
    IF nome_tabela = 'fornecedor' THEN
        EXECUTE 'SELECT COUNT(*) FROM compra WHERE cod_fornecedor IN (SELECT cod_fornecedor FROM fornecedor WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o fornecedor, pois ele possui % compras registradas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'categoria' THEN
        EXECUTE 'SELECT COUNT(*) FROM titulo_categoria WHERE cod_categoria IN (SELECT cod_categoria FROM categoria WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a categoria, pois existem % títulos associados.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'cliente' THEN
        EXECUTE 'SELECT COUNT(*) FROM venda WHERE cod_cliente IN (SELECT cod_cliente FROM cliente WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o cliente, pois ele possui % vendas registradas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'funcionario' THEN
        EXECUTE 'SELECT COUNT(*) FROM venda WHERE cod_funcionario IN (SELECT cod_funcionario FROM funcionario WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o funcionário, pois ele possui % vendas registradas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'titulo' THEN
        EXECUTE 'SELECT COUNT(*) FROM midia WHERE cod_titulo IN (SELECT cod_titulo FROM titulo WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o título, pois existem % mídias associadas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'tipo_midia' THEN
        EXECUTE 'SELECT COUNT(*) FROM midia WHERE cod_tipo_midia IN (SELECT cod_tipo_midia FROM tipo_midia WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover o tipo de mídia, pois existem % mídias associadas.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'compra' THEN
        EXECUTE 'SELECT COUNT(*) FROM item_compra WHERE cod_compra IN (SELECT cod_compra FROM compra WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a compra, pois ela possui % itens registrados.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'midia' THEN
        EXECUTE 'SELECT COUNT(*) FROM item_compra WHERE cod_midia IN (SELECT cod_midia FROM midia WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a mídia, pois ela possui % itens de compra registrados.', qtd_relacionados;
        END IF;
        EXECUTE 'SELECT COUNT(*) FROM item_venda WHERE cod_midia IN (SELECT cod_midia FROM midia WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a mídia, pois ela possui % itens de venda registrados.', qtd_relacionados;
        END IF;
    ELSIF nome_tabela = 'venda' THEN
        EXECUTE 'SELECT COUNT(*) FROM item_venda WHERE cod_venda IN (SELECT cod_venda FROM venda WHERE ' || condicao || ')' INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RAISE EXCEPTION 'Não é possível remover a venda, pois ela possui % itens registrados.', qtd_relacionados;
        END IF;
    END IF;

    -- Monta e executa o comando DELETE
    comando := format('DELETE FROM %I WHERE %s', nome_tabela, condicao);
    EXECUTE comando;

    RAISE INFO 'Registro(s) removido(s) com sucesso da tabela %!', nome_tabela;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
