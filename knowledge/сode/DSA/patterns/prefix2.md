# Префиксные суммы и HashMap: мастер-класс по технике подмассивов

**Префиксные суммы** — мощная техника оптимизации, превращающая O(n²) в O(n) для задач о подмассивах. В сочетании с HashMap она становится универсальным инструментом решения сложных проблем.

## 📊 Основная концепция

**Префиксная сумма** — массив, где `prefix[i]` содержит сумму первых `i` элементов:
```java
prefix[i] = nums[0] + nums[1] + ... + nums[i-1]
```

**Ключевое наблюдение**: сумма подмассива `[i, j]`:
```
sum(i, j) = prefix[j+1] - prefix[i]
```

Это позволяет вычислять сумму любого подмассива за O(1), если предварительно посчитать префиксные суммы.

## 🔥 Фундаментальная идея

Для задачи **"найти подмассив с суммой = K"**:

```
prefix[j] - prefix[i] = K
prefix[i] = prefix[j] - K
```

Мы ищем в истории такую префиксную сумму `prefix[i]`, которая равна `prefix[j] - K`.

**HashMap здесь выступает как мгновенный поисковик в истории** — вместо линейного перебора предыдущих индексов (O(n²)), мы получаем O(1).

---

## 🎯 Паттерны задач и решения

### 1️⃣ **Точное совпадение суммы**

**Задача**: Найти кратчайший подмассив с суммой = target

```java
public int shortestSubarray(int[] nums, int target) {
    Map<Integer, Integer> prefixMap = new HashMap<>();
    prefixMap.put(0, -1); // Пустой подмассив (важная инициализация!)
    
    int sum = 0, minLength = Integer.MAX_VALUE;
    
    for (int j = 0; j < nums.length; j++) {
        sum += nums[j]; // Текущая префиксная сумма
        
        // Ищем в истории: sum - previous = target
        if (prefixMap.containsKey(sum - target)) {
            int i = prefixMap.get(sum - target);
            minLength = Math.min(minLength, j - i);
        }
        
        // Сохраняем только первое вхождение (для кратчайшего)
        prefixMap.putIfAbsent(sum, j);
    }
    
    return minLength == Integer.MAX_VALUE ? -1 : minLength;
}
```

📝 **Когда использовать**: 
- Все числа положительные
- Нужно найти подмассив РОВНО с заданной суммой
- Пример: `[1, 2, 3, 4], target = 6` → `[2, 4]` длина 2

---

### 2️⃣ **Подсчёт количества подмассивов**

**Задача**: Сколько подмассивов имеют сумму = target?

```java
public int countSubarrays(int[] nums, int target) {
    Map<Integer, Integer> freqMap = new HashMap<>();
    freqMap.put(0, 1); // Пустой подмассив уже существует
    
    int sum = 0, count = 0;
    
    for (int num : nums) {
        sum += num;
        
        // Каждое предыдущее вхождение даёт новый подмассив
        count += freqMap.getOrDefault(sum - target, 0);
        
        // Увеличиваем частоту текущей суммы
        freqMap.put(sum, freqMap.getOrDefault(sum, 0) + 1);
    }
    
    return count;
}
```

📝 **Пример**: `[1, 1, 1], target = 2`
- `sum=1` → нет 1-2=-1
- `sum=2` → есть 2-2=0 (count=1) → `[1, 1]`
- `sum=3` → есть 3-2=1 (count=2) → `[1, 1]` (индексы 1-2)

---

### 3️⃣ **Подмассивы по модулю**

**Задача**: Найти подмассив с суммой, кратной K

```java
public int longestSubarrayDivisibleByK(int[] nums, int K) {
    Map<Integer, Integer> modMap = new HashMap<>();
    modMap.put(0, -1); // Сумма 0 делится на любое K
    
    int sum = 0, maxLength = 0;
    
    for (int j = 0; j < nums.length; j++) {
        sum += nums[j];
        int remainder = sum % K;
        
        // Корректируем отрицательные остатки
        if (remainder < 0) remainder += K;
        
        if (modMap.containsKey(remainder)) {
            // Две суммы с одинаковым остатком → их разность делится на K
            maxLength = Math.max(maxLength, j - modMap.get(remainder));
        } else {
            modMap.put(remainder, j);
        }
    }
    
    return maxLength;
}
```

📝 **Логика**: Если `prefix[j] % K == prefix[i] % K`, то `(prefix[j] - prefix[i]) % K == 0`

---

### 4️⃣ **Сбалансированные последовательности**

**Задача**: Найти максимальную длину подмассива с равным количеством 0 и 1

```java
public int findMaxLength(int[] nums) {
    // Преобразуем: 0 → -1, 1 → 1
    Map<Integer, Integer> balanceMap = new HashMap<>();
    balanceMap.put(0, -1);
    
    int balance = 0, maxLength = 0;
    
    for (int i = 0; i < nums.length; i++) {
        balance += (nums[i] == 1) ? 1 : -1;
        
        if (balanceMap.containsKey(balance)) {
            // Если баланс повторился, между этими индексами 0 и 1 поровну
            maxLength = Math.max(maxLength, i - balanceMap.get(balance));
        } else {
            balanceMap.put(balance, i);
        }
    }
    
    return maxLength;
}
```

📝 **Пример**: `[0, 1, 0, 0, 1, 1, 0]`
Преобразуем: `[-1, 1, -1, -1, 1, 1, -1]`
Баланс = 0 на индексах 0 и 6 → длина = 6

