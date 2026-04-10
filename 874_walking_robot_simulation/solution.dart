// 874. Walking Robot Simulation
// Difficulty: Medium
// Topic: Array, Hash Table, Simulation
// Runtime: O(N + K) where N = commands.length, K = total steps taken (≤ 9*10^4)
// Space:   O(O) where O = obstacles.length (for the set)
//
// INTUITION:
// Simulate the robot's movement step by step.
// Use a direction array [north, east, south, west] and an index to track facing.
// Turn commands update the direction index modulo 4.
// For move commands, attempt one unit at a time; if next cell is obstacle, stop moving.
// Keep track of max squared distance from origin.

class Solution {
  int robotSim(List<int> commands, List<List<int>> obstacles) {
    // Directions: 0=N, 1=E, 2=S, 3=W
    final List<List<int>> dirs = [
      [0, 1],   // north
      [1, 0],   // east
      [0, -1],  // south
      [-1, 0]   // west
    ];

    // Store obstacles as Set of strings for O(1) lookup
    Set<String> obstacleSet = {};
    for (var obs in obstacles) {
      obstacleSet.add("${obs[0]},${obs[1]}");
    }

    int x = 0, y = 0;
    int dir = 0; // start facing north
    int maxDistSq = 0;

    for (int cmd in commands) {
      if (cmd == -2) {
        // turn left: (dir - 1) mod 4
        dir = (dir + 3) % 4;
      } else if (cmd == -1) {
        // turn right: (dir + 1) mod 4
        dir = (dir + 1) % 4;
      } else {
        // move forward cmd steps
        int dx = dirs[dir][0];
        int dy = dirs[dir][1];
        for (int s = 0; s < cmd; s++) {
          int nx = x + dx;
          int ny = y + dy;
          if (obstacleSet.contains("$nx,$ny")) {
            break; // obstacle, stop moving
          }
          x = nx;
          y = ny;
          maxDistSq = max(maxDistSq, x * x + y * y);
        }
      }
    }
    return maxDistSq;
  }

  int max(int a, int b) => a > b ? a : b;
}

// DRY RUN — Example 1
// commands = [4,-1,3], obstacles = []
// Start (0,0), dir=0 (north)
// cmd=4: move north 4 steps → (0,4), maxDistSq=16
// cmd=-1: turn right → dir=1 (east)
// cmd=3: move east 3 steps → (3,4), maxDistSq=25
// Return 25