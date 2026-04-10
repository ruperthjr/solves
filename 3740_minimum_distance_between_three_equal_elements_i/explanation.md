## 3740. Minimum Distance Between Three Equal Elements I – Step‑by‑Step Explanation

### 1. Understanding the problem

We are given an array of integers. We need to find three **distinct** indices `i`, `j`, `k` such that `nums[i] == nums[j] == nums[k]`. The distance of such a tuple is defined as:
abs(i - j) + abs(j - k) + abs(k - i)

We want the **minimum possible distance** among all good tuples. If none exist, return `-1`.

### 2. Simplifying the distance formula

For any three sorted indices `a < b < c`, the distance is:
(b - a) + (c - b) + (c - a) = 2 * (c - a)


So the distance depends **only on the smallest and largest index** in the triple. The middle index doesn't matter!

That means to minimise the distance, we need to pick three occurrences of the same value that are as **close together** as possible – specifically, we want to minimise the gap between the first and third occurrence.

### 3. Approach

- Group the indices of each distinct value using a hash map.
- For each value that appears at least **three times**, slide a window of size 3 over its sorted indices (they are naturally sorted if we traverse the array from left to right).
- For each window `[indices[i], indices[i+1], indices[i+2]]`, compute `2 * (indices[i+2] - indices[i])`.
- Keep track of the global minimum.

### 4. Complexity

- **Time:** O(n) – one pass to build the map, and each group is scanned once.  
- **Space:** O(n) – for storing indices.

### 5. Dry run (Example 1)

`nums = [1,2,1,1,3]`

Indices map:
- 1 → [0, 2, 3]
- 2 → [1]
- 3 → [4]

Only value `1` has ≥3 occurrences.  
Window i=0: indices = [0,2,3] → distance = 2 × (3 - 0) = **6**.

Output: `6`.

### 6. Connection

This problem is a warm‑up for the “minimum distance between equal elements” pattern, which appears in many forms (e.g., “Shortest Distance to a Character”). The key observation is that the middle index cancels out, reducing the problem to a simple spread calculation.