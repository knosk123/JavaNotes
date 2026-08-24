# Spring Boot 速通文档

> Java Web 开发核心框架速查手册。你已经写过 `@RestController`/`@RequestMapping` 这类代码了，这份文档把散落的知识点串成完整体系。

---

## 1. Spring Boot 是什么，解决什么问题

一句话：**Spring Boot 是一套"开箱即用"的框架，让你几行代码就能启动一个能处理HTTP请求的Web服务器**。

在这之前（传统Java Web开发），你要手动配置很多东西：Web服务器（Tomcat）、各种XML配置文件、依赖管理……非常繁琐。Spring Boot 把这些**约定俗成的配置全部简化**，你只需要关心"业务逻辑怎么写"，其他的它帮你搞定。

**跟你已经会的知识对应一下**：

- Maven 帮你管理依赖 → Spring Boot 项目也是一个 Maven 项目，`pom.xml` 里引入 `spring-boot-starter-web` 就自带了内嵌的 Tomcat
- 你之前写的 `@RestController`、`@RequestMapping` → 这些注解就是 Spring 提供的，用来告诉框架"这个类/方法负责处理什么请求"
- axios 发的请求 → 最终就是打到 Spring Boot 启动的这个内嵌 Tomcat 上，由你写的 Controller 方法接收处理

---

## 2. 项目结构

一个标准 Spring Boot 项目大概长这样：

```
my-project/
├── pom.xml                              ← Maven依赖配置
├── src/main/java/com/itheima/
│   ├── MyProjectApplication.java        ← 启动类（程序入口）
│   ├── controller/                      ← 控制层：接收前端请求
│   │   └── EmpController.java
│   ├── service/                         ← 业务层：处理业务逻辑
│   │   ├── EmpService.java              ← 接口
│   │   └── impl/EmpServiceImpl.java     ← 实现类
│   └── mapper/                          ← 数据访问层：操作数据库
│       └── EmpMapper.java
└── src/main/resources/
    ├── application.yml                   ← 项目配置文件（数据库连接、端口等）
    └── static/                            ← 静态资源（html/css/js，如果前后端不分离才需要）
```

这套 **controller → service → mapper** 三层结构叫**三层架构**，是Java Web的标准分层方式，下面详细讲。

---

## 3. 启动类

```java
package com.itheima;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MyProjectApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyProjectApplication.class, args);
    }
}
```

- `@SpringBootApplication` —— 整个项目的核心注解，标记"这是一个Spring Boot应用的入口"，它内部其实打包了好几个注解的功能（自动配置、组件扫描等），你只需要知道**这个注解必须加在启动类上**
- `main` 方法 —— Java程序标准入口，`SpringApplication.run(...)` 这一行代码，会启动内嵌的Tomcat，加载整个Spring容器，项目就跑起来了

运行这个 `main` 方法（IDEA里点绿色箭头），控制台会打印一堆启动日志，最后看到类似 `Tomcat started on port 8080` 就说明启动成功了，可以在浏览器/axios里访问了。

---

## 4. 三层架构：Controller / Service / Mapper

这是 Spring Boot（以及Java Web整体）最重要的设计思想——**把不同职责的代码拆开，各司其职**。

```
前端请求
    ↓
Controller（控制层）  —— 接收请求、返回响应，不写具体业务逻辑
    ↓
Service（业务层）     —— 写核心业务逻辑（比如"计算工资"、"校验数据"）
    ↓
Mapper（数据访问层）  —— 负责跟数据库打交道（增删改查SQL）
    ↓
数据库
```

### Controller：接收请求

```java
package com.itheima.controller;

import com.itheima.service.EmpService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/emps")
public class EmpController {

    @Autowired
    private EmpService empService; //创建对象empService

    @GetMapping("/list")
    public Result list(String name, String gender) {
        List<Emp> empList = empService.list(name, gender);
        return Result.success(empList);
    }
}
```

![[Pasted image 20260823162649.png]]

