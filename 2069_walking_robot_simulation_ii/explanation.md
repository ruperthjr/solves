## 2069. Walking Robot Simulation II – Step‑by‑Step Explanation

### 1. Understanding the problem

We have a rectangular grid of size `width × height`. A robot starts at `(0,0)` facing **East**. It moves along the **perimeter** of the grid. When it would step out of bounds, it first turns 90° counter‑clockwise, then tries the same step again.

The robot can be commanded to move `num` steps forward. We need to implement:
- `step(num)` – move the robot.
- `getPos()` – return current `[x, y]`.
- `getDir()` – return current direction as string.

### 2. Key observation: the robot is stuck on the perimeter

Because the robot always turns when it hits a wall, it never leaves the outer boundary. The entire path forms a **closed loop** (a cycle). The length of this loop is:

P = 2 × (width + height) - 4


Every `P` steps, the robot returns exactly to its starting cell and direction.

### 3. Using the cycle to avoid step‑by‑step simulation

`num` can be as large as `10^5`, but `P ≤ 400` (since `width,height ≤ 100`). We can:
1. Precompute the sequence of `(x, y, direction)` for every cell along the perimeter, in the order the robot visits them.
2. Keep a pointer `idx` to the robot's current position in this sequence.
3. For `step(num)`, advance `idx` by `num % P` (modulo the cycle length) and update position/direction instantly.

This makes every operation **O(1)**.

### 4. Building the perimeter sequence

We start at `(0,0)` facing East. The path is:
- East along the bottom edge: `(0,0) → (width-1, 0)`.
- North along the right edge: `(width-1, 1) → (width-1, height-1)`.
- West along the top edge: `(width-2, height-1) → (0, height-1)`.
- South along the left edge: `(0, height-2) → (0, 1)`.

**Note:** We do not include `(0,0)` twice. The loop is closed naturally by the modulo arithmetic.

We also record the **direction** the robot faces when standing still on that cell. For example, on the bottom edge it faces East; on the right edge it faces North, etc.

### 5. Complexity

- **Precomputation:** O(width + height) time and space.
- **Each method call:** O(1).

### 6. Dry run (Example 1)

`Robot(6,3)`

Perimeter length = 2×(6+3) - 4 = 14.

Sequence (index, x, y, dir):
0: (0,0,E), 1: (1,0,E), 2: (2,0,E), 3: (3,0,E), 4: (4,0,E), 5: (5,0,E),
6: (5,1,N), 7: (5,2,N),
8: (4,2,W), 9: (3,2,W), 10: (2,2,W), 11: (1,2,W), 12: (0,2,W),
13: (0,1,S).

- `step(2)` → idx = 2 → (2,0,E)
- `step(2)` → idx = 4 → (4,0,E)
- `getPos()` → [4,0], `getDir()` → "East"
- `step(2)` → idx = 6 → (5,1,N)
- `step(1)` → idx = 7 → (5,2,N)
- `step(4)` → idx = 11 → (1,2,W)
- `getPos()` → [1,2], `getDir()` → "West"

Matches expected output.

### 7. Connection

This problem is a more advanced version of “Walking Robot Simulation” (LeetCode 874). The key addition is the **cycle precomputation** to handle large step counts efficiently. It also resembles “Robot Bounded In Circle” in that the robot’s path is ultimately periodic.