# Axios 速通文档

> 面向后端开发者的 Axios 速查手册。目标：够用就行，覆盖前端调用你写的 Java 后端接口时需要的核心用法。

---

## 1. Axios 是什么

一句话：**JS 版的 HTTP 请求工具**，专门用来在前端页面里发请求，调用后端接口。

跟 Java 里发 HTTP 请求的工具类比一下：

|Java|JS|
|---|---|
|`HttpClient` / `RestTemplate`|`axios`|
|后端调用别的服务的接口|前端调用你写的后端接口|

浏览器本身自带一个更底层的 `fetch`，但 `axios` 封装得更好用（自动转JSON、错误处理更方便），实际项目里基本都用 axios。

---

## 2. 引入方式

```html
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
```

引入后，全局直接能用 `axios` 这个对象，不用额外处理。

---

## 3. 发 GET 请求（查询数据）

### 写法一：直接传URL

```javascript
axios.get('https://api.xxx.com/emps/list').then(res => {
    console.log(res.data);
})
```
分两部分：
1. `axios.get('...')` —— 发起请求，**立刻返回一个 Promise 对象**（这时候请求可能还没完成，但代码已经往下走了）
2. `.then(res => {...})` —— 在这个 Promise 对象上"追加"一段逻辑：等请求真正完成、拿到结果后，自动执行这个函数

`res` 不是关键字，随便叫什么都行

流程:
```
1. 执行 axios.get('...')          → "嘿服务器，把emps/list的数据给我"（信发出去了，不等）
2. .then(res => {...})            → "等你数据回来了，就按这个逻辑处理"
3. （中间可能有几十到几百毫秒的网络延迟，JS这段时间去做别的事了）
4. 服务器返回数据                  → axios收到了
5. 自动执行 then() 里的函数         → res就是服务器返回的响应对象
6. console.log(res.data)          → 打印出真正的数据内容
```
### 写法二：配置对象形式

```javascript
axios({
    url: 'https://api.xxx.com/emps/list',
    method: 'get'
}).then(res => {
    console.log(res.data);
})
```

两种写法效果一样，**写法一更常用**，更简洁。

### 带查询参数（拼在URL后面）

```javascript
// 手动拼接（简单场景常用）
axios.get(`https://api.xxx.com/emps/list?name=${name}&gender=${gender}`)

// 用 params 配置（参数多、有特殊字符时更推荐，axios自动处理编码）
axios.get('https://api.xxx.com/emps/list', {
    params: {
        name: name,
        gender: gender
    }
})
```

`params` 写法会被 axios 自动转换成 `?name=xxx&gender=xxx` 拼在 URL 后面，效果和手动拼接一样，但更不容易因为特殊字符（比如中文、`&`）出问题。

对应你的 Java 后端接口大概长这样：

```java
@GetMapping("/emps/list")
public Result list(String name, String gender) {
    // ...
}
```

---

## 4. 发 POST 请求（提交/修改数据）

```javascript
axios.post('https://api.xxx.com/emps/update', {
    id: 1,
    name: '张三',
    age: 20
}).then(res => {
    console.log(res.data);
})
```

`post` 方法第二个参数就是要提交的数据（对象），axios 会自动转成 JSON 放进请求体（request body）。

配置对象写法：

```javascript
axios({
    url: 'https://api.xxx.com/emps/update',
    method: 'post',
    data: {
        id: 1,
        name: '张三'
    }
}).then(res => {
    console.log(res.data);
})
```

**注意**：GET 请求用 `params`（拼URL），POST 请求用 `data`（放请求体），**不要混用**。

对应你的 Java 后端接口：

```java
@PostMapping("/emps/update")
public Result update(@RequestBody Employee emp) {
    // @RequestBody 就是用来接收前端 axios post 传过来的 JSON 数据
}
```

---

## 5. 常用请求方法速查

```javascript
axios.get(url)              // 查询
axios.post(url, data)       // 新增/提交
axios.put(url, data)        // 更新（整体替换）
axios.delete(url)           // 删除
```

对应 Spring 的注解：

|axios方法|Spring注解|
|---|---|
|`axios.get`|`@GetMapping`|
|`axios.post`|`@PostMapping`|
|`axios.put`|`@PutMapping`|
|`axios.delete`|`@DeleteMapping`|

---

## 6. 处理返回结果

```javascript
axios.get(url).then(res => {
    console.log(res.data);   // 后端返回的数据在这
}).catch(err => {
    console.log(err);        // 请求失败（网络错误、状态码非2xx等）
})
```

`res`（response对象）里常用的字段：

```javascript
res.data       // 后端返回的响应体内容（最常用）
res.status     // HTTP状态码，比如200、404
res.headers    // 响应头
```

### 后端返回结构举例

假设你的 Spring Boot 接口统一返回这种格式：

```json
{
  "code": 200,
  "msg": "success",
  "data": [ {...}, {...} ]
}
```

那么真正想要的数据要多取一层：

```javascript
axios.get(url).then(res => {
    console.log(res.data);        // 整个响应体：{code, msg, data}
    console.log(res.data.data);   // 才是真正的业务数据
})
```

**如果不确定结构，先 `console.log(res.data)` 打印出来看一眼真实格式**，比瞎猜靠谱。

---

## 7. then 写法 vs async/await 写法

两种写法效果完全一样，看个人/团队习惯：

```javascript
// then 写法（更常见于教程）
axios.get(url).then(res => {
    console.log(res.data);
}).catch(err => {
    console.log(err);
})

