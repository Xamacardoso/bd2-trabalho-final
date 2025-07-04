# bd2-trabalho-final
Trabalho final da disciplina de Banco de Dados 2 - IFPI ADS 2025.1

## Como subir o banco de dados com Docker

1. **Pré-requisitos:**
   - Docker e Docker Compose instalados em sua máquina.

2. **Subindo o container:**
   
   No terminal, navegue até a pasta do projeto e execute:
   
   ```sh
   docker-compose up -d
   ```
   Isso irá baixar a imagem do Postgres (caso necessário), criar o banco e executar todos os scripts de inicialização presentes em `initdb/`.

3. **Acessando o banco de dados Postgres dentro do container:**

   Para acessar o terminal do Postgres, execute:
   
   ```sh
   docker exec -it trabalhofinal-db-1 psql -U postgres -d trabalho-final-db
   ```
   
   - `trabalhofinal-db-1` é o nome do container (confirme com `docker ps` se necessário).
   - `-U postgres` define o usuário.
   - `-d trabalho-final-db` define o banco de dados.

4. **Executando comandos SQL:**

   Dentro do prompt do Postgres, você pode executar comandos SQL normalmente, por exemplo:
   
   ```sql
   SELECT * FROM cliente;
   SELECT * FROM venda;
   ```

5. **Parando e removendo o container e os dados:**

   Para parar e remover o container e os dados do banco (útil para reinicializar do zero):
   
   ```sh
   docker-compose down -v
   ```

---

Se precisar alterar os scripts de criação ou povoamento, edite os arquivos em `initdb/` e repita o processo acima para reinicializar o banco.
