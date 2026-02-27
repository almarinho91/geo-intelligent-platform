SELECT
    speed_category,
    COUNT(*) AS total_points
FROM curated_ais
GROUP BY speed_category
ORDER BY total_points DESC;