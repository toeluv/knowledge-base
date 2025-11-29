## 1. Что такое BST?

**BST (Binary Search Tree)** — это бинарное дерево, для которого выполняются следующие условия:

1. **У каждого узла есть не более двух потомков** (левый и правый)
2. **Для любого узла X:**
   - Все значения в **левом поддереве** меньше значения узла X
   - Все значения в **правом поддереве** больше значения узла X
3. **Левые и правые поддеревья** также являются BST

## 2. Базовая структура узла

```python
class TreeNode:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None
```

## 3. Основные операции

### 🔍 **Поиск элемента**

```python
def search(root, value):
    if root is None or root.value == value:
        return root
    
    if value < root.value:
        return search(root.left, value)
    else:
        return search(root.right, value)
```

**Временная сложность:**
- **В среднем случае:** O(log n)
- **В худшем случае:** O(n) - когда дерево вырождается в список

### ➕ **Вставка элемента**

```python
def insert(root, value):
    if root is None:
        return TreeNode(value)
    
    if value < root.value:
        root.left = insert(root.left, value)
    elif value > root.value:
        root.right = insert(root.right, value)
    
    return root
```

### ❌ **Удаление элемента**

Удаление имеет три случая:

```python
def delete(root, value):
    if root is None:
        return root
    
    if value < root.value:
        root.left = delete(root.left, value)
    elif value > root.value:
        root.right = delete(root.right, value)
    else:
        # Случай 1: Нет потомков или один потомок
        if root.left is None:
            return root.right
        elif root.right is None:
            return root.left
        
        # Случай 2: Два потомка
        # Находим минимальный элемент в правом поддереве
        temp = min_value_node(root.right)
        root.value = temp.value
        root.right = delete(root.right, temp.value)
    
    return root

def min_value_node(node):
    current = node
    while current.left is not None:
        current = current.left
    return current
```

## 4. Обходы дерева

### 🔄 **In-order (центрированный)**
```python
def inorder_traversal(root):
    if root:
        inorder_traversal(root.left)
        print(root.value, end=" ")
        inorder_traversal(root.right)
```
**Результат:** элементы в отсортированном порядке

### 🔄 **Pre-order (прямой)**
```python
def preorder_traversal(root):
    if root:
        print(root.value, end=" ")
        preorder_traversal(root.left)
        preorder_traversal(root.right)
```

### 🔄 **Post-order (обратный)**
```python
def postorder_traversal(root):
    if root:
        postorder_traversal(root.left)
        postorder_traversal(root.right)
        print(root.value, end=" ")
```

## 5. Пример работы

Создадим BST и добавим элементы: 50, 30, 70, 20, 40, 60, 80

```
        50
       /  \
     30    70
    /  \   /  \
  20   40 60   80
```

**In-order обход:** 20 30 40 50 60 70 80 (отсортированный!)

## 6. Важные свойства

### ✅ **Преимущества:**
- **Быстрый поиск** (в среднем O(log n))
- **Эффективная вставка/удаление**
- **Автоматическая сортировка** данных
- **Гибкость** - легко модифицировать

### ❌ **Недостатки:**
- **Производительность зависит от баланса**
- **В худшем случае** вырождается в связный список O(n)
- **Нет гарантии** сбалансированности

## 7. Сбалансированные BST

Чтобы избежать вырождения, используют сбалансированные версии:

- **AVL-деревья** - строгая балансировка
- **Красно-черные деревья** - менее строгая, но эффективная балансировка
- **B-деревья** - для работы с диском и базами данных

## 8. Практический пример

```python
class BST:
    def __init__(self):
        self.root = None
    
    def insert(self, value):
        self.root = self._insert(self.root, value)
    
    def _insert(self, node, value):
        if node is None:
            return TreeNode(value)
        
        if value < node.value:
            node.left = self._insert(node.left, value)
        elif value > node.value:
            node.right = self._insert(node.right, value)
        
        return node
    
    def search(self, value):
        return self._search(self.root, value)
    
    def _search(self, node, value):
        if node is None or node.value == value:
            return node is not None
        
        if value < node.value:
            return self._search(node.left, value)
        return self._search(node.right, value)
    
    def display(self):
        print("In-order:", end=" ")
        self._inorder(self.root)
        print()
    
    def _inorder(self, node):
        if node:
            self._inorder(node.left)
            print(node.value, end=" ")
            self._inorder(node.right)

# Использование
bst = BST()
values = [50, 30, 70, 20, 40, 60, 80]

for value in values:
    bst.insert(value)

bst.display()  # In-order: 20 30 40 50 60 70 80
print("Search 40:", bst.search(40))  # True
print("Search 45:", bst.search(45))  # False
```

## 9. Применение BST

- **Базы данных** - для индексов
- **Файловые системы** - организация каталогов
- **Сети** - таблицы маршрутизации
- **Игры** - AI и принятие решений
- **Компиляторы** - таблицы символов

BST — это фундаментальная структура данных, которая сочетает в себе эффективность поиска из отсортированных массивов и гибкость связных списков, что делает ее незаменимой во многих областях компьютерных наук.
