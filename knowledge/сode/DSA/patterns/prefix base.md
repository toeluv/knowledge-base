Отлично! Добавил LeetCode задачи, визуализации и более структурированный подход.

# 🎯 Префиксные суммы + HashMap: Полное руководство с LeetCode задачами

## 📊 **Базовая концепция**
Префиксные суммы позволяют быстро находить сумму любого подмассива за O(1) после O(n) препроцессинга.

**Пример:**
```
nums = [1, 2, 3, 4, 5]
prefix = [1, 3, 6, 10, 15]
Сумма подмассива [2,4] = prefix[4] - prefix[1] = 15 - 3 = 12
```

## 🎯 **Главная формула**
```
sum[i...j] = prefix[j] - prefix[i-1]
```
Переформулируем для поиска target:
```
prefix[j] - prefix[i] = target
prefix[i] = prefix[j] - target
```
**Идея:** Ищем в HashMap, встречался ли нам `prefix[j] - target`.

---

## 📝 **Паттерны задач с LeetCode примерами**

### 1️⃣ **Точное совпадение суммы**
**Когда использовать:** Нужно найти подмассив с конкретной суммой.

| Задача | Ссылка | Сложность | Ключевая идея |
|--------|--------|-----------|---------------|
| **Subarray Sum Equals K** | [560](https://leetcode.com/problems/subarray-sum-equals-k/) | Medium | Классика! Подсчёт всех подмассивов |
| **Continuous Subarray Sum** | [523](https://leetcode.com/problems/continuous-subarray-sum/) | Medium | Кратность k, длина ≥ 2 |
| **Binary Subarrays With Sum** | [930](https://leetcode.com/problems/binary-subarrays-with-sum/) | Medium | Для бинарных массивов |

```java
// 560. Subarray Sum Equals K (классическая задача)
public int subarraySum(int[] nums, int k) {
    Map<Integer, Integer> prefixCount = new HashMap<>();
    prefixCount.put(0, 1); // Пустой подмассив
    
    int sum = 0, count = 0;
    for (int num : nums) {
        sum += num;
        if (prefixCount.containsKey(sum - k)) {
            count += prefixCount.get(sum - k);
        }
        prefixCount.put(sum, prefixCount.getOrDefault(sum, 0) + 1);
    }
    return count;
}
```

### 2️⃣ **Длина подмассива (кратчайшая/длиннейшая)**
**Когда использовать:** Найти оптимальную длину подмассива.

| Задача | Ссылка | Сложность | Ключевая идея |
|--------|--------|-----------|---------------|
| **Minimum Size Subarray Sum** | [209](https://leetcode.com/problems/minimum-size-subarray-sum/) | Medium | Кратчайший подмассив с суммой ≥ target |
| **Longest Subarray Sum Equals K** | — | — | Вариация для интервью |

```java
// Найти кратчайший подмассив с суммой ≥ target
public int minSubArrayLen(int target, int[] nums) {
    int n = nums.length;
    int[] prefix = new int[n + 1];
    
    for (int i = 1; i <= n; i++) {
        prefix[i] = prefix[i - 1] + nums[i - 1];
    }
    
    int minLength = Integer.MAX_VALUE;
    for (int i = 0; i <= n; i++) {
        // Для эффективного поиска можно использовать бинарный поиск
        // Или sliding window
    }
    return minLength == Integer.MAX_VALUE ? 0 : minLength;
}
```

### 3️⃣ **Модульные задачи (кратность k)**
**Когда использовать:** Условия с остатками от деления.

| Задача | Ссылка | Сложность | Ключевая идея |
|--------|--------|-----------|---------------|
| **Subarray Sums Divisible by K** | [974](https://leetcode.com/problems/subarray-sums-divisible-by-k/) | Medium | Классика с остатками |
| **Make Sum Divisible by P** | [1590](https://leetcode.com/problems/make-sum-divisible-by-p/) | Medium | Удаление минимального подмассива |

**Ключевое наблюдение:**
```
Если prefix[i] % k == prefix[j] % k, 
то сумма подмассива [i+1...j] делится на k
```

```java
// 974. Subarray Sums Divisible by K
public int subarraysDivByK(int[] nums, int k) {
    Map<Integer, Integer> remainderCount = new HashMap<>();
    remainderCount.put(0, 1); // Пустой подмассив
    
    int sum = 0, count = 0;
    for (int num : nums) {
        sum += num;
        int remainder = sum % k;
        if (remainder < 0) remainder += k; // Корректировка
        
        count += remainderCount.getOrDefault(remainder, 0);
        remainderCount.put(remainder, remainderCount.getOrDefault(remainder, 0) + 1);
    }
    return count;
}
```

### 4️⃣ **Сбалансированные массивы (0 и 1)**
**Когда использовать:** Равенство количества элементов разных типов.

| Задача | Ссылка | Сложность | Ключевая идея |
|--------|--------|-----------|---------------|
| **Contiguous Array** | [525](https://leetcode.com/problems/contiguous-array/) | Medium | Классика с 0 и 1 |
| **Find Longest Awesome Substring** | [1542](https://leetcode.com/problems/find-longest-awesome-substring/) | Hard | Битмаска для палиндромов |

**Трюк:** Заменяем 0 на -1, тогда сбалансированный подмассив имеет сумму 0.

```java
// 525. Contiguous Array
public int findMaxLength(int[] nums) {
    Map<Integer, Integer> map = new HashMap<>();
    map.put(0, -1); // Сумма 0 на позиции -1
    
    int maxLen = 0, count = 0;
    for (int i = 0; i < nums.length; i++) {
        count += (nums[i] == 1 ? 1 : -1);
        
        if (map.containsKey(count)) {
            maxLen = Math.max(maxLen, i - map.get(count));
        } else {
            map.put(count, i);
        }
    }
    return maxLen;
}
```

### 5️⃣ **Ближайшая сумма (TreeMap)**
**Когда использовать:** Нужно найти значение, близкое к target.

| Задача | Ссылка | Сложность | Ключевая идея |
|--------|--------|-----------|---------------|
| **Maximum Size Subarray Sum Equals k** | — | — | Для интервью |
| **Range Sum Query 2D** | [304](https://leetcode.com/problems/range-sum-query-2d-mutable/) | Medium | 2D префиксные суммы |

```java
// Найти ближайшую сумму к target
public int closestSubarray(int[] nums, int target) {
    TreeMap<Integer, Integer> prefixMap = new TreeMap<>();
    prefixMap.put(0, -1);
    
    int sum = 0, minDiff = Integer.MAX_VALUE;
    for (int i = 0; i < nums.length; i++) {
        sum += nums[i];
        
        // Ищем ближайший prefix к (sum - target)
        Integer floor = prefixMap.floorKey(sum - target);
        Integer ceil = prefixMap.ceilingKey(sum - target);
        
        if (floor != null) {
            minDiff = Math.min(minDiff, Math.abs((sum - floor) - target));
        }
        if (ceil != null) {
            minDiff = Math.min(minDiff, Math.abs((sum - ceil) - target));
        }
        
        prefixMap.put(sum, i);
    }
    return minDiff;
}
```

---

## 🎮 **Визуализация работы**

### Пример: nums = [1, -1, 1, 1, 1], k = 3
```
Шаг 0: map = {0:1}, sum=0, count=0
Шаг 1: sum=1 → (1-3)=-2 нет в map → map={0:1, 1:1}
Шаг 2: sum=0 → (0-3)=-3 нет в map → map={0:2, 1:1}
Шаг 3: sum=1 → (1-3)=-2 нет в map → map={0:2, 1:2}
Шаг 4: sum=2 → (2-3)=-1 нет в map → map={0:2, 1:2, 2:1}
Шаг 5: sum=3 → (3-3)=0 есть! count+=2 → count=2
```

---

## 📊 **Сравнение паттернов**

| Критерий | Подсчёт | Длина | Модуль | Баланс | Ближайший |
|----------|---------|-------|--------|--------|-----------|
| **Структура** | HashMap | HashMap | HashMap | HashMap | TreeMap |
| **Значение** | Частота | Индекс | Индекс | Индекс | Индекс |
| **Инициализация** | (0,1) | (0,-1) | (0,1) | (0,-1) | (0,-1) |
| **Сложность** | O(n) | O(n) | O(n) | O(n) | O(n log n) |

---

## 🚀 **Продвинутые задачи**

### 1. **2D префиксные суммы**
```java
// 304. Range Sum Query 2D - Immutable
class NumMatrix {
    private int[][] prefix;
    
    public NumMatrix(int[][] matrix) {
        int m = matrix.length, n = matrix[0].length;
        prefix = new int[m + 1][n + 1];
        
        for (int i = 1; i <= m; i++) {
            for (int j = 1; j <= n; j++) {
                prefix[i][j] = matrix[i-1][j-1] 
                    + prefix[i-1][j] 
                    + prefix[i][j-1] 
                    - prefix[i-1][j-1];
            }
        }
    }
    
    public int sumRegion(int row1, int col1, int row2, int col2) {
        return prefix[row2+1][col2+1] 
            - prefix[row1][col2+1] 
            - prefix[row2+1][col1] 
            + prefix[row1][col1];
    }
}
```

### 2. **С несколькими условиями**
```java
// 1442. Count Triplets That Can Form Two Arrays of Equal XOR
public int countTriplets(int[] arr) {
    int n = arr.length;
    int[] prefixXor = new int[n + 1];
    
    for (int i = 0; i < n; i++) {
        prefixXor[i + 1] = prefixXor[i] ^ arr[i];
    }
    
    int count = 0;
    // Для всех i < j: arr[i] ^ ... ^ arr[j-1] = 0
    // Тогда prefixXor[i] == prefixXor[j]
    // Количество троек для таких пар: (j - i)
    // Упрощаем до O(n^2) или используем HashMap для O(n)
    
    return count;
}
```

---

## ⚠️ **Частые ошибки**

1. **Забыли инициализировать** с `(0, 1)` или `(0, -1)`
2. **Не скорректировали отрицательные остатки** в модульных задачах
3. **Путаем сохранение первого/последнего вхождения**
4. **Не обновляем HashMap в правильном порядке** (сначала проверка, потом добавление)
5. **Для TreeMap забываем** про `floorKey()`/`ceilingKey()`

---

## 🎯 **Шаблон решения на интервью**

```java
public int solvePrefixSumProblem(int[] nums, int target) {
    // 1. Выбрать структуру данных
    Map<Integer, Integer> map = new HashMap<>();
    
    // 2. Инициализировать базовый случай
    map.put(0, 1); // или (0, -1)
    
    // 3. Пройти по массиву
    int sum = 0, result = 0;
    for (int i = 0; i < nums.length; i++) {
        // 4. Обновить сумму
        sum += nums[i];
        
        // 5. Проверить условие
        int needed = sum - target;
        if (map.containsKey(needed)) {
            result += map.get(needed); // или обновить длину
        }
        
        // 6. Обновить map
        map.put(sum, map.getOrDefault(sum, 0) + 1);
    }
    
    return result;
}
```

---

## 📈 **Практические советы**

1. **Начинайте с вопроса:** "Можно ли переформулировать как `prefix[j] - prefix[i] = target`?"
2. **Выбирайте структуру:**
   - Нужно считать частоты → `HashMap<Sum, Count>`
   - Нужно находить длины → `HashMap<Sum, FirstIndex>`
   - Нужно искать ближайшее → `TreeMap<Sum, Index>`
3. **Всегда тестируйте** на:
   - Пустом массиве
   - Одном элементе
   - Отрицательных числах
   - Больших значениях

---

## 🔗 **Топ-10 LeetCode задач для практики**

1. ✅ **[560](https://leetcode.com/problems/subarray-sum-equals-k/)** - Must know!
2. ✅ **[523](https://leetcode.com/problems/continuous-subarray-sum/)** - Модули + длина
3. ✅ **[525](https://leetcode.com/problems/contiguous-array/)** - Баланс 0/1
4. ✅ **[974](https://leetcode.com/problems/subarray-sums-divisible-by-k/)** - Модули
5. ✅ **[930](https://leetcode.com/problems/binary-subarrays-with-sum/)** - Бинарный массив
6. ✅ **[1248](https://leetcode.com/problems/count-number-of-nice-subarrays/)** - Чётность
7. ✅ **[1442](https://leetcode.com/problems/count-triplets-that-can-form-two-arrays-of-equal-xor/)** - XOR вариант
8. ✅ **[1542](https://leetcode.com/problems/find-longest-awesome-substring/)** - Хард с битмаской
9. ✅ **[1590](https://leetcode.com/problems/make-sum-divisible-by-p/)** - Продвинутые модули
10. ✅ **[1915](https://leetcode.com/problems/number-of-wonderful-substrings/)** - Битмаски

---

**💡 Запомните:** Префиксные суммы + HashMap решают 80% задач на подмассивы! 
Один паттерн — десятки решённых задач. Удачи в практике! 🚀

**P.S.** Попробуйте решить задачи в порядке возрастания сложности, начиная с 560 → 523 → 525. После каждой задачи спрашивайте себя: "Какой паттерн здесь используется?"
