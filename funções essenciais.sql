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

CREATE OR REPLACE FUNCTION colunas_existem(nome_tabela text, colunas text[])
RETURNS boolean AS $$
DECLARE
    colunas_tabela text[];
    coluna text;
BEGIN
    colunas_tabela := colunas_da_tabela(nome_tabela);

    FOREACH coluna IN ARRAY colunas LOOP
        IF NOT (coluna = ANY(colunas_tabela)) THEN
            RETURN FALSE;
        END IF;
    END LOOP;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;



---------------------------------------------
CREATE OR REPLACE FUNCTION inserir_registro(
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
RETURNS TEXT AS $$
DECLARE
    comando TEXT;
    qtd_relacionados INTEGER;
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RETURN format('A tabela %s não existe!', nome_tabela);
    END IF;

    -- Exemplos de verificações de integridade por tabela
    IF nome_tabela = 'fornecedor' THEN
        EXECUTE 'SELECT COUNT(*) FROM compra WHERE ' || condicao INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RETURN 'Não é possível remover o fornecedor, pois ele possui compras registradas.';
        END IF;
    ELSIF nome_tabela = 'categoria' THEN
        EXECUTE 'SELECT COUNT(*) FROM produto WHERE ' || condicao INTO qtd_relacionados;
        IF qtd_relacionados > 0 THEN
            RETURN 'Não é possível remover a categoria, pois existem produtos associados.';
        END IF;
    END IF;

    -- Monta e executa o comando DELETE
    comando := format('DELETE FROM %I WHERE %s', nome_tabela, condicao);
    EXECUTE comando;

    RETURN format('Registro removido com sucesso da tabela %s.', nome_tabela);
END;
$$ LANGUAGE plpgsql;

