# JavaScript 速通文档

> 面向后端开发者的前端速查手册。目标：够用就行，不深挖底层原理，重点覆盖你写 Vue + Axios 时会用到的语法。

---
```html
<head>
    <link rel="stylesheet" href="style.css">  <!-- CSS放这 -->
</head>
<body>
    <div id="app">
    ...
    </div>
    <script src="app.js"></script>  <!-- JS放这 -->
</body>
```


## 1. 变量声明

```javascript
let name = 'Tom';      // 可重新赋值，块级作用域（最常用），双引号单引号都可以
const age = 18;        // 不可重新赋值，块级作用域（能用const就用const）
var old = '别用了';     // 老写法，函数作用域，容易踩坑，现代代码基本不用
```

**记住**：能用 `const` 就用 `const`，需要改变量值时才用 `let`，`var` 忘掉它。

---

## 2. 数据类型

JS 是**弱类型**语言，声明变量不用写类型，运行时自动判断。

```javascript
let str = 'hello';       // 字符串
let num = 100;           // 数字（整数小数不分家，都是 number）
```

**单引号 `'` 还是双引号 `"`？**

功能完全一样，JS 不区分，纯粹是风格问题：

```javascript
let a = 'hello';   // 都合法
let b = "hello";   // 都合法
```

- 业界更常用**单引号**（大多数代码规范工具如 ESLint 默认推荐单引号），保持统一风格即可，别在同一个项目里混用
- 唯一要注意的场景：字符串内容本身包含引号时，用另一种引号包裹能省去转义

```javascript
let s1 = "It's a test";     // 内容含单引号，外面用双引号更省事
let s2 = 'She said "hi"';   // 内容含双引号，外面用单引号更省事
```

- 如果字符串里需要**拼接变量**，优先用反引号（模板字符串），不纠结单双引号：

```javascript
let name = 'Tom';
let msg = `Hello, ${name}`;  // 反引号支持插值，单双引号都不行
```

```javascript
let bool = true;         // 布尔值
let arr = [1, 2, 3];     // 数组
let obj = { a: 1 };      // 对象
let n = null;            // 空值
let u;                   // undefined（声明了没赋值）
```

**判断类型**：`typeof 变量名`

```javascript
typeof 'hello'   // "string"
typeof 100       // "number"
typeof true      // "boolean"
typeof {}        // "object"
typeof undefined // "undefined"
```

```javascript
let name = 'Tom';
console.log(typeof name);   // "string"

let age = 18;
console.log(typeof age);    // "number"

let flag = true;
console.log(typeof flag);   // "boolean"

let obj = {};
console.log(typeof obj);    // "object"

let arr = [1,2,3];
console.log(typeof arr);    // "object"  ⚠️ 数组也是object，见下面说明

let u;
console.log(typeof u);      // "undefined"

let fn = function() {};
console.log(typeof fn);     // "function"
```
---

## 3. 字符串

```javascript
let name = 'Tom';
let age = 18;

// 模板字符串（推荐，用反引号 ` ）
let msg = `我叫${name}，今年${age}岁`;

// 传统拼接（老写法，能不用就不用）
let msg2 = '我叫' + name + '，今年' + age + '岁';
```
这个只是用来拼接，效果和我叫tom，今年18岁一样。

模板字符串在拼接 URL、拼接 HTML 内容时特别常用，比如你之前写的：

```javascript
axios.get(`https://xxx.com/emps/list?name=${this.searchForm.name}`)
```

---

## 4. 函数

### 4.1 三种写法

```javascript
// 普通函数声明
function add(a, b) {
    return a + b;
}

// 函数表达式
const add = function(a, b) {
    return a + b;
};

// 箭头函数（最常用，尤其在Vue/回调里）
const add = (a, b) => {
    return a + b;
};

// 箭头函数简写：单表达式可省略 return 和大括号
const add = (a, b) => a + b;

// 单个参数可以省略括号
const square = x => x * x;
```

### 4.2 对象里方法的简写

```javascript
// 完整写法
let obj = {
    sayHi: function() {
        console.log('hi');
    }
}

