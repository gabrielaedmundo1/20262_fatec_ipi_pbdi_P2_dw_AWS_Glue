-- Enunciado 5
/* Conectado ao banco pelo psql do CloudShell, crie os schemas staging e dw e a tabela
staging.sales, com as colunas e os tipos da Tabela 2, NOT NULL em todas elas e row_id
como chave primária. Registre todo o SQL no script.sql. */

-- Verifica a versão do PSQL
-- psql --version

-- Realiza a conexão com o banco de dados
-- psql -h dw-superstore-2041382521025.cvqogdb2b1ys.us-east-1.rds.amazonaws.com -p 5432 -U postgres -d superstore_dw

-- Cria os schemas
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dw;

-- Cria a tabela de destino
DROP TABLE IF EXISTS staging.sales CASCADE;
CREATE TABLE staging.sales (
	row_id INTEGER PRIMARY KEY,
	order_id VARCHAR(20) NOT NULL,
	order_date DATE NOT NULL,
	ship_date DATE NOT NULL,
	ship_mode VARCHAR(20) NOT NULL,
	customer_id VARCHAR(20) NOT NULL,
	customer_name VARCHAR(60) NOT NULL,
	segment VARCHAR(20) NOT NULL,
	country VARCHAR(40) NOT NULL,
	city VARCHAR(60) NOT NULL,
	state VARCHAR(40) NOT NULL,
	postal_code VARCHAR(10) NOT NULL,
	region VARCHAR(20) NOT NULL,
	product_id VARCHAR(20) NOT NULL,
	category VARCHAR(30) NOT NULL,
	sub_category VARCHAR(30) NOT NULL,
	product_name VARCHAR(200) NOT NULL,
	sales NUMERIC(12,2) NOT NULL
);

-- Verifica a criação dos schemas e da tabela
\dn
\d staging.sales

-- Enunciado 10
/* Escreva uma única consulta sobre staging.sales que devolva, em uma linha: a quantidade
de linhas, a soma de sales, a menor data de pedido, a maior data de envio, a quantidade de
códigos postais 'N/D' e a quantidade de linhas com data de envio anterior à data do pedido.
Registre os valores em comentário. A quantidade de linhas e a de códigos postais 'N/D'
devem coincidir com as respostas (a) e (c) do Enunciado 2. */

SELECT
    COUNT(*) AS qtd_linhas, -- 9800
    SUM(sales) AS total_vendas, -- 2261536.97
    MIN(order_date) AS primeira_data_pedido, -- 2015-01-03
    MAX(ship_date) AS ultima_data_envio, -- 2019-01-05
    COUNT(*) FILTER (WHERE postal_code = 'N/D') AS qtd_nd, -- 11
    COUNT(*) FILTER (WHERE ship_date < order_date) AS qtd_envio_antes_pedido -- 0
FROM staging.sales;

-- Enunciado 11
/* Crie e carregue dw.dim_date como na Seção 12.4 da apostila, com o calendário gerado por
generate_series a partir de subconsultas sobre a staging: do primeiro dia do ano da menor
data de pedido até o último dia do ano da maior data de envio. Explique em comentário por
que o fim do calendário é calculado com a data de envio, e não com a do pedido. */

