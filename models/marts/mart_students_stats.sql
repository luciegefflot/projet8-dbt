-- ==============================================================================
-- Modèle : mart_students_stats.sql
-- Couche : Marts
-- Description : Analyse agrégée des étudiants par région, filière, tranche d'âge
--               et genre, avec calcul de la durée moyenne de leur parcours.
-- ==============================================================================

WITH deduplicated_students AS (
    -- Récupération des étudiants uniques depuis la couche Intermediate
    SELECT * FROM {{ ref('int_students') }}
)

SELECT
    region,
    filiere,
    tranche_age,
    genre,
    
    -- Nombre total d'étudiants par groupe
    COUNT(user_id) AS nombre_etudiants,
    
    -- Calcul de la durée moyenne du parcours en années (écart entre dernière et première inscription)
    ROUND(AVG(annee_derniere_inscription - annee_premiere_inscription), 2) AS duree_moyenne_parcours_ans

FROM deduplicated_students
GROUP BY 
    region,
    filiere,
    tranche_age,
    genre