// ES6简写（等价，更常见）
let obj = {
    sayHi() {
        console.log('hi');
    }
}
```

---

## 5. 数组常用方法

```javascript
let arr = [1, 2, 3, 4, 5];

arr.push(6);           // 末尾添加，返回新长度
arr.pop();              // 删除末尾一个，返回被删的元素
arr.map(x => x * 2);    // 遍历+转换，返回新数组 [2,4,6,8,10]
arr.filter(x => x > 2); // 过滤，返回新数组 [3,4,5]
arr.forEach(x => console.log(x)); // 遍历，无返回值
arr.find(x => x > 2);   // 找到第一个满足条件的元素，返回 3
arr.includes(3);        // 是否包含某元素，返回 true/false
arr.length;              // 数组长度
```

**你在 Vue 里最常用的是 `map`**——比如把后端返回的数据转换格式。

---

## 6. 对象

```javascript
let user = {
    name: 'Tom',
    age: 18
};

// 取值
user.name          // 'Tom'
user['name']       // 'Tom'（用变量做key时必须用这种写法）

// 改值/加新属性
user.age = 20;
user.gender = '男';  // 对象可以随时加新属性，不需要提前声明
```

### 解构赋值（很常用，简化取值）

```javascript
let { name, age } = user;
console.log(name, age); // Tom 18

// 数组同理
let [a, b] = [1, 2];
```

---

## 7. this 指向（重点区分和 Java 的不同）

Java 里 `this` 永远指向"当前对象实例"，**在编译期就确定**，不会变。

JS 里 `this` **取决于函数怎么被调用**，是运行时动态决定的：

```javascript
let user = {
    name: 'Tom',
    sayHi() {
        console.log(this.name); // 这里 this 指向 user，因为是 user.sayHi() 调用的
    }
}
user.sayHi(); // 'Tom'
```

**箭头函数不绑定自己的 this**，它会用外层作用域的 this（这也是箭头函数在 Vue/回调里很受欢迎的原因，不用担心 this 跑偏）：

```javascript
methods: {
    search() {
        axios.get(url).then(res => {
            // 这里用箭头函数，this 依然指向Vue实例本身
            this.empList = res.data.data;
        })
    }
}
```

如果这里用普通 `function` 而不是箭头函数，`this` 就不再指向 Vue 实例了，会报错或者拿不到数据——**这是最容易踩的坑，记住回调函数优先用箭头函数**。

---

## 8. 条件与循环（跟 Java 基本一样，简单过一下）

```javascript
if (age >= 18) {
    console.log('成年');
} else if (age >= 12) {
    console.log('青少年');
} else {
    console.log('儿童');
}

// 三元表达式
let result = age >= 18 ? '成年' : '未成年';

for (let i = 0; i < 5; i++) {
    console.log(i);
}

for (let item of arr) {   // 遍历数组元素本身
    console.log(item);
}

for (let key in obj) {    // 遍历对象的key
    console.log(key, obj[key]);
}
```

---

## 9. 异步：Promise 和 async/await

这块是 JS 特有的东西，Java 里没有直接对应（Java 靠多线程/CompletableFuture 处理异步，机制不一样）。

### 9.1 为什么需要异步

发请求（比如 axios）不会立刻拿到结果，浏览器不能"卡住等结果"，所以要用异步方式：请求发出去后先不管，等结果回来了再执行后续逻辑。

### 9.2 Promise + then（你目前一直在用的写法）

```javascript
axios.get(url).then(res => {
    console.log(res.data); // 请求成功后执行
}).catch(err => {
    console.log(err); // 请求失败后执行
})
```

### 9.3 async/await（更简洁的写法，效果等价）

```javascript
async function getData() {
    try {
        const res = await axios.get(url);
        console.log(res.data);
    } catch (err) {
        console.log(err);
    }
}
```

- `async` 标记这是一个异步函数
- `await` 后面跟一个 Promise，会"暂停"等待这个请求结果回来，再往下执行
- 看起来像同步代码，但本质还是异步——只是写法更接近你熟悉的 Java 同步代码风格

**两种写法二选一即可，效果一样**，`then` 写法更常见于教程和老代码，`async/await` 更现代、可读性更好。

---

## 10. ES6 常用语法糖速查表

|语法|例子|说明|
|---|---|---|
|模板字符串|`` `${name}` ``|拼接字符串更方便|
|箭头函数|`x => x * 2`|简化函数写法|
|解构赋值|`let {a, b} = obj`|快速取对象/数组的值|
|展开运算符|`[...arr1, ...arr2]`|合并数组/对象，复制|
|默认参数|`function f(x = 10) {}`|参数没传时用默认值|
|可选链|`obj?.a?.b`|连续取值时避免报错（前面某层是null/undefined时不报错，直接返回undefined）|

**展开运算符示例**（复制对象常用，避免直接修改原对象）：

```javascript
let user = { name: 'Tom', age: 18 };
let newUser = { ...user, age: 20 }; // 复制user，覆盖age字段
// newUser = { name: 'Tom', age: 20 }，原user不受影响
```

---

## 11. DOM 操作基础（了解即可，Vue项目里很少手写）

```javascript
document.querySelector('.box');       // 选一个元素
document.querySelectorAll('.box');    // 选多个元素（返回类数组）
document.getElementById('app');       // 按id选