---

## ⚠️ **Критические ошибки и как их избежать**

### ❌ Ошибка 1: Пропуск инициализации
```java
// НЕПРАВИЛЬНО:
Map<Integer, Integer> map = new HashMap<>();
// Пропущен put(0, -1) или put(0, 1)

// ПРАВИЛЬНО:
map.put(0, -1); // Для задач на длину
// ИЛИ
map.put(0, 1);  // Для задач на подсчёт
```

**Почему**: Пустой подмассив (сумма=0) всегда существует!

### ❌ Ошибка 2: Перезапись индексов в задачах на максимальную длину
```java
// Для МАКСИМАЛЬНОЙ длины:
map.putIfAbsent(sum, i);  // Сохраняем первый индекс

// Для МИНИМАЛЬНОЙ длины:
map.put(sum, i);  // Обновляем на последний индекс
```

### ❌ Ошибка 3: Игнорирование отрицательных чисел
```java
// Для задач с отрицательными числами:
int[] nums = {1, -1, 1, -1};
// HashMap работает корректно
// TreeMap для "ближайшей суммы"
```

---

## 🎪 Сравнение структур данных

| Структура | Когда использовать | Пример задачи |
|-----------|-------------------|---------------|
| **HashMap** | Точное совпадение, подсчёт | Найти подмассив суммой = K |
| **TreeMap** | Ближайшее значение, диапазоны | Найти подмассив суммой ≥ K |
| **Monotonic Queue** | Sliding window максимум/минимум | Ограниченная длина |

---

## 🔬 **Продвинутые техники**

### Комбинирование условий
```java
// Найти подмассив с суммой между A и B
public int countSubarraysInRange(int[] nums, int A, int B) {
    TreeMap<Integer, Integer> map = new TreeMap<>();
    map.put(0, 1);
    
    int sum = 0, count = 0;
    
    for (int num : nums) {
        sum += num;
        
        // sum - prev ≥ A → prev ≤ sum - A
        // sum - prev ≤ B → prev ≥ sum - B
        Map<Integer, Integer> subMap = map.subMap(sum - B, true, sum - A, true);
        
        for (int freq : subMap.values()) {
            count += freq;
        }
        
        map.put(sum, map.getOrDefault(sum, 0) + 1);
    }
    
    return count;
}
```

---

## 📈 **Практическое применение**

### В аналитике данных:
```java
// Найти период с максимальным ростом продаж
public int[] bestSalesPeriod(int[] dailySales, int targetGrowth) {
    // Используем префиксные суммы для скользящего среднего
    // Ищем подпериод с ростом ≥ targetGrowth
}
```

### В обработке сигналов:
```java
// Обнаружение аномалий в временных рядах
public List<Integer> detectAnomalies(int[] sensorData, int threshold) {
    // Ищем подпоследовательности с суммой превышающей нормальный диапазон
}
```

### В финансовых алгоритмах:
```java
// Найти максимальную прибыль в исторических данных
public int maxProfit(int[] prices) {
    // Разность цен → префиксные суммы → задача о максимальной сумме подмассива
}
```

---

## 🧠 **Алгоритмический чеклист**

1. **Определите тип задачи**:
   - Точное совпадение → `map.containsKey(sum - target)`
   - Подсчёт → `count += map.getOrDefault(sum - target, 0)`
   - Максимальная длина → `putIfAbsent()`
   - Минимальная длина → `put()` (обновлять)

2. **Инициализируйте правильно**:
   - `map.put(0, -1)` для индексов
   - `map.put(0, 1)` для подсчёта

3. **Учитывайте отрицательные числа**:
   - HashMap работает для любых чисел
   - Для "сумма ≥ K" нужна монотонная очередь

4. **Тестируйте краевые случаи**:
   - Пустой массив
   - Отрицательный target
   - Все числа одинаковые

---

## 🚀 **Быстрый старт: шаблон для 80% задач**

```java
public int solveSubarrayProblem(int[] nums, int target) {
    // Шаг 1: Выбери структуру
    Map<Integer, Integer> map = new HashMap<>();
    
    // Шаг 2: Правильная инициализация
    map.put(0, -1); // или map.put(0, 1) для подсчёта
    
    // Шаг 3: Основной цикл
    int sum = 0, result = 0; // или min/max значение
    
    for (int j = 0; j < nums.length; j++) {
        sum += nums[j];
        
        // Шаг 4: Логика поиска
        if (map.containsKey(sum - target)) {
            // Обновление результата
            result = Math.max(result, j - map.get(sum - target));
        }
        
        // Шаг 5: Сохранение в map
        map.putIfAbsent(sum, j); // для max длины
        // map.put(sum, j); // для min длины
        // map.put(sum, map.getOrDefault(sum, 0) + 1); // для подсчёта
    }
    
    return result;
}
```

---

## 💡 **Золотые правила**

1. **Префиксные суммы + HashMap** решает большинство задач о подмассивах за O(n)
2. **Всегда инициализируй с (0, -1/1)** — не забывай про пустой подмассив
3. **Для отрицательных чисел и "сумма ≥ K"** нужны более сложные структуры
4. **Практикуй разные вариации** — точное значение, диапазон, модуль

**Эта техника — фундамент для задач на подмассивы. Освой её — и 30% алгоритмических задач станут для тебя тривиальными!** 🎯
