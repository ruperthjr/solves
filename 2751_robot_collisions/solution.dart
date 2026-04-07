// 2751. Robot Collisions
// Difficulty: Hard
// Topic: Stack + Sorting
// Runtime: O(n log n) — the sort dominates
// Space:   O(n)       — stack + robots list
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXPLANATION — read this before a single line of code
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Picture a straight road. Robots are placed on it at different
// spots. Some drive RIGHT →, some drive LEFT ←. Everyone moves
// at exactly the same speed.
//
// The only way two robots ever crash is when one is going RIGHT
// and another is going LEFT and they are moving TOWARD each other.
//   → ←   they will meet. CRASH.
//   → →   same direction, the gap never closes. NO CRASH.
//   ← ←   same direction. NO CRASH.
//   ← →   moving AWAY from each other. NO CRASH.
//
// When they crash:
//   higher health wins, its health drops by 1, loser is gone.
//   equal health → BOTH gone.
//
// We need to return the healths of the survivors, in the ORIGINAL
// order the robots were given to us (not sorted order).
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WHY SORT FIRST?
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Positions can come in ANY order in the input array:
//   positions = [5, 4, 3, 2, 1]
// That means robot 0 is at position 5, robot 1 is at position 4.
// On the actual road, robot 1 (pos 4) is to the LEFT of robot 0 (pos 5).
//
// Collisions happen based on WHERE robots are on the road, not
// where they appear in the array. So we sort by position first
// so we can process robots from left to right, just like reading
// the road left to right.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WHY A STACK?
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Walking left to right, every RIGHT-moving robot we see is a
// THREAT waiting to happen. It might collide with a future
// LEFT-moving robot that hasn't appeared yet. So we park it
// on a stack — a waiting room of rightward robots.
//
// The moment we see a LEFT-moving robot, it starts fighting
// the most recent rightward robot (top of stack). If it wins,
// it keeps fighting the next one. If it loses, it dies. The
// stack gives us the "most recent rightward robot" for free.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WHY TRACK THE ORIGINAL INDEX?
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// We sorted the robots to process them correctly. But the problem
// says return healths in the ORIGINAL input order. So each robot
// remembers its original index (idx) so we can place it back.

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THE ROBOT DATA CLASS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// We bundle everything about one robot into a single object so
// we never have to juggle three separate arrays in parallel.
// pos   → where on the road it starts
// health→ how many hits it can take
// dir   → 'R' (right) or 'L' (left)
// idx   → its original position in the input (for output ordering)

class Robot {
  int pos;
  int health;
  String dir;
  int idx;
  Robot(this.pos, this.health, this.dir, this.idx);
}

class Solution {
  List<int> survivedRobotsHealths(
    List<int> positions,
    List<int> healths,
    String directions,
  ) {
    int n = positions.length;

    // ── STEP 1: Bundle each robot into an object ──────────────
    // We use the original index i as the robot's memory of where
    // it came from in the input.
    List<Robot> robots = [];
    for (int i = 0; i < n; i++) {
      robots.add(Robot(positions[i], healths[i], directions[i], i));
    }

    // ── STEP 2: Sort by position (left to right on the road) ──
    // After this, robots[0] is the leftmost robot on the road,
    // robots[n-1] is the rightmost. We can now walk the road
    // in order.
    robots.sort((a, b) => a.pos.compareTo(b.pos));

    // ── STEP 3: The stack — a waiting room for right-movers ───
    // Only RIGHT-moving robots sit here waiting for a collision.
    // LEFT-moving robots fight their way through this stack.
    List<Robot> stack = [];

    for (Robot robot in robots) {

      if (robot.dir == 'R') {
        // ── RIGHT-MOVER: park it and move on ──────────────────
        // It can't crash with anything behind it (everything
        // behind is already processed and moving away or also
        // rightward). It can only crash with a future left-mover.
        // The stack will hold it until that moment comes.
        stack.add(robot);

      } else {
        // ── LEFT-MOVER: start fighting ────────────────────────
        // This robot is moving left. Every right-mover currently
        // on the stack is to its LEFT on the road and heading
        // TOWARD it. Fight them one by one, starting from the
        // closest (top of stack).
        //
        // We keep a nullable reference to the left-mover.
        // If it dies, we set this to null to stop the loop.
        Robot? currentLeft = robot;

        while (
          stack.isNotEmpty &&       // there is someone to fight
          stack.last.dir == 'R' &&  // and it's a right-mover
          currentLeft != null       // and our left-mover is still alive
        ) {
          Robot right = stack.last; // the closest right-mover on the road

          if (right.health > currentLeft.health) {
            // RIGHT WINS ────────────────────────────────────────
            // The right-mover is stronger. It survives but loses
            // 1 health from the impact. The left-mover is gone.
            right.health--;
            currentLeft = null; // left-mover destroyed, stop fighting

          } else if (right.health == currentLeft.health) {
            // DRAW — BOTH DIE ───────────────────────────────────
            // Equal health means equal destruction. Pop the
            // right-mover off the stack and kill the left-mover.
            stack.removeLast();
            currentLeft = null; // both gone

          } else {
            // LEFT WINS ─────────────────────────────────────────
            // The left-mover is stronger. It survives but loses
            // 1 health. The right-mover is gone (popped).
            // Loop continues — the left-mover may face the NEXT
            // right-mover sitting beneath on the stack.
            currentLeft.health--;
            stack.removeLast(); // right-mover destroyed
          }
        }

        // If the left-mover survived all the fights (or there
        // were no right-movers to fight at all), it goes on the
        // stack. It will never fight anything already on the
        // stack because everything beneath is either left-moving
        // (same direction, no crash) or there is nothing left.
        if (currentLeft != null) {
          stack.add(currentLeft);
        }
      }
    }

    // ── STEP 4: Restore original order ────────────────────────
    // The stack holds survivors sorted by road position.
    // The problem wants them in original INPUT order.
    // We create a result array of size n filled with -1 (sentinel
    // for "this robot did not survive"), then place each survivor
    // at its original index. Finally we filter out the -1s.
    List<int> result = List.filled(n, -1);
    for (Robot r in stack) {
      result[r.idx] = r.health;
    }
    return result.where((h) => h != -1).toList();
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRY RUN — Example 2
// positions  = [3, 5, 2, 6]
// healths    = [10,10,15,12]
// directions = "RLRL"
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Bundle robots (before sort):
//   Robot(pos=3, health=10, dir='R', idx=0)
//   Robot(pos=5, health=10, dir='L', idx=1)
//   Robot(pos=2, health=15, dir='R', idx=2)
//   Robot(pos=6, health=12, dir='L', idx=3)
//
// After sorting by position:
//   pos=2 R health=15 idx=2   ← leftmost on road
//   pos=3 R health=10 idx=0
//   pos=5 L health=10 idx=1
//   pos=6 L health=12 idx=3
//
// Process:
//   pos=2 R → push.           stack: [R15]
//   pos=3 R → push.           stack: [R15, R10]
//   pos=5 L → fight!
//     top=R10, left=L10 → equal → BOTH DIE
//     stack.removeLast()      stack: [R15]
//     currentLeft = null      (left-mover also dead)
//     loop ends.
//   pos=6 L → fight!
//     top=R15, left=L12 → R15 > L12 → RIGHT WINS
//     R15.health-- → R14
//     currentLeft = null      (left-mover dead)
//     loop ends.
//
// Stack survivors: [R14 idx=2]
//
// Restore order:
//   result = [-1, -1, -1, -1]
//   place R14 at idx=2 → [-1, -1, 14, -1]
//   filter -1s → [14]
//
// Output: [14] ✓