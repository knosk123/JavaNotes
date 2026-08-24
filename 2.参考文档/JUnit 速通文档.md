# JUnit 速通文档

> Java 单元测试框架速查手册，覆盖 JUnit5（Jupiter）的核心用法。

---

## 1. JUnit 是什么，解决什么问题

JUnit 是 Java 生态最主流的**单元测试框架**，作用是：**让你写的每个方法都能独立、自动化地验证"结果对不对"**，不用每次改完代码都手动跑 `main` 方法、肉眼看控制台输出。

没有 JUnit 之前，验证一个方法要这样：

```java
public static void main(String[] args) {
    UserService service = new UserService();
    Integer age = service.getAge("110002200505091218");
    System.out.println(age);  // 肉眼看，自己判断对不对
}
```

有了 JUnit，验证方式变成：

```java
@Test
public void testGetAge() {
    Integer age = new UserService().getAge("110002200505091218");
    Assertions.assertEquals(20, age);  // 自动判断，不用肉眼看
}
```

ps：![[Pasted image 20260823133816.png]]

区别在于：**JUnit 能自动断言"实际结果是否等于预期结果"**，测试跑完直接告诉你"通过"还是"失败"，不需要你自己盯着输出核对。

Maven 项目里，JUnit 通过 `pom.xml` 引入，只在 `src/test/java` 目录下生效（跟正式代码 `src/main/java` 是分开的两套源码目录，包名相同即可互相访问，具体关系可以参考"Maven和JUnit的关系"这块）。

---

## 2. 基础注解：`@Test`

标记一个方法是测试方法，让 JUnit（或 IDEA）识别并可以单独执行：

```java
import org.junit.jupiter.api.Test;

public class UserServiceTest {

    @Test
    public void testGetAge() {
        Integer age = new UserService().getAge("110002200505091218");
        System.out.println(age);
    }
}
```

- 方法必须是 `public`
- 方法名随意，但约定俗成写成 `test + 被测方法名`，方便一眼看出测的是哪个方法
- IDEA 里方法左边会出现一个绿色小箭头，可以单独点击运行这一个测试

---

## 3. 断言：`Assertions`（核心中的核心）

断言是 JUnit 的灵魂——**用代码自动判断"实际结果符不符合预期"**，不符合就让这个测试标记为"失败"。

### 常用断言方法速查

```java
import org.junit.jupiter.api.Assertions;

// 判断相等
Assertions.assertEquals(预期值, 实际值);
Assertions.assertEquals(预期值, 实际值, "失败时显示的提示信息");

// 判断不相等
Assertions.assertNotEquals(预期值, 实际值);

// 判断为true/false
Assertions.assertTrue(条件表达式);
Assertions.assertFalse(条件表达式);

// 判断为null/不为null
Assertions.assertNull(对象);
Assertions.assertNotNull(对象);

// 判断两个引用是否指向同一个对象（不是内容相等，是同一个引用）
Assertions.assertSame(obj1, obj2);
Assertions.assertNotSame(obj1, obj2);

// 判断会抛出指定异常
Assertions.assertThrows(异常类型.class, () -> {
    // 会抛出异常的代码
});
```

### 用法示例

```java
@Test
public void testGetGender() {
    String gender = new UserService().getGender("612429198904201611");
    Assertions.assertEquals("男", gender);  // 预期是"男"，如果实际结果不是"男"，测试失败
}
```

### `assertEquals` vs `assertSame` 的区别（容易搞混）

```java
String s1 = new String("Hello");
String s2 = "Hello";

Assertions.assertEquals(s1, s2);  // ✅ 通过，因为内容一样
Assertions.assertSame(s1, s2);    // ❌ 失败，因为s1和s2是内存里两个不同的对象
```

`assertEquals` 比较的是**内容/值**是否相等（底层调用 `.equals()`），`assertSame` 比较的是**是不是同一个对象引用**（底层用 `==`）——这跟你学 Java 基础时 `==` 和 `.equals()` 的区别是同一个知识点。

