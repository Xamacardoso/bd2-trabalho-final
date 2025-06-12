--item-venda
create table item_venda(
	cod_midia int not null,
	cod_venda int not null,
	subtotal float not null,
	qtd_item int not null,
	primary key(cod_midia, cod_venda),
	foreign key(cod_midia) references midia(cod_midia),
	foreign key(cod_venda) references venda(cod_venda)
)

--venda
create table venda(
	cod_venda serial not null primary key,
	cod_funcionario int not null,
	cod_cliente int not null,
	dt_hora_venda timestamp not null,
	total float not null,
	foreign key (cod_funcionario) references funcionario(cod_funcionario),
	foreign key (cod_cliente) references cliente(cod_cliente)
)

--cliente
create table cliente(
	cod_cliente serial not null primary key,
	nome varchar(90) not null,
	telefone varchar(20) not null,
	email varchar(90),
	cep int
)


--funcionario
create table funcionario(
	cod_funcionario serial not null primary key,
	nome varchar(90) not null,
	telefone varchar(20) not null,
	cep int not null,
	salario float not null
);

--Mídia
create table midia(
	cod_midia serial not null primary key,
	valor_unid float not null,
	qtd_estoque int,
	cod_tipo_midia int not null,
	-- cod_fornecedor int not null,
	cod_titulo int not null,
	foreign key (cod_tipo_midia) references tipo_midia(cod_tipo_midia),
	foreign key (cod_fornecedor) references fornecedor(cod_fornecedor),
	foreign key (cod_titulo) references titulo(cod_titulo)
);

--Tipo mídia
create table tipo_midia(
	nome_formato varchar(60) not null,
	cod_tipo_midia serial not null primary key
);

--Categoria
create table categoria(
	cod_categoria serial not null primary key,
	nome varchar(50) not null
);

--titulo_categoria
create table titulo_categoria(
	cod_categoria int not null,
	cod_titulo int not null,
	primary key (cod_categoria, cod_titulo),
	foreign key(cod_categoria) references categoria(cod_categoria),
	foreign key(cod_titulo) references titulo(cod_titulo)
);

--Título
create table titulo(
	cod_titulo serial not null primary key,
	nome varchar(90) not null,
	classificacao_ind int not null,
	ano_lancamento int not null
);

--Fornecedor
create table fornecedor(
	cod_fornecedor serial not null primary key,
	nome varchar(60) not null,
	telefone varchar(20) not null,
	email varchar(90) not null
);

--Compra
create table compra(
	cod_compra serial not null primary key,
	cod_fornecedor int not null,
	foreign key(cod_fornecedor) references fornecedor(cod_fornecedor),
	total float not null,
	dt_compra date not null
);

--item compra
create table item_compra(
	cod_compra int not null primary key
	cod_midia int not null primary key
	quantidade int not null
	subtotal float not null
);

