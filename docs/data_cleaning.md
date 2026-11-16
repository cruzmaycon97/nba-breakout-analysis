# Data Cleaning and Preparation

## Overview

This document describes the data quality issues identified during the NBA Breakout Analysis project and the steps taken to prepare the datasets for analysis.

The project compares NBA player statistics from the 2025-26 regular season with the first eight games played by each eligible player in the 2026-27 season.

## 1. Data Quality Issue: Merged Schedule Records

During the preparation of the 2026-27 NBA schedule dataset, two consecutive games were found merged into a single CSV record.

The affected games were:

| Date | Away Team | Home Team |
|---|---|---|
| October 31, 2026 | Oklahoma City Thunder | Houston Rockets |
| November 1, 2026 | Boston Celtics | Orlando Magic |

This formatting issue prevented the second game from being recognized as an independent record during data import.

## 2. Cleaning Procedure

The following steps were performed:

1. Inspected the original schedule CSV.
2. Identified the malformed record containing two games.
3. Separated the games into individual CSV records.
4. Preserved the original schedule columns.
5. Checked for duplicate games based on date and team matchup.
6. Exported the corrected dataset.

## 3. Validation Results

| Validation | Result |
|---|---|
| Original CSV records | 173 |
| Corrected game records | 174 |
| Duplicate date-and-matchup combinations | 0 |

The corrected dataset was saved as:

`data/processed/schedule_2026_cleaned.csv`

## 4. Data Integrity Considerations

The project also includes SQL validation queries to inspect:

- Record counts across database tables.
- Game distribution by season.
- Duplicate player-game records.
- Foreign key integrity.
- Player statistics coverage by season.

These checks are documented in `sql/02_data_validation.sql`.

## 5. Limitations

The corrected schedule covers the available 2026-27 dataset through November 12, 2026.

The analysis is based on a partial season and does not represent final 2026-27 season statistics.

## 6. Importance of Data Cleaning

This issue demonstrates why data validation is essential before performing statistical analysis.

A malformed schedule record can affect game identification, relational joins, and the completeness of player statistics.

Documenting the correction helps make the analysis more transparent and reproducible.
