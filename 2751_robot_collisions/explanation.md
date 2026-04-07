## 2751. Robot Collisions – Step‑by‑Step Explanation

### 1. Understanding the problem (like I'm 5 years old)

Imagine a **straight road**. Robots are placed at different positions.
All robots start moving at the **same speed**.

- If a robot points **R**, it goes **right** (→).
- If a robot points **L**, it goes **left** (←).

Two robots **only crash** when one is going **right** and the other is going **left** **towards each other**.
If they go the same direction, they never meet. If they go away from each other, they never meet.

**When they crash:**

- The one with **higher health** survives, but its health goes **down by 1**.
- The one with **lower health** is destroyed.
- If healths are **equal**, **both** are destroyed.

After all possible crashes are over, we return the **healths of the survivors** in the **same order** as the input robots were given.

### 2. Why do we need to sort by position?

The input positions can be in **any order** (e.g., `[5,4,3,2,1]`).
On the real road, robot 1 (pos 4) is to the **left** of robot 0 (pos 5).
To know which robots can meet, we must know **who is left and who is right**.
So we **sort all robots by their position** – from leftmost to rightmost – and process them in that order.

### 3. Why a stack?

When we walk from left to right:

- Every **right‑moving** robot we see is a **potential threat** – it might collide with a **future left‑moving** robot that appears to its right.
  So we **push** it onto a stack. The stack acts like a waiting room.

- When we see a **left‑moving** robot, it will try to **crash** with the **most recent** right‑moving robot (the one on top of the stack).
  - If the left robot wins, it continues to fight the **next** right‑moving robot (the new top of stack).
  - If it loses, it dies and we stop.
  - If it draws, both die and we move on.

The stack gives us **automatic ordering** of collisions: the closest right‑mover to the left is the first to fight.

### 4. Tracking original order

After sorting, we lost the original positions in the input array.
But the problem says: return survivors **in the order they were given**.
So each robot remembers its **original index** (`idx`).
At the end, we place each survivor's health into a result array at that index, then filter out the dead ones (`-1`).

### 5. Step‑by‑step of the code

**Robot class:**

```dart
class Robot {
  int pos;      // position on the road
  int health;   // current health
  String dir;   // 'R' or 'L'
  int idx;      // original index in the input list
  Robot(this.pos, this.health, this.dir, this.idx);
}
```

We pack all information about a robot into one object. This makes it easy to sort and move around.

**Main function:**

1. **Bundle** – create a Robot for each input, storing its original index.

2. **Sort** – by pos ascending.

3. **Process** – iterate over the sorted robots:
   - If robot goes R → `stack.add(robot)`.
   - If robot goes L:
     - Start with `currentLeft = robot`.
     - While there is a right‑mover on top of the stack and `currentLeft` is not null:
       - Compare healths.
       - Update healths or remove robots accordingly.
       - If left robot dies, set `currentLeft = null` to exit loop.
     - If `currentLeft` still exists (survived all fights), push it onto stack.

4. **Restore order** – create a list of size n filled with -1. For each survivor in stack, put its health at `result[survivor.idx]`. Filter out -1s and return.

### 6. Dry run of example 2

**Input:**

```
positions = [3,5,2,6]
healths = [10,10,15,12]
directions = "RLRL"
```

**Step 1 – Bundle with original indices:**

- Robot A: pos=3, health=10, dir=R, idx=0
- Robot B: pos=5, health=10, dir=L, idx=1
- Robot C: pos=2, health=15, dir=R, idx=2
- Robot D: pos=6, health=12, dir=L, idx=3

**Step 2 – Sort by position:**

- Robot C (pos=2, R, 15, idx=2)
- Robot A (pos=3, R, 10, idx=0)
- Robot B (pos=5, L, 10, idx=1)
- Robot D (pos=6, L, 12, idx=3)

**Step 3 – Process with stack:**

- C (R) → push. Stack: [C]
- A (R) → push. Stack: [C, A]
- B (L) → fight:
  - top = A (health 10), left = B (health 10) → equal → both die.
  - Pop A from stack. Set `currentLeft = null`.
  - Stack now: [C].
  - Loop ends because `currentLeft == null`.
- D (L) → fight:
  - top = C (health 15), left = D (health 12) → right wins → C.health-- (now 14), left dies.
  - Stack remains [C].
  - Loop ends.
- Stack survivors: only C (health 14, idx=2)

**Step 4 – Restore order:**

- Result array of size 4: [-1, -1, -1, -1]
- Place survivor at idx=2: [-1, -1, 14, -1]
- Filter out -1 → [14]

### 7. Complexity

- **Time:** O(n log n) – dominated by the sort.
- **Space:** O(n) – for the robots list and the stack.
