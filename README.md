# Prova - Data Warehouse na Nuvem com AWS

## Integrantes
- Arthur Carvalho Araujo - RA 2041382521031
- Gabriela Edmundo de Araújo - RA 2041382521025

## Ambiente AWS
- Integrante dona da conta: Gabriela Edmundo de Araújo
- RA usado nos nomes dos recursos: 2041382521025
- ID da conta AWS: 296444421404
- Região: us-east-1

## Dataset
### Enunciado 2
**a)** A base de dados possui 9800 linhas sem contar o cabeçalho.

**b)** A coluna 'Order Date' utiliza o formato DD/MM/AAAA, como comprova o valor `22/11/2016`, uma vez que não há mês 22, logo 22 se refere ao dia e 11 ao mês. A coluna 'Ship Date' também utiliza o formato DD/MM/AAAA, como comprova o valor `26/11/2016`.

**c)** Não há valores na coluna 'Postal Code' em 11 linhas da base de dados.

**d)** A base possui valores na coluna 'Product Name' que possuem vírgula como em `"Stur-D-Stor Shelving, Vertical 5-Shelf: 72""H x 36""W x 18 1/2""D"`. Como o valor está entre aspas duplas, a vírgula presente no nome do produto não é entendida como um caractere separador de colunas da extensão de arquivo CSV.

## Respostas
### Enunciado 4
A **regra 1** permite o acesso ao PostgreSQL usando psql no terminal CloudShell, pela porta TCP 5432. Sem essa regra, a tentativa de conexão pode falhar alegando tempo esgotado (Connection timed out).

A **regra 2** é autorreferenciada e permite a comunicação entre os recursos do mesmo security group, incluindo os componentes do Glue e o banco. Sem essa regra, o teste de conexão ou a execução do job pode falhar por tempo esgotado.


(Enunciados 6 e 7)