## Что такое String Pool?

**String Pool** — это специальная область памяти в **Heap (куче)**, где Java хранит уникальные строковые литералы. Это своего рода "кэш" для строковых объектов.

## Местоположение String Pool

- **До Java 7:** String Pool находился в **PermGen** (Permanent Generation)
- **Java 7 и позднее:** String Pool перемещен в **основную Heap** (Young Generation)

**Почему это важно:** Размещение в основной куче позволяет сборщику мусора управлять строками так же, как и обычными объектами, предотвращая `OutOfMemoryError`.

## Как работает String Pool?

### 1. Создание строк через литералы
```java
String s1 = "hello";
String s2 = "hello";
String s3 = "world";
```

**Что происходит:**
1. При первой встрече `"hello"` JVM проверяет пул
2. Если строки нет — создает новый объект в пуле
3. При последующих использованиях того же литерала возвращается ссылка на существующий объект

**Результат:**
```java
System.out.println(s1 == s2); // true - одна и та же ссылка
System.out.println(s1 == s3); // false - разные объекты
```

### 2. Создание через оператор `new`
```java
String s4 = new String("hello");
String s5 = new String("hello");
```

**Что происходит:**
- `new` всегда создает новый объект в куче (вне пула)
- Аргумент `"hello"` сначала помещается в пул (если его там нет)

**Результат:**
```java
System.out.println(s1 == s4); // false - разные объекты
System.out.println(s4 == s5); // false - разные объекты
```

## Методы для работы с String Pool

### `intern()` - основной метод
```java
String s6 = new String("hello").intern();
String s7 = new String("hello").intern();

System.out.println(s1 == s6); // true
System.out.println(s6 == s7); // true
```

**Метод `intern()`:**
- Проверяет наличие строки в пуле
- Если есть — возвращает ссылку из пула
- Если нет — добавляет строку в пул и возвращает ссылку

## Визуализация работы String Pool

```java
// Создание через литералы (используется пул)
String a = "cat";        // → String Pool: ["cat"]
String b = "cat";        // → ссылка на существующий "cat"

// Создание через new (минуя пул)
String c = new String("cat"); // → Heap: новый объект, String Pool: ["cat"]

// Явное помещение в пул
String d = c.intern();   // → возвращает ссылку на "cat" из пула

// Проверки
System.out.println(a == b); // true - один объект в пуле
System.out.println(a == c); // false - разные объекты
System.out.println(a == d); // true - intern() вернул ссылку из пула
```

## String Pool и конкатенация

### Компиляторная оптимизация
```java
String s1 = "hello" + "world";        // → "helloworld" (оптимизация на этапе компиляции)
String s2 = "helloworld";

System.out.println(s1 == s2); // true - компилятор создает один литерал
```

### Runtime конкатенация
при Runtime конкатенации на каждую операцию создается `Stringbuilder`
1. Проблема "плохого" варианта
```java
// ПЛОХО - создает много временных объектов
String result = "";
for (int i = 0; i < 1000; i++) {
    result += i; // new StringBuilder каждый раз!
}
```
Что на самом деле происходит в цикле:

```java
// Эквивалент того, что делает компилятор:
String result = "";
for (int i = 0; i < 1000; i++) {
    result = new StringBuilder().append(result).append(i).toString();
}
```
2. Детальный анализ "плохого" подхода
На каждой итерации цикла:
Создается новый StringBuilder

Копируется всё содержимое текущей строки result

Добавляется новый символ i

Создается новая строка через toString()

Старая строка становится мусором (ждет GC)

```java
// Итерация 1: result = "" + "0"
// Создается: StringBuilder, копируется "", добавляется "0", создается строка "0"

// Итерация 2: result = "0" + "1"  
// Создается: StringBuilder, копируется "0", добавляется "1", создается строка "01"

// Итерация 3: result = "01" + "2"
// Создается: StringBuilder, копируется "01", добавляется "2", создается строка "012"
```
Проблема квадратичной сложности O(n²)
Количество копируемых символов:

Итерация 1: копируется 0 символов

Итерация 2: копируется 1 символ

Итерация 3: копируется 2 символа

...

Итерация 1000: копируется 999 символов

Общее количество операций копирования: 0 + 1 + 2 + ... + 999 = ~500,000 операций!

3. Почему "хороший" вариант лучше
```java
// ХОРОШО - один StringBuilder
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.append(i);
}
String result = sb.toString();
```
Преимущества:
1. Один объект StringBuilder на весь цикл

Создается ДО цикла

Используется ВО ВСЕХ итерациях

Уничтожается ПОСЛЕ цикла

2. Эффективное добавление символов

Символы добавляются непосредственно в внутренний массив char[]

Нет постоянного копирования предыдущего содержимого
```java
String s3 = "hello";
String s4 = s3 + "world";             // → создается новый объект StringBuilder
String s5 = "helloworld";

System.out.println(s4 == s5); // false - разные объекты
System.out.println(s4.intern() == s5); // true - после intern()
```

## Практические примеры и нюансы

### Пример 1: Базовое использование
```java
public class StringPoolExample {
    public static void main(String[] args) {
        String literal1 = "java";
        String literal2 = "java";
        String newString = new String("java");
        String internedString = newString.intern();
        
        System.out.println("literal1 == literal2: " + (literal1 == literal2));           // true
        System.out.println("literal1 == newString: " + (literal1 == newString));         // false
        System.out.println("literal1 == internedString: " + (literal1 == internedString)); // true
    }
}
```

### Пример 2: Конкатенация на этапе компиляции vs runtime
```java
public class ConcatenationExample {
    public static void main(String[] args) {
        final String constPart = "hello"; // final - известна на этапе компиляции
        String dynamicPart = "world";
        
        String s1 = "hello" + "world";           // Оптимизация компилятором
        String s2 = constPart + "world";         // Оптимизация компилятором
        String s3 = constPart + dynamicPart;     // Runtime конкатенация
        
        System.out.println(s1 == "helloworld");  // true
        System.out.println(s2 == "helloworld");  // true  
        System.out.println(s3 == "helloworld");  // false
    }
}
```

## Преимущества String Pool

1. **Экономия памяти:** Один объект вместо множества одинаковых
2. **Ускорение сравнения:** `==` вместо `equals()` для литералов
3. **Повышение производительности:** Меньше создания объектов

## Осторожность с `intern()`

**Не используйте `intern()` без необходимости:**
```java
// ПЛОХО - может заполнить пул
for (int i = 0; i < 1000000; i++) {
    String unique = ("user_" + i).intern(); // Опасно!
}

// ЛУЧШЕ - используйте обычные строки
Map<String, String> stringCache = new HashMap<>();
for (int i = 0; i < 1000000; i++) {
    String key = "user_" + i;
    String cached = stringCache.computeIfAbsent(key, k -> k);
}
```

## Современные особенности (Java 8+)

### CDS (Class Data Sharing)
В современных JVM String Pool может использовать CDS для:
- Разделения строк между разными JVM процессами
- Ускорения старта приложения
- Снижения памяти для множества экземпляров JVM

### G1GC оптимизации
Garbage Collector оптимизирует работу с дублирующимися строками через дедупликацию.

## Итог для собеседования

**Ключевые тезисы:**
- String Pool — это кэш строковых литералов в Heap
- Литералы автоматически помещаются в пул
- `new String()` создает объект вне пула
- `intern()` позволяет явно помещать строки в пул
- Неизменяемость String делает пул безопасным
- Используйте `intern()` с осторожностью

**На собеседовании обязательно упомяните:**
- Разницу между `==` и `equals()`
- Отличие литералов от `new String()`
- Роль неизменяемости строк
- Изменение местоположения пула в Java 7

String Pool — прекрасный пример оптимизации, которая делает Java эффективнее, сохраняя простоту языка для разработчика.
