# Монотонный стек на Java: ПОЛНАЯ выжимка

## 📌 Базовый шаблон (ищем первый больший элемент справа)

```java
public int[] nextGreaterElement(int[] nums) {
    int n = nums.length;
    int[] result = new int[n];
    Arrays.fill(result, -1); // значение по умолчанию
    Deque<Integer> stack = new ArrayDeque<>(); // храним индексы!
    
    for (int i = 0; i < n; i++) {
        // 🔥 КРИТИЧЕСКИЙ МОМЕНТ: ПОЧЕМУ while с pop()?
        while (!stack.isEmpty() && nums[i] > nums[stack.peek()]) {
            int prevIdx = stack.pop();  // ⬅️ ВЫТАСКИВАЕМ индекс
            result[prevIdx] = nums[i];  // ⬅️ НАШЛИ решение для prevIdx!
        }
        stack.push(i); // Текущий элемент ждёт своего решения
    }
    return result;
}
```

## 🎯 ПОЧЕМУ while с stack.pop()? (ГЛАВНОЕ ПРАВИЛО)

### **Философия**: "Один решает — многие получают решение"

```java
// Когда текущий элемент nums[i] БОЛЬШЕ вершины стека:
// 1. Для вершины стека (stack.peek()) — nums[i] это ПЕРВЫЙ БОЛЬШИЙ справа!
// 2. Но это же верно и для ВСЕХ в стеке, потому что стек МОНОТОННЫЙ!
// 3. Поэтому ПОКА условие выполняется — ВЫТАСКИВАЕМ и РЕШАЕМ!

// Пример: nums = [3, 2, 1, 4]
// Стек после обработки 3,2,1: [0,1,2] (значения [3,2,1]) ← УБЫВАЮЩИЙ!
// Приходит nums[3]=4:
// 4 > 1? ДА! → pop(2), result[2]=4
// 4 > 2? ДА! → pop(1), result[1]=4  
// 4 > 3? ДА! → pop(0), result[0]=4
// ОДНА цифра 4 решила задачу для ТРЁХ предыдущих!
```

### **Визуализация**:
```
ДО:   Стек: [3, 2, 1]  ← все ждут кого-то больше себя
ТЕКУЩИЙ: 4
ПРОЦЕСС:
  Шаг 1: 4 > 1 ✓ → 1 находит решение: 4
  Шаг 2: 4 > 2 ✓ → 2 находит решение: 4  
  Шаг 3: 4 > 3 ✓ → 3 находит решение: 4
ПОСЛЕ: Стек: [4] ← теперь 4 ждёт кого-то больше себя
```

## 📊 Типы монотонных стеков и их условия

| Что ищем | Тип стека | Условие в while | Направление | Пример |
|----------|-----------|----------------|-------------|--------|
| **Первый БОЛЬШИЙ** справа | Убывающий | `current > stack.peek()` | Слева→Направо | `[3,2,1] → 4` |
| **Первый МЕНЬШИЙ** справа | Возрастающий | `current < stack.peek()` | Слева→Направо | `[1,2,3] → 0` |
| **Первый БОЛЬШИЙ** слева | Убывающий | `current > stack.peek()` | Справа→Налево | |
| **Первый МЕНЬШИЙ** слева | Возрастающий | `current < stack.peek()` | Справа→Налево | |

## 🎪 3 ОСНОВНЫХ ШАБЛОНА (запомнить!)

### 1. Шаблон для расстояний (Daily Temperatures)
```java
public int[] dailyTemperatures(int[] temps) {
    int n = temps.length;
    int[] result = new int[n];
    Deque<Integer> stack = new ArrayDeque<>();
    
    for (int i = 0; i < n; i++) {
        // 🔥 ПОКА текущий теплее вершины
        while (!stack.isEmpty() && temps[i] > temps[stack.peek()]) {
            int prevDay = stack.pop();     // ⬅️ день, который получил ответ
            result[prevDay] = i - prevDay; // ⬅️ расстояние в днях
        }
        stack.push(i); // текущий день ждёт своего тёплого дня
    }
    // Оставшиеся в стеке: дней теплее нет → result уже 0
    return result;
}
```