-- Cria a dimensão date
DROP TABLE IF EXISTS dw.dim_date CASCADE;
CREATE TABLE dw.dim_date (
    date_sk INTEGER PRIMARY KEY,         -- no formato AAAAMMDD
    full_date DATE NOT NULL UNIQUE,
    day SMALLINT NOT NULL,
    month SMALLINT NOT NULL,
    month_name VARCHAR(15) NOT NULL,
    quarter SMALLINT NOT NULL,
    year SMALLINT NOT NULL,
    day_of_week VARCHAR(15) NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

-- Gera e insere o calendário na dimensão date
INSERT INTO dw.dim_date
SELECT
    CAST(TO_CHAR(d, 'YYYYMMDD') AS INTEGER),
    d::DATE,
    EXTRACT(DAY FROM d)::SMALLINT,
    EXTRACT(MONTH FROM d)::SMALLINT,
    TO_CHAR(d, 'TMMonth'),
    EXTRACT(QUARTER FROM d)::SMALLINT,
    EXTRACT(YEAR FROM d)::SMALLINT,
    TO_CHAR(d, 'TMDay'),
    EXTRACT(DOW FROM d) IN (0, 6)
FROM generate_series(
         -- 1 de janeiro do ano da primeira data de pedido
         (SELECT date_trunc('year', MIN(order_date)) FROM staging.sales),
         -- 31 de dezembro do ano da ultima data de envio
         (SELECT date_trunc('year', MAX(ship_date)) + INTERVAL '1 year - 1 day'
            FROM staging.sales),
         INTERVAL '1 day') g(d);

-- Verifica a inserção dos dados na dimensão date
SELECT MIN(full_date), MAX(full_date), COUNT(*) FROM dw.dim_date;
-- Resultado da consulta acima:
--    min     |    max     | count 
------------+------------+--------
-- 2015-01-01 | 2019-12-31 |  1826

/* O fim do calendário é calculado com a maior data de envio porque
um pedido pode ser enviado depois da data em que foi feito, inclusive
no ano seguinte. Assim, o calendário também contempla as datas de envio.
Se usássemos a maior data de pedido como referência, os envios de um
ano posterior poderiam ficar fora do calendário. */

-- Enunciado 12
/* Escreva três consultas de verificação sobre a staging e registre os resultados em 
comentário: quantos product_id aparecem com mais de um product_name; quantos customer_id
aparecem com mais de um customer_name ou mais de um segment; e quantas combinações
de cidade, estado e código postal aparecem com mais de uma região. */

-- Verifica quantos product_id aparecem com mais de um product_name
SELECT COUNT(*) AS qtd_produtos_varios_nomes
FROM (
    SELECT product_id
    FROM staging.sales
    GROUP BY product_id
    HAVING COUNT(DISTINCT product_name) > 1); -- Resultado: 32

-- Verifica quantos customer_id aparecem com mais de um customer_name ou mais de um segment
SELECT COUNT(*) AS qtd_clientes_varios_nomes_ou_segmentos
FROM (
    SELECT customer_id
    FROM staging.sales
    GROUP BY customer_id
    HAVING (COUNT(DISTINCT customer_name) > 1) OR (COUNT(DISTINCT segment) > 1)); -- Resultado: 0

-- Verifica quantas combinações de cidade, estado e código postal aparecem com mais de uma região
SELECT COUNT(*) AS qtd_combinacoes_varias_regioes
FROM (
    SELECT city, state, postal_code
    FROM staging.sales
    GROUP BY city, state, postal_code
    HAVING COUNT(DISTINCT region) > 1); -- Resultado: 0

-- Enunciado 13
/* Crie as tabelas dw.dim_customer, dw.dim_product, dw.dim_location, dw.dim_ship_mode
e dw.fact_sales conforme a Figura 4: chaves SERIAL, atributos naturais UNIQUE (em
dim_location, a combinação de país, estado, cidade e código postal), seis chaves estrangeiras
NOT NULL na fato, duas delas para dw.dim_date, métricas NOT NULL e um índice por chave
estrangeira. Nesta fase as tabelas ficam vazias. */

-- Cria a dimensão customer
DROP TABLE IF EXISTS dw.dim_customer CASCADE;
CREATE TABLE dw.dim_customer (
    customer_sk SERIAL PRIMARY KEY,
	customer_id VARCHAR(20) NOT NULL UNIQUE,
    customer_name VARCHAR(60) NOT NULL,
	segment VARCHAR(20) NOT NULL
);

-- Cria a dimensão product
DROP TABLE IF EXISTS dw.dim_product CASCADE;
CREATE TABLE dw.dim_product (
    product_sk SERIAL PRIMARY KEY,
	product_id VARCHAR(20) NOT NULL UNIQUE,
    product_name VARCHAR(200) NOT NULL,
	category VARCHAR(30) NOT NULL,
	sub_category VARCHAR(30) NOT NULL
);

-- Cria a dimensão location
DROP TABLE IF EXISTS dw.dim_location CASCADE;
CREATE TABLE dw.dim_location (
    location_sk SERIAL PRIMARY KEY,
    country VARCHAR(40) NOT NULL,
    state VARCHAR(40) NOT NULL,
    city VARCHAR(60) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    region VARCHAR(20) NOT NULL,
    CONSTRAINT uq_dim_location UNIQUE (country, state, city, postal_code)
);

-- Cria a dimensão ship_mode
DROP TABLE IF EXISTS dw.dim_ship_mode CASCADE;
CREATE TABLE dw.dim_ship_mode (
    ship_mode_sk SERIAL PRIMARY KEY,
    ship_mode VARCHAR(20) NOT NULL UNIQUE
);

-- Cria a fato sales
DROP TABLE IF EXISTS dw.fact_sales CASCADE;
CREATE TABLE dw.fact_sales (
	sale_sk SERIAL PRIMARY KEY,
	row_nk INTEGER NOT NULL UNIQUE,
	order_nk VARCHAR(20) NOT NULL,
	order_date_sk INTEGER NOT NULL REFERENCES dw.dim_date(date_sk),
	ship_date_sk INTEGER NOT NULL REFERENCES dw.dim_date(date_sk),
	customer_sk INTEGER NOT NULL REFERENCES dw.dim_customer(customer_sk),
	product_sk INTEGER NOT NULL REFERENCES dw.dim_product(product_sk),
	location_sk INTEGER NOT NULL REFERENCES dw.dim_location(location_sk),
	ship_mode_sk INTEGER NOT NULL REFERENCES dw.dim_ship_mode(ship_mode_sk),
	sales NUMERIC(12,2) NOT NULL,
	ship_days INTEGER NOT NULL
);

-- Cria um índice para cada chave estrangeira da fato
CREATE INDEX ix_fs_order_date ON dw.fact_sales (order_date_sk);
CREATE INDEX ix_fs_ship_date ON dw.fact_sales (ship_date_sk);
CREATE INDEX ix_fs_customer ON dw.fact_sales (customer_sk);
CREATE INDEX ix_fs_product ON dw.fact_sales (product_sk);
CREATE INDEX ix_fs_location ON dw.fact_sales (location_sk);
CREATE INDEX ix_fs_ship_mode ON dw.fact_sales (ship_mode_sk);