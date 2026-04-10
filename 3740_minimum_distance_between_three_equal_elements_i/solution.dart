// 3740. Minimum Distance Between Three Equal Elements I
// Difficulty: Easy
// Topic: Array, Hash Table
// Runtime: O(n) — single pass to group indices, then scan groups
// Space:   O(n) — store indices per value
//
// INTUITION:
// For a good tuple (i, j, k) with same value, distance = 2*(max - min).
// So we only need the smallest spread among any three occurrences of the same number.
// Group indices by value, sort each group (they are naturally in order if we traverse),
// and for each group with >=3 indices, slide a window of size 3 to compute 2*(list[i+2]-list[i]).
// Take the global minimum.

class Solution {
  int minimumDistance(List<int> nums) {
    // Map each value to list of indices where it appears
    Map<int, List<int>> pos = {};
    for (int i = 0; i < nums.length; i++) {
      pos.putIfAbsent(nums[i], () => []).add(i);
    }

    int minDist = -1;
    for (var indices in pos.values) {
      if (indices.length < 3) continue;
      // indices are already in increasing order because we added in order
      for (int i = 0; i <= indices.length - 3; i++) {
        int dist = 2 * (indices[i + 2] - indices[i]);
        if (minDist == -1 || dist < minDist) {
          minDist = dist;
        }
      }
    }
    return minDist;
  }
}

// DRY RUN — Example 1
// nums = [1,2,1,1,3]
// pos: 1->[0,2,3], 2->[1], 3->[4]
// For value 1: window i=0: indices[0]=0, indices[2]=3 => dist = 2*(3-0)=6. minDist=6.
// Output: 6