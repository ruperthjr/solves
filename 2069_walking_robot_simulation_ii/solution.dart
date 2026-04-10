// 2069. Walking Robot Simulation II
// Difficulty: Medium
// Topic: Design, Simulation
// Runtime: O(1) per step (amortized) using modulo arithmetic on perimeter
// Space:   O(width + height) for perimeter list
//
// INTUITION:
// The robot only ever moves on the outer perimeter of the grid.
// The perimeter forms a cycle of length P = 2*(width + height) - 4.
// We can precompute the sequence of (x, y, dir) along this cycle.
// For step(num), we advance the current index by (num % P) and update position/direction.
// This avoids simulating every single step when num is large.

class Robot {
  late List<_Cell> _perimeter;
  late int _perimeterLen;
  late int _idx; // current position in the perimeter list

  Robot(int width, int height) {
    _perimeter = [];
    // Build the perimeter in clockwise order starting from (0,0) facing East.
    // East along bottom edge
    for (int x = 0; x < width; x++) {
      _perimeter.add(_Cell(x, 0, 'East'));
    }
    // North along right edge (skip (width-1,0) already added)
    for (int y = 1; y < height; y++) {
      _perimeter.add(_Cell(width - 1, y, 'North'));
    }
    // West along top edge (skip (width-1,height-1) already added)
    if (height > 1) {
      for (int x = width - 2; x >= 0; x--) {
        _perimeter.add(_Cell(x, height - 1, 'West'));
      }
    }
    // South along left edge (skip (0,height-1) already added, and stop before (0,0))
    if (width > 1) {
      for (int y = height - 2; y > 0; y--) {
        _perimeter.add(_Cell(0, y, 'South'));
      }
    }
    _perimeterLen = _perimeter.length;
    _idx = 0; // start at (0,0) facing East
  }

  void step(int num) {
    // The robot moves along the cycle. After moving, it may end up at a different cell.
    // Use modulo to skip full laps.
    int move = num % _perimeterLen;
    _idx = (_idx + move) % _perimeterLen;
  }

  List<int> getPos() {
    return [_perimeter[_idx].x, _perimeter[_idx].y];
  }

  String getDir() {
    return _perimeter[_idx].dir;
  }
}

class _Cell {
  int x;
  int y;
  String dir;
  _Cell(this.x, this.y, this.dir);
}

// DRY RUN — Example 1
// Robot(6,3)
// Perimeter:
// (0,0,E),(1,0,E),(2,0,E),(3,0,E),(4,0,E),(5,0,E),
// (5,1,N),(5,2,N),
// (4,2,W),(3,2,W),(2,2,W),(1,2,W),(0,2,W),
// (0,1,S)
// Total length = 6+2+5+1 = 14? Wait: width=6,height=3 -> perimeter = 2*6+2*3-4=12+6-4=14. Correct.
//
// step(2): _idx = 2 -> pos (2,0), dir East
// step(2): _idx = 4 -> (4,0), East
// getPos() -> [4,0]
// getDir() -> "East"
// step(2): _idx = 6 -> (5,1), North? Actually index 6 is (5,1) with dir North. Correct.
// step(1): _idx = 7 -> (5,2), North
// step(4): _idx = 11 -> (1,2), West? Let's verify: indices: 8:(4,2,W),9:(3,2,W),10:(2,2,W),11:(1,2,W). Yes.
// getPos() -> [1,2], getDir() -> "West"
// Matches example.