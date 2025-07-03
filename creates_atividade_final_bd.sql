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

