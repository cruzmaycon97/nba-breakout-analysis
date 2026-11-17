
-- NBA Breakout Analysis
-- Load player game statistics from both NBA seasons.
-- Prerequisites:
-- Players, teams and games must be loaded.
-- Both player statistics CSV files must be imported.

-- 1. Combine player statistics datasets

WITH all_stats AS (
    SELECT
        date, id, team, opp, season,
        minutes, points, rebounds, assists,
        steals, blocks, turnovers,
        fgm, fga, col_17, col_18, ftm, fta
    FROM stats_2025_import

    UNION ALL

    SELECT
        date, id, team, opp, season,
        minutes, points, rebounds, assists,
        steals, blocks, turnovers,
        fgm, fga, col_17, col_18, ftm, fta
    FROM stats_2026_import
)

-- 2. Load player game statistics
-- Match games using date, season, team and opponent.
-- Both home and away team combinations are considered.
-- col_17: three-pointers made.
-- col_18: assumed three-pointers attempted,
-- pending confirmation of the original CSV header.

INSERT INTO player_game_stats (
    game_id,
    player_id,
    team_id,
    minutes,
    points,
    rebounds,
    assists,
    steals,
    blocks,
    turnovers,
    field_goals_made,
    field_goals_attempted,
    three_pointers_made,
    three_pointers_attempted,
    free_throws_made,
    free_throws_attempted
)

SELECT
    g.game_id,
    p.player_id,
    t.team_id,
    s.minutes,
    s.points,
    s.rebounds,
    s.assists,
    s.steals,
    s.blocks,
    s.turnovers,
    s.fgm,
    s.fga,
    s.col_17,
    s.col_18,
    s.ftm,
    s.fta
FROM all_stats s
JOIN players p
    ON s.id = p.player_id
JOIN teams t
    ON s.team = t.abbreviation
JOIN teams o
    ON s.opp = o.abbreviation
JOIN games g
    ON s.date = g.game_date
    AND s.season = g.season
    AND (
        (t.team_id = g.home_team_id
         AND o.team_id = g.away_team_id)
        OR
        (t.team_id = g.away_team_id
         AND o.team_id = g.home_team_id)
    );

-- 3. Validate total record count
-- Expected: 30488

SELECT COUNT(*) AS total_records
FROM player_game_stats;

-- 4. Validate records and players by season
-- Expected:
-- 2025-26: 26568 records, 582 players
-- 2026-27: 3920 records, 465 players

SELECT
    g.season,
    COUNT(*) AS total_records,
    COUNT(DISTINCT s.player_id) AS total_players
FROM player_game_stats s
JOIN games g
    ON s.game_id = g.game_id
GROUP BY g.season
ORDER BY g.season;

-- 5. Check for duplicate player-game records
-- Expected result: no rows

SELECT
    game_id,
    player_id,
    COUNT(*) AS total_records
FROM player_game_stats
GROUP BY game_id, player_id
HAVING COUNT(*) > 1;

-- 6. Inspect relational player statistics

SELECT
    p.player_name,
    g.game_date,
    g.season,
    t.abbreviation AS team,
    s.minutes,
    s.points,
    s.rebounds,
    s.assists,
    s.steals,
    s.blocks,
    s.turnovers,
    s.three_pointers_made
FROM player_game_stats s
JOIN players p
    ON s.player_id = p.player_id
JOIN games g
    ON s.game_id = g.game_id
JOIN teams t
    ON s.team_id = t.team_id
ORDER BY g.game_date DESC, p.player_name
LIMIT 15;

-- 7. Check foreign key integrity
-- Expected result: no rows

PRAGMA foreign_key_check;
