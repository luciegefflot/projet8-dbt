-- ==============================================================================
-- Modèle : int_students.sql
-- Couche : Intermediate
-- Description : Agrégation au niveau étudiant unique (1 ligne par user_id)
-- ==============================================================================

WITH staging AS (
    SELECT * FROM {{ ref('stg_students') }}
),

deduplicated AS (
    SELECT
        user_id,
        filiere,
        tranche_age,
        genre,
        region,
        annee_inscription
    FROM staging
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_id 
        ORDER BY annee_inscription DESC
    ) = 1
)

SELECT * FROM deduplicated