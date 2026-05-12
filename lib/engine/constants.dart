/// Game constants for Dipok.
///
/// See game_specification.md §1 and §7.3.

const columnMinimums = [7, 6, 6, 8, 8];

const minPlayers = 1;
const maxPlayers = 4;
const rollsPerTurn = 3;
const columnsPerLine = 5;
const diceCount = 5;

/// Game ends when this many lines are closed (figure + special).
/// Total possible lines: 5 figure + 3 special = 8.
const closedLinesForGameEnd = 4;
