-- Teste de verificação do título problemático
-- Verificar se o título foi inserido corretamente

-- 1. Verificar todos os títulos inseridos
SELECT cod_titulo, nome FROM titulo ORDER BY cod_titulo;

-- 2. Verificar especificamente o título problemático
SELECT cod_titulo, nome FROM titulo WHERE nome LIKE '%Senhor dos Anéis%';

-- 3. Testar a função initcap no título
SELECT initcap('O Senhor dos Anéis: A Sociedade do Anel') as titulo_formatado;

-- 4. Verificar se existe algum título com esse nome formatado
SELECT cod_titulo, nome FROM titulo WHERE nome = initcap('O Senhor dos Anéis: A Sociedade do Anel');

-- 5. Testar a busca exata
SELECT cod_titulo, nome FROM titulo WHERE nome = 'O Senhor dos Anéis: A Sociedade do Anel';

-- 6. Verificar se há diferenças de espaços ou caracteres
SELECT cod_titulo, nome, length(nome) as tamanho FROM titulo WHERE nome LIKE '%Senhor%'; 