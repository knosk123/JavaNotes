# Vue 速通文档

> 面向后端开发者的 Vue 速查手册。目标：够用就行，覆盖你写"前端展示 + axios调后端接口"这类场景需要的核心语法。

---

## 1. 引入方式

### CDN引入（学习/小demo用，你目前主要用这种）

```html
<script type="module">
  import { createApp } from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js'
</script>
```

### npm安装（正式项目用，需要脚手架，先了解即可）

```bash
npm create vue@latest
```

---

## 2. 基本结构：一个Vue应用长什么样

```html
<div id="app">
    {{ message }}
</div>

<script type="module">
    import { createApp } from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js'

    createApp({
        data() {
            return {
                message: 'Hello Vue'
            }
        }
    }).mount('#app')
</script>
```

三件事：

1. `createApp({...})` —— 创建一个Vue应用实例，配置对象里写数据和逻辑
2. `data()` —— 返回这个应用要用到的**响应式数据**（数据变了，页面自动跟着变）
3. `.mount('#app')` —— 把这个Vue应用"挂载"到页面上某个元素里，只有这个元素内部才受Vue管理

---

## 3. 插值表达式 `{{ }}`

用来把数据显示在**标签内容**里：

```html
<p>{{ message }}</p>
<p>{{ 1 + 1 }}</p>              <!-- 支持表达式，显示2 -->
<p>{{ age >= 18 ? '成年' : '未成年' }}</p>  <!-- 支持三元表达式 -->
```

**⚠️ 只能用在标签内容里，不能用在标签属性上**：

```html
<img alt="{{ name }}">   <!-- ❌ 错误，不生效 -->
```

属性想绑定动态值，要用下面讲的 `v-bind`。

---

## 4. v-bind：绑定属性

```html
<img v-bind:src="imageUrl">
<!-- 简写（更常用） -->
<img :src="imageUrl">

<img :alt="userName">
<a :href="linkUrl">点击</a>
```

规律：**标签的属性**（等号赋值的那些）想用变量，前面加 `:` 或 `v-bind:`。

---

## 5. v-model：双向绑定（表单常用）

用在 `input`、`select`、`textarea` 这类表单元素上，实现"输入框的值 ↔ 数据"自动同步：

```html
<input v-model="searchForm.name" placeholder="姓名" />
<p>你输入的是：{{ name }}</p>
```

```javascript
data() {
    return {
        searchForm: { name: '' } //左边key右边value
    }
}
```

- 用户在输入框打字 → `searchForm.name` 自动更新
- 代码里改 `searchForm.name` → 输入框内容也自动更新

配合 `select`：

```html
<select v-model="searchForm.gender">
    <option value="">全部</option>
    <option value="1">男</option>
    <option value="2">女</option>
</select>
```

---

## 6. v-for：循环渲染（渲染表格/列表的核心）

```html
<tr v-for="(item, index) in list" :key="index">
    <td>{{ item.name }}</td>
</tr>
```

- `(item, index)` —— `item` 是当前遍历到的元素，`index` 是下标（可省略不写）
- `in list` —— 要遍历的数组
- `:key="index"` —— **必须写**，Vue内部用来识别每一项，帮助高效更新，通常绑定数据里唯一的id更好，没有id就用index兜底

**命名习惯**：数组用复数（`brands`），循环出来的单个元素用单数（`brand`），避免俩变量重名混淆：

```html
<tr v-for="(brand, index) in brands" :key="index">
    <td>{{ brand.name }}</td>
</tr>
```

---

## 7. v-if / v-else-if / v-else：条件渲染

```html
<span v-if="score >= 85">优秀</span>
<span v-else-if="score >= 60">及格</span>
<span v-else>不及格</span>
```

条件不满足时，这个DOM元素**根本不会被渲染出来**（不是隐藏，是压根不存在）。

---

## 8. v-show：条件显示（跟v-if的区别）

```html
<span v-show="isVisible">内容</span>
```

跟 `v-if` 效果类似（都是控制"显不显示"），但原理不同：

||v-if|v-show|
|---|---|---|
|原理|条件不满足就不渲染这个元素（DOM里没有）|元素一直在DOM里，只是用CSS `display:none` 隐藏|
|适用场景|条件很少切换|需要频繁切换显示/隐藏（性能更好）|

**简单记**：不常变就用 `v-if`，经常来回切换就用 `v-show`。

---

## 9. @click：事件绑定

```html
<button @click="search">查询</button>
<!-- 等价于 -->
<button v-on:click="search">查询</button>
```

对应 `methods` 里定义的方法：

```javascript
methods: {
    search() {
        console.log('查询按钮被点击了');
    }
}
```

其他常见事件：`@input`、`@change`、`@submit`，用法都一样，`@事件名="方法名"`。

---

## 10. methods：定义方法

