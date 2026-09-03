-- ==============================================================================
-- Modèle : stg_insee_regions.sql
-- Couche : Staging
-- Description : Préparation et conversion des données démographiques INSEE par région.
-- ==============================================================================

WITH source AS (
    -- Lecture de la table brute des régions INSEE depuis Snowflake
    SELECT * FROM {{ source('raw', 'raw_insee_regions') }}
),

renamed AS (
    SELECT
        -- Conversion du code région en texte pour préserver les formats (ex. 01 à 09)
        CAST(code_region AS STRING) AS code_region,
        
        -- Nettoyage des espaces superflus autour du nom de la région
        TRIM(nom_region) AS region,
        
        -- Conversion de la population totale en nombre entier
        CAST(population_totale AS INT) AS population_totale
    FROM source
)

SELECT * FROM renamed