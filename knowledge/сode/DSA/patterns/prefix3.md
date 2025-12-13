# 📊 **Паттерны Prefix Sum + HashMap**

## 🎯 **Паттерн 1: ПОДСЧЕТ подмассивов**
```java
// Когда: "count", "number of"
public int countSubarrays(int[] nums, int k) {
    Map<Integer, Integer> freq = new HashMap<>();
    freq.put(0, 1);  // 🎯 Базовый случай
    
    int count = 0, prefix = 0;
    for (int num : nums) {
        prefix += num;
        count += freq.getOrDefault(prefix - k, 0);  // 🔍 Что ищем
        freq.put(prefix, freq.getOrDefault(prefix, 0) + 1);  // 📝 Храним частоту
    }
    return count;
}
```

### **По остатку:**
```java
public int countSubarraysDivisible(int[] nums, int k) {
    Map<Integer, Integer> modFreq = new HashMap<>();
    modFreq.put(0, 1);
    
    int count = 0, sum = 0;
    for (int num : nums) {
        sum += num;
        int rem = sum % k;
        if (rem < 0) rem += k;  // 📌 Корректировка
        
        count += modFreq.getOrDefault(rem, 0);
        modFreq.put(rem, modFreq.getOrDefault(rem, 0) + 1);
    }
    return count;
}
```

---

## 🎯 **Паттерн 2: МАКСИМАЛЬНАЯ длина**
```java
// Когда: "max length", "longest"
public int maxLengthSubarray(int[] nums, int k) {
    Map<Integer, Integer> firstSeen = new HashMap<>();
    firstSeen.put(0, -1);  // 🎯 Базовый случай
    
    int maxLen = 0, prefix = 0;
    for (int i = 0; i < nums.length; i++) {
        prefix += nums[i];
        if (firstSeen.containsKey(prefix - k)) {
            maxLen = Math.max(maxLen, i - firstSeen.get(prefix - k));
        }
        firstSeen.putIfAbsent(prefix, i);  // 📝 Только первый индекс!
    }
    return maxLen;
}
```

### **По остатку (макс. длина):**
```java
public int maxLengthDivisible(int[] nums, int k) {
    Map<Integer, Integer> firstRem = new HashMap<>();
    firstRem.put(0, -1);
    
    int maxLen = 0, sum = 0;
    for (int i = 0; i < nums.length; i++) {
        sum += nums[i];
        int rem = sum % k;
        if (rem < 0) rem += k;
        
        if (firstRem.containsKey(rem)) {
            maxLen = Math.max(maxLen, i - firstRem.get(rem));
        }
        firstRem.putIfAbsent(rem, i);
    }
    return maxLen;
}
```

---

## 🎯 **Паттерн 3: ПРОВЕРКА существования**
```java
// Когда: "check if", "exists"
public boolean existsSubarray(int[] nums, int k, int minLength) {
    Map<Integer, Integer> lastSeen = new HashMap<>();
    lastSeen.put(0, -1);
    
    int prefix = 0;
    for (int i = 0; i < nums.length; i++) {
        prefix += nums[i];
        if (lastSeen.containsKey(prefix - k)) {
            if (i - lastSeen.get(prefix - k) >= minLength) {
                return true;  // 🎯 Ранний выход
            }
        }
        lastSeen.put(prefix, i);  // 📝 Последний индекс
    }
    return false;
}
```

### **По остатку (проверка):**
```java
public boolean existsSubarrayDivisible(int[] nums, int k, int minLength) {
    Map<Integer, Integer> lastRem = new HashMap<>();
    lastRem.put(0, -1);
    
    int sum = 0;
    for (int i = 0; i < nums.length; i++) {
        sum += nums[i];
        int rem = sum % k;
        if (rem < 0) rem += k;
        
        if (lastRem.containsKey(rem)) {
            if (i - lastRem.get(rem) >= minLength) {
                return true;
            }
        } else {
            lastRem.put(rem, i);  // Только первое вхождение
        }
    }
    return false;
}
```

---

## 📌 **Сводная таблица:**

| Паттерн | Инициализация | Храним в Map | Обновление | Примеры |
|---------|---------------|--------------|------------|---------|
| **Подсчет** | `map.put(0, 1)` | Частоту | `put(key, freq+1)` | 560, 974 |
| **Макс. длина** | `map.put(0, -1)` | Первый индекс | `putIfAbsent(key, i)` | 325, 525 |
| **Проверка** | `map.put(0, -1)` | Последний индекс | `put(key, i)` | 523 |

---

## 🎯 **Работа с остатками (общий шаблон):**

```java
// Общий шаблон для остатков:
public int solveWithRemainder(int[] nums, int k) {
    Map<Integer, Integer> map = new HashMap<>();
    map.put(0, INIT_VALUE);  // 1 или -1
    
    int result = 0, sum = 0;
    for (int i = 0; i < nums.length; i++) {
        sum += nums[i];
        int rem = sum % k;
        
        // 📌 Обязательная корректировка:
        if (rem < 0) rem += k;
        
        // 🔍 Что ищем (зависит от задачи):
        int targetRem = rem;  // или (rem - target + k) % k
        
        if (map.containsKey(targetRem)) {
            // Подсчет или длина
        }
        
        // 📝 Как сохраняем:
        // Для подсчета: map.put(rem, freq+1)
        // Для макс. длины: map.putIfAbsent(rem, i)
        // Для проверки: map.put(rem, i)
    }
    return result;
}
```

---

## 🔧 **Быстрые преобразования:**

### **1. 0 и 1 → баланс:**
```java
// Для задач с 0 и 1
balance += (num == 1) ? 1 : -1;
// Баланс = 0 → равное количество
```

### **2. Четное/нечетное:**
```java
// Для равного количества четных/нечетных
balance += (num % 2 == 0) ? 1 : -1;
```

### **3. Целевой остаток ≠ 0:**
```java
// Если нужно sum % k = r (не 0)
int targetRem = (rem - r + k) % k;
// Ищем targetRem в map
```

---

## ⚡ **Оптимизации:**

```java
// 1. Для положительных чисел:
if (k < 0 && allPositive) return 0;

// 2. Ранний выход для проверки:
if (found) return true;

// 3. Для макс. длины:
if (maxLen == nums.length) return maxLen;

// 4. Использование массива вместо HashMap:
// Если остатки в диапазоне [0, k-1] и k маленькое
int[] remIndex = new int[k];
Arrays.fill(remIndex, -2);  // -2 = не встречалось
remIndex[0] = -1;
```

---

## ✅ **Быстрая диагностика:**

1. **"Count..."** → Паттерн 1 → `freq.put(0, 1)`
2. **"Max length..."** → Паттерн 2 → `first.put(0, -1)` + `putIfAbsent`
3. **"Check if..."** → Паттерн 3 → `last.put(0, -1)` + `put`
4. **Есть % или "divisible"** → работаем с остатками + корректировка отрицательных
