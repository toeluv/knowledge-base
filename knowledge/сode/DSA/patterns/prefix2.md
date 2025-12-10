# Префиксные суммы и HashMap: краткий обзор
**Основная концепция**  
Префиксные суммы — это техника для эффективного вычисления суммы подмассивов, позволяющая избежать повторных вычислений.

**Ключевая формула:**
```
prefixSum[j] − prefixSum[i] = target
```
Перегруппируем:
```
prefixSum[i] = prefixSum[j] − target
```
Используя HashMap, мы храним ранее встреченные префиксные суммы и их индексы, что позволяет эффективно находить подмассивы.

---

## 🔹 Паттерны задач и использование HashMap

| Паттерн                     | Тип задачи                                          | Ключевая идея HashMap                                     | Ключ HashMap            | Значение HashMap           |
|-----------------------------|----------------------------------------------------|----------------------------------------------------------|-------------------------|----------------------------|
| **Точное совпадение суммы** | Найти кратчайший подмассив с суммой = target       | Проверка наличия `prefixSum[j] - target`                 | Значения префиксных сумм | Индекс первого вхождения   |
| **Количество подмассивов**  | Посчитать подмассивы с суммой = target             | Подсчёт частот `prefixSum[j] - target`                   | Значения префиксных сумм | Частота каждой суммы       |
| **Модульное условие**       | Найти подмассив с суммой % k == 0                  | Проверка остатков `prefixSum[j] % k`                     | Остаток от деления на k  | Индекс первого вхождения   |
| **Сбалансированная сумма**  | Подмассив с равным количеством 0 и 1 (0 → -1)      | Работа с преобразованными префиксными суммами            | Значения префиксных сумм | Индекс первого вхождения   |
| **Ближайшая сумма**         | Подмассив с суммой, наиболее близкой к target      | Использование TreeMap для поиска ближайшего ключа        | Значения префиксных сумм | Индекс первого вхождения   |

---

## 🔹 Примеры задач и решения

### 1. Кратчайший подмассив с суммой = target
```java
public int shortestSubarray(int[] nums, int target) {
    int shortest = Integer.MAX_VALUE, sum = 0;
    Map<Integer, Integer> map = new HashMap<>();
    map.put(0, -1); // База: пустой подмассив
    
    for (int j = 0; j < nums.length; j++) {
        sum += nums[j];
        if (map.containsKey(sum - target)) {
            shortest = Math.min(shortest, j - map.get(sum - target));
        }
        // Сохраняем только первое вхождение для кратчайшего подмассива
        map.putIfAbsent(sum, j);
    }
    return shortest == Integer.MAX_VALUE ? -1 : shortest;
}
```

### 2. Длиннейший подмассив с суммой = target
```java
public int longestSubarray(int[] nums, int target) {
    int longest = 0, sum = 0;
    Map<Integer, Integer> map = new HashMap<>();
    map.put(0, -1);
    
    for (int j = 0; j < nums.length; j++) {
        sum += nums[j];
        if (map.containsKey(sum - target)) {
            longest = Math.max(longest, j - map.get(sum - target));
        }
        // Сохраняем только первое вхождение
        map.putIfAbsent(sum, j);
    }
    return longest;
}
```

### 3. Количество подмассивов с суммой = target
```java
public int countSubarray(int[] nums, int target) {
    int count = 0, sum = 0;
    Map<Integer, Integer> map = new HashMap<>();
    map.put(0, 1);
    
    for (int j = 0; j < nums.length; j++) {
        sum += nums[j];
        count += map.getOrDefault(sum - target, 0);
        map.put(sum, map.getOrDefault(sum, 0) + 1);
    }
    return count;
}
```

### 4. Подмассив с суммой, ближайшей к target (TreeMap)
```java
public int closestSubarray(int[] nums, int target) {
    int closestDiff = Integer.MAX_VALUE, sum = 0;
    TreeMap<Integer, Integer> map = new TreeMap<>();
    map.put(0, -1);
    
    for (int j = 0; j < nums.length; j++) {
        sum += nums[j];
        // Ближайший ключ к (sum - target)
        Integer floor = map.floorKey(sum - target);
        Integer ceil = map.ceilingKey(sum - target);
        
        if (floor != null) {
            closestDiff = Math.min(closestDiff, Math.abs(sum - floor - target));
        }
        if (ceil != null) {
            closestDiff = Math.min(closestDiff, Math.abs(sum - ceil - target));
        }
        map.put(sum, j);
    }
    return closestDiff;
}
```

### 5. Длиннейший подмассив с суммой, кратной k
```java
public int longestSubarrayDivK(int[] nums, int k) {
    int longest = 0, sum = 0;
    Map<Integer, Integer> map = new HashMap<>();
    map.put(0, -1);
    
    for (int j = 0; j < nums.length; j++) {
        sum += nums[j];
        int remainder = sum % k;
        if (remainder < 0) remainder += k; // Корректировка для отрицательных чисел
        
        if (map.containsKey(remainder)) {
            longest = Math.max(longest, j - map.get(remainder));
        } else {
            map.put(remainder, j);
        }
    }
    return longest;
}
```

### 6. Сбалансированный подмассив (равное количество 0 и 1)
```java
public int findMaxLength(int[] nums) {
    int maxLength = 0, prefixSum = 0;
    Map<Integer, Integer> map = new HashMap<>();
    map.put(0, -1);
    
    for (int i = 0; i < nums.length; i++) {
        // Преобразуем: 0 → -1, 1 → 1
        prefixSum += (nums[i] == 1) ? 1 : -1;
        
        if (map.containsKey(prefixSum)) {
            maxLength = Math.max(maxLength, i - map.get(prefixSum));
        } else {
            map.put(prefixSum, i);
        }
    }
    return maxLength;
}
```

---

## 🔹 Ключевые различия и частые ошибки

| Тип задачи               | Метод поиска                          | Используемая структура      | Особенности                          |
|--------------------------|---------------------------------------|-----------------------------|--------------------------------------|
| Точное совпадение        | `prefixSum[j] - target == prefixSum[i]` | HashMap (индекс)            | Сохраняем первое вхождение          |
| Подсчёт частот           | `count += map.get(prefixSum[j] - target)` | HashMap (частота)           | Учитываем все вхождения             |
| Ближайшее значение       | `floorKey()` и `ceilingKey()`         | TreeMap                     | Работа с упорядоченными ключами      |
| Модульные условия        | `prefixSum[j] % k == prefixSum[i] % k` | HashMap (остаток → индекс)  | Корректировка отрицательных остатков |

**Важные моменты:**
- Всегда инициализируйте HashMap с `(0, -1)` или `(0, 1)`
- Для кратчайшего подмассива — `putIfAbsent()`
- Для подсчёта — увеличиваем частоту
- При работе с остатками корректируем отрицательные значения

---

## 🔹 Практическое применение в AI/ML
- **Прогнозирование временных рядов** — обнаружение аномалий в логах
- **Анализ последовательностей в NLP** — поиск паттернов в тексте
- **Обнаружение мошенничества** — выявление аномальных финансовых операций

**Владение техникой префиксных сумм + HashMap критически важно для эффективного решения широкого класса задач на подмассивы! 🚀**
