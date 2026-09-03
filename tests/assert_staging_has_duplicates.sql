-- tests/assert_staging_has_duplicates.sql
-- Valide que la table Staging conserve bien tout l'historique brut (4 647 lignes vs 4 010 user_id)
WITH metrics AS (
    SELECT 
        COUNT(*) AS total_rows,
        COUNT(DISTINCT user_id) AS unique_users
    FROM {{ ref('stg_students') }}
)

SELECT *
FROM metrics
WHERE total_rows <= unique_users -- Anomalie si pas de doublons conservés