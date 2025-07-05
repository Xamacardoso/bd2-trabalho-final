-- Teste de correção de sintaxe
-- Verificar se a função f_cadastrar_json está funcionando corretamente

-- Teste 1: Cadastrar uma categoria
SELECT f_cadastrar_json('categoria', '{"nome": "Teste Correção"}');

-- Teste 2: Verificar se foi inserida
SELECT * FROM categoria WHERE nome = 'Teste Correção';

-- Teste 3: Cadastrar um cliente
SELECT f_cadastrar_json('cliente', '{"nome": "Cliente Teste", "telefone": "1234-5678", "email": "teste@email.com", "cep": "64000-000"}');

-- Teste 4: Verificar se foi inserido
SELECT * FROM cliente WHERE nome = 'Cliente Teste';

-- Limpeza
SELECT f_remover_json('categoria', '{"nome": "Teste Correção"}');
SELECT f_remover_json('cliente', '{"nome": "Cliente Teste"}');

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE INFO 'Teste de correção de sintaxe executado com sucesso!';
END $$; 