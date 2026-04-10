## 874. Walking Robot Simulation – Step‑by‑Step Explanation

### 1. Understanding the problem

A robot starts at `(0, 0)` facing **north**. It executes a series of commands:

- `-2` : turn left 90°
- `-1` : turn right 90°
- `1..9` : move forward that many units, **one unit at a time**.

Some grid cells contain obstacles. If the robot would step onto an obstacle, it stops moving for the rest of that command (but stays on the previous cell).

We need the **maximum squared Euclidean distance** the robot ever reaches from the origin.

### 2. Why simulation works

The total number of steps is at most `commands.length * 9 ≤ 10^4 * 9 = 90,000`. Simulating step‑by‑step is perfectly fine.  
Obstacles are stored in a hash set for O(1) look‑ups.

### 3. Direction handling

We use a direction array:

0: North → (0, 1)
1: East → (1, 0)
2: South → (0, -1)
3: West → (-1, 0)


- Turn left: `dir = (dir + 3) % 4` (equivalent to `dir - 1` mod 4).
- Turn right: `dir = (dir + 1) % 4`.

### 4. Step‑by‑step movement

For a move command of `k` units:
- Determine the unit vector `(dx, dy)` for the current direction.
- Repeat up to `k` times:
  - Compute next cell `(x+dx, y+dy)`.
  - If it's an obstacle, break.
  - Otherwise, update position and update `maxDistSq`.

### 5. Complexity

- **Time:** O(commands.length + total_steps). Worst‑case ~90k operations, very fast.
- **Space:** O(obstacles.length) for the set.

### 6. Dry run (Example 2)

`commands = [4,-1,4,-2,4]`, `obstacles = [[2,4]]`

- Start (0,0) N.
- `4` → move N 4 → (0,4), max=16.
- `-1` → turn R → E.
- `4` → move E:
  - step 1: (1,4) ok, max=17.
  - step 2: next (2,4) is obstacle → stop. Robot at (1,4).
- `-2` → turn L → N.
- `4` → move N 4 → (1,8), max=1+64=65.

Output: `65`.

### 7. Connection

This is a classic simulation problem that appears in many variants (e.g., “Robot Bounded In Circle”). The key is clean state management and obstacle lookup.