-- Query demonstrating partition pruning

SELECT *
FROM curated_ais_partitioned
WHERE dt = '2024-01-01';