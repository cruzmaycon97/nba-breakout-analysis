
-- NBA Breakout Analysis
-- Player performance comparison across NBA seasons.
--
-- Methodology:
-- Baseline: full 2025-26 regular season.
-- Current period: first eight games played in 2026-27.
-- Minimum average playing time: 15 minutes per game.
-- Players must have historical data from 2025-26.
-- Dataset cutoff: November 12, 2026.
-- Expected result: 233 eligible players.

-- 1. Identify the first eight games played by each player
CREATE VIEW IF NOT EXISTS player_season_comparison AS
WITH ranked_games AS (
    SELECT
        s.player_id,
        s.minutes,
        s.points,
        s.rebounds,
        s.assists,
        s.steals,
        s.blocks,
        s.turnovers,
        s.three_pointers_made,
        ROW_NUMBER() OVER (
            PARTITION BY s.player_id
            ORDER BY g.game_date, g.game_id
        ) AS game_number
    FROM player_game_stats s
    JOIN games g
        ON s.game_id = g.game_id
    WHERE g.season = '2026-27'
),

-- 2. Calculate current season averages
-- Apply minimum games and playing time requirements

averages_2026 AS (
    SELECT
        player_id,
        COUNT(*) AS games_played,
        AVG(minutes) AS avg_minutes,
        AVG(points) AS avg_points,
        AVG(rebounds) AS avg_rebounds,
        AVG(assists) AS avg_assists,
        AVG(steals) AS avg_steals,
        AVG(blocks) AS avg_blocks,
        AVG(turnovers) AS avg_turnovers,
        AVG(three_pointers_made) AS avg_three_pointers
    FROM ranked_games
    WHERE game_number <= 8
    GROUP BY player_id
    HAVING COUNT(*) = 8
        AND AVG(minutes) >= 15
),

-- 3. Calculate historical season averages
-- Use all games from the previous regular season

averages_2025 AS (
    SELECT
        s.player_id,
        COUNT(*) AS games_played,
        AVG(s.minutes) AS avg_minutes,
        AVG(s.points) AS avg_points,
        AVG(s.rebounds) AS avg_rebounds,
        AVG(s.assists) AS avg_assists,
        AVG(s.steals) AS avg_steals,
        AVG(s.blocks) AS avg_blocks,
        AVG(s.turnovers) AS avg_turnovers,
        AVG(s.three_pointers_made) AS avg_three_pointers
    FROM player_game_stats s
    JOIN games g
        ON s.game_id = g.game_id
    WHERE g.season = '2025-26'
    GROUP BY s.player_id
)

-- 4. Compare player performance across seasons
-- Positive differences indicate statistical improvement.
-- Turnover differences are reversed because fewer
-- turnovers represent better performance.
-- Minutes are included as contextual information.

SELECT
    p.player_id,
    p.player_name,
    a.games_played AS games_2025,
    b.games_played AS games_2026,

    ROUND(a.avg_minutes, 2) AS minutes_2025,
    ROUND(b.avg_minutes, 2) AS minutes_2026,
    ROUND(b.avg_minutes - a.avg_minutes, 2) AS delta_minutes,

    ROUND(a.avg_points, 2) AS points_2025,
    ROUND(b.avg_points, 2) AS points_2026,
    ROUND(b.avg_points - a.avg_points, 2) AS delta_points,

    ROUND(a.avg_rebounds, 2) AS rebounds_2025,
    ROUND(b.avg_rebounds, 2) AS rebounds_2026,
    ROUND(b.avg_rebounds - a.avg_rebounds, 2) AS delta_rebounds,

    ROUND(a.avg_assists, 2) AS assists_2025,
    ROUND(b.avg_assists, 2) AS assists_2026,
    ROUND(b.avg_assists - a.avg_assists, 2) AS delta_assists,

    ROUND(a.avg_steals, 2) AS steals_2025,
    ROUND(b.avg_steals, 2) AS steals_2026,
    ROUND(b.avg_steals - a.avg_steals, 2) AS delta_steals,

    ROUND(a.avg_blocks, 2) AS blocks_2025,
    ROUND(b.avg_blocks, 2) AS blocks_2026,
    ROUND(b.avg_blocks - a.avg_blocks, 2) AS delta_blocks,

    ROUND(a.avg_turnovers, 2) AS turnovers_2025,
    ROUND(b.avg_turnovers, 2) AS turnovers_2026,
    ROUND(a.avg_turnovers - b.avg_turnovers, 2)
        AS turnover_improvement,

    ROUND(a.avg_three_pointers, 2) AS three_pointers_2025,
    ROUND(b.avg_three_pointers, 2) AS three_pointers_2026,
    ROUND(b.avg_three_pointers - a.avg_three_pointers, 2)
        AS delta_three_pointers

FROM averages_2025 a
INNER JOIN averages_2026 b
    ON a.player_id = b.player_id
INNER JOIN players p
    ON a.player_id = p.player_id
ORDER BY delta_points DESC;

-- Validate the comparison view
SELECT COUNT(*) AS total_eligible_players
FROM player_season_comparison;

-- Retrieve player season comparison
SELECT *
FROM player_season_comparison
ORDER BY delta_points DESC;
