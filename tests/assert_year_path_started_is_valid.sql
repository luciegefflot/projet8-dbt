-- Le test renvoie les lignes invalides (dbt attend 0 ligne pour valider le test)
SELECT *
FROM {{ ref('stg_students') }}
WHERE annee_premiere_inscription IS NULL
   OR annee_premiere_inscription < 2000
   OR annee_premiere_inscription > EXTRACT(YEAR FROM CURRENT_DATE())