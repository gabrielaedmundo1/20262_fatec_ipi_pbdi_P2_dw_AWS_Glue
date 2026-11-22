-- Enunciado 5
/* Conectado ao banco pelo psql do CloudShell, crie os schemas staging e dw e a tabela
staging.sales, com as colunas e os tipos da Tabela 2, NOT NULL em todas elas e row_id
como chave primária. Registre todo o SQL no script.sql. */

-- Verifica a versão do PSQL
psql --version

-- Realiza a conexão com o banco de dados
psql -h dw-superstore-2041382521025.cvqogdb2b1ys.us-east-1.rds.amazonaws.com -p 5432 -U postgres -d superstore_dw

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