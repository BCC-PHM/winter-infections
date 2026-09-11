/*
Extracting weekly hospital admissions over the winter of 23/24 for:
	- Influenza (J9-J11)
	- Covid (U07.1)
	- RSV (B97.4)

Each patient is only counted once per day for each infection.
*/

WITH 

-- Get table with local authorities for each patient number
BSolStatuses AS (
	SELECT DISTINCT
		Pseudo_NHS_Number,
		LAD_2022_Desc AS LocalAuthority
	FROM [EAT_Reporting_BSOL].[Demographic].BSOL_Resident_Population
), 

influenza_admissions AS (
	SELECT
		B.NHSNumber,
		CAST(B.AdmissionDate AS DATE) AS admission_date
	FROM 
		[EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodesDiagnosisRelational] AS A
	INNER JOIN 
		[EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodes] AS B
		ON A.EpisodeId = B.EpisodeId
	INNER JOIN 
		BSolStatuses AS C
		ON B.NHSNumber = C.Pseudo_NHS_Number
	WHERE 
		(
			A.DiagnosisCode LIKE 'J9%'
			OR A.DiagnosisCode LIKE 'J10%'
			OR A.DiagnosisCode LIKE 'J11%'
		)
		AND C.LocalAuthority = 'Birmingham'
		--AND A.DiagnosisOrder = 1
		AND B.AdmissionDate >= '2025-04-01'
		AND B.AdmissionDate < '2026-04-01'
	GROUP BY
		B.NHSNumber,
		CAST(B.AdmissionDate AS DATE)
),

influenza_counts AS (
	SELECT
		DATEDIFF(DAY, '2025-04-01', admission_date) / 7 AS week_number,
		'Influenza' AS infection,
		COUNT(*) AS influenza_count
	FROM influenza_admissions
	GROUP BY
		DATEDIFF(DAY, '2025-04-01', admission_date) / 7
),

covid_admissions AS (
	SELECT
		B.NHSNumber,
		CAST(B.AdmissionDate AS DATE) AS admission_date
	FROM 
		[EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodesDiagnosisRelational] AS A
	INNER JOIN 
		[EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodes] AS B
		ON A.EpisodeId = B.EpisodeId
	INNER JOIN 
		BSolStatuses AS C
		ON B.NHSNumber = C.Pseudo_NHS_Number
	WHERE 
		(
			A.DiagnosisCode = 'U071' 
			OR A.DiagnosisCode = 'U07.2'
		)
		AND C.LocalAuthority = 'Birmingham'
		--AND A.DiagnosisOrder = 1
		AND B.AdmissionDate >= '2025-04-01'
		AND B.AdmissionDate < '2026-04-01'
	GROUP BY
		B.NHSNumber,
		CAST(B.AdmissionDate AS DATE)
),

covid_counts AS (
	SELECT
		DATEDIFF(DAY, '2025-04-01', admission_date) / 7 AS week_number,
		'COVID-19' AS infection,
		COUNT(*) AS covid_count
	FROM covid_admissions
	GROUP BY
		DATEDIFF(DAY, '2025-04-01', admission_date) / 7
),

rsv_admissions AS (
	SELECT
		B.NHSNumber,
		CAST(B.AdmissionDate AS DATE) AS admission_date
	FROM 
		[EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodesDiagnosisRelational] AS A
	INNER JOIN 
		[EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodes] AS B
		ON A.EpisodeId = B.EpisodeId
	INNER JOIN 
		BSolStatuses AS C
		ON B.NHSNumber = C.Pseudo_NHS_Number
	WHERE 
		(
			A.DiagnosisCode = 'B974' 
			--OR A.DiagnosisCode = 'J210'
		)
		AND C.LocalAuthority = 'Birmingham'
		--AND A.DiagnosisOrder = 1
		AND B.AdmissionDate >= '2025-04-01'
		AND B.AdmissionDate < '2026-04-01'
	GROUP BY
		B.NHSNumber,
		CAST(B.AdmissionDate AS DATE)
),

rsv_counts AS (
	SELECT
		DATEDIFF(DAY, '2025-04-01', admission_date) / 7 AS week_number,
		'RSV' AS infection,
		COUNT(*) AS covid_count
	FROM rsv_admissions
	GROUP BY
		DATEDIFF(DAY, '2025-04-01', admission_date) / 7
)

-- combine everything

SELECT *
FROM influenza_counts

UNION ALL

SELECT *
FROM covid_counts

UNION ALL

SELECT *
FROM rsv_counts
ORDER BY infection, week_number;