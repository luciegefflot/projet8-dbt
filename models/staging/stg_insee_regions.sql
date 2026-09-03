-- ==============================================================================
-- Modèle : stg_insee_regions.sql
-- Couche : Staging
-- Description : Préparation, correction d'encodage et agrégation des données 
--               démographiques INSEE par région.
-- ==============================================================================

WITH source AS (
    -- Lecture de la table brute des régions INSEE depuis Snowflake
    SELECT * FROM {{ source('raw', 'raw_insee_regions') }}
),

cleaned AS (
    SELECT
        CAST(code_region AS STRING) AS code_region,
        
        -- Correction des caractères corrompus (UTF-8) et harmonisation des DROM
        CASE 
            WHEN nom_region LIKE '%le-de-France%' THEN 'Île-de-France'
            WHEN nom_region LIKE '%Rh%ne-Alpes%' THEN 'Auvergne-Rhône-Alpes'
            WHEN nom_region LIKE '%Franche-Comt%' THEN 'Bourgogne-Franche-Comté'
            WHEN nom_region LIKE '%C%te d%Azur%' THEN 'Provence-Alpes-Côte d''Azur'
            WHEN nom_region LIKE '%union%' THEN 'La Réunion'
            WHEN TRIM(nom_region) IN ('Guadeloupe', 'Martinique', 'Guyane', 'La Réunion', 'Mayotte', 'DROM') THEN 'DROM'
            ELSE TRIM(nom_region)
        END AS region,
        
        CAST(population_totale AS INT) AS population_totale
    FROM source
),

aggregated AS (
    -- Groupement par région pour sommer la population des DROM regroupés
    SELECT
        region,
        SUM(population_totale) AS population_totale
    FROM cleaned
    GROUP BY region
)

SELECT
    region,
    population_totale
FROM aggregated