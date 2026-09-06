-- ==============================================================================
-- Modèle : int_students.sql
-- Couche : Intermediate
-- Description : Agrégation au niveau étudiant unique (1 ligne par user_id)
--               en conservant son inscription la plus récente.
-- ==============================================================================

WITH staging AS (
    -- Lecture de la vue nettoyée stg_students
    SELECT * FROM {{ ref('stg_students') }}
),

deduplicated AS (
    SELECT
        user_id,
        filiere,
        tranche_age,
        genre,
        region,
        annee_premiere_inscription,
        annee_derniere_inscription,
        annee_inscription
    FROM staging
    -- Application de la règle métier : 1 seul profil par étudiant (le plus récent)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_id 
        ORDER BY annee_inscription DESC
    ) = 1
)

SELECT * FROM deduplicated