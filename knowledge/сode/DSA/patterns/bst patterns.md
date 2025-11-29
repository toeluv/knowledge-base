## 🔍 **Важные свойства и инварианты BST**

### 1. **Свойство упорядочивания**
```java
public boolean isValidBST(TreeNode root) {
    return isValidBST(root, Long.MIN_VALUE, Long.MAX_VALUE);
}

private boolean isValidBST(TreeNode node, long min, long max) {
    if (node == null) return true;
    
    if (node.val <= min || node.val >= max) {
        return false;
    }
    
    return isValidBST(node.left, min, node.val) && 
           isValidBST(node.right, node.val, max);
}
```

### 2. **Размер дерева**
```java
public int size(TreeNode root) {
    if (root == null) return 0;
    return 1 + size(root.left) + size(root.right);
}
```

### 3. **Проверка полноты дерева**
```java
public boolean isComplete(TreeNode root) {
    if (root == null) return true;
    
    Queue<TreeNode> queue = new LinkedList<>();
    queue.offer(root);
    boolean foundNull = false;
    
    while (!queue.isEmpty()) {
        TreeNode current = queue.poll();
        
        if (current == null) {
            foundNull = true;
        } else {
            if (foundNull) return false;
            queue.offer(current.left);
            queue.offer(current.right);
        }
    }
    return true;
}
```

## 🎯 **Важные паттерны обхода**

### 1. **In-order с сбором результатов**
```java
public List<Integer> inorderToList(TreeNode root) {
    List<Integer> result = new ArrayList<>();
    inorderCollect(root, result);
    return result;
}

private void inorderCollect(TreeNode node, List<Integer> result) {
    if (node == null) return;
    inorderCollect(node.left, result);
    result.add(node.val);
    inorderCollect(node.right, result);
}
```

### 2. **Итеративный in-order обход**
```java
public List<Integer> inorderIterative(TreeNode root) {
    List<Integer> result = new ArrayList<>();
    Stack<TreeNode> stack = new Stack<>();
    TreeNode current = root;
    
    while (current != null || !stack.isEmpty()) {
        while (current != null) {
            stack.push(current);
            current = current.left;
        }
        
        current = stack.pop();
        result.add(current.val);
        current = current.right;
    }
    
    return result;
}
```

## 🔄 **Паттерны модификации дерева**

### 1. **Инвертирование BST (Mirror)**
```java
public TreeNode invertTree(TreeNode root) {
    if (root == null) return null;
    
    TreeNode left = invertTree(root.left);
    TreeNode right = invertTree(root.right);
    
    root.left = right;
    root.right = left;
    
    return root;
}
```

### 2. **Balanced BST из отсортированного массива**
```java
public TreeNode sortedArrayToBST(int[] nums) {
    return buildBST(nums, 0, nums.length - 1);
}

private TreeNode buildBST(int[] nums, int left, int right) {
    if (left > right) return null;
    
    int mid = left + (right - left) / 2;
    TreeNode node = new TreeNode(nums[mid]);
    
    node.left = buildBST(nums, left, mid - 1);
    node.right = buildBST(nums, mid + 1, right);
    
    return node;
}
```

## 📊 **Паттерны статистики дерева**

### 1. **K-й наименьший элемент**
```java
public int kthSmallest(TreeNode root, int k) {
    Stack<TreeNode> stack = new Stack<>();
    TreeNode current = root;
    int count = 0;
    
    while (current != null || !stack.isEmpty()) {
        while (current != null) {
            stack.push(current);
            current = current.left;
        }
        
        current = stack.pop();
        count++;
        if (count == k) return current.val;
        
        current = current.right;
    }
    return -1;
}
```

### 2. **Поиск предка и преемника**
```java
public TreeNode[] findPredecessorSuccessor(TreeNode root, int key) {
    TreeNode[] result = new TreeNode[2]; // [predecessor, successor]
    TreeNode current = root;
    
    while (current != null) {
        if (current.val == key) {
            // Predecessor - max в левом поддереве
            if (current.left != null) {
                TreeNode temp = current.left;
                while (temp.right != null) temp = temp.right;
                result[0] = temp;
            }
            
            // Successor - min в правом поддереве
            if (current.right != null) {
                TreeNode temp = current.right;
                while (temp.left != null) temp = temp.left;
                result[1] = temp;
            }
            break;
        } else if (key < current.val) {
            result[1] = current; // potential successor
            current = current.left;
        } else {
            result[0] = current; // potential predecessor
            current = current.right;
        }
    }
    
    return result;
}
```

## 🎪 **Паттерны диапазонов**