### 2. Шаблон с часовым (Largest Rectangle)
```java
public int largestRectangleArea(int[] heights) {
    // Добавляем нули по краям для обработки границ
    int[] newHeights = new int[heights.length + 2];
    System.arraycopy(heights, 0, newHeights, 1, heights.length);
    
    Deque<Integer> stack = new ArrayDeque<>();
    int maxArea = 0;
    
    for (int i = 0; i < newHeights.length; i++) {
        // 🔥 ПОКА текущий МЕНЬШЕ вершины (ищем ПЕРВЫЙ МЕНЬШИЙ справа)
        while (!stack.isEmpty() && newHeights[i] < newHeights[stack.peek()]) {
            int height = newHeights[stack.pop()]; // высота столбца
            // Ширина = от предыдущего меньшего до текущего меньшего
            int left = stack.peek(); // предыдущий меньший (индекс)
            int width = i - left - 1;
            maxArea = Math.max(maxArea, height * width);
        }
        stack.push(i);
    }
    return maxArea;
}
```

### 3. Шаблон для сумм минимумов (Sum of Subarray Minimums)
```java
public int sumSubarrayMins(int[] arr) {
    int n = arr.length;
    int MOD = 1_000_000_007;
    
    // left[i] = сколько элементов слева >= arr[i] (включая сам arr[i])
    // right[i] = сколько элементов справа > arr[i] (включая сам arr[i])
    int[] left = new int[n], right = new int[n];
    Deque<Integer> stack = new ArrayDeque<>();
    
    // Слева направо: ищем ПРЕДЫДУЩИЙ МЕНЬШИЙ
    for (int i = 0; i < n; i++) {
        // 🔥 Удаляем ВСЕ, что БОЛЬШЕ текущего
        while (!stack.isEmpty() && arr[stack.peek()] > arr[i]) {
            stack.pop();
        }
        left[i] = stack.isEmpty() ? i + 1 : i - stack.peek();
        stack.push(i);
    }
    
    stack.clear();
    
    // Справа налево: ищем СЛЕДУЮЩИЙ МЕНЬШИЙ ИЛИ РАВНЫЙ
    for (int i = n - 1; i >= 0; i--) {
        // 🔥 Удаляем ВСЕ, что БОЛЬШЕ ИЛИ РАВНО текущему
        while (!stack.isEmpty() && arr[stack.peek()] >= arr[i]) {
            stack.pop();
        }
        right[i] = stack.isEmpty() ? n - i : stack.peek() - i;
        stack.push(i);
    }
    
    long result = 0;
    for (int i = 0; i < n; i++) {
        result = (result + (long) arr[i] * left[i] * right[i]) % MOD;
    }
    return (int) result;
}
```

## 🚨 КРИТИЧЕСКИЕ МОМЕНТЫ (чтоб не забыть!)

### 1. **ЧТО ХРАНИМ В СТЕКЕ?**
```java
// ВАРИАНТ 1: Индексы (90% случаев!)
Deque<Integer> stack = new ArrayDeque<>(); // ← ЛУЧШИЙ ВЫБОР
while (!stack.isEmpty() && arr[i] > arr[stack.peek()]) { ... }

// ВАРИАНТ 2: Значения (редко)
Deque<Integer> stack = new ArrayDeque<>();
while (!stack.isEmpty() && arr[i] > stack.peek()) { ... }
```

### 2. **> или >= или < ?**
```java
// Для "ПЕРВОГО БОЛЬШЕГО (строго)": >
while (!stack.isEmpty() && arr[i] > arr[stack.peek()])

// Для "ПЕРВОГО БОЛЬШЕГО ИЛИ РАВНОГО": >=  
while (!stack.isEmpty() && arr[i] >= arr[stack.peek()])

// Для "ПЕРВОГО МЕНЬШЕГО (строго)": <
while (!stack.isEmpty() && arr[i] < arr[stack.peek()])

// Для "ПЕРВОГО МЕНЬШЕГО ИЛИ РАВНОГО": <=
while (!stack.isEmpty() && arr[i] <= arr[stack.peek()])
```

### 3. **НАПРАВЛЕНИЕ ОБХОДА**
```java
// Ищем элементы СПРАВА от текущего → обычный обход
for (int i = 0; i < n; i++)

// Ищем элементы СЛЕВА от текущего → обратный обход  
for (int i = n - 1; i >= 0; i--)

// Нужно и СЛЕВА и СПРАВА → два прохода (как в sumSubarrayMins)
```

