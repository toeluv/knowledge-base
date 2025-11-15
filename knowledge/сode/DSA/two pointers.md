### 1. Суть метода двух указателей

Идея в том, чтобы использовать два указателя (часто это просто индексы в массиве или ссылки в списке), которые движутся по структуре данных, обычно с разной скоростью или навстречу друг другу. Это позволяет решать задачу за один проход (O(n)) вместо наивных решений за O(n²).

### 2. Основные шаблоны (Patterns)

Есть три главных способа использования двух указателей:

#### **а) Встречные указатели**
Один указатель начинает с начала (`left`), другой с конца (`right`). Они движутся навстречу, пока не встретятся.

**Типичные задачи:**
*   Сумма двух чисел в отсортированном массиве (Two Sum II).
*   Проверка, является ли строка палиндромом.
*   Треугольник с максимальным периметром.

**Базовый шаблон:**
```java
public void twoPointersOpposite(int[] nums) {
    int left = 0;
    int right = nums.length - 1;
    
    while (left < right) {
        // Логика на основе nums[left] и nums[right]
        if (/* условие */) {
            left++;
        } else {
            right--;
        }
    }
}
```

#### **б) Указатели с одинаковой скоростью (или "Бегунки")**
Оба указателя начинают с начала. Один ("медленный") `slow` отмечает позицию для следующего валидного элемента, а второй ("быстрый") `fast` ищет следующий валидный элемент.

**Типичные задачи:**
*   Удаление дубликатов из отсортированного массива.
*   Удаление элемента из массива.
*   Слияние двух отсортированных массивов.

**Базовый шаблон:**
```java
public int twoPointersSameDirection(int[] nums) {
    int slow = 0;
    for (int fast = 0; fast < nums.length; fast++) {
        // Если элемент nums[fast] нам подходит, перемещаем его на позицию slow
        if (/* условие для nums[fast] */) {
            nums[slow] = nums[fast];
            slow++;
        }
    }
    return slow; // новая длина после "фильтрации"
}
```

#### **в) Разделяй и властвуй (для связных списков)**
"Быстрый" указатель движется в два раза быстрее "медленного". Когда быстрый достигает конца, медленный оказывается в середине.

**Типичные задачи:**
*   Нахождение середины связного списка.
*   Проверка цикла в связном списке (Floyd's Cycle Finding Algorithm).

**Базовый шаблон для середины списка:**
```java
public ListNode findMiddle(ListNode head) {
    ListNode slow = head;
    ListNode fast = head;
    
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
    }
    return slow;
}
```

---

### 3. План изучения на LeetCode (от простого к сложному)

Рекомендую проходить задачи именно в таком порядке, чтобы увидеть прогрессию.

#### **Этап 1: Базовое понимание (Встречные указатели)**

1.  **[Valid Palindrome](https://leetcode.com/problems/valid-palindrome/)** (№125) - Классика жанра.
    ```java
    public boolean isPalindrome(String s) {
        int left = 0, right = s.length() - 1;
        while (left < right) {
            // Пропускаем не-буквенно-цифровые символы
            while (left < right && !Character.isLetterOrDigit(s.charAt(left))) left++;
            while (left < right && !Character.isLetterOrDigit(s.charAt(right))) right--;
            // Сравниваем
            if (Character.toLowerCase(s.charAt(left)) != Character.toLowerCase(s.charAt(right))) {
                return false;
            }
            left++;
            right--;
        }
        return true;
    }
    ```

2.  **[Two Sum II - Input Array Is Sorted](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/)** (№167) - Идеальная задача для метода.
    ```java
    public int[] twoSum(int[] numbers, int target) {
        int left = 0, right = numbers.length - 1;
        while (left < right) {
            int sum = numbers[left] + numbers[right];
            if (sum == target) {
                return new int[]{left + 1, right + 1};
            } else if (sum < target) {
                left++;
            } else {
                right--;
            }
        }
        return new int[]{-1, -1};
    }
    ```

3.  **[Container With Most Water](https://leetcode.com/problems/container-with-most-water/)** (№11) - Немного сложнее, но логика та же.
    ```java
    public int maxArea(int[] height) {
        int left = 0, right = height.length - 1;
        int maxArea = 0;
        while (left < right) {
            int currentArea = Math.min(height[left], height[right]) * (right - left);
            maxArea = Math.max(maxArea, currentArea);
            // Двигаем тот указатель, у которого высота меньше
            if (height[left] < height[right]) {
                left++;
            } else {
                right--;
            }
        }
        return maxArea;
    }
    ```

#### **Этап 2: Указатели с одинаковой скоростью**

4.  **[Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)** (№26) - Канонический пример.
    ```java
    public int removeDuplicates(int[] nums) {
        if (nums.length == 0) return 0;
        int k = 1; // Медленный указатель (новая длина)
        for (int i = 1; i < nums.length; i++) { // i - быстрый указатель
            if (nums[i] != nums[i - 1]) { // Нашли новый уникальный элемент
                nums[k] = nums[i];
                k++;
            }
        }
        return k;
    }
    ```

5.  **[Remove Element](https://leetcode.com/problems/remove-element/)** (№27) - Практически идентичная логика.
    ```java
    public int removeElement(int[] nums, int val) {
        int k = 0; // Медленный указатель
        for (int i = 0; i < nums.length; i++) { // i - быстрый указатель
            if (nums[i] != val) {
                nums[k] = nums[i];
                k++;
            }
        }
        return k;
    }
    ```

#### **Этап 3: Комбинированные и сложные задачи**

6.  **[3Sum](https://leetcode.com/problems/3sum/)** (№15) - Золотая классика собеседований. Здесь вы фиксируете один элемент и для оставшейся части массива используете метод двух указателей как в "Two Sum II".
7.  **[Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/)** (№42) - Сложная задача, где два указателя движутся навстречу, отслеживая максимумы слева и справа.
8.  **[Linked List Cycle II](https://leetcode.com/problems/linked-list-cycle-ii/)** (№142) - Алгоритм Флойда для нахождения цикла. Сначала найдите встречу указателей, затем найдите начало цикла.

### 4. Советы для собеседования

1.  **Всегда уточняйте условие.** Задавайте вопросы: "Отсортирован ли массив?", "Могут ли быть дубликаты?", "Что насчет пустого ввода?".
2.  **Сначала объясните наивное решение (Brute Force).** Покажите, что вы понимаете проблему ("Можно решить двумя циклами за O(n²), но..."), а затем предложите оптимизацию через два указателя.
3.  **Проговорите логику движения указателей.** "Здесь я буду двигать левый указатель, потому что...".
4.  **Пишите аккуратный код.** Исп