**`methods` 部分**——这是**新的一块**，跟 `data()` 是**平级**的（都是 `createApp({...})` 配置对象里的属性）

```javascript
createApp({
    data() {
        return { count: 0 }
    },
    methods: {
        increment() {
            this.count++;   // 方法里访问data里的数据，必须加 this.
        }
    }
}).mount('#app')
```

**记住**：`methods` 里访问 `data()` 返回的数据，一定要加 `this.`，因为 Vue 把 `data()` 返回的对象里所有字段，都挂到了 Vue 实例（也就是 `this`）上。

---

## 11. mounted：生命周期钩子（发请求的常用位置）

```javascript
createApp({
    data() {
        return { userList: [] }
    },
    mounted() {
        // Vue实例挂载完成后，自动执行这里的代码
        axios.get('/api/users').then(res => {
            this.userList = res.data.data;
        })
    }
}).mount('#app')
```

`mounted()` 会在页面渲染完成后**自动执行一次**，最常见的用途就是：页面一加载，立刻发请求去后端拿初始数据。

---

## 12. 结合axios：真实的数据请求场景

这是你实际项目里最常用的组合，把上面的知识点串起来：

```javascript
createApp({
    data() {
        return {
            searchForm: { name: '', gender: '', job: '' },
            empList: []
        }
    },
    mounted() {
        this.search();  // 页面加载完先查一次全部数据
    },
    methods: {
        search() {
            axios.get(`/emps/list?name=${this.searchForm.name}&gender=${this.searchForm.gender}`)
                .then(res => {
                    this.empList = res.data.data;
                })
        },
        clear() {
            this.searchForm = { name: '', gender: '', job: '' };
        }
    }
}).mount('#app')
```

```html
<input v-model="searchForm.name" placeholder="姓名" />
<button @click="search">查询</button>
<button @click="clear">清空</button>

<tr v-for="(emp, index) in empList" :key="index">
    <td>{{ emp.name }}</td>
    <td><img :src="emp.image"></td>
    <td>
        <span v-if="emp.gender === 1">男</span>
        <span v-else>女</span>
    </td>
</tr>
```

---

## 13. 常见坑速查

|坑|正确写法|
|---|---|
|`alt="{{ name }}"` 不生效|改成 `:alt="name"`|
|`v-for` 里俩变量重名|数组用复数，元素用单数，别都叫一样的名字|
|`v-for` 忘了写 `:key`|每次都要写 `:key="index"` 或 `:key="item.id"`|
|`v-if` 判断顺序写反|分数判断这类要从**高到低**判断，不然逻辑错|
|`methods` 里访问数据忘了 `this.`|`this.count`，别漏|
|`mounted` 里的回调用普通function|用箭头函数 `() => {}`，保证 `this` 还指向Vue实例|

**关于 `mounted` 里的 this 坑，展开说一下**：

```javascript
mounted() {
    axios.get(url).then(res => {
        this.empList = res.data.data;  // ✅ 箭头函数，this正确指向Vue实例
    })
}

mounted() {
    axios.get(url).then(function(res) {
        this.empList = res.data.data;  // ❌ 普通function，this不再指向Vue实例，会报错
    })
}
```

这跟你之前问过的 JS `this` 指向问题是同一个坑，Vue 里的回调函数**优先用箭头函数**，能避免这个问题。

---

## 14. 和你已经会的Java Web知识对应关系

|Vue概念|类比/关联|
|---|---|
|`data()`|相当于页面的"状态"，类似Java对象的成员变量|
|`methods`|相当于类里的方法|
|`mounted()`|类似Servlet的`init()`，或Spring的`@PostConstruct`——"准备好了自动跑一次"|
|`axios.get(url)`|前端发起HTTP请求，对应你后端要写的 `@GetMapping` 接口|
|`axios.post(url, data)`|对应后端 `@PostMapping` + `@RequestBody` 接收参数|
|`v-for` 渲染表格|类似JSP里的 `<c:forEach>`，只是Vue是响应式的，数据变了自动重新渲染|

---

## 总结：真正要记住的核心

1. `{{ }}` 用于标签内容，`:属性名` 用于标签属性，别混
2. `v-model` 做表单双向绑定
3. `v-for` 配 `:key`，遍历渲染列表/表格
4. `v-if` 条件少变化，`v-show` 频繁切换
5. `@click="方法名"` 绑定事件，方法写在 `methods` 里
6. `mounted()` 里发请求，拿到数据赋值给 `data()` 里的字段，页面自动刷新
7. 所有回调函数（尤其是 axios 的 `.then()`）优先用箭头函数，避免 `this` 指向问题

这份文档覆盖的是"能看懂、能改、能自己拼出一个前后端联调页面"所需的量，不涉及组件化开发（`.vue`文件、props、生命周期全集、Vuex/Pinia状态管理）这些进阶内容——真正做完整项目时才需要，遇到再单独问。