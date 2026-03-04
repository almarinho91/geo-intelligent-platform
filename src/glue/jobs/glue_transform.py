from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()

# Read parquet created previously
df = spark.read.parquet(
    "s3://andre-geo-platform-dev/curated_parquet/"
)

df.printSchema()

# simple transformation
df_filtered = df.select("mmsi","speed_category","sog")

# write result
df_filtered.write.mode("overwrite").parquet(
    "s3://andre-geo-platform-dev/glue_output/"
)

print("Job finished")