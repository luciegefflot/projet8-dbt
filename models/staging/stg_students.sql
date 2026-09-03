-- ==============================================================================
-- Modèle : stg_students.sql
-- Couche : Staging
-- Description : Lecture et préparation de la source de données brute étudiants, nettoyage du genre/région et calcul du parcours
--               d'inscription (première et dernière année) par étudiant.
-- ==============================================================================

WITH source AS (
    -- Importation des données brutes depuis la table Snowflake raw_students
    SELECT * FROM {{ source('raw', 'raw_students') }}
),

renamed_and_calculated AS (
    SELECT
        user_id AS user_id,
        path_category_name AS filiere,
        age_group AS tranche_age,
        
        -- Nettoyage et standardisation des valeurs du genre
        CASE 
            WHEN LOWER(TRIM(gender)) IN ('m', 'male', 'homme') THEN 'Homme'
            WHEN LOWER(TRIM(gender)) IN ('f', 'female', 'femme') THEN 'Femme'
            WHEN LOWER(TRIM(gender)) IN ('autre', 'other') THEN 'Autre'
            WHEN gender IS NULL OR TRIM(gender) = '' THEN 'Non précisé'
            ELSE 'Non précisé'
        END AS genre,

        -- Nettoyage des espaces et remplacement des régions manquantes par "Inconnu"
        COALESCE(TRIM(region), 'Inconnu') AS region,
        
        year_path_started AS annee_inscription,

        -- Calcul de la première et dernière année d'inscription sans perdre l'historique
        MIN(year_path_started) OVER (PARTITION BY user_id) AS annee_premiere_inscription,
        MAX(year_path_started) OVER (PARTITION BY user_id) AS annee_derniere_inscription
    FROM source
),

deduplicated AS (
    -- Suppression des doublons exacts (étudiant, filière et année)
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, filiere, annee_inscription 
            ORDER BY annee_inscription DESC
        ) AS rn
    FROM renamed_and_calculated
)

-- Sélection finale des lignes uniques
SELECT
    user_id,
    filiere,
    tranche_age,
    genre,
    region,
    annee_inscription,
    annee_premiere_inscription,
    annee_derniere_inscription
FROM deduplicated
WHERE rn = 1