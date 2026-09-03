-- ==============================================================================
-- Modèle : int_students.sql
-- Couche : Intermediate
-- Description : Agrégation au niveau étudiant unique (1 ligne par user_id)
--               en conservant son statut le plus récent.
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
        annee_derniere_inscription
    FROM staging
    -- Application de la règle métier : conserver un seul profil par étudiant
    -- Sélection de l'inscription la plus récente (et arbitrage par tranche d'âge si égalité)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_id 
        ORDER BY annee_derniere_inscription DESC, tranche_age DESC
    ) = 1
)

SELECT * FROM deduplicated