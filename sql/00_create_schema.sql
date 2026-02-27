-- Create database
CREATE DATABASE IF NOT EXISTS geo_platform;

-- Use database (manual selection in Athena UI)
-- CREATE TABLE for curated AIS CSV data

CREATE EXTERNAL TABLE IF NOT EXISTS curated_ais (
  mmsi BIGINT,
  timestamp STRING,
  lat DOUBLE,
  lon DOUBLE,
  sog DOUBLE,
  speed_category STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ','
)
LOCATION 's3://andre-geo-platform-dev/curated/'
TBLPROPERTIES (
  'skip.header.line.count'='1'
);