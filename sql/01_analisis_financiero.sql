-- =============================================
-- BASE DE DATOS Y ESTRUCTURA
-- =============================================
-- CREATE DATABASE merval_analysis;
-- GO

USE merval_analysis;
GO

-- CREATE TABLE merval_metrics (
--     trade_date DATE,
--     open_price FLOAT,
--     high_price FLOAT,
--     low_price FLOAT,
--     close_price FLOAT,
--     volume FLOAT,
--     daily_return FLOAT,
--     cumulative_return FLOAT,
--     volatility_20d FLOAT,
--     ma20 FLOAT,
--     ma50 FLOAT,
--     volume_avg_20d FLOAT,
--     volume_spike FLOAT,
--     symbol VARCHAR(10)
-- );
-- GO

-- =============================================
-- RESUMEN GENERAL POR ACCIÓN
-- =============================================
SELECT
    symbol,
    ROUND(MAX(cumulative_return), 2)              AS retorno_acumulado_pct,
    ROUND(AVG(volatility_20d), 2)                 AS volatilidad_promedio,
    ROUND(MAX(close_price), 2)                    AS precio_maximo,
    ROUND(MIN(close_price), 2)                    AS precio_minimo,
    ROUND(MAX(close_price) - MIN(close_price), 2) AS rango_precio
FROM merval_metrics
GROUP BY symbol
ORDER BY retorno_acumulado_pct DESC;

-- =============================================
-- RELACIÓN RIESGO / RETORNO
-- =============================================
SELECT
    symbol,
    ROUND(MAX(cumulative_return), 2)         AS retorno_acumulado_pct,
    ROUND(AVG(volatility_20d), 2)            AS volatilidad_promedio,
    ROUND(MAX(cumulative_return) /
          NULLIF(AVG(volatility_20d), 0), 2) AS ratio_retorno_riesgo
FROM merval_metrics
WHERE volatility_20d IS NOT NULL
GROUP BY symbol
ORDER BY ratio_retorno_riesgo DESC;

-- =============================================
-- PICOS DE VOLUMEN INUSUALES
-- =============================================
SELECT
    symbol,
    trade_date,
    ROUND(volume, 0)         AS volumen,
    ROUND(volume_avg_20d, 0) AS volumen_promedio_20d,
    ROUND(volume_spike, 2)   AS spike_ratio
FROM merval_metrics
WHERE volume_spike >= 2
ORDER BY volume_spike DESC;

-- =============================================
-- EVOLUCIÓN MENSUAL DEL RETORNO
-- =============================================
SELECT
    symbol,
    FORMAT(trade_date, 'yyyy-MM') AS year_month,
    ROUND(MAX(cumulative_return), 2) AS retorno_acumulado_mes,
    ROUND(AVG(daily_return), 2)      AS retorno_diario_promedio,
    ROUND(AVG(volatility_20d), 2)    AS volatilidad_promedio
FROM merval_metrics
GROUP BY symbol, FORMAT(trade_date, 'yyyy-MM')
ORDER BY symbol, year_month;

-- =============================================
-- VISTA ANALÍTICA — RESUMEN POR ACCIÓN
-- =============================================
-- CREATE VIEW vw_resumen_acciones AS
-- SELECT
--     symbol,
--     ROUND(MAX(cumulative_return), 2)         AS retorno_acumulado_pct,
--     ROUND(AVG(volatility_20d), 2)            AS volatilidad_promedio,
--     ROUND(MAX(cumulative_return) /
--           NULLIF(AVG(volatility_20d), 0), 2) AS ratio_retorno_riesgo,
--     ROUND(MAX(close_price), 2)               AS precio_maximo,
--     ROUND(MIN(close_price), 2)               AS precio_minimo,
--     ROUND(AVG(volume), 0)                    AS volumen_promedio
-- FROM merval_metrics
-- WHERE volatility_20d IS NOT NULL
-- GROUP BY symbol;
-- GO

SELECT * FROM vw_resumen_acciones;