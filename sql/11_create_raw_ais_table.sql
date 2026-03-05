CREATE EXTERNAL TABLE raw_ais (
  mmsi BIGINT,
  base_date_time STRING,
  longitude DOUBLE,
  latitude DOUBLE,
  sog DOUBLE,
  cog DOUBLE,
  heading DOUBLE,
  vessel_name STRING,
  imo STRING,
  call_sign STRING,
  vessel_type INT,
  status DOUBLE,
  length DOUBLE,
  width DOUBLE,
  draft DOUBLE,
  cargo DOUBLE,
  transceiver STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"'
)
LOCATION 's3://andre-geo-platform-dev/raw_ais/'
TBLPROPERTIES (
  "skip.header.line.count"="1",
  "use.null.for.invalid.data"="true"
);