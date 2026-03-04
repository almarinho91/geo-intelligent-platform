-- Athena external table over Glue/Spark partitioned Parquet output

CREATE EXTERNAL TABLE IF NOT EXISTS glue_ais_partitioned (
  mmsi BIGINT,
  timestamp STRING,
  lat DOUBLE,
  lon DOUBLE,
  sog DOUBLE,
  speed_category STRING
)
PARTITIONED BY (dt STRING)
STORED AS PARQUET
LOCATION 's3://andre-geo-platform-dev/glue_output_partitioned/';