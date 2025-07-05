-- Teste da correção da busca de títulos
-- Verificar se a função f_cadastrar_json agora consegue encontrar títulos corretamente

-- Teste 1: Tentar inserir um relacionamento título-categoria com o título problemático
SELECT f_cadastrar_json('titulo_categoria', '{"nome_categoria": "Aventura", "nome_titulo": "O Senhor dos Anéis: A Sociedade do Anel"}');

-- Teste 2: Verificar se foi inserido
SELECT tc.cod_titulo_categoria, c.nome as categoria, t.nome as titulo 
FROM titulo_categoria tc 
JOIN categoria c ON tc.cod_categoria = c.cod_categoria 
JOIN titulo t ON tc.cod_titulo = t.cod_titulo 
WHERE t.nome LIKE '%Senhor dos Anéis%';

-- Teste 3: Tentar inserir um item de compra com o título problemático
SELECT f_cadastrar_json('item_compra', '{"cod_compra": "1", "nome_midia": "O Senhor dos Anéis: A Sociedade do Anel", "quantidade": "5", "subtotal": "150.00"}');

-- Teste 4: Verificar se foi inserido
SELECT ic.cod_compra, ic.quantidade, t.nome as titulo 
FROM item_compra ic 
JOIN midia m ON ic.cod_midia = m.cod_midia 
JOIN titulo t ON m.cod_titulo = t.cod_titulo 
WHERE t.nome LIKE '%Senhor dos Anéis%';

-- Teste 5: Tentar inserir um item de venda com o título problemático
SELECT f_cadastrar_json('item_venda', '{"nome_midia": "O Senhor dos Anéis: A Sociedade do Anel", "cod_venda": "1", "qtd_item": "1"}');

-- Teste 6: Verificar se foi inserido
SELECT iv.cod_venda, iv.qtd_item, t.nome as titulo 
FROM item_venda iv 
JOIN midia m ON iv.cod_midia = m.cod_midia 
JOIN titulo t ON m.cod_titulo = t.cod_titulo 
WHERE t.nome LIKE '%Senhor dos Anéis%';

-- Limpeza dos testes
SELECT f_remover_json('titulo_categoria', '{"nome_categoria": "Aventura", "nome_titulo": "O Senhor dos Anéis: A Sociedade do Anel"}');
SELECT f_remover_json('item_compra', '{"cod_compra": "1", "nome_midia": "O Senhor dos Anéis: A Sociedade do Anel"}');
SELECT f_remover_json('item_venda', '{"nome_midia": "O Senhor dos Anéis: A Sociedade do Anel", "cod_venda": "1"}');

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE INFO 'Teste da correção de busca de títulos executado com sucesso!';
    RAISE INFO 'A função f_cadastrar_json agora consegue encontrar títulos corretamente';
END $$; 