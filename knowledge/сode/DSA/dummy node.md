## Что такое Dummy Node?

**Dummy Node** — это временный фиктивный узел, который создаётся в начале операции и указывает на голову списка. После завершения операции он удаляется.

```java
class ListNode {
    int val;
    ListNode next;
    ListNode(int val) { this.val = val; }
}

// Без dummy node - сложно!
// С dummy node - просто!
```

## Зачем нужен Dummy Node?

### Проблема без Dummy Node:
```java
public static ListNode removeElements(ListNode head, int val) {
    // Сложная обработка краевых случаев
    while (head != null && head.val == val) {
        head = head.next; // Голова может меняться несколько раз
    }
    
    if (head == null) return null;
    
    ListNode current = head;
    while (current.next != null) {
        if (current.next.val == val) {
            current.next = current.next.next;
        } else {
            current = current.next;
        }
    }
    
    return head;
}
```

### Решение с Dummy Node:
```java
public static ListNode removeElements(ListNode head, int val) {
    ListNode dummy = new ListNode(0); // Фиктивный узел
    dummy.next = head;
    
    ListNode current = dummy;
    
    while (current.next != null) {
        if (current.next.val == val) {
            current.next = current.next.next;
        } else {
            current = current.next;
        }
    }
    
    return dummy.next; // Возвращаем реальную голову
}
```

## Ключевые преимущества:

1. **Упрощение краевых случаев** - не нужно отдельно обрабатывать удаление головы
2. **Единообразие логики** - все узлы обрабатываются одинаково
3. **Предотвращение null pointer** - всегда есть предыдущий узел

## Практические примеры:

### 1. Remove Nth Node From End (задача с LeetCode)
```java
// Без dummy - сложно!
public static ListNode removeNthFromEndNoDummy(ListNode head, int n) {
    // Нужно отдельно обрабатывать случай удаления головы
    int length = 0;
    ListNode current = head;
    while (current != null) {
        length++;
        current = current.next;
    }
    
    if (n == length) {
        return head.next; // Удаляем голову
    }
    
    current = head;
    for (int i = 0; i < length - n - 1; i++) {
        current = current.next;
    }
    current.next = current.next.next;
    
    return head;
}

// С dummy - элегантно!
public static ListNode removeNthFromEnd(ListNode head, int n) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    
    ListNode fast = dummy;
    ListNode slow = dummy;
    
    // Двигаем fast на n+1 шагов вперед
    for (int i = 0; i <= n; i++) {
        fast = fast.next;
    }
    
    // Двигаем оба указателя
    while (fast != null) {
        fast = fast.next;
        slow = slow.next;
    }
    
    // Удаляем узел
    slow.next = slow.next.next;
    
    return dummy.next;
}
```

### 2. Merge Two Sorted Lists
```java
public static ListNode mergeTwoLists(ListNode l1, ListNode l2) {
    ListNode dummy = new ListNode(0);
    ListNode current = dummy;
    
    while (l1 != null && l2 != null) {
        if (l1.val <= l2.val) {
            current.next = l1;
            l1 = l1.next;
        } else {
            current.next = l2;
            l2 = l2.next;
        }
        current = current.next;
    }
    
    // Добавляем оставшиеся элементы
    current.next = (l1 != null) ? l1 : l2;
    
    return dummy.next;
}
```

### 3. Swap Nodes in Pairs
```java
public static ListNode swapPairs(ListNode head) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    ListNode current = dummy;
    
    while (current.next != null && current.next.next != null) {
        ListNode first = current.next;
        ListNode second = current.next.next;
        
        // Меняем местами
        first.next = second.next;
        second.next = first;
        current.next = second;
        
        // Двигаемся вперед
        current = current.next.next;
    }
    
    return dummy.next;
}

// До: dummy -> 1 -> 2 -> 3 -> 4
// После: dummy -> 2 -> 1 -> 4 -> 3
```

### 4. Reverse Linked List (частичный разворот)
```java
public static ListNode reverseBetween(ListNode head, int left, int right) {
    ListNode dummy = new ListNode(0);
    dummy.next = head;
    
    // Находим узел перед left
    ListNode prev = dummy;
    for (int i = 0; i < left - 1; i++) {
        prev = prev.next;
    }
    
    // Разворачиваем часть списка
    ListNode current = prev.next;
    for (int i = 0; i < right - left; i++) {
        ListNode next = current.next;
        current.next = next.next;
        next.next = prev.next;
        prev.next = next;
    }
    
    return dummy.next;
}
```

## Когда использовать Dummy Node?

### ✅ Обязательно использовать:
- **Удаление элементов** из списка (может поменяться голова)
- **Разворот списка** или его части
- **Слияние списков** 
- **Любые операции**, где голова списка может измениться

### ❌ Можно не использовать:
- Простой обход списка (только чтение)
- Поиск элемента без модификации
- Когда голова гарантированно не меняется

## Продвинутые техники:

### 1. Dummy Node с двумя указателями
```java
public static ListNode partition(ListNode head, int x) {
    ListNode lessDummy = new ListNode(0);
    ListNode greaterDummy = new ListNode(0);
    
    ListNode less = lessDummy;
    ListNode greater = greaterDummy;
    
    ListNode current = head;
    
    while (current != null) {
        if (current.val < x) {
            less.next = current;
            less = less.next;
        } else {
            greater.next = current;
            greater = greater.next;
        }
        current = current.next;
    }
    
    // Соединяем два списка
    greater.next = null; // Важно!
    less.next = greaterDummy.next;
    
    return lessDummy.next;
}
```

### 2. Dummy Node для сложных операций
```java
public static ListNode addTwoNumbers(ListNode l1, ListNode l2) {
    ListNode dummy = new ListNode(0);
    ListNode current = dummy;
    int carry = 0;
    
    while (l1 != null || l2 != null || carry != 0) {
        int sum = carry;
        if (l1 != null) {
            sum += l1.val;
            l1 = l1.next;
        }
        if (l2 != null) {
            sum += l2.val;
            l2 = l2.next;
        }
        
        carry = sum / 10;
        current.next = new ListNode(sum % 10);
        current = current.next;
    }
    
    return dummy.next;
}
```

## Важные замечания:

1. **Всегда возвращайте `dummy.next`** - это реальная голова нового списка
2. **Не забывайте обрывать связи** - особенно при разбиении списков
3. **Dummy node создается на стеке** - автоматически удаляется после метода
4. **Экономия памяти** - один фиктивный узел vs сложная логика

**Итог:** Dummy Node — это ваш лучший друг при работе со связными списками! Он делает код чище, надежнее и проще для понимания. 🎯