- `@RestController` —— 你已经知道了，标记这是一个"返回JSON数据"的控制器
- `@RequestMapping("/emps")` —— 写在类上，表示这个类里所有接口，路径都以 `/emps` 开头（比如下面的 `/list` 实际访问路径是 `/emps/list`）
- Controller 层**不写具体业务逻辑**，只负责"接收参数 → 调用Service → 把结果包装成响应返回"，逻辑上很薄


## Q：@RequestMapping("/emps")和@GetMapping("/list")到底有什么区别？

A：两者本质上是**同一类东西**（都是"路径映射"注解），区别在于**限定的请求方式**和**通常的使用位置**。
```java
@RequestMapping("/emps")   // 不限定请求方式，GET/POST/PUT/DELETE都能匹配上
@GetMapping("/list")       // 明确限定：只匹配GET请求
```

**它们其实是"父子关系"**，`@GetMapping` 底层就是 `@RequestMapping` 加了个限制：
```java
// 这两种写法效果完全一样
@GetMapping("/list")
public Result list() { ... }

@RequestMapping(value = "/list", method = RequestMethod.GET)
public Result list() { ... }
```

`@GetMapping("/list")` 只是 `@RequestMapping(value="/list", method=RequestMethod.GET)` 的**简写**。

**为什么你在图里看到的用法不一样：一个在类上，一个在方法上**

```java
@RestController
@RequestMapping("/emps")          // 写在类上
public class EmpController {

    @GetMapping("/list")           // 写在方法上
    public Result list() { ... }

    @PostMapping("/add")
    public Result add() { ... }
}
```

这是Spring里非常常见的**组合用法**，作用是"**路径拼接**"：

- 类上的 `@RequestMapping("/emps")` —— 给这个类下所有接口，统一加一个**路径前缀**
- 方法上的 `@GetMapping("/list")` —— 加上前缀后，实际完整路径是 `/emps/list`

```
最终访问路径 = 类上的路径前缀 + 方法上的路径
```

所以上面这段代码，实际能访问到的接口是：

- `GET /emps/list` → 触发 `list()`
- `POST /emps/add` → 触发 `add()`

**为什么类上一般用 `@RequestMapping`，而不是 `@GetMapping`**

因为类上标注的是**整个类的公共前缀**，这个类里的方法可能有 GET 也有 POST（增删改查都可能有），如果类上写死了 `@GetMapping`，那这个类下所有方法都只能是GET请求，就没法灵活区分了。所以类级别的注解习惯用**不限定方式**的 `@RequestMapping`，具体每个方法再用精确的 `@GetMapping`/`@PostMapping` 去区分。
![[Pasted image 20260823162459.png]]


### Service：业务逻辑

```java
package com.itheima.service;

public interface EmpService {
    List<Emp> list(String name, String gender);
}
```

```java
package com.itheima.service.impl;

import com.itheima.service.EmpService;
import org.springframework.stereotype.Service;

@Service
public class EmpServiceImpl implements EmpService {

    @Autowired
    private EmpMapper empMapper;

    @Override
    public List<Emp> list(String name, String gender) {
        // 这里写真正的业务逻辑，比如数据校验、多步骤处理
        return empMapper.list(name, gender);
    }
}
```

- Service 先定义**接口**（`EmpService`），再写**实现类**（`EmpServiceImpl`）——这是Java里"面向接口编程"的体现，你之前学OOP时接触过接口的概念，这里就是实际应用场景
- `@Service` —— 标记这个类是一个"业务层组件"，交给Spring管理

### Mapper：操作数据库

```java
package com.itheima.mapper;

import org.apache.ibatis.annotations.*;

@Mapper
public interface EmpMapper {

    @Select("select * from emp where name like concat('%',#{name},'%')")
    List<Emp> list(String name, String gender);
}
```

- `@Mapper` —— 标记这是数据访问层接口（这里用了 MyBatis 框架简化SQL操作，先了解个大概就行，等专门学到数据库对接这块再深入）
- 这一层是唯一直接跟数据库打交道的地方，其他层都不应该直接写SQL

---

## 5. 依赖注入：`@Autowired`

```java
@Autowired
private EmpService empService;
```