### 异常断言示例

```java
@Test
public void testDivideByZero() {
    Calculator calc = new Calculator();
    Assertions.assertThrows(ArithmeticException.class, () -> {
        calc.divide(10, 0);  // 预期这行代码会抛出 ArithmeticException
    });
}
```

用来验证"某段代码**应该**抛出异常"，如果没抛异常，或者抛的异常类型不对，测试失败。常用于验证参数校验逻辑（比如传了非法参数应该报错）。

---

## 4. `@DisplayName`：自定义测试展示名

```java
@Test
@DisplayName("测试根据身份证号获取年龄")
public void testGetAge() {
    // ...
}
```

不影响测试逻辑，只是让测试报告/IDEA测试面板显示更易读的名字，而不是原始方法名。

---

## 5. 生命周期注解：控制测试前后跑什么

这几个注解用来在测试方法执行**前后**自动插入一些准备/清理逻辑，避免每个测试方法都重复写同样的初始化代码。

```java
import org.junit.jupiter.api.*;

public class UserServiceTest {

    private UserService userService;

    @BeforeAll
    static void beforeAll() {
        System.out.println("整个测试类开始前，只执行一次");
    }

    @BeforeEach
    void beforeEach() {
        userService = new UserService();  // 每个测试方法执行前都跑一次
        System.out.println("每个测试方法前都执行");
    }

    @Test
    void testGetAge() {
        Integer age = userService.getAge("110002200505091218");
        Assertions.assertNotNull(age);
    }

    @Test
    void testGetGender() {
        String gender = userService.getGender("612429198904201611");
        Assertions.assertEquals("男", gender);
    }

    @AfterEach
    void afterEach() {
        System.out.println("每个测试方法后都执行");
    }

    @AfterAll
    static void afterAll() {
        System.out.println("整个测试类结束后，只执行一次");
    }
}
```

### 执行顺序

```
@BeforeAll（一次）
    @BeforeEach → testGetAge() → @AfterEach
    @BeforeEach → testGetGender() → @AfterEach
@AfterAll（一次）
```

### 速查表

|注解|执行时机|常见用途|
|---|---|---|
|`@BeforeAll`|整个测试类只执行一次，最先执行|建立数据库连接、加载配置（必须是static方法）|
|`@BeforeEach`|每个 `@Test` 方法执行前都跑一次|初始化测试对象，保证每个测试互不干扰|
|`@AfterEach`|每个 `@Test` 方法执行后都跑一次|清理测试数据|
|`@AfterAll`|整个测试类只执行一次，最后执行|关闭连接、释放资源（必须是static方法）|

**为什么要用 `@BeforeEach` 而不是把 `userService` 定义成类的成员变量直接初始化**

因为 `@BeforeEach` 能保证**每个测试方法执行前都拿到一个全新的对象**，测试之间互不影响（一个测试改了某个对象的状态，不会带到下一个测试里去）——这是单元测试很重要的原则：**每个测试应该相互独立，不依赖执行顺序，也不共享状态**。

---

## 6. `@ParameterizedTest` + `@ValueSource`：一个方法跑多组数据

普通 `@Test` 一次只能验证一组固定输入，`@ParameterizedTest` 可以让同一个方法**自动用多组数据分别跑一遍**：

```java
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

@ParameterizedTest
@ValueSource(strings = {
    "612429198904201611",
    "612429198904201612",
    "110002200505091218"
})
void testGetGenderMulti(String idCard) {
    String gender = new UserService().getGender(idCard);
    System.out.println(idCard + " -> " + gender);
}
```

- `@ValueSource` 提供一组数据，方法参数会依次接收每一个值
- 支持 `strings`、`ints`、`longs`、`doubles`、`booleans`，但**一次只能传一种类型**

好处：省去写多个 `@Test` 方法验证同一段逻辑不同输入的重复代码。

---

## 7. `@Disabled`：临时禁用某个测试

```java
@Test
@Disabled("接口还没实现，先跳过")
public void testFeatureNotDone() {
    // ...
}
```

