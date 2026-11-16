-- NBA Breakout Analysis
-- Data quality and integrity validation

-- 1. Count records in each table
SELECT 'players' AS table_name, COUNT(*) AS total_records FROM players
UNION ALL
SELECT 'teams', COUNT(*) FROM teams
UNION ALL
SELECT 'games', COUNT(*) FROM games
UNION ALL
SELECT 'player_game_stats', COUNT(*) FROM player_game_stats;

-- 2. Count games by season
SELECT
    season,
    COUNT(*) AS total_games
FROM games
GROUP BY season
ORDER BY season;

-- 3. Check for duplicate player-game records
SELECT
    player_id,
    game_id,
    COUNT(*) AS duplicate_count
FROM player_game_stats
GROUP BY player_id, game_id
HAVING COUNT(*) > 1;

-- 4. Check foreign key integrity
PRAGMA foreign_key_check;

-- 5. Count player statistics by season
SELECT
    g.season,
    COUNT(*) AS total_player_game_records,
    COUNT(DISTINCT s.player_id) AS unique_players
FROM player_game_stats s
JOIN games g
    ON s.game_id = g.game_id
GROUP BY g.season
ORDER BY g.season;
