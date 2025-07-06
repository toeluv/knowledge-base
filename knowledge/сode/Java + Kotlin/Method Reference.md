# **Method Reference в Java и Kotlin**  

Method Reference (ссылка на метод) — это компактный синтаксис лямбда-выражений, который позволяет **переиспользовать уже существующие методы** вместо написания новой лямбды.  

## **1. Method Reference в Java**  
В Java есть **4 вида** method reference:  

### **1. Ссылка на статический метод**  
**Синтаксис:** `Класс::статическийМетод`  
**Пример:**  
```java
// Лямбда
Function<Integer, String> lambda = num -> String.valueOf(num);
// Method Reference
Function<Integer, String> ref = String::valueOf;

System.out.println(ref.apply(123)); // "123"
```

### **2. Ссылка на метод экземпляра (конкретного объекта)**  
**Синтаксис:** `объект::метод`  
**Пример:**  
```java
String str = "Java";
// Лямбда
Supplier<String> lambda = () -> str.toUpperCase();
// Method Reference
Supplier<String> ref = str::toUpperCase;

System.out.println(ref.get()); // "JAVA"
```

### **3. Ссылка на метод произвольного объекта (по типу)**  
**Синтаксис:** `Класс::методЭкземпляра`  
**Пример:**  
```java
// Лямбда
Function<String, Integer> lambda = s -> s.length();
// Method Reference
Function<String, Integer> ref = String::length;

System.out.println(ref.apply("Hello")); // 5
```

### **4. Ссылка на конструктор**  
**Синтаксис:** `Класс::new`  
**Пример:**  
```java
// Лямбда
Supplier<List<String>> lambda = () -> new ArrayList<>();
// Method Reference
Supplier<List<String>> ref = ArrayList::new;

List<String> list = ref.get();
list.add("Java");
System.out.println(list); // [Java]
```

---

## **2. Method Reference в Kotlin**  
Kotlin также поддерживает method reference, но синтаксис немного отличается.  

### **1. Ссылка на функцию (аналог статического метода)**  
**Синтаксис:** `::функция`  
**Пример:**  
```kotlin
fun isEven(num: Int) = num % 2 == 0

val numbers = listOf(1, 2, 3, 4)
// Лямбда
val lambdaFilter = numbers.filter { num -> isEven(num) }
// Method Reference
val refFilter = numbers.filter(::isEven)

println(refFilter) // [2, 4]
```

### **2. Ссылка на метод экземпляра**  
**Синтаксис:** `объект::метод`  
**Пример:**  
```kotlin
val str = "Kotlin"
// Лямбда
val lambdaGetUpper = { str.uppercase() }
// Method Reference
val refGetUpper = str::uppercase

println(refGetUpper()) // "KOTLIN"
```

### **3. Ссылка на конструктор**  
**Синтаксис:** `::Класс`  
**Пример:**  
```kotlin
class Person(val name: String)

// Лямбда
val lambdaCreate: (String) -> Person = { name -> Person(name) }
// Method Reference
val refCreate = ::Person

val person = refCreate("Alice")
println(person.name) // "Alice"
```

### **4. Ссылка на свойство (Property Reference)**  
**Особенность Kotlin:** можно ссылаться на поля класса.  
**Синтаксис:** `объект::поле`  
**Пример:**  
```kotlin
data class User(val name: String, val age: Int)

val users = listOf(User("Alice", 25), User("Bob", 30))
// Лямбда
val lambdaNames = users.map { user -> user.name }
// Method Reference
val refNames = users.map(User::name)

println(refNames) // ["Alice", "Bob"]
```

---

## **Вывод**  
| **Тип**               | **Java**            | **Kotlin**          |
|-----------------------|---------------------|---------------------|
| Статический метод     | `Класс::метод`      | `::функция`         |
| Метод объекта         | `объект::метод`     | `объект::метод`     |
| Метод произвольного объекта | `Класс::метод` | `Класс::метод`      |
| Конструктор           | `Класс::new`        | `::Класс`           |
| Свойство (Kotlin-only)| —                   | `Класс::поле`       |

**Преимущества Method Reference:**  
- Улучшает читаемость кода.  
- Уменьшает дублирование (переиспользует существующие методы).  
- Работает везде, где принимаются лямбды (Streams, коллекции, обработка событий).  

**Когда использовать?**  
- Когда лямбда просто вызывает один метод.  
- Когда метод уже существует и его можно переиспользовать.  

**Пример в Stream API (Java):**  
```java
List<String> names = List.of("Alice", "Bob", "Charlie");
// Лямбда
names.stream().map(name -> name.toUpperCase()).forEach(System.out::println);
// Method Reference
names.stream().map(String::toUpperCase).forEach(System.out::println);
```

**Пример в Kotlin:**  
```kotlin
val numbers = listOf(1, 2, 3, 4)
// Лямбда
numbers.map { it * 2 }.forEach { println(it) }
// Method Reference
numbers.map(Int::toDouble).forEach(::println)
```

Method Reference делает код чище и выразительнее! 🚀