这行代码的意思是：**"我需要用一个EmpService对象，请Spring自动帮我创建/找到一个，塞给我，我自己不用手动 `new`"**。

**对比一下没有依赖注入时怎么写**

```java
// 没有Spring时，得自己手动new
EmpService empService = new EmpServiceImpl();
```

```java
// 有Spring的依赖注入，自动完成
@Autowired
private EmpService empService;
// 这行代码执行后，empService已经自动指向了一个EmpServiceImpl对象，你不用写new
```

**为什么要这样设计**

Spring 会在项目启动时，把所有标了 `@Service`、`@Controller`、`@Mapper`、`@Component` 这些注解的类，**统一创建好对象（这些对象叫"Bean"），放进一个"容器"里管理**。当某个类需要用到另一个类时（比如Controller要用Service），不用自己手动 `new`，只需要写 `@Autowired`，Spring会自动从容器里找到对应的Bean"注入"进来。

好处：解耦、方便测试、方便切换实现类（比如以后想换一个 `EmpServiceImpl` 的实现，代码几乎不用改）。这套机制叫 **IOC（控制反转）+ DI（依赖注入）**，是Spring框架的核心思想，名字听起来玄乎，实际用起来就是"加个 `@Autowired`，Spring自动帮你把对象准备好"。

---

## 6. 接收参数的几种方式

### `@RequestParam`（接收URL查询参数，你之前axios的params对应这个）

```java
@GetMapping("/list")
public Result list(@RequestParam String name) {
    // 前端: axios.get('/emps/list?name=张三')
}
```

如果方法参数名和URL参数名一致，`@RequestParam` **可以省略不写**：

```java
@GetMapping("/list")
public Result list(String name) {  // 效果一样，Spring自动按名字匹配
}
```

### `@RequestBody`（接收请求体JSON，你之前axios的data对应这个）

```java
@PostMapping("/add")
public Result add(@RequestBody Emp emp) {
    // 前端: axios.post('/emps/add', { name: '张三', age: 20 })
    // Spring自动把JSON转成Emp对象
}
```

### `@PathVariable`（接收URL路径中的参数）

```java
@DeleteMapping("/{id}")
public Result delete(@PathVariable Integer id) {
    // 前端: axios.delete('/emps/5')  → id自动等于5
}
```

### 速查表

|注解|用于接收|对应的axios写法|
|---|---|---|
|`@RequestParam`（可省略）|URL问号后的查询参数|`axios.get(url, {params:{...}})`|
|`@RequestBody`|请求体里的JSON数据|`axios.post(url, data)`|
|`@PathVariable`|URL路径里的一部分（如 `/emps/5` 里的5）|`axios.delete(`/emps/${id}`)`|

---

## 7. 统一响应结果：`Result`

实际项目里，接口一般不会直接返回裸数据，而是包一层统一格式，方便前端统一处理：

```java
public class Result {
    private Integer code;   // 状态码，200表示成功
    private String msg;     // 提示信息
    private Object data;    // 真正的数据

    public static Result success(Object data) {
        Result r = new Result();
        r.code = 200;
        r.msg = "success";
        r.data = data;
        return r;
    }

    public static Result error(String msg) {
        Result r = new Result();
        r.code = 500;
        r.msg = msg;
        return r;
    }
    // getter/setter省略
}
```

这就是你之前在Axios文档里问过的 `res.data.data` 那"多一层"的来源——后端统一返回这种 `{code, msg, data}` 结构，前端要拿真实数据得多取一层 `.data`。

---

## 8. 配置文件：`application.yml`

```yaml
server:
  port: 8080          # 服务启动端口

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/tlias
    username: root
    password: 123456
    driver-class-name: com.mysql.cj.jdbc.Driver
```

这个文件负责配置项目运行相关的各种参数，最常用的就是**服务端口**和**数据库连接信息**。YAML格式用**缩进**表示层级关系（类似Python，不用大括号），冒号后面要加空格。

---

## 9. 跨域配置：`@CrossOrigin`

之前Axios文档里提过，前端页面跟后端接口如果域名/端口不一致，会被浏览器拦截（CORS问题），后端加这个注解解决：

