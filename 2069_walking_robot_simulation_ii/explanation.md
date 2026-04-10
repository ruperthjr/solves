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


Every `P` steps, the robot returns to a state that is equivalent (but not necessarily identical to the start state – at corners, the direction may differ). After the first step, the state sequence repeats every `P` steps.

### 3. Using simulation for one lap, then modulo for all steps

`num` can be as large as `10^5`, but `P ≤ 400` (since `width,height ≤ 100`). We can:
1. Simulate the robot for exactly `P` steps, recording the `(x, y, direction)` after **each** step.
2. Keep a running total of steps taken (`_stepsTaken`).
3. For `getPos` and `getDir`:
   - If no steps taken, return start state `(0,0,"East")`.
   - Otherwise, compute `idx = (_stepsTaken - 1) % P` and return the recorded state at that index.

This correctly handles the corner direction changes: e.g., after completing a lap on an `8×2` grid, the robot stops at `(0,0)` facing **South**, not East.

### 4. Complexity

- **Precomputation:** O(P) time and space.
- **Each method call:** O(1).

### 5. Dry run of the previously failing test case

`Robot(8,2)` → `P = 16`.

Simulated states (indices 0..15):
0: (1,0,E)  
1: (2,0,E)  
2: (3,0,E)  
3: (4,0,E)  
4: (5,0,E)  
5: (6,0,E)  
6: (7,0,E)  
7: (7,1,N)  
8: (6,1,W)  
9: (5,1,W)  
10: (4,1,W)  
11: (3,1,W)  
12: (2,1,W)  
13: (1,1,W)  
14: (0,1,W)  
15: (0,0,S)

After `step(17)` → total steps = 17 → index = (17-1)%16 = 0 → (1,0,E) 
After `step(21)` → total steps = 38 → index = (38-1)%16 = 37%16 = 5 → (6,0,E) 
After `step(22)` + `step(34)` → total = 94 → index = (94-1)%16 = 93%16 = 13 → (1,1,W)
After `step(1)` + `step(46)` + `step(35)` → total = 176 → index = (176-1)%16 = 175%16 = 15 → (0,0,S)

### 6. Connection

This problem is a more advanced version of “Walking Robot Simulation” (LeetCode 874). The key addition is the **cycle precomputation** to handle large step counts efficiently and to correctly manage corner direction states.