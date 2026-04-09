// 3655. XOR After Range Multiplication Queries II
// Difficulty: Hard
// Topic: Array, Math, Prefix Product, Square Root Decomposition
// Runtime: O((n + q) * sqrt(n)) — balanced by sqrt threshold
// Space:   O(n)                     — result array + diff arrays
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXPLANATION — read this before a single line of code
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Picture a row of numbered buckets. You have many paint cans.
// Each can says:
//   "Start at bucket L, stop at bucket R, jump K buckets at a time,
//    and multiply the number in each bucket you hit by V."
//
// If K is large (K > √n), you only touch a few buckets per can.
// Just apply the paint directly — it's fast.
//
// If K is small (K ≤ √n), you might touch almost every bucket.
// Doing that for many cans would take forever. BUT notice:
// when K is small, the pattern repeats. Buckets that share the
// same remainder when divided by K are always hit together.
//
// We group all queries with the same K and same starting remainder.
// Then we use a "multiplication difference array" for that group:
//   - mark where to start multiplying by V
//   - mark where to stop (using modular inverse, like "dividing")
//   - sweep once to apply all multiplications for that group.
//
// Finally, XOR all bucket values together.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WHY SQUARE ROOT DECOMPOSITION?
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Direct simulation: O(q * (n/k)) per query → worst O(n*q) when k=1.
// Too slow for 10^5. We split into two regimes:
//   • Small K (≤ √n): process in batches by remainder. Each batch
//     takes O(size of batch + #queries in group). Total work O(q*√n).
//   • Large K (> √n): each query touches at most √n elements.
//     Total work O(q*√n).
// Together O((n+q)*√n) — fast enough.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WHY A DIFFERENCE ARRAY FOR MULTIPLICATION?
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// For addition, diff array: add at start, subtract after end.
// For multiplication, we do: multiply at start, multiply by
// modular inverse after end. Because prefix product then applies
// the multiplier only within the range.
// Modular inverse exists because MOD = 1e9+7 is prime.

import 'dart:math';

class Solution {
  static const int MOD = 1000000007;

  int xorAfterQueries(List<int> nums, List<List<int>> queries) {
    int n = nums.length;
    int B = sqrt(n).ceil(); // threshold: sqrt(n)

    // Copy nums to modify
    List<int> result = List<int>.from(nums);

    // Separate queries into small K and large K
    List<List<int>> largeKQueries = [];
    Map<String, List<List<int>>> smallKGroups = {};

    for (var q in queries) {
      int l = q[0], r = q[1], k = q[2], v = q[3];
      if (k > B) {
        largeKQueries.add(q);
      } else {
        // Group key = "k|remainder" (l % k determines the starting offset)
        String key = "$k|${l % k}";
        smallKGroups.putIfAbsent(key, () => []).add(q);
      }
    }

    // 1. Large K queries: apply directly
    for (var q in largeKQueries) {
      int l = q[0], r = q[1], k = q[2], v = q[3];
      for (int idx = l; idx <= r; idx += k) {
        result[idx] = (result[idx] * v) % MOD;
      }
    }

    // 2. Small K queries: process each (k, remainder) group
    for (var entry in smallKGroups.entries) {
      var parts = entry.key.split('|');
      int k = int.parse(parts[0]);
      int rem = int.parse(parts[1]);
      var qs = entry.value;

      // How many elements in this remainder class?
      // Indices: rem, rem+k, rem+2k, ... ≤ n-1
      int M = (n - 1 - rem) ~/ k + 1;
      if (M <= 0) continue;

      // Multiplication difference array (size M+1, initialized to 1)
      List<int> multDiff = List<int>.filled(M + 1, 1);

      for (var q in qs) {
        int l = q[0], r = q[1], v = q[3];
        // Convert real indices to positions in the virtual array
        int leftIdx = (l - rem) ~/ k;
        int rightIdx = (r - rem) ~/ k;

        // Multiply at start
        multDiff[leftIdx] = (multDiff[leftIdx] * v) % MOD;
        // Multiply by inverse after end (to cancel the multiplication)
        int invV = _modInverse(v);
        multDiff[rightIdx + 1] = (multDiff[rightIdx + 1] * invV) % MOD;
      }

      // Sweep: apply prefix product to actual array
      int currentMult = 1;
      for (int i = 0; i < M; i++) {
        currentMult = (currentMult * multDiff[i]) % MOD;
        int actualIdx = rem + i * k;
        result[actualIdx] = (result[actualIdx] * currentMult) % MOD;
      }
    }

    // Compute XOR of all elements
    int xorSum = 0;
    for (int val in result) {
      xorSum ^= val;
    }
    return xorSum;
  }

  // Modular inverse using Fermat's little theorem (MOD is prime)
  int _modInverse(int x) {
    return _modPow(x, MOD - 2);
  }

  int _modPow(int base, int exp) {
    int res = 1;
    int b = base % MOD;
    int e = exp;
    while (e > 0) {
      if ((e & 1) == 1) res = (res * b) % MOD;
      b = (b * b) % MOD;
      e >>= 1;
    }
    return res;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRY RUN — Example 2
// nums = [2,3,1,5,4]
// queries = [[1,4,2,3], [0,2,1,2]]
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// n = 5, B = ceil(√5) = 3.
//
// Query 1: [1,4,2,3] → K=2 ≤ 3 → small group.
//   remainder = 1%2 = 1. Key = "2|1".
// Query 2: [0,2,1,2] → K=1 ≤ 3 → small group.
//   remainder = 0%1 = 0. Key = "1|0".
// No large K queries.
//
// Group "2|1" (indices with rem=1: 1, 3 → M=2)
//   multDiff size 3 = [1,1,1].
//   Q1: l=1,r=4,k=2,v=3 → leftIdx = (1-1)/2=0, rightIdx=(4-1)/2=1.
//   multDiff[0] *= 3 → [3,1,1].
//   inv(3)=333333336, multDiff[2] *= inv(3) → [3,1,333333336].
//   Sweep:
//     i=0: currentMult=3 → nums[1]=3*3=9.
//     i=1: currentMult=3*333333336%MOD=1 → nums[3]=5*1=5? Wait 15*1=15.
//   Array now: [2,9,1,15,4]
//
// Group "1|0" (all indices: M=5)
//   multDiff size 6 = [1,1,1,1,1,1].
//   Q2: l=0,r=2,v=2 → leftIdx=0, rightIdx=2.
//   multDiff[0] *= 2 → [2,1,1,1,1,1].
//   inv(2)=500000004, multDiff[3] *= inv(2) → [2,1,1,500000004,1,1].
//   Sweep:
//     i=0: cur=2 → nums[0]=2*2=4
//     i=1: cur=2 → nums[1]=9*2=18
//     i=2: cur=2 → nums[2]=1*2=2
//     i=3: cur=2*500000004%MOD=1 → nums[3]=15*1=15
//     i=4: cur=1 → nums[4]=4*1=4
//   Final: [4,18,2,15,4]
//
// XOR: 4^18=22, 22^2=20, 20^15=27, 27^4=31.
// Output: 31 
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PATTERN REFERENCE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// This problem is a multiplication version of "Range Addition"
// (LeetCode 370) combined with square root decomposition.
// The technique of splitting by step size appears in:
//   - "Range Sum Query - Mutable" (sqrt decomposition)
//   - "Count of Range Sum" (prefix sums with merging)