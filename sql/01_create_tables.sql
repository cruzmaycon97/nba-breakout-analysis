-- NBA Breakout Analysis
-- Database schema (SQLite)
-- Creates the four relational tables used in the project.
-- Run this script on an empty SQLite database before importing data.

PRAGMA foreign_keys = ON;

-- 1. Player reference data
CREATE TABLE players (
    player_id INTEGER PRIMARY KEY,
    player_name TEXT NOT NULL,
    position TEXT,
    birth_date TEXT
);

-- 2. Team reference data
CREATE TABLE teams (
    team_id INTEGER PRIMARY KEY,
    team_name TEXT NOT NULL,
    abbreviation TEXT NOT NULL UNIQUE
);

-- 3. Game schedule and season data
CREATE TABLE games (
    game_id TEXT PRIMARY KEY,
    game_date TEXT NOT NULL,
    season TEXT NOT NULL,
    home_team_id INTEGER NOT NULL,
    away_team_id INTEGER NOT NULL,

    FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES teams(team_id),

    CHECK (home_team_id <> away_team_id)
);

-- 4. Player statistics recorded for each game
CREATE TABLE player_game_stats (
    game_id TEXT NOT NULL,
    player_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,

    minutes REAL NOT NULL DEFAULT 0,

    points INTEGER NOT NULL DEFAULT 0,
    rebounds INTEGER NOT NULL DEFAULT 0,
    assists INTEGER NOT NULL DEFAULT 0,
    steals INTEGER NOT NULL DEFAULT 0,
    blocks INTEGER NOT NULL DEFAULT 0,
    turnovers INTEGER NOT NULL DEFAULT 0,

    field_goals_made INTEGER NOT NULL DEFAULT 0,
    field_goals_attempted INTEGER NOT NULL DEFAULT 0,

    three_pointers_made INTEGER NOT NULL DEFAULT 0,
    three_pointers_attempted INTEGER NOT NULL DEFAULT 0,

    free_throws_made INTEGER NOT NULL DEFAULT 0,
    free_throws_attempted INTEGER NOT NULL DEFAULT 0,

    PRIMARY KEY (game_id, player_id),

    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),

    CHECK (minutes >= 0),
    CHECK (points >= 0),
    CHECK (rebounds >= 0),
    CHECK (assists >= 0),
    CHECK (steals >= 0),
    CHECK (blocks >= 0),
    CHECK (turnovers >= 0),

    CHECK (field_goals_made <= field_goals_attempted),
    CHECK (three_pointers_made <= three_pointers_attempted),
    CHECK (free_throws_made <= free_throws_attempted)
);
