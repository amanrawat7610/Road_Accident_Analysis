-- 1. Database select karein
USE road_accident;

-- 3. Aapke bataye gaye schema ke hisaab se table create karein
CREATE TABLE road_table (
    accident_index VARCHAR(50),
    accident_date TEXT,                -- Date ko TEXT rakha hai taaki import fail na ho
    day_of_week VARCHAR(50),
    junction_control VARCHAR(50),
    junction_detail VARCHAR(50),
    accident_severity VARCHAR(50),
    light_conditions VARCHAR(50),
    local_authority VARCHAR(50),
    carriageway_hazards VARCHAR(50),
    number_of_casualties TINYINT,      
    number_of_vehicles TINYINT,        
    police_force VARCHAR(50),
    road_surface_conditions VARCHAR(50),
    road_type VARCHAR(50),
    speed_limit TINYINT,               -- Schema ke mutabik TINYINT
    time TEXT,                         -- Time ko TEXT rakha hai safety ke liye
    urban_or_rural_area VARCHAR(50),
    weather_conditions VARCHAR(50),
    vehicle_type VARCHAR(50)
);


-- 1. Database select 
USE road_accident;

-- 2. CSV file se data load karne ki query
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/road_accident.csv' 
INTO TABLE road_table 
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

SET SQL_SAFE_UPDATES = 0;
UPDATE road_table 
SET accident_date = STR_TO_DATE(accident_date, '%d-%m-%Y');
ALTER TABLE road_table 
MODIFY COLUMN accident_date DATE;

-- 3. Verify karein ki data aaya ya nahi
SET SQL_SAFE_UPDATES = 1;
SELECT COUNT(*) AS Total_Rows FROM road_table;
SELECT * FROM road_table;
SELECT SUM(number_of_casualties) AS CY_casualties
FROM road_table
WHERE  YEAR(accident_date) ='2022';

 -- CY_ CASUALTIES
SELECT COUNT(DISTINCT accident_index) AS CY_ACCIDENT
FROM road_table
WHERE  YEAR(accident_date) ='2022';

-- SUM OF FATAL CASUALTIES
SELECT SUM(number_of_casualties) AS CY_Fatal_Casualties
FROM road_table
WHERE  accident_severity='Fatal';

-- SUM OF Serious CASUALTIES
SELECT SUM(number_of_casualties) AS CY_Serious_Casualties
FROM road_table
WHERE  year(accident_date)='2022' AND accident_severity='serious';

-- SUM OF slight CASUALTIES
SELECT SUM(number_of_casualties) AS CY_slight_Casualties
FROM road_table
WHERE  year(accident_date)='2022' AND accident_severity='slight';
SELECT * FROM road_table;


-- 4 -- CASUALTIES BY BUS,CAR,BIKE,AGRICULTRAL,VAN

SELECT
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
        WHEN vehicle_type IN ('Car','Taxi/Private hire car') THEN 'Cars'
        WHEN vehicle_type IN ('Motorcycle 125cc and under','Motorcycle 50cc and under','Motorcycle over 125cc and up to 500cc','
        Motorcycle over 500cc','Pedal cycle') THEN 'Bike'
        WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)','Minibus(8-16 passenger seats)') THEN 'Bus'
        WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over','Goods over 3.5t. and under 7.5t','Van/Goods 3.5 tonnes mgw or under') THEN 'Van'
        
        ELSE 'Other'
	END AS Vehicle_group,
	SUM(number_of_casualties)as CY_Casualties
FROM road_table
WHERE YEAR(accident_date)=2022
GROUP BY
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
        WHEN vehicle_type IN ('Car','Taxi/Private hire car') THEN 'Cars'
        WHEN vehicle_type IN ('Motorcycle 125cc and under','Motorcycle 50cc and under','Motorcycle over 125cc and up to 500cc','
        Motorcycle over 500cc','Pedal cycle') THEN 'Bike'
        WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)','Minibus(8-16 passenger seats)') THEN 'Bus'
        WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over','Goods over 3.5t. and under 7.5t','Van/Goods 3.5 tonnes mgw or under') THEN 'Van'
        ELSE 'Other'
		END;
        
        
-- 5 .CY CASUALTIES 

SELECT 
    MONTHNAME(accident_date) AS Month_Name,
    SUM(number_of_casualties) AS CY_Casualties
