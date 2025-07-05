В Java функциональные интерфейсы — это интерфейсы, которые содержат **ровно один абстрактный метод** (SAM — Single Abstract Method). Они используются в лямбда-выражениях и method reference.  

С появлением Java 8 в пакет `java.util.function` были добавлены несколько встроенных функциональных интерфейсов для удобства работы с лямбда-выражениями.  

Рассмотрим основные из них:  

---

## **1. `Supplier<T>`**  
**Описание:** Не принимает аргументов, но возвращает значение типа `T`.  
**Метод:** `T get()`  
**Использование:** Полезен для ленивой генерации или предоставления значений.  

**Пример:**  
```java
Supplier<String> randomStringSupplier = () -> "Hello, World!";
System.out.println(randomStringSupplier.get()); // "Hello, World!"

Supplier<Double> randomSupplier = Math::random;
System.out.println(randomSupplier.get()); // случайное число
```

---

## **2. `Consumer<T>`**  
**Описание:** Принимает один аргумент типа `T` и ничего не возвращает (`void`).  
**Метод:** `void accept(T t)`  
**Дополнения:**  
- `BiConsumer<T, U>` — принимает два аргумента.  
- `IntConsumer`, `DoubleConsumer` — специализированные потребители.  

**Пример:**  
```java
Consumer<String> printConsumer = s -> System.out.println(s);
printConsumer.accept("Hello!"); // "Hello!"

BiConsumer<String, Integer> biPrint = (s, i) -> System.out.println(s + " " + i);
biPrint.accept("Age:", 25); // "Age: 25"
```

---

## **3. `Function<T, R>`**  
**Описание:** Принимает аргумент типа `T` и возвращает результат типа `R`.  
**Метод:** `R apply(T t)`  
**Дополнения:**  
- `BiFunction<T, U, R>` — принимает два аргумента.  
- `UnaryOperator<T>` — частный случай `Function<T, T>` (аргумент и результат одного типа).  
- `BinaryOperator<T>` — частный случай `BiFunction<T, T, T>`.  

**Пример:**  
```java
Function<String, Integer> lengthFunction = String::length;
System.out.println(lengthFunction.apply("Java")); // 4

UnaryOperator<String> toUpper = String::toUpperCase;
System.out.println(toUpper.apply("hello")); // "HELLO"

BinaryOperator<Integer> sum = Integer::sum;
System.out.println(sum.apply(5, 3)); // 8
```

---

## **4. `Predicate<T>`**  
**Описание:** Принимает аргумент типа `T` и возвращает `boolean`.  
**Метод:** `boolean test(T t)`  
**Дополнения:**  
- `BiPredicate<T, U>` — принимает два аргумента.  
- `IntPredicate`, `DoublePredicate` — специализированные предикаты.  

**Пример:**  
```java
Predicate<String> isEmpty = s -> s.isEmpty();
System.out.println(isEmpty.test("")); // true

BiPredicate<String, Integer> isLengthEqual = (s, len) -> s.length() == len;
System.out.println(isLengthEqual.test("Java", 4)); // true
```

---

## **5. `Runnable`**  
**Описание:** Не принимает аргументов и не возвращает результат (`void`).  
**Метод:** `void run()`  
**Использование:** Для выполнения действий без параметров.  

**Пример:**  
```java
Runnable task = () -> System.out.println("Task executed!");
task.run(); // "Task executed!"
```

---

## **6. Другие полезные интерфейсы**  
- **`Callable<V>`** — аналог `Runnable`, но может возвращать значение и бросать исключения (`V call()`).  
- **`Comparator<T>`** — используется для сортировки (`int compare(T o1, T o2)`).  

---

## **Вывод**  
Функциональные интерфейсы Java позволяют писать более гибкий и лаконичный код, особенно в сочетании с лямбда-выражениями. Основные интерфейсы:  
- **`Supplier<T>`** — поставщик (`get()`).  
- **`Consumer<T>`** — потребитель (`accept(T t)`).  
- **`Function<T, R>`** — преобразователь (`apply(T t)`).  
- **`Predicate<T>`** — условие (`test(T t)`).  
- **`Runnable`** — задача (`run()`).  

Их можно комбинировать в Stream API, Optional и многопоточности. 🚀