el.addEventListener('click', function() { ... }); // 绑定事件

el.style.color = 'red';               // 改样式
el.innerHTML = '<p>内容</p>';         // 改内容（含HTML标签）
el.textContent = '纯文本';            // 改内容（纯文本，更安全）
```

**用了 Vue 之后，这些原生DOM操作基本用不上**——Vue 帮你自动处理了"数据变化 → 页面更新"这件事（`v-model`、`v-if`、`{{}}` 插值），你只需要关心数据本身，不用手动操作DOM。了解这块是为了明白 Vue 底层帮你省了什么。

---

## 12. 和 Java 的关键差异速记

|特性|Java|JavaScript|
|---|---|---|
|类型系统|强类型，编译时检查|弱类型，运行时才确定|
|this指向|固定指向当前对象，编译期确定|取决于调用方式，运行时动态决定|
|函数地位|必须依附于类/接口|一等公民，可以直接赋值给变量传来传去|
|异步处理|多线程/CompletableFuture|单线程+事件循环，Promise/async-await|
|类型转换|显式强转|隐式转换较多，容易有坑（如 `==` 和 `===`）|
|空值判断|`null`|`null` 和 `undefined` 两种"空"|

**关于 `==` 和 `===`**：JS 里永远用 `===`（严格相等，类型不同直接判false），别用 `==`（会做隐式类型转换，容易出诡异bug，比如 `'1' == 1` 结果是 `true`）。这是新手最容易踩的坑之一。

---

## 13. 你实际会用到的高频组合（结合Vue场景）

```javascript
// 典型的Vue组件写法，把本文档知识点串起来
export default {
    data() {
        return {
            userList: []   // 声明响应式数据
        }
    },
    mounted() {
        this.loadData();   // 生命周期钩子，组件挂载完自动执行
    },
    methods: {
        // async/await + axios 发请求（箭头函数不需要，这里methods里用普通写法即可）
        async loadData() {
            const res = await axios.get('/api/users');
            this.userList = res.data.data.map(item => ({
                ...item,                     // 展开原对象所有字段
                fullName: `${item.firstName}${item.lastName}` // 加一个计算字段
            }));
        }
    }
}
```

这一段基本把 `async/await`、`map`、模板字符串、展开运算符、`this` 全用上了，是你以后写 Vue 组件时最常见的代码形态。

---

## 总结：真正要记住的核心

1. `let`/`const` 替代 `var`
2. 箭头函数在回调里优先用（避免 this 指向问题）
3. `map`/`filter`/`forEach` 是数组操作的主力
4. `async/await` 或 `then` 处理异步请求，二选一
5. 模板字符串拼接字符串，别再用 `+`
6. 判断相等永远用 `===`
7. Vue 项目里几乎不需要手写 DOM 操作，专注数据逻辑就够了

这份文档覆盖的是"够写 Vue + Axios"的量，不涉及闭包、原型链、事件循环底层机制这些前端进阶内容——你不需要深挖这些，遇到具体问题再单独问就行。