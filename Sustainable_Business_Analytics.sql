-- ============================================
-- PROJECT: Sustainable Business Analytics
-- DATABASE: Sustainable_Business_Analytics
-- TOOL: MySQL 8.0
-- DATA: Sample factory sustainability data
-- PERIOD: 2024-2025
-- ============================================

USE Sustainable_Business_Analytics; 
-- ============================================
-- 1. TOTAL ELECTRICITY CONSUMPTION BY YEAR
-- ============================================

SELECT
    year,
    SUM(electricity_consumed) AS total_electricity
FROM energy_consumption
GROUP BY year
ORDER BY year; 
-- ============================================
-- 2. RENEWABLE ENERGY SHARE BY FACTORY (2025)
-- ============================================

SELECT
    f.factory_name,
    ROUND(
        e.renewable_energy /
        e.electricity_consumed * 100,
        2
    ) AS renewable_percentage
FROM factory_details f
JOIN energy_consumption e
    ON f.factory_id = e.factory_id
WHERE e.year = 2025
ORDER BY renewable_percentage DESC; 
-- ============================================
-- 3. CARBON EMISSIONS BY FACTORY (2025)
-- ============================================

SELECT
    f.factory_name,
    m.carbon_emissions
FROM factory_details f
JOIN environmental_metrics m
    ON f.factory_id = m.factory_id
WHERE m.year = 2025
ORDER BY m.carbon_emissions DESC; 
-- ============================================
-- 4. CARBON EMISSION REDUCTION (2024 vs 2025)
-- ============================================

SELECT
    f.factory_name,
    SUM(CASE WHEN m.year = 2024
        THEN m.carbon_emissions ELSE 0 END) AS emissions_2024,
    SUM(CASE WHEN m.year = 2025
        THEN m.carbon_emissions ELSE 0 END) AS emissions_2025,
    SUM(CASE WHEN m.year = 2024
        THEN m.carbon_emissions ELSE 0 END)
    -
    SUM(CASE WHEN m.year = 2025
        THEN m.carbon_emissions ELSE 0 END)
        AS emissions_reduced
FROM factory_details f
JOIN environmental_metrics m
    ON f.factory_id = m.factory_id
GROUP BY f.factory_id, f.factory_name
ORDER BY emissions_reduced DESC; 
-- ============================================
-- 5. WATER CONSUMPTION COMPARISON (2024 vs 2025)
-- ============================================

SELECT
    f.factory_name,
    SUM(CASE WHEN m.year = 2024
        THEN m.water_consumption ELSE 0 END) AS water_2024,
    SUM(CASE WHEN m.year = 2025
        THEN m.water_consumption ELSE 0 END) AS water_2025,
    SUM(CASE WHEN m.year = 2024
        THEN m.water_consumption ELSE 0 END)
    -
    SUM(CASE WHEN m.year = 2025
        THEN m.water_consumption ELSE 0 END) AS water_saved
FROM factory_details f
JOIN environmental_metrics m
    ON f.factory_id = m.factory_id
GROUP BY f.factory_id, f.factory_name
ORDER BY water_saved DESC; 
-- ============================================
-- 6. TOTAL WASTE GENERATION BY YEAR
-- ============================================

SELECT
    year,
    SUM(waste_generated) AS total_waste
FROM environmental_metrics
GROUP BY year
ORDER BY year; 
-- ============================================
-- 7. RENEWABLE ENERGY SHARE BY YEAR
-- ============================================

SELECT
    year,
    SUM(electricity_consumed) AS total_electricity,
    SUM(renewable_energy) AS total_renewable,
    ROUND(
        SUM(renewable_energy) /
        SUM(electricity_consumed) * 100,
        2
    ) AS renewable_percentage
FROM energy_consumption
GROUP BY year
ORDER BY year; 
-- ============================================
-- 8. WASTE GENERATION BY FACTORY (2025)
-- ============================================

SELECT
    f.factory_name,
    m.waste_generated
FROM factory_details f
JOIN environmental_metrics m
    ON f.factory_id = m.factory_id
