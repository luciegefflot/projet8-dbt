-- ==============================================================================
-- Modèle : mart_students_enriched.sql
-- Couche : Marts
-- Description : Table finale consolidée au niveau de l'étudiant.
--               Combine les profils individuels nettoyés et les indicateurs 
--               régionaux INSEE (taux de pénétration pour 100 000 habitants).
-- ==============================================================================

WITH students AS (
    -- 1. Importation des 4 010 étudiants uniques depuis la couche Intermediate
    SELECT * FROM {{ ref('int_students') }}
),

insee AS (
    -- 2. Importation du référentiel INSEE nettoyé (régions et populations)
    SELECT * FROM {{ ref('stg_insee_regions') }}
),

stats_par_region AS (
    -- 3. Calcul préalable du nombre total d'étudiants pour chaque région
    SELECT
        region,
        COUNT(user_id) AS nb_etudiants
    FROM students
    GROUP BY region
)

-- 4. Assemblage final : conservation du détail étudiant + ajout des métriques INSEE
SELECT
    -- Informations sociodémographiques individuelles de l'apprenant
    s.user_id,
    s.filiere,
    s.tranche_age,
    s.genre,
    s.annee_inscription,
    s.region,

    -- Indicateurs régionaux rattachés à l'étudiant
    reg.nb_etudiants AS nb_etudiants_region,
    i.population_totale AS population_region,

    -- Calcul de l'indicateur phare : taux de pénétration pour 100 000 habitants
    ROUND((reg.nb_etudiants / i.population_totale) * 100000, 2) AS taux_penetration_pour_100k_hab

FROM students s

-- Première jointure : Récupération du volume total d'étudiants de la région
LEFT JOIN stats_par_region reg 
    ON s.region = reg.region

-- Seconde jointure : Rapprochement avec la table INSEE
-- (Nettoyage des minuscules/majuscules, espaces et tirets pour garantir 100% d'appariement)
LEFT JOIN insee i 
    ON LOWER(REPLACE(TRIM(s.region), '-', ' ')) = LOWER(REPLACE(TRIM(i.region), '-', ' '))