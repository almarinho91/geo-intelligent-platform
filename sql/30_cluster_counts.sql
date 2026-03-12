SELECT
  vessel_behavior_cluster,
  COUNT(*) AS vessel_count
FROM (
  SELECT
    CASE
      WHEN stopped_ratio > 0.9 THEN 'anchored_vessels'
      WHEN avg_sog < 2 THEN 'slow_movers'
      WHEN avg_sog BETWEEN 2 AND 12 THEN 'normal_traffic'
      WHEN speed_anomaly_points > 0 THEN 'anomalous_vessels'
      ELSE 'other'
    END AS vessel_behavior_cluster
  FROM vessel_behavior_features
)
GROUP BY vessel_behavior_cluster
ORDER BY vessel_count DESC;