```java
@CrossOrigin
@RestController
public class EmpController {
    // 这个类下所有接口都允许跨域访问
}
```

正式项目里更常见的做法是写一个全局配置类，一次性给所有Controller开放跨域，而不是每个类都单独加注解（先了解现象，具体这个全局配置怎么写，用到时再展开）。

---

## 10. 完整流程串一遍（配合你之前写的前端代码）

```
1. 前端：axios.get('/emps/list?name=张三')
        ↓
2. Controller接收请求：
   @GetMapping("/list")
   public Result list(String name) {
       List<Emp> list = empService.list(name);   ← 调用Service
       return Result.success(list);               ← 包装成统一格式返回
   }
        ↓
3. Service处理业务逻辑：
   public List<Emp> list(String name) {
       return empMapper.list(name);   ← 调用Mapper
   }
        ↓
4. Mapper查数据库：
   @Select("select * from emp where name like ...")
   List<Emp> list(String name);
        ↓
5. 数据库返回结果 → 一路往上传 → Controller返回JSON
        ↓
6. 前端拿到res.data.data，Vue自动渲染表格
```

这就是一个完整的"前端 → 后端三层架构 → 数据库"的请求处理流程，也是你之前写的所有前端代码（Vue+Axios），最终要对接的后端全貌。

---

## 常见坑速查

|坑|说明|
|---|---|
|`@Autowired` 报红/注入失败|检查目标类有没有加 `@Service`/`@Component` 这类注解，Spring才能识别并管理它|
|接口访问404|检查 `@RequestMapping` 路径拼写、请求方式（GET/POST）是否对得上|
|前端跨域报错|后端加 `@CrossOrigin`，不是前端代码问题|
|`@RequestBody` 接收不到数据|确认前端确实是把数据放进了请求体（`axios.post(url, data)`），而不是拼在URL上|
|修改了代码但没生效|检查是不是忘记重启项目（Spring Boot改代码后一般需要重启，除非配置了热部署）|

---

## 总结

Spring Boot 的核心工作流程可以概括为：

1. **启动**：`@SpringBootApplication` + `main` 方法，一键启动内嵌服务器
2. **接收请求**：Controller 层用 `@RequestMapping`/`@GetMapping` 等注解声明"哪个路径归我管"，用 `@RequestParam`/`@RequestBody`/`@PathVariable` 接收不同来源的参数
3. **分层处理**：Controller 调 Service（业务逻辑），Service 调 Mapper（数据库操作），各层职责清晰、互不越界
4. **依赖管理**：`@Autowired` 让 Spring 自动帮你创建和注入对象，不用手动 `new`
5. **统一响应**：用 `Result` 类统一封装返回格式，方便前端处理

**相关知识延伸**：

- **MyBatis**：上面 Mapper 层用 `@Select` 直接写SQL的方式叫 MyBatis 注解方式，实际项目里SQL复杂时更常用 XML 映射文件写法，这块属于"持久层框架"范畴，是Java Web里跟数据库打交道的标准工具，值得专门花时间学。
- **全局异常处理**：实际项目不会让每个Controller方法自己try-catch处理异常，而是用 `@RestControllerAdvice` 统一捕获所有Controller抛出的异常，返回统一的错误格式，这样每个业务方法可以专注写正常逻辑，不用到处写异常处理代码。
- **参数校验**：配合 `@Valid` 注解和 `@NotNull`/`@Size` 这类校验注解，可以在方法执行前自动校验参数合法性（比如姓名不能为空、年龄要在合理范围），不用手写一堆if判断。
- **拦截器/过滤器**：如果想在请求真正到达Controller之前统一做点什么（比如登录校验、日志记录），会用到拦截器（Interceptor）机制，这也是之后学登录鉴权时的重要知识点。

这份文档覆盖的是"看懂并能写出一个基础CRUD接口"所需的量，MyBatis细节、全局异常处理、参数校验、拦截器这些进阶内容，等你正式学到对应章节时再深入，目前有个印象、知道"以后会用到"就够了。