// async/await 写法（更接近同步代码的书写习惯，可读性更好）
async function getData() {
    try {
        const res = await axios.get(url);
        console.log(res.data);
    } catch (err) {
        console.log(err);
    }
}
```

在 Vue 的 `methods` 里两种都很常见：

```javascript
methods: {
    // then写法
    search() {
        axios.get(url).then(res => {
            this.empList = res.data.data;
        })
    },
    // async/await写法
    async search() {
        const res = await axios.get(url);
        this.empList = res.data.data;
    }
}
```

---

## 8. 结合 Vue 的完整实战示例

```javascript
createApp({
    data() {
        return {
            searchForm: { name: '', gender: '' },
            empList: []
        }
    },
    mounted() {
        this.search();   // 页面加载完先查一次
    },
    methods: {
        search() {
            axios.get('https://api.xxx.com/emps/list', {
                params: {
                    name: this.searchForm.name,
                    gender: this.searchForm.gender
                }
            }).then(res => {
                this.empList = res.data.data;
            })
        },
        deleteEmp(id) {
            axios.delete(`https://api.xxx.com/emps/${id}`).then(res => {
                if (res.data.code === 200) {
                    this.search();   // 删除成功后重新查一次，刷新列表
                }
            })
        }
    }
}).mount('#app')
```

**关键点：回调函数用箭头函数**（之前讲过this指向问题，这里再强调一次）：

```javascript
axios.get(url).then(res => {
    this.empList = res.data.data;   // ✅ 箭头函数，this正确指向Vue实例
})

axios.get(url).then(function(res) {
    this.empList = res.data.data;   // ❌ 普通function，this指向错误，会报错
})
```

---

## 9. 设置请求头（了解即可，涉及登录鉴权时会用）

```javascript
axios.get(url, {
    headers: {
        'Authorization': 'Bearer ' + token
    }
})
```

常用于携带登录令牌（token），后端通过 `@RequestHeader` 接收：

```java
@GetMapping("/emps/list")
public Result list(@RequestHeader("Authorization") String token) {
    // ...
}
```

---

## 10. 常见坑速查

|坑|说明|
|---|---|
|GET请求用了 `data` 传参|GET要用 `params`，`data` 是POST/PUT专用|
|拿到的是 `undefined`|检查是不是漏了一层 `res.data.data`，先打印`res.data`看真实结构|
|回调里 `this` 报错/拿不到数据|回调函数改成箭头函数|
|中文参数乱码|用 `params` 配置对象让axios自动编码，别手动拼URL时忘记处理特殊字符|
|请求没反应，控制台报CORS错误|跨域问题，需要后端配置允许跨域（`@CrossOrigin`），前端代码本身没问题|

**关于 CORS 跨域**，提一下（属于常见拦路虎，了解一下现象即可）：

浏览器出于安全考虑，默认**不允许**网页向"不同域名/端口"的接口发请求。你本地前端页面（比如 `localhost:5500`）请求你本地后端接口（比如 `localhost:8080`），就属于"跨域"，浏览器会拦截，控制台报类似 `CORS policy` 的错误。

这个问题**要在后端解决**，不是前端代码写错了：

```java
@CrossOrigin  // 加在Controller类或方法上，允许跨域访问
@RestController
public class EmpController {
    // ...
}
```

以后你自己写 Spring Boot 后端接口时，如果前端调用报 CORS 错误，第一反应就是去后端加这个注解。

---

## 总结：真正要记住的核心

1. GET用 `axios.get(url, {params:{...}})`，参数拼URL
2. POST/PUT用 `axios.post(url, data)`，参数放请求体
3. `.then(res => {})` 拿返回结果，注意可能要多取一层 `res.data.data`
4. 回调函数用箭头函数，避免 `this` 指向出错
5. 请求报错先看控制台，CORS问题去后端加 `@CrossOrigin`，别在前端瞎折腾
6. axios方法 ↔ Spring注解基本一一对应：get↔GetMapping，post↔PostMapping+RequestBody

这份文档覆盖的是"能看懂、能写出前端调后端接口"所需的量，不涉及拦截器（interceptor）、请求取消、并发请求控制这些进阶内容——正式项目做鉴权、统一错误处理时才会用到，遇到再单独问。