### 4. **ЧАСОВОЙ ЭЛЕМЕНТ (СЕНТИНЕЛ)**
```java
// Проблема: элементы остаются в стеке без решения
// Решение: добавить минимальное/максимальное значение в конец

// Пример для Largest Rectangle:
int[] newHeights = new int[heights.length + 2];
newHeights[0] = 0; // часовой слева
System.arraycopy(heights, 0, newHeights, 1, heights.length);
newHeights[newHeights.length - 1] = 0; // часовой справа
```

## 🧠 МНЕМОНИКА ДЛЯ ЗАПОМИНАНИЯ

### **"СТЕК-ОЖИДАНИЕ"**:
1. **Каждый в стеке → ждёт своего "спасителя"** (большего/меньшего)
2. **Новый элемент → проверяет: "Могу ли я кого-то спасти?"**
3. **Если ДА → спасаю ВСЕХ, кого могу (while + pop)**
4. **После → сам становлюсь "ожидающим" (push)**

### **"БОЛЬШОЙ БРАТ"**:
```java
// Представьте старшеклассников (стек) и новичка (текущий элемент)
int[] grades = [90, 80, 70, 95]; // оценки

// Новичок с оценкой 95 приходит:
// - Смотрит на последнего в очереди (70): "Я лучше тебя!" → помогает
// - Смотрит на следующего (80): "Я лучше тебя!" → помогает  
// - Смотрит на следующего (90): "Я лучше тебя!" → помогает
// Теперь сам стоит в очереди (95), ждёт кого-то лучше себя
```

## 📝 ЧЕК-ЛИСТ ПРИ РЕШЕНИИ

1. **Определить что ищем**:
   - [ ] Первый больший справа?
   - [ ] Первый меньший справа?
   - [ ] Первый больший слева?
   - [ ] Первый меньший слева?

2. **Выбрать тип стека**:
   - [ ] Убывающий (для поиска большего)
   - [ ] Возрастающий (для поиска меньшего)

3. **Выбрать что хранить**:
   - [ ] Индексы (если нужно расстояние/ширину)
   - [ ] Значения (если только сравнение)

4. **Определить условие while**:
   - [ ] `>` для строго большего
   - [ ] `>=` для большего или равного
   - [ ] `<` для строго меньшего
   - [ ] `<=` для меньшего или равного

5. **Обработать границы**:
   - [ ] Добавить часовые элементы?
   - [ ] Обработать оставшиеся в стеке?
   - [ ] Проверить на пустой массив?

## 💎 УНИВЕРСАЛЬНЫЙ ШАБЛОН "НА ВСЕ СЛУЧАИ"

```java
public int[] monotonicStackTemplate(int[] arr, boolean findGreater, boolean strict) {
    int n = arr.length;
    int[] result = new int[n];
    Arrays.fill(result, -1);
    Deque<Integer> stack = new ArrayDeque<>();
    
    for (int i = 0; i < n; i++) {
        // Выбираем условие на лету
        boolean condition;
        if (findGreater) {
            condition = strict ? arr[i] > arr[stack.peek()] : arr[i] >= arr[stack.peek()];
        } else {
            condition = strict ? arr[i] < arr[stack.peek()] : arr[i] <= arr[stack.peek()];
        }
        
        while (!stack.isEmpty() && condition) {
            int idx = stack.pop();
            result[idx] = arr[i]; // или i, или i-idx в зависимости от задачи
        }
        stack.push(i);
    }
    return result;
}
```

## 🎓 ИТОГОВОЕ ПРАВИЛО (САМОЕ ГЛАВНОЕ)

**`while (!stack.isEmpty() && условие) { stack.pop(); }`** — это **"МАССОВОЕ РЕШЕНИЕ"**:
- Каждый `pop()` — элемент получил ответ
- Текущий `arr[i]` — "решатель" для многих
- Стек остаётся монотонным после обработки
- Оставшиеся в стеке — ждут решения (или его нет)

**ЗАПОМНИТЕ ЭТУ КАРТИНКУ:**
```
Стек: [5, 4, 3, 2, 1] ← все ждут кого-то БОЛЬШЕ себя
Приходит: 6
6 > 1? ДА! → 1 находит решение: 6
6 > 2? ДА! → 2 находит решение: 6
6 > 3? ДА! → 3 находит решение: 6
6 > 4? ДА! → 4 находит решение: 6  
6 > 5? ДА! → 5 находит решение: 6
ОДНА цифра 6 решила задачу для ПЯТИ предыдущих!
```

Теперь у вас есть полная шпаргалка. Сохраните её и возвращайтесь, когда нужно решить задачу на монотонный стек! 🚀
