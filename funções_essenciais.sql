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
    colunas text[];
    valores text[];
    coluna text;
    valor text;
    comando text;
    i integer := 0;
    tipo_coluna text;
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RAISE EXCEPTION 'A tabela % não existe!', nome_tabela;
    END IF;

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

    -- Monta e executa o INSERT
    comando := format('INSERT INTO %I (%s) VALUES (%s)', 
                     nome_tabela, 
                     array_to_string(colunas, ','), 
                     array_to_string(valores, ','));
    EXECUTE comando;

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

-- Padroniza o campo email: tudo minúsculo (apenas se o campo existir)
-- Verifica se a tabela tem o campo email antes de tentar acessá-lo
IF TG_TABLE_NAME IN ('cliente', 'fornecedor') THEN
    IF NEW.email IS NOT NULL THEN
        NEW.email := lower(NEW.email);
    END IF;
END IF;
