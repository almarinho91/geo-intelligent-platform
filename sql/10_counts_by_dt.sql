-- Validate that partitions are visible
SELECT dt, COUNT(*) AS n_rows
FROM glue_ais_partitioned
GROUP BY dt
ORDER BY dt;