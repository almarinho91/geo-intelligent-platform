-- Load partitions from S3 folder structure (dt=YYYY-MM-DD/)
MSCK REPAIR TABLE glue_ais_partitioned;