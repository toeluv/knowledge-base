Ниже — шаблоны для каждого паттерна в Java. Это не решения конкретных задач, а «каркасы», которые можно адаптировать под большинство LeetCode‑задач по хеш‑таблицам.[1][2]

***

## 1. Проверка наличия / дубликатов

### 1.1. Есть ли дубликаты (HashSet)

```java
boolean hasDuplicate(int[] nums) {
    Set<Integer> seen = new HashSet<>();
    for (int x : nums) {
        if (seen.contains(x)) {
            return true; // нашли повтор
        }
        seen.add(x);
    }
    return false;
}
```

Используется в задачах типа Contains Duplicate, отслеживание уже встреченных значений.[3][4]

### 1.2. Two Sum (комплемент в HashMap)

```java
int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> indexByValue = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
        int need = target - nums[i];
        if (indexByValue.containsKey(need)) {
            return new int[]{indexByValue.get(need), i};
        }
        indexByValue.put(nums[i], i);
    }
    return new int[]{-1, -1}; // если решения нет
}
```

Шаблон: на каждом шаге проверяешь, есть ли в map нужное дополнение.[2][5]

### 1.3. Дубликаты в диапазоне k (скользящее окно + Set)

```java
boolean containsNearbyDuplicate(int[] nums, int k) {
    Set<Integer> window = new HashSet<>();
    int left = 0;
    for (int right = 0; right < nums.length; right++) {
        if (window.contains(nums[right])) {
            return true;
        }
        window.add(nums[right]);
        if (right - left >= k) {
            window.remove(nums[left]);
            left++;
        }
    }
    return false;
}
```

Окно фиксированного размера, в котором не допускаются повторы.[5]

***

## 2. Частоты (frequency map)

### 2.1. Подсчёт частот символов в строке

```java
Map<Character, Integer> buildCharFreq(String s) {
    Map<Character, Integer> freq = new HashMap<>();
    for (char c : s.toCharArray()) {
        freq.put(c, freq.getOrDefault(c, 0) + 1);
    }
    return freq;
}
```

Базовый кусок для задач Valid Anagram, Ransom Note и т.п.[4]

### 2.2. Проверка анаграммы двумя freq‑map

```java
boolean isAnagram(String s, String t) {
    if (s.length() != t.length()) return false;

    Map<Character, Integer> freq = new HashMap<>();
    for (char c : s.toCharArray()) {
        freq.put(c, freq.getOrDefault(c, 0) + 1);
    }

    for (char c : t.toCharArray()) {
        if (!freq.containsKey(c)) return false;
        freq.put(c, freq.get(c) - 1);
        if (freq.get(c) == 0) {
            freq.remove(c);
        }
    }

    return freq.isEmpty();
}
```

Та же идея используется для проверки «хватает ли ресурсов/букв».[6][4]

### 2.3. Частоты элементов массива

```java
Map<Integer, Integer> buildFreq(int[] nums) {
    Map<Integer, Integer> freq = new HashMap<>();
    for (int x : nums) {
        freq.put(x, freq.getOrDefault(x, 0) + 1);
    }
    return freq;
}
```

Шаблон для задач Unique Number of Occurrences, Top K Frequent Elements и др.[7][6]

***

## 3. Группировка по сигнатуре (signature key)

### 3.1. Группировка анаграмм по отсортированной строке

```java
List<List<String>> groupAnagrams(String[] strs) {
    Map<String, List<String>> groups = new HashMap<>();

    for (String s : strs) {
        char[] chars = s.toCharArray();
        Arrays.sort(chars);
        String key = new String(chars); // сигнатура

        groups.computeIfAbsent(key, k -> new ArrayList<>()).add(s);
    }

    return new ArrayList<>(groups.values());
}
```

Ключ — любая детерминированная форма строки (отсортированные символы / частоты).[4][6]

### 3.2. Группировка по массиву частот (без сортировки)

