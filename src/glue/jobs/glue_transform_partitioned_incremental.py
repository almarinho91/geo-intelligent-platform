from pyspark.sql import SparkSession
from pyspark.sql.functions import substring

spark = SparkSession.builder.getOrCreate()

df = spark.read.parquet("s3://andre-geo-platform-dev/curated_parquet/")

df = df.withColumn("dt", substring("timestamp", 1, 10))

# ✅ Deduplicate to reduce duplicate writes on re-runs (simple idempotency)
df = df.dropDuplicates(["mmsi", "timestamp", "lat", "lon"])

(df.write
   .mode("append")
   .partitionBy("dt")
   .parquet("s3://andre-geo-platform-dev/glue_output_partitioned/"))

print("Incremental partitioned write completed (deduplicated)")