跑测试的时候会跳过这个方法，不算失败，也不算成功，常用于"这段代码还没写完/临时有问题，先不测"的场景，正式项目里应该尽量少用（容易忘记打开）。

---

## 8. 完整示例：串起来看

```java
package com.itheima;

import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

/**
 * UserService 的单元测试类
 */
public class UserServiceTest {

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService();
    }

    @Test
    @DisplayName("测试根据身份证计算年龄")
    void testGetAge() {
        Integer age = userService.getAge("110002200505091218");
        Assertions.assertNotNull(age);
        Assertions.assertTrue(age > 0);
    }

    @Test
    @DisplayName("测试根据身份证判断性别")
    void testGetGender() {
        String gender = userService.getGender("612429198904201611");
        Assertions.assertEquals("男", gender);
    }

    @ParameterizedTest
    @DisplayName("批量测试性别判断")
    @ValueSource(strings = {
        "612429198904201611",
        "612429198904201612"
    })
    void testGetGenderMulti(String idCard) {
        String gender = userService.getGender(idCard);
        Assertions.assertTrue(gender.equals("男") || gender.equals("女"));
    }

    @Test
    @DisplayName("测试身份证格式非法时抛出异常")
    void testInvalidIdCard() {
        Assertions.assertThrows(StringIndexOutOfBoundsException.class, () -> {
            userService.getGender("123");  // 长度不够18位，应该抛异常
        });
    }
}
```

---

## 9. 常见坑速查

|坑|说明|
|---|---|
|测试方法不是 `public`|JUnit5其实允许包级私有（不写修饰符）也能跑，但保持`public`更保险、更规范|
|`@BeforeAll`/`@AfterAll` 忘记加 `static`|这两个必须是静态方法，否则编译报错|
|`assertEquals` 参数顺序写反|约定是 `assertEquals(预期值, 实际值)`，顺序反了不影响测试通过/失败判断，但报错提示信息会显示反，不好排查|
|测试之间有依赖（一个测试的结果影响另一个）|单元测试应该互相独立，用 `@BeforeEach` 保证每次都是干净状态，别指望测试按固定顺序执行|
|`@ValueSource` 混用多种类型|一次只能传一种类型的数组（要么全strings，要么全ints），不支持混合|

---

## 总结

JUnit 的核心工作流程可以概括成三步：

1. **标记**：用 `@Test` 告诉框架"这是一个测试方法"
2. **执行**：调用你的业务方法，拿到实际结果
3. **断言**：用 `Assertions.xxx()` 系列方法，自动判断实际结果是否符合预期，不用肉眼核对

在这个基础上，`@DisplayName` 让测试报告更好读，`@BeforeEach`/`@AfterEach` 帮你管理测试前后的准备与清理工作，`@ParameterizedTest`+`@ValueSource` 让同一段验证逻辑能批量跑多组数据，`@Disabled` 用来临时跳过还没完成的测试。

**相关知识延伸**：

- **单元测试 vs 集成测试**：JUnit 测的是单个方法/类的逻辑（单元测试），如果要测试"多个组件配合起来工作对不对"（比如Controller+Service+数据库整体流程），那属于集成测试范畴，Spring Boot 项目里会用到 `@SpringBootTest` 这类注解来支持（跟纯 JUnit 有区别，但底层还是依赖 JUnit 跑测试）。
- **测试覆盖率（Coverage）**：衡量"你写的测试覆盖了多少比例的业务代码"，IDEA 自带覆盖率工具，可以直观看到哪些代码分支没被测试到，是评估测试完整性的常用指标，等你写更复杂的项目时会用到。
- **Mock（模拟对象）**：如果被测试的方法依赖数据库、网络请求这些"外部资源"，直接测会很慢、很不稳定，实际项目里常用 Mockito 这类框架"模拟"这些依赖，让测试更快更可控——这是比当前内容更进阶的话题，等写 Spring Boot 项目、涉及数据库操作时再深入了解即可。