CREATE TABLE road_accidents (
    accident_index VARCHAR(50) PRIMARY KEY,
    accident_date DATE,
    day_of_week VARCHAR(20),
    junction_control VARCHAR(50),
    junction_detail VARCHAR(50),
    accident_severity VARCHAR(20),
    light_conditions VARCHAR(50),
    local_authority VARCHAR(100),
    carriageway_hazards VARCHAR(100),
    number_of_casualties SMALLINT,
    number_of_vehicles SMALLINT,
    police_force VARCHAR(50),
    road_surface_conditions VARCHAR(50),
    road_type VARCHAR(50),
    speed_limit SMALLINT,
    time TIME,
    urban_or_rural_area VARCHAR(20),
    weather_conditions VARCHAR(50),
    vehicle_type VARCHAR(50)
);

SELECT * FROM road_accidents;

--CY Casualties --
SELECT SUM(number_of_casualties) AS CY_casualties
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022;

--CY Accidents--
SELECT COUNT (DISTINCT accident_index) AS CY_Accidents
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022;

--CY Fatal Casualties--
SELECT SUM(number_of_casualties) AS CY_Fatal_Casualties
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022 AND accident_severity = 'Fatal';

--CY Serious Casualties--
SELECT SUM(number_of_casualties) AS CY_Serious_Casualties
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022 AND accident_severity = 'Serious';

--CY Slight Casualties--
SELECT SUM(number_of_casualties) AS CY_Slight_Casualties
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022 AND accident_severity = 'Slight';

--Casualties by Vehicle type--
SELECT 
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
		WHEN vehicle_type IN ('Car','Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle 125cc and under','Motorcycle 50cc and under','Motorcycle over 125cc and up to 500cc','Motorcycle over 500cc','Pedal cycle') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)','Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over','Goods over 3.5t. and under 7.5t','Van / Goods 3.5 tonnes mgw or under') THEN 'Van'
		ELSE 'Other'
	END As vehicle_group,
	SUM(number_of_Casualties) AS CY_Casualties
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022
GROUP BY 
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
		WHEN vehicle_type IN ('Car','Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle 125cc and under','Motorcycle 50cc and under','Motorcycle over 125cc and up to 500cc','Motorcycle over 500cc','Pedal cycle') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)','Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over','Goods over 3.5t. and under 7.5t','Van / Goods 3.5 tonnes mgw or under') THEN 'Van'
		ELSE 'Other'
	END


-- CY Casualties VS PY Casualties Monthly Trend --
SELECT 
    TO_CHAR(accident_date, 'Mon') AS month_name,
    SUM(number_of_casualties) AS CY_casualties
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022
GROUP BY TO_CHAR(accident_date, 'Mon'),
         EXTRACT(MONTH FROM accident_date)
ORDER BY EXTRACT(MONTH FROM accident_date);


SELECT 
    TO_CHAR(accident_date, 'Mon') AS month_name,
    SUM(number_of_casualties) AS PY_casualties
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2021
GROUP BY TO_CHAR(accident_date, 'Mon'),
         EXTRACT(MONTH FROM accident_date)
ORDER BY EXTRACT(MONTH FROM accident_date);

-- Casualties by Road Type --
SELECT road_type, SUM(number_of_casualties) AS CY_Casualties
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022
GROUP BY road_type

--CY Casualties by Urban/Rural Area--
SELECT urban_or_rural_area, SUM(number_of_Casualties)* 100 /
(SELECT SUM(number_of_Casualties) FROM road_accidents WHERE EXTRACT(YEAR FROM accident_date) = 2022) As percentage
FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022
GROUP BY urban_or_rural_area

-- Casualties by Light Condition--
SELECT
    CASE
        WHEN light_conditions IN ('Daylight') THEN 'Day'
        WHEN light_conditions IN (
            'Darkness - lighting unknown',
            'Darkness - lights lit',
            'Darkness - lights unlit',
            'Darkness - no lighting'
        ) THEN 'Night'
    END AS light_condition,

    ROUND(
        (SUM(number_of_casualties) * 100.0) /
        (
            SELECT SUM(number_of_casualties)
            FROM road_accidents
            WHERE EXTRACT(YEAR FROM accident_date) = 2022
        ),
        2
    ) AS cy_casualties_pct

FROM road_accidents
WHERE EXTRACT(YEAR FROM accident_date) = 2022

GROUP BY
    CASE
        WHEN light_conditions IN ('Daylight') THEN 'Day'
        WHEN light_conditions IN (
            'Darkness - lighting unknown',
            'Darkness - lights lit',
            'Darkness - lights unlit',
            'Darkness - no lighting'
        ) THEN 'Night'
    END;


-- Top 10 Location by No of Casualties--
SELECT local_authority, SUM(number_of_Casualties) AS Total_Casualties
FROM road_accidents
GROUP BY local_authority
ORDER BY Total_Casualties DESC
LIMIT 10;