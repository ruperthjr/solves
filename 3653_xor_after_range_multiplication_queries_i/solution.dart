// 3653. XOR After Range Multiplication Queries I
// Difficulty: Medium
// Topic: Array, Simulation
// Runtime: O(q * (n / k)) worst-case O(n * q) — but constraints allow it (n,q ≤ 1000)
// Space:   O(1) extra (modify in-place)
//
// INTUITION:
// The constraints are small (n, q ≤ 1000). We can simply apply each query
// by looping over the affected indices with the given step `k` and multiplying by `v`.
// Since we only need the final XOR, we can modify the array in-place and compute XOR at the end.

class Solution {
  static const int MOD = 1000000007;

  int xorAfterQueries(List<int> nums, List<List<int>> queries) {
    for (var q in queries) {
      int l = q[0], r = q[1], k = q[2], v = q[3];
      for (int idx = l; idx <= r; idx += k) {
        nums[idx] = (nums[idx] * v) % MOD;
      }
    }

    int xorSum = 0;
    for (int val in nums) {
      xorSum ^= val;
    }
    return xorSum;
  }
}

// DRY RUN — Example 2
// nums = [2,3,1,5,4]
// queries = [[1,4,2,3], [0,2,1,2]]
//
// Query1: l=1,r=4,k=2,v=3
//   idx=1: 3*3=9
//   idx=3: 5*3=15
// nums = [2,9,1,15,4]
//
// Query2: l=0,r=2,k=1,v=2
//   idx=0: 2*2=4
//   idx=1: 9*2=18
//   idx=2: 1*2=2
// nums = [4,18,2,15,4]
//
// XOR: 4^18=22, 22^2=20, 20^15=27, 27^4=31
// Output: 31