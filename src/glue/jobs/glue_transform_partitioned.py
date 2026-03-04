from pyspark.sql import SparkSession
from pyspark.sql.functions import substring

spark = SparkSession.builder.getOrCreate()

# Read Parquet from your data lake
df = spark.read.parquet("s3://andre-geo-platform-dev/curated_parquet/")

# Create dt partition column from ISO timestamp: YYYY-MM-DD
df = df.withColumn("dt", substring("timestamp", 1, 10))

# Write partitioned Parquet to S3
(df.write
   .mode("overwrite")
   .partitionBy("dt")
   .parquet("s3://andre-geo-platform-dev/glue_output_partitioned/"))

print("Partitioned Glue job finished")