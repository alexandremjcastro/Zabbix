-- Databricks notebook source
-- MAGIC %md #Reading from BRONZE, TRAINING/AGG Data and saving on SILVER

-- COMMAND ----------

-- MAGIC %python
-- MAGIC 
-- MAGIC import pyspark.sql.functions as f 
-- MAGIC 
-- MAGIC df = spark.table('bronze.snowflake_analytics_portalvendas_tb_bif_ordem_venda')
-- MAGIC df.write.format('delta').mode('overwrite').saveAsTable('silver.example_delta_silver_pyspark')
-- MAGIC df.createOrReplaceTempView('orders_table')

-- COMMAND ----------

-- MAGIC %sql
-- MAGIC 
-- MAGIC create or replace table silver.example_delta_silver_sql
-- MAGIC using delta
-- MAGIC as
-- MAGIC select 
-- MAGIC   year(dt_digitacao_ordem_venda) as `year`,
-- MAGIC   sum(vl_total_item_desconto) as vl_total_item_desconto
-- MAGIC from orders_table
-- MAGIC group by `year`