```java
String buildSignature(String s) {
    int[] count = new int[26];
    for (char c : s.toCharArray()) {
        count[c - 'a']++;
    }
    StringBuilder sb = new StringBuilder();
    for (int x : count) {
        sb.append('#').append(x);
    }
    return sb.toString();
}

List<List<String>> groupByFreq(String[] strs) {
    Map<String, List<String>> groups = new HashMap<>();
    for (String s : strs) {
        String key = buildSignature(s);
        groups.computeIfAbsent(key, k -> new ArrayList<>()).add(s);
    }
    return new ArrayList<>(groups.values());
}
```

Такой подход часто полезен, когда сортировка дорогая или надо избежать коллизий.[2][6]

***

## 4. Sliding window + HashSet / HashMap

### 4.1. Самая длинная подстрока без повторов (Set)

```java
int lengthOfLongestSubstring(String s) {
    Set<Character> window = new HashSet<>();
    int left = 0;
    int best = 0;

    for (int right = 0; right < s.length(); right++) {
        char c = s.charAt(right);
        while (window.contains(c)) {
            window.remove(s.charAt(left));
            left++;
        }
        window.add(c);
        best = Math.max(best, right - left + 1);
    }
    return best;
}
```

Базовый sliding window + set.[8][9]

### 4.2. Окно с подсчётом частот (Map)

```java
int longestWithAtMostKDistinct(String s, int k) {
    Map<Character, Integer> freq = new HashMap<>();
    int left = 0, best = 0;

    for (int right = 0; right < s.length(); right++) {
        char c = s.charAt(right);
        freq.put(c, freq.getOrDefault(c, 0) + 1);

        while (freq.size() > k) {
            char leftChar = s.charAt(left);
            freq.put(leftChar, freq.get(leftChar) - 1);
            if (freq.get(leftChar) == 0) {
                freq.remove(leftChar);
            }
            left++;
        }

        best = Math.max(best, right - left + 1);
    }
    return best;
}
```

Это общий шаблон для задач типа Minimum Window / «не более K различных символов».[10][8]

***

## 5. Prefix sum + HashMap

### 5.1. Количество подмассивов с суммой k

```java
int countSubarraysWithSum(int[] nums, int k) {
    Map<Integer, Integer> countByPrefix = new HashMap<>();
    countByPrefix.put(0, 1); // важная инициализация

    int prefix = 0;
    int ans = 0;

    for (int x : nums) {
        prefix += x;
        int need = prefix - k;
        ans += countByPrefix.getOrDefault(need, 0);
        countByPrefix.put(prefix, countByPrefix.getOrDefault(prefix, 0) + 1);
    }

    return ans;
}
```

Шаблон для задач Subarray Sum Equals K и похожих.[11][12]

### 5.2. Максимальная длина подмассива с суммой k

```java
int maxLenSubarrayWithSum(int[] nums, int k) {
    Map<Integer, Integer> firstIndexByPrefix = new HashMap<>();
    firstIndexByPrefix.put(0, -1);

    int prefix = 0;
    int best = 0;

    for (int i = 0; i < nums.length; i++) {
        prefix += nums[i];

        int need = prefix - k;
        if (firstIndexByPrefix.containsKey(need)) {
            best = Math.max(best, i - firstIndexByPrefix.get(need));
        }

        if (!firstIndexByPrefix.containsKey(prefix)) {
            firstIndexByPrefix.put(prefix, i);
        }
    }

    return best;
}
```

Шаблон: map хранит первый индекс каждого prefix’а.[12][13]

### 5.3. Остатки по модулю (сумма кратна k)

```java
boolean hasSubarraySumMultipleOfK(int[] nums, int k) {
    Map<Integer, Integer> firstIndexByRem = new HashMap<>();
    firstIndexByRem.put(0, -1);

    int prefix = 0;
    for (int i = 0; i < nums.length; i++) {
        prefix += nums[i];
        int rem = k == 0 ? prefix : ((prefix % k) + k) % k;

        if (firstIndexByRem.containsKey(rem)) {
            if (i - firstIndexByRem.get(rem) >= 2) {
                return true;
            }
        } else {
            firstIndexByRem.put(rem, i);
        }
    }
    return false;
}
```

Этот приём используется в задачах вроде Continuous Subarray Sum.[13][12]

***

## 6. Hash для состояния / visited