FROM road_table
WHERE YEAR(accident_date) = '2022'
GROUP BY Month_Name,
MONTH(accident_date)
ORDER BY MONTH(accident_date); 

-- 6 .PY CASUALTIES 

SELECT 
    MONTHNAME(accident_date) AS Month_Name,
    SUM(number_of_casualties) AS PY_Casualties
FROM road_table
WHERE YEAR(accident_date) = '2021'
GROUP BY Month_Name,
MONTH(accident_date)
ORDER BY MONTH(accident_date); 

-- 7-- CY CASUALTIES BY ROADTYPE
SELECT road_type,SUM(number_of_casualties) AS CY_CASUALTIES FROM road_table
WHERE YEAR(accident_date)='2022'
GROUP BY road_type;

-- 8-- PY CASUALTIES BY ROADTYPE
SELECT road_type,SUM(number_of_casualties) AS CY_CASUALTIES FROM road_table
WHERE YEAR(accident_date)='2021'
GROUP BY road_type;

-- 9. CY CASUALTIES BY URBEN AND RURAL AREAS.
SELECT urban_or_rural_area, CAST(SUM(number_of_casualties)AS DECIMAL(10,2))*100/ 
(SELECT CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) FROM road_table WHERE YEAR(accident_date)='2022') AS PCT FROM road_table
WHERE YEAR(accident_date)='2022'
GROUP BY urban_or_rural_area;

-- 10.PY CASUALTIES BY URBEN AND RURAL AREAS.
SELECT urban_or_rural_area, CAST(SUM(number_of_casualties)AS DECIMAL(10,2))*100/ 
(SELECT CAST(SUM(number_of_casualties) AS DECIMAL(10,2)) FROM road_table WHERE YEAR(accident_date)='2022') AS PCT FROM road_table
WHERE YEAR(accident_date)='2021'
GROUP BY urban_or_rural_area;
 
 
--  11.CY_NUMBER_OF_CASUALTIES BY LIGHT_CONDITIONS.
SELECT 
			CASE
					WHEN light_conditions IN ('Daylight') THEN 'DAY'
                    WHEN light_conditions IN ('Darkness - lighting unknown', 'Darkness - lights lit','Darkness - lights unlit', 'Darkness - no lighting')THEN 'Night'
			END AS Light_condition,
            CAST(CAST(SUM(number_of_casualties)AS DECIMAL(10,2)) * 100/
            (SELECT CAST(SUM(number_of_casualties)AS DECIMAL(10,2))FROM road_table WHERE YEAR(accident_date)='2022') AS DECIMAL(10,2)) AS CY_Casualties_PCT FROM road_table WHERE YEAR(accident_date)='2022'
            GROUP BY 
            CASE
					WHEN light_conditions IN ('Daylight') THEN 'DAY'
                    WHEN light_conditions IN ('Darkness - lighting unknown', 'Darkness - lights lit','Darkness - lights unlit', 'Darkness - no lighting')THEN 'Night'
            END;     
            
            
            
--  12.PY_NUMBER_OF_CASUALTIES BY LIGHT_CONDITIONS.
SELECT 
			CASE
					WHEN light_conditions IN ('Daylight') THEN 'DAY'
                    WHEN light_conditions IN ('Darkness - lighting unknown', 'Darkness - lights lit','Darkness - lights unlit', 'Darkness - no lighting')THEN 'Night'
			END AS Light_condition,
            CAST(CAST(SUM(number_of_casualties)AS DECIMAL(10,2)) * 100/
            (SELECT CAST(SUM(number_of_casualties)AS DECIMAL(10,2))FROM road_table WHERE YEAR(accident_date)='2021') AS DECIMAL(10,2)) AS CY_Casualties_PCT FROM road_table WHERE YEAR(accident_date)='2021'
            GROUP BY 
            CASE
					WHEN light_conditions IN ('Daylight') THEN 'DAY'
                    WHEN light_conditions IN ('Darkness - lighting unknown', 'Darkness - lights lit','Darkness - lights unlit', 'Darkness - no lighting')THEN 'Night'
            END;     


-- 13.CY_NUMBER_OF_CASUALTIES BY LOCAL_AUTHORITY
SELECT  local_authority, SUM(number_of_casualties) AS TOTAL_CASUALTIES FROM road_table
GROUP BY local_authority
ORDER BY TOTAL_CASUALTIES DESC
LIMIT 10;
            
            