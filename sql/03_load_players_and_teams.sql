
-- NBA Breakout Analysis
-- Load reference data: NBA teams
-- Player data will be added after validation.

-- 1. Insert NBA teams
-- Team IDs are project-specific, not official NBA IDs.

INSERT INTO teams (team_id, team_name, abbreviation)
VALUES
(1, 'Atlanta Hawks', 'ATL'),
(2, 'Boston Celtics', 'BOS'),
(3, 'Brooklyn Nets', 'BKN'),
(4, 'Charlotte Hornets', 'CHA'),
(5, 'Chicago Bulls', 'CHI'),
(6, 'Cleveland Cavaliers', 'CLE'),
(7, 'Dallas Mavericks', 'DAL'),
(8, 'Denver Nuggets', 'DEN'),
(9, 'Detroit Pistons', 'DET'),
(10, 'Golden State Warriors', 'GSW'),
(11, 'Houston Rockets', 'HOU'),
(12, 'Indiana Pacers', 'IND'),
(13, 'Los Angeles Clippers', 'LAC'),
(14, 'Los Angeles Lakers', 'LAL'),
(15, 'Memphis Grizzlies', 'MEM'),
(16, 'Miami Heat', 'MIA'),
(17, 'Milwaukee Bucks', 'MIL'),
(18, 'Minnesota Timberwolves', 'MIN'),
(19, 'New Orleans Pelicans', 'NOP'),
(20, 'New York Knicks', 'NYK'),
(21, 'Oklahoma City Thunder', 'OKC'),
(22, 'Orlando Magic', 'ORL'),
(23, 'Philadelphia 76ers', 'PHI'),
(24, 'Phoenix Suns', 'PHX'),
(25, 'Portland Trail Blazers', 'POR'),
(26, 'Sacramento Kings', 'SAC'),
(27, 'San Antonio Spurs', 'SAS'),
(28, 'Toronto Raptors', 'TOR'),
(29, 'Utah Jazz', 'UTA'),
(30, 'Washington Wizards', 'WAS');

-- 2. Validate the number of teams
-- Expected result: 30

SELECT COUNT(*) AS total_teams
FROM teams;

-- 3. Verify team reference data

SELECT
    team_id,
    team_name,
    abbreviation
FROM teams
ORDER BY team_id;

-- 4. Check for duplicate abbreviations
-- Expected result: no rows

SELECT
    abbreviation,
    COUNT(*) AS total
FROM teams
GROUP BY abbreviation
HAVING COUNT(*) > 1;

-- 5. Standardize player names across seasons
-- The same player appears with different accent marks
-- in the source datasets.

UPDATE stats_2025_import
SET player = 'Moussa Cissé'
WHERE id = 1630619
  AND player = 'Moussa Cisse';

-- 6. Load unique players from both seasons

WITH all_players AS (
    SELECT
        id,
        player,
        pos
    FROM stats_2025_import

    UNION ALL

    SELECT
        id,
        player,
        pos
    FROM stats_2026_import
),

unique_players AS (
    SELECT
        id,
        MAX(player) AS player_name,
        MAX(pos) AS position
    FROM all_players
    GROUP BY id
)

INSERT INTO players (
    player_id,
    player_name,
    position
)
SELECT
    id,
    player_name,
    position
FROM unique_players;

-- 7. Validate player count
-- Expected result: 645

SELECT COUNT(*) AS total_players
FROM players;

-- 8. Check for duplicate player names
-- Expected result: no rows

SELECT
    player_name,
    COUNT(*) AS total
FROM players
GROUP BY player_name
HAVING COUNT(*) > 1;

-- 9. Verify player records

SELECT
    player_id,
    player_name,
    position
FROM players
ORDER BY player_name
LIMIT 20;
