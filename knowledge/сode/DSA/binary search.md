### **Бинарный поиск (Binary Search)**  

#### **📌 Основная идея**  
Бинарный поиск — это алгоритм поиска элемента в **отсортированном массиве** за время **O(log n)**.  
Работает по принципу **"разделяй и властвуй"**, последовательно сужая диапазон поиска вдвое.  

---

### **🔍 Алгоритм (шаги)**  
![image](https://github.com/user-attachments/assets/fc4a5909-95b7-4e4d-ac51-650733edde97)
---
![image](https://github.com/user-attachments/assets/16a13cc4-4afe-4dd2-9584-100efc084f1a)

---

### **⚡ Сложность алгоритма**  
- **Время:** **O(log n)** — так как диапазон делится пополам на каждом шаге.  
- **Память:** **O(1)** — не требует дополнительной памяти.  

---

### **📌 Ключевые свойства**  
1. **Работает только на отсортированных данных** (иначе не гарантируется корректность).  
2. **Эффективнее линейного поиска (O(n)) на больших массивах**.  
3. **Можно реализовать итеративно и рекурсивно**.  

---
### **🧑🏻‍💻 Реализация**
```java
public class BinarySearch {
  public static int search(int[] array, int toFind) {
    for (int i = 0; i < array.length - 1; i++) {
      if (array[i] > array[i + 1]) {
        throw new IllegalStateException("Input array must be sorted in ascending order");
      }
    }
    int left = 0;
    int right = array.length - 1;
    while (left <= right) {
      int mid = left + (right - left) / 2;
      if (array[mid] == toFind) {
        return mid;
      } else if (array[mid] < toFind) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
    return -1;
  }
}
```
---
### **🛠️ Применение**  
- Поиск в массивах, списках.  
- В более сложных алгоритмах (например, поиск в **бинарных деревьях**).  

**Итог:** Бинарный поиск — один из самых эффективных алгоритмов поиска, но требует **отсортированных данных**. 🚀
