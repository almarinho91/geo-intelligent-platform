-- Demonstrate partition pruning

SELECT *
FROM curated_ais_partitioned_v2
WHERE dt = '2024-01-01';