### 6.1. Visited‑множество (например, цикл в односвязном списке)

```java
boolean hasCycle(ListNode head) {
    Set<ListNode> visited = new HashSet<>();
    ListNode cur = head;
    while (cur != null) {
        if (visited.contains(cur)) {
            return true;
        }
        visited.add(cur);
        cur = cur.next;
    }
    return false;
}
```

Общий шаблон для visited в графах, DFS/BFS и т.п.[14][6]

### 6.2. Valid Sudoku — несколько set’ов состояния

```java
boolean isValidSudoku(char[][] board) {
    Set<String> seen = new HashSet<>();

    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
            char val = board[r][c];
            if (val == '.') continue;

            String rowKey = "r" + r + val;
            String colKey = "c" + c + val;
            String boxKey = "b" + (r / 3) + (c / 3) + val;

            if (!seen.add(rowKey) || !seen.add(colKey) || !seen.add(boxKey)) {
                return false;
            }
        }
    }
    return true;
}
```

Шаблон: кодируешь разные ограничения в строковые ключи/сигнатуры.[5]

***

## 7. Дизайн с hash (например, LRU Cache)

### 7.1. Каркас LRU Cache (HashMap + двусвязный список)

```java
class LRUCache {
    private static class Node {
        int key, value;
        Node prev, next;
        Node(int k, int v) { key = k; value = v; }
    }

    private final int capacity;
    private final Map<Integer, Node> map = new HashMap<>();
    private final Node head = new Node(0, 0); // dummy head
    private final Node tail = new Node(0, 0); // dummy tail

    public LRUCache(int capacity) {
        this.capacity = capacity;
        head.next = tail;
        tail.prev = head;
    }

    public int get(int key) {
        if (!map.containsKey(key)) return -1;
        Node node = map.get(key);
        moveToFront(node);
        return node.value;
    }

    public void put(int key, int value) {
        if (map.containsKey(key)) {
            Node node = map.get(key);
            node.value = value;
            moveToFront(node);
            return;
        }

        if (map.size() == capacity) {
            Node lru = tail.prev;
            removeNode(lru);
            map.remove(lru.key);
        }

        Node node = new Node(key, value);
        addToFront(node);
        map.put(key, node);
    }

    private void addToFront(Node node) {
        node.next = head.next;
        node.prev = head;
        head.next.prev = node;
        head.next = node;
    }

    private void removeNode(Node node) {
        node.prev.next = node.next;
        node.next.prev = node.prev;
    }

    private void moveToFront(Node node) {
        removeNode(node);
        addToFront(node);
    }
}
```

Здесь `HashMap` даёт O(1) доступ по ключу, а список — порядок использования.[15][6]

***

Если хочешь, можно для каждого паттерна подобрать конкретные easy‑задачи из твоего текущего списка и расписать, какой именно из этих шаблонов туда «прикручивать» и что менять.

[1](https://www.techinterviewhandbook.org/algorithms/hash-table/)
[2](https://leetcode.com/discuss/study-guide/4042753/**-Mastering-Hashtable-Patterns:-A-Comprehensive-Guide/)
[3](https://leetcode.com/problem-list/hash-table/)
[4](http://akshatshah21.github.io/lc75-5/)
[5](https://bbs.huaweicloud.com/blogs/342444)
[6](https://www.geeksforgeeks.org/dsa/top-50-problems-on-hash-data-structure-asked-in-sde-interviews/)
[7](https://leetcode.com/problems/count-elements-with-maximum-frequency/)
[8](https://www.gauravaryal.com/leetcode/sliding-window/)
[9](https://www.youtube.com/watch?v=NWPtdSiuAAs)
[10](https://www.youtube.com/watch?v=PBZ_YSC1YSA)
[11](https://www.linkedin.com/posts/somanathp_problem-560-activity-7392267717778575360-H2uO)
[12](https://www.aspires.cc/prefix-sum/)
[13](https://javabulletin.substack.com/p/understanding-leetcode-prefix-sum)
[14](https://interviewing.io/hash-tables-interview-questions)
[15](https://dev.to/kuddleman/technical-interview-prep-hash-tables-part-i-3pl6)