### 1. **Поиск в диапазоне**
```java
public List<Integer> rangeSearch(TreeNode root, int low, int high) {
    List<Integer> result = new ArrayList<>();
    rangeSearchHelper(root, low, high, result);
    return result;
}

private void rangeSearchHelper(TreeNode node, int low, int high, List<Integer> result) {
    if (node == null) return;
    
    if (node.val > low) {
        rangeSearchHelper(node.left, low, high, result);
    }
    
    if (node.val >= low && node.val <= high) {
        result.add(node.val);
    }
    
    if (node.val < high) {
        rangeSearchHelper(node.right, low, high, result);
    }
}
```

### 2. **Сумма в диапазоне**
```java
public int rangeSumBST(TreeNode root, int low, int high) {
    if (root == null) return 0;
    
    int sum = 0;
    if (root.val >= low && root.val <= high) {
        sum += root.val;
    }
    
    if (root.val > low) {
        sum += rangeSumBST(root.left, low, high);
    }
    
    if (root.val < high) {
        sum += rangeSumBST(root.right, low, high);
    }
    
    return sum;
}
```

## 🔧 **Паттерны сериализации**

### 1. **Сериализация BST в строку**
```java
public String serialize(TreeNode root) {
    StringBuilder sb = new StringBuilder();
    serializeHelper(root, sb);
    return sb.toString();
}

private void serializeHelper(TreeNode node, StringBuilder sb) {
    if (node == null) return;
    
    sb.append(node.val).append(",");
    serializeHelper(node.left, sb);
    serializeHelper(node.right, sb);
}
```

### 2. **Десериализация BST из строки**
```java
public TreeNode deserialize(String data) {
    if (data.isEmpty()) return null;
    
    String[] values = data.split(",");
    Queue<Integer> queue = new LinkedList<>();
    for (String value : values) {
        queue.offer(Integer.parseInt(value));
    }
    
    return deserializeHelper(queue, Integer.MIN_VALUE, Integer.MAX_VALUE);
}

private TreeNode deserializeHelper(Queue<Integer> queue, int min, int max) {
    if (queue.isEmpty()) return null;
    
    int value = queue.peek();
    if (value < min || value > max) return null;
    
    queue.poll();
    TreeNode node = new TreeNode(value);
    node.left = deserializeHelper(queue, min, value);
    node.right = deserializeHelper(queue, value, max);
    
    return node;
}
```

## 🎭 **Паттерны итераторов**

### 1. **Итератор BST**
```java
class BSTIterator {
    private Stack<TreeNode> stack;
    
    public BSTIterator(TreeNode root) {
        stack = new Stack<>();
        pushAllLeft(root);
    }
    
    public boolean hasNext() {
        return !stack.isEmpty();
    }
    
    public int next() {
        TreeNode node = stack.pop();
        pushAllLeft(node.right);
        return node.val;
    }
    
    private void pushAllLeft(TreeNode node) {
        while (node != null) {
            stack.push(node);
            node = node.left;
        }
    }
}
```

## 📈 **Паттерны анализа**

### 1. **Проверка сбалансированности**
```java
public boolean isBalanced(TreeNode root) {
    return checkHeight(root) != -1;
}

private int checkHeight(TreeNode node) {
    if (node == null) return 0;
    
    int leftHeight = checkHeight(node.left);
    if (leftHeight == -1) return -1;
    
    int rightHeight = checkHeight(node.right);
    if (rightHeight == -1) return -1;
    
    if (Math.abs(leftHeight - rightHeight) > 1) return -1;
    
    return Math.max(leftHeight, rightHeight) + 1;
}
```

### 2. **Наибольшая сумма пути**
```java
private int maxSum = Integer.MIN_VALUE;

public int maxPathSum(TreeNode root) {
    calculateMaxPathSum(root);
    return maxSum;
}

private int calculateMaxPathSum(TreeNode node) {
    if (node == null) return 0;
    
    int leftMax = Math.max(0, calculateMaxPathSum(node.left));
    int rightMax = Math.max(0, calculateMaxPathSum(node.right));
    
    maxSum = Math.max(maxSum, leftMax + rightMax + node.val);
    
    return Math.max(leftMax, rightMax) + node.val;
}
```

## 💡 **Ключевые выводы:**

### **Важные свойства:**
- **In-order обход** дает отсортированную последовательность
- **Высота** определяет эффективность операций
- **Баланс** критически важен для производительности

### **Основные паттерны:**
- **Рекурсивный обход** - основа большинства операций
- **Итеративный обход** - эффективное использование памяти
- **Разделяй и властвуй** - построение сбалансированных деревьев
- **Two-pointer в дереве** - поиск пар узлов

### **Практическое применение:**
- **Базы данных** - индексы B-tree
- **Файловые системы** - организация директорий
- **Кэширование** - структуры данных с быстрым поиском
- **Сети** - таблицы маршрутизации

Эти паттерны охватывают большинство практических задач с BST и являются фундаментом для понимания более сложных древовидных структур!
