from pyspark.sql import SparkSession
from pyspark.sql.functions import substring

spark = SparkSession.builder.getOrCreate()

# Read curated parquet (source)
df = spark.read.parquet("s3://andre-geo-platform-dev/curated_parquet/")

# Derive partition column
df = df.withColumn("dt", substring("timestamp", 1, 10))

# Incremental write: append new partitions
(df.write
   .mode("append")
   .partitionBy("dt")
   .parquet("s3://andre-geo-platform-dev/glue_output_partitioned/"))

print("Incremental partitioned write completed")