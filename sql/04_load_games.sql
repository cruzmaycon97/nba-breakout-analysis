
-- NBA Breakout Analysis
-- Load regular season games from both NBA seasons.
-- Prerequisites:
-- Team reference data must be loaded.
-- Both schedule CSV files must be imported.

-- 1. Combine schedule datasets

WITH all_games AS (
    SELECT
        date,
        visitor_neutral,
        home_neutral,
        '2025-26' AS season
    FROM schedule_2025_import

    UNION ALL

    SELECT
        date,
        visitor_neutral,
        home_neutral,
        '2026-27' AS season
    FROM schedule_2026_import
),

-- 2. Convert dates to ISO 8601 format

converted_schedule AS (
    SELECT
        SUBSTR(date, -4) || '-' ||
        CASE SUBSTR(date, 5, 3)
            WHEN 'Jan' THEN '01'
            WHEN 'Feb' THEN '02'
            WHEN 'Mar' THEN '03'
            WHEN 'Apr' THEN '04'
            WHEN 'May' THEN '05'
            WHEN 'Jun' THEN '06'
            WHEN 'Jul' THEN '07'
            WHEN 'Aug' THEN '08'
            WHEN 'Sep' THEN '09'
            WHEN 'Oct' THEN '10'
            WHEN 'Nov' THEN '11'
            WHEN 'Dec' THEN '12'
        END || '-' ||
        PRINTF('%02d', CAST(SUBSTR(date, 9, 2) AS INTEGER))
        AS game_date,
        visitor_neutral,
        home_neutral,
        season
    FROM all_games
)

-- 3. Generate game IDs and load relational data
-- Game IDs are project-specific: YYYYMMDD_HOME_AWAY.

INSERT INTO games (
    game_id,
    game_date,
    season,
    home_team_id,
    away_team_id
)

SELECT
    REPLACE(s.game_date, '-', '') || '_' ||
    home.abbreviation || '_' ||
    away.abbreviation AS game_id,
    s.game_date,
    s.season,
    home.team_id,
    away.team_id
FROM converted_schedule s
JOIN teams home
    ON s.home_neutral = home.team_name
JOIN teams away
    ON s.visitor_neutral = away.team_name;

-- 4. Validate game count by season
-- Expected: 1230 and 174

SELECT
    season,
    COUNT(*) AS total_games
FROM games
GROUP BY season
ORDER BY season;

-- 5. Validate total game count
-- Expected: 1404

SELECT COUNT(*) AS total_games
FROM games;

-- 6. Verify game and team relationships

SELECT
    g.game_id,
    g.game_date,
    g.season,
    home.team_name AS home_team,
    away.team_name AS away_team
FROM games g
JOIN teams home
    ON g.home_team_id = home.team_id
JOIN teams away
    ON g.away_team_id = away.team_id
ORDER BY g.game_date, g.game_id
LIMIT 20;

-- 7. Check foreign key integrity
-- Expected result: no rows

PRAGMA foreign_key_check;