WHERE m.year = 2025
ORDER BY m.waste_generated DESC; 
-- ============================================
-- 9. FACTORY EMISSION CLASSIFICATION (2025)
-- ============================================

SELECT
    f.factory_name,
    m.carbon_emissions,
    CASE
        WHEN m.carbon_emissions < 1000 THEN 'Low'
        WHEN m.carbon_emissions < 2000 THEN 'Medium'
        ELSE 'High'
    END AS emission_category
FROM factory_details f
JOIN environmental_metrics m
    ON f.factory_id = m.factory_id
WHERE m.year = 2025
ORDER BY m.carbon_emissions DESC; 
-- ============================================
-- 10. FACTORY SUSTAINABILITY PERFORMANCE SCORE
-- ============================================

SELECT
    f.factory_name,
    (
        CASE WHEN
            SUM(CASE WHEN m.year = 2025
                THEN m.carbon_emissions ELSE 0 END)
            <
            SUM(CASE WHEN m.year = 2024
                THEN m.carbon_emissions ELSE 0 END)
        THEN 1 ELSE 0 END
        +
        CASE WHEN
            SUM(CASE WHEN m.year = 2025
                THEN m.water_consumption ELSE 0 END)
            <
            SUM(CASE WHEN m.year = 2024
                THEN m.water_consumption ELSE 0 END)
        THEN 1 ELSE 0 END
        +
        CASE WHEN
            SUM(CASE WHEN m.year = 2025
                THEN m.waste_generated ELSE 0 END)
            <
            SUM(CASE WHEN m.year = 2024
                THEN m.waste_generated ELSE 0 END)
        THEN 1 ELSE 0 END
    ) AS sustainability_score
FROM factory_details f
JOIN environmental_metrics m
    ON f.factory_id = m.factory_id
GROUP BY f.factory_id, f.factory_name
ORDER BY sustainability_score DESC; 
-- ============================================
-- 11. CONSOLIDATED SUSTAINABILITY REPORT (2025)
-- ============================================

SELECT
    f.factory_name,
    e.electricity_consumed,
    e.renewable_energy,
    ROUND(
        e.renewable_energy /
        e.electricity_consumed * 100, 2
    ) AS renewable_percentage,
    m.carbon_emissions,
    m.water_consumption,
    m.waste_generated
FROM factory_details f
JOIN energy_consumption e
    ON f.factory_id = e.factory_id
JOIN environmental_metrics m
    ON f.factory_id = m.factory_id
    AND e.year = m.year
WHERE e.year = 2025
ORDER BY m.carbon_emissions DESC; 
-- ============================================
-- 12. TOP 5 FACTORIES BY RENEWABLE ENERGY
-- ============================================

SELECT
    f.factory_name,
    e.renewable_energy,
    ROUND(
        e.renewable_energy /
        e.electricity_consumed * 100,
        2
    ) AS renewable_percentage
FROM factory_details f
JOIN energy_consumption e
    ON f.factory_id = e.factory_id
WHERE e.year = 2025
ORDER BY renewable_percentage DESC
LIMIT 5; 
-- ============================================
-- 13. DATA QUALITY - MISSING VALUES
-- ============================================

SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN carbon_emissions IS NULL
        THEN 1 ELSE 0 END) AS missing_emissions,
    SUM(CASE WHEN water_consumption IS NULL
        THEN 1 ELSE 0 END) AS missing_water,
    SUM(CASE WHEN waste_generated IS NULL
        THEN 1 ELSE 0 END) AS missing_waste
FROM environmental_metrics; 
-- ============================================
-- 14. DATA QUALITY - DUPLICATE RECORDS
-- ============================================

SELECT
    factory_id,
    year,
    COUNT(*) AS record_count
FROM environmental_metrics
GROUP BY factory_id, year
HAVING COUNT(*) > 1; 
-- ============================================
-- 15. DATA QUALITY - NEGATIVE VALUES
-- ============================================

SELECT *
FROM environmental_metrics
WHERE carbon_emissions < 0
   OR water_consumption < 0
   OR waste_generated < 0; 