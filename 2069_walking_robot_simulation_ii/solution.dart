// 2069. Walking Robot Simulation II
// Difficulty: Medium
// Topic: Design, Simulation
// Runtime: O(1) per step (amortized) using modulo arithmetic on perimeter
// Space:   O(width + height) for perimeter list
//
// INTUITION:
// The robot only ever moves on the outer perimeter of the grid.
// The perimeter forms a cycle of length P = 2*(width + height) - 4.
// We can simulate the first P steps and store the resulting (x, y, dir) for each step.
// For step(num), we add num to totalSteps and map (totalSteps-1) % P to the list.
// This correctly handles the direction change at corners (e.g., (0,0) is East at start,
// but South after completing a lap).

class Robot {
  late int _width, _height;
  late int _perimeterLen;
  late List<_State> _states; // states after 1,2,...,P steps
  int _stepsTaken = 0;

  Robot(int width, int height) {
    _width = width;
    _height = height;
    _perimeterLen = 2 * (width + height) - 4;
    _states = [];
    _buildPerimeterStates();
  }

  void _buildPerimeterStates() {
    // Simulate robot movement for _perimeterLen steps, recording state after each step.
    int x = 0, y = 0;
    int dir = 0; // 0: East, 1: North, 2: West, 3: South
    const dirs = [
      [1, 0],  // East
      [0, 1],  // North
      [-1, 0], // West
      [0, -1]  // South
    ];
    const dirNames = ['East', 'North', 'West', 'South'];

    for (int step = 0; step < _perimeterLen; step++) {
      // Attempt to move one step in current direction
      int nx = x + dirs[dir][0];
      int ny = y + dirs[dir][1];
      // If out of bounds, turn counter‑clockwise and recompute next step
      if (nx < 0 || nx >= _width || ny < 0 || ny >= _height) {
        dir = (dir + 1) % 4; // turn left (counter‑clockwise)
        nx = x + dirs[dir][0];
        ny = y + dirs[dir][1];
      }
      // Move to the new cell
      x = nx;
      y = ny;
      _states.add(_State(x, y, dirNames[dir]));
    }
  }

  void step(int num) {
    _stepsTaken += num;
  }

  List<int> getPos() {
    if (_stepsTaken == 0) {
      return [0, 0];
    }
    int idx = (_stepsTaken - 1) % _perimeterLen;
    return [_states[idx].x, _states[idx].y];
  }

  String getDir() {
    if (_stepsTaken == 0) {
      return 'East';
    }
    int idx = (_stepsTaken - 1) % _perimeterLen;
    return _states[idx].dir;
  }
}

class _State {
  int x;
  int y;
  String dir;
  _State(this.x, this.y, this.dir);
}

// DRY RUN — Example 1
// Robot(6,3)
// P = 2*(6+3)-4 = 14
// Simulate 14 steps:
//  1: (1,0,East)
//  2: (2,0,East)
//  ...
//  7: (7,0,East)? Wait width=6 so max x=5. Actually:
//  width=6, height=3.
//  Steps simulation yields correct sequence as before.
// Test case that failed now passes: after 176 steps on 8x2 grid, (0,0,South) is returned.