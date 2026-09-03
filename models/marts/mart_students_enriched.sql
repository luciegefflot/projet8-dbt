-- ==============================================================================
-- Modèle : mart_students_enriched.sql
-- Couche : Marts
-- Description : Analyse régionale croisant le nombre d'étudiants uniques
--               avec la population INSEE pour calculer le taux de pénétration.
-- ==============================================================================

WITH students AS (
    -- Importation des étudiants uniques depuis la couche Intermediate
    SELECT * FROM {{ ref('int_students') }}
),

insee AS (
    -- Importation des données de population par région
    SELECT * FROM {{ ref('stg_insee_regions') }}
),

stats_par_region AS (
    -- Calcul du nombre total d'étudiants par région
    SELECT
        region,
        COUNT(user_id) AS nb_etudiants
    FROM students
    GROUP BY region
)

SELECT
    s.region,
    s.nb_etudiants,
    i.population_totale,
    
    -- Calcul du nombre d'étudiants pour 100 000 habitants (arrondi à 2 décimales)
    ROUND((s.nb_etudiants / i.population_totale) * 100000, 2) AS taux_penetration_pour_100k_hab

FROM stats_par_region s
-- Jointure entre les régions (en ignorant les majuscules, espaces et tirets)
LEFT JOIN insee i 
    ON LOWER(REPLACE(TRIM(s.region), '-', ' ')) = LOWER(REPLACE(TRIM(i.region), '-', ' '))