import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue import DynamicFrame

def sparkSqlQuery(glueContext, query, mapping, transformation_ctx) -> DynamicFrame:
    for alias, frame in mapping.items():
        frame.toDF().createOrReplaceTempView(alias)
    result = spark.sql(query)
    return DynamicFrame.fromDF(result, glueContext, transformation_ctx)
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Script generated for node AWS Glue Data Catalog
AWSGlueDataCatalog_node1795393074071 = glueContext.create_dynamic_frame.from_catalog(database="superstore_catalog", table_name="bruto", transformation_ctx="AWSGlueDataCatalog_node1795393074071")

# Script generated for node Change Schema
ChangeSchema_node1795393180151 = ApplyMapping.apply(frame=AWSGlueDataCatalog_node1795393074071, mappings=[("row id", "long", "row_id", "string"), ("order id", "string", "order_id", "string"), ("order date", "string", "order_date", "string"), ("ship date", "string", "ship_date", "string"), ("ship mode", "string", "ship_mode", "string"), ("customer id", "string", "customer_id", "string"), ("customer name", "string", "customer_name", "string"), ("segment", "string", "segment", "string"), ("country", "string", "country", "string"), ("city", "string", "city", "string"), ("state", "string", "state", "string"), ("postal code", "long", "postal_code", "string"), ("region", "string", "region", "string"), ("product id", "string", "product_id", "string"), ("category", "string", "category", "string"), ("sub-category", "string", "sub_category", "string"), ("product name", "string", "product_name", "string"), ("sales", "double", "sales", "string")], transformation_ctx="ChangeSchema_node1795393180151")

# Script generated for node SQL Query
SqlQuery470 = '''
SELECT 
	CAST(TRIM(row_id) AS INT) AS row_id,
	TRIM(order_id) AS order_id,
    TO_DATE(TRIM(order_date), 'dd/MM/yyyy') AS order_date,
	TO_DATE(TRIM(ship_date), 'dd/MM/yyyy') AS ship_date,
	TRIM(ship_mode) AS ship_mode,
	TRIM(customer_id) AS customer_id,
	TRIM(customer_name) AS customer_name,
	TRIM(segment) AS segment,	
	TRIM(country) AS country,
	TRIM(city) AS city,
    TRIM(state) AS state,
	COALESCE(NULLIF(TRIM(postal_code), ''), 'N/D') AS postal_code,
	TRIM(region) AS region,
	TRIM(product_id) AS product_id,
	TRIM(category) AS category,
	TRIM(sub_category) AS sub_category,
	TRIM(product_name) AS product_name,
    CAST(TRIM(sales) AS decimal(12,2)) AS sales
FROM myDataSource
'''
SQLQuery_node1795393644507 = sparkSqlQuery(glueContext, query = SqlQuery470, mapping = {"myDataSource":ChangeSchema_node1795393180151}, transformation_ctx = "SQLQuery_node1795393644507")

# Script generated for node PostgreSQL
PostgreSQL_node1795401862590 = glueContext.write_dynamic_frame.from_catalog(frame=SQLQuery_node1795393644507, database="superstore_catalog", table_name="superstore_dw_staging_sales", transformation_ctx="PostgreSQL_node1795401862590")

job.commit()