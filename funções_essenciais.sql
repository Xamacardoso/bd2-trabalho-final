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
    colunas_para_verificar text[];
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
        
        -- Validação de tipo: impede string em campo numérico e número em campo string
        IF tipo_coluna_v IN ('integer', 'numeric', 'float', 'double precision', 'real', 'smallint', 'bigint') THEN
            -- Se valor não for numérico, lança erro
            IF valor_v ~ '[^0-9\.]' THEN
                RAISE EXCEPTION 'Valor "%" não é numérico para a coluna %!', valor_v, coluna_v;
            END IF;
        ELSIF tipo_coluna_v IN ('character varying', 'text') THEN
            -- Se valor for puramente numérico, lança erro
            IF valor_v ~ '^\d+$' THEN
                RAISE EXCEPTION 'Valor "%" não pode ser apenas número para a coluna % (esperado texto)!', valor_v, coluna_v;
            END IF;
        END IF;
        
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

    -- AUTOMATIZAÇÃO DE TIMESTAMP E TOTAL PARA VENDAS E COMPRAS
    -- Adiciona campos de timestamp automaticamente se não fornecidos
    IF nome_tabela = 'venda' AND NOT ('dt_hora_venda' = ANY(colunas_v)) THEN
        i_v := i_v + 1;
        colunas_v[i_v] := 'dt_hora_venda';
        valores_v[i_v] := 'CURRENT_TIMESTAMP';
        RAISE INFO 'Campo dt_hora_venda adicionado automaticamente com CURRENT_TIMESTAMP';
    END IF;
    
    IF nome_tabela = 'compra' AND NOT ('dt_compra' = ANY(colunas_v)) THEN
        i_v := i_v + 1;
        colunas_v[i_v] := 'dt_compra';
        valores_v[i_v] := 'CURRENT_TIMESTAMP';
        RAISE INFO 'Campo dt_compra adicionado automaticamente com CURRENT_TIMESTAMP';
    END IF;
    
    -- AUTOMATIZAÇÃO DO CAMPO TOTAL PARA VENDAS
    -- Inicializa total com 0 para que os triggers calculem o valor real
    IF nome_tabela = 'venda' AND NOT ('total' = ANY(colunas_v)) THEN
        i_v := i_v + 1;
        colunas_v[i_v] := 'total';
        valores_v[i_v] := '0';
        RAISE INFO 'Campo total inicializado automaticamente com 0 (será calculado pelos triggers)';
    END IF;

    -- Verifica se as colunas existem (apenas as colunas originais do JSON)
    -- Não inclui os campos automáticos na verificação para evitar erro
    colunas_para_verificar := ARRAY(
        SELECT unnest(colunas_v) 
        WHERE unnest != 'dt_hora_venda' 
        AND unnest != 'dt_compra'
        AND unnest != 'total'
        OR (unnest = 'dt_hora_venda' AND nome_tabela = 'venda')
        OR (unnest = 'dt_compra' AND nome_tabela = 'compra')
        OR (unnest = 'total' AND nome_tabela = 'venda')
    );
    
    IF NOT colunas_existem(nome_tabela, array_to_string(colunas_para_verificar, ',')) THEN
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

-- ========================================
-- FUNÇÃO UNIVERSAL PARA OPERAÇÕES JSON
-- ========================================

CREATE OR REPLACE FUNCTION f_operacao_json(
    operacao text,
    nome_tabela text,
    dados json,
    condicao text DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    -- Verifica se a tabela existe
    IF NOT tabela_existe(nome_tabela) THEN
        RAISE EXCEPTION 'A tabela % não existe!', nome_tabela;
    END IF;

    -- Executa a operação baseada no parâmetro
    CASE operacao
        WHEN 'INSERT' THEN
            PERFORM f_cadastrar_json(nome_tabela, dados);
        WHEN 'UPDATE' THEN
            IF condicao IS NULL THEN
                RAISE EXCEPTION 'Condição obrigatória para operação UPDATE!';
            END IF;
            PERFORM f_alterar_json(nome_tabela, dados, condicao);
        WHEN 'DELETE' THEN
            PERFORM f_remover_json(nome_tabela, dados);
        ELSE
            RAISE EXCEPTION 'Operação "%" não suportada! Use INSERT, UPDATE ou DELETE.', operacao;
    END CASE;

    RAISE INFO 'Operação % executada com sucesso na tabela %!', operacao, nome_tabela;
END;
$$ LANGUAGE plpgsql;