---
title: "使用cglib增强dto和注解的简单使用"
date: 2020-11-03T06:11:09+08:00
draft: true
---

## 业务场景
最近在接手一位同事的客户清洗项目,该项目的目的是清洗客户提供的不合格的数据,校验数据的合格性并给出错误提示.在我接手的时候,由于业务需求更改,导致原来的代码不在符合需求,但是业务逻辑改变不大.因此,我想尽可能地在不修改太多代码地情况完成需求更改.

## 需求分析
更改的需求除了常规的业务逻辑外,还有excel的模板更改和报错的提示更改.这两个需求看似改变不大,但如果硬编码的话其实并不好修改.
首先,excel的输出模板是由类的字段顺序来决定的,但由于清洗模板和值集转换模板现在变成了两个不同的模板,因此之前靠类的字段顺序生成模板的方式就要放弃.
其次,报错信息由之前的一个错误一个字段更改为一个字段一个错误,这样一个字段可能有多种错误,这时候需要将字符串拼接起来.而之前都是使用setter方法将错误信息存在对象中,一个错误一个字段,如果现在要拼接后存储错误信息,将十分繁杂,需要在每个dto的setter方法之前拼接字符串.

## 处理方案
知道了需求后,我们就要根据需求进行开发.
在excel的输出模板的问题中,我决定采用注解的特性来完成需求开发.这样通过注解产生的excel字段顺序永远都是你想要的,并且当你想要新增模板时,只需要再加上另外一个注解,当你想要修改模板的字段顺序时,只需要修改该模板所对应的注解的值.
在报错信息提示问题中,我决定通过cglib的动态代理来处理.通过动态代理对象来处理实例对象,这样就不需要在每次调用setter之前调用getter和拼接字符串,由三步变成了一步.并且对当前代码侵入性很低,只需要生成一个代理对象,并将实例对象注入其中.

## 注解的简单使用
在讲解注解的使用时,我们需要先了解注解的一些概念.
注解是java se 5.0就引入的特性.在java的类库中也有一些现成的注解,比如 `@Override` , `@Deprecated`,前者代表重写,后者代表过时,过会儿讲完概念可以看看这两个注解的使用范围.
注解其实和接口特别相似,两者都是对一种特定行为的标记,两者都不会自身发生作用.但相比接口的对类的定性作用,对于注解的作用我们貌似常常摸不着头脑,不知道这东西是在哪儿作用的.

### 注解的声明
首先,我们来说说注解的声明,很简单,如下:

```java
public @interface Address{
}
```

这就是一个注解了,是不是看起来和接口特别相似.哈哈.
不过,这只是定义了这个注解是叫什么的,它的作用范围,以及怎么作用这儿都没有说.

### 元注解
在这儿,我们可以说说注解的作用范围,它标记了什么时候注解生效,什么地方生效.
最基础的元注解有二个 `@Retention` 和 `@Target`,这两元注解是所有注解都有的.前者代表了什么时候,后者代表了什么地方.

#### @Retention
Rentention的英文意为保留期的意思.代表了注解能产生作用的时期.
它的取值如下:
- RetentionPolicy.SOURCE 注解只在源码阶段保留,在编译器进行编译时它被忽略.例如,`@Override`
- RetentionPolicy.CLASS 注解只被保留到编译进行的时候,不会被加载到JVM中.这部分是当初设计注解的主要原因,是默认设置,但是在java web中使用比较少.
- RetentionPolicy.RUNTIME 注解可以保留到程序运行的时候,会被加载到JVM中,在程序运行时可以获取他们.例如,`@Deprecated`,用的最多.

```java
@Rentention(RetentionPolicy.RUNTIME)
public @interface Address{
}
```

#### @Target
Target的英文意为目标的意思,代表了这个注解要作用在什么地方.
它的取值如下:
- ElementType.ANNOTATION_TYPE 注解
- ELementType.CONSTRUCTOR 构造方法
- ElementType.FIELD 属性
- ELementType.LOCAL_VARIABLE 局部变量
- ELementType.METHOD 方法
- ELementType.PACKAGE 可以给一个包进行注解
- ElementType.PARAMETER 可以给一个方法内的参数进行注解
- ElementType.TYPE 类(类,接口,枚举)

```java
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD,ElementType.TYPE})
public @interface Address {
}
```

### 注解的属性
使用元注解定义注解的保留时期和作用目标后,我们就需要开始定义注解的属性了.注解的属性主要是用来传递数据的,而这些数据是用来定义规则的.
在注解中定义属性时它的类型必须是8种基础数据类型外加类,接口,注解以及他们的数组.注解中属性可以有默认值,默认值需要用default关键字指定.
现在,我们先看一个实例,通过实例我们来了解注解的属性定义语法.

```java
@Address
public class AddressAnnotation {
}

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD,ElementType.TYPE})
@interface Address {

    String country() default "中国";

    AddressDefult province() default AddressDefult.HUBEI;

    String value() default "";

    int[] arrayAttr() default {1,3,5};

    MetaAnnotation annotationAttr() default @MetaAnnotation("field");

}

enum AddressDefult {
    HUBEI,ANHUI,HUNAN
}

@interface MetaAnnotation{
    String value();
}
```


### 注解的使用
给Address注解添加了两个最基础的注解和属性的定义后,我们就可以使用这个注解啦.
注解的使用是和反射关联在一起,在@Retention(RetentionPolicy.RUNTIME)状态下,我们可以通过在jvm虚拟机运行期间来获取到@Address注解的值.

```java
@Address
public class AddressAnnotation {
    public static void main(String[] args) {
        Address declaredAnnotation = AddressAnnotation.class.getDeclaredAnnotation(Address.class);
        Assert.assertEquals(declaredAnnotation.country(),"中国");
        Assert.assertEquals(declaredAnnotation.province(),AddressDefualt.HUBEI);
        Assert.assertEquals(declaredAnnotation.value(),"");
        Assert.assertEquals(Arrays.toString(declaredAnnotation.arrayAttr()),Arrays.toString(new int[]{1,3,5}));
        Assert.assertEquals(declaredAnnotation.annotationAttr().value(),"field");
    }
}
```

### 结合业务场景来使用
我们之前的业务是数据清洗和数据转换都是一个模板,因此之前通过字段顺序决定excel字段顺序是没有问题的,现在分成了俩个模板,并且这两模板的字段顺序不一致,现在我们为每个模板创建一个注解,通过注解来决定excel字段的顺序.

```java
/* ***********************************************************************
 * @author mengjian.ke create in 22:14 2018/10/2
 * 用来标注数据清洗模板字段位置
 *********************************************************************** */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD})
public @interface CleanModelAnchor {
    int value();
}
```

```java
/* ***********************************************************************
 * @author mengjian.ke create in 22:14 2018/10/2
 * 用来标注数据转换模板字段位置
 *********************************************************************** */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD})
public @interface TransferModelAnchor {
    int value();
}
```

这两注解分别代表了清洗模板和值集转换模板的注解,都只有一个int数据类型的属性.这个属性代表在这个模板中字段所在的位置.

```java
public class Customer {
    @TransferModelAnchor(1)
	private String ak; //分类编码

    @TransferModelAnchor(2)
    @CleanModelAnchor(2)
	private String c; //客户公司全称

    @TransferModelAnchor(3)
    @CleanModelAnchor(1)
	private String b; //客户编码

    ~~~
}
```

在给dto标记注解之后,我们就要正式使用它了.

```java
public static Object[] objectToArrayByAnnotation(Object object,String annotation) throws IllegalAccessException {
    Class<? extends Object> objectClass = object.getClass();
    //获取类的所有成员变量
    Field[] fields = objectClass.getDeclaredFields();
    int size = fields.length;
    Object[] objects = new Object[size];
    //把对象的所有数据放入Object[]数组中
    for (int i = 0; i < size; i++) {
        Field field = fields[i];
        field.setAccessible(true); // 设置属性是可以访问的
        if(field.isAnnotationPresent((Class<? extends Annotation>) map.get(annotation))){
            //根据模板类型,选择相应注解的数据,并将数据放入相应的位置
            switch (annotation){
                case "CleanModelAnchor":
                    CleanModelAnchor clean = field.getAnnotation(CleanModelAnchor.class);
                    objects[clean.value()-1]=field.get(object);
                    break;
                case "TransferModelAnchor":
                    TransferModelAnchor transfer = field.getAnnotation(TransferModelAnchor.class);
                    objects[transfer.value()-1]=field.get(object);
                    break;
            }
        }
    }
    return objects;
}
```

获得了List<Object[]>结构的数据后,然后将其遍历输出到模板中.至此,这个开发任务就结束了.日后不管模板怎么更改,我们都不需要更改实际代码,只需要更改每个字段在相应模板的位置,就算增加了模板,只要是这个DTO,我们直接在上面添加另外的模板注解就可以定下excel的字段顺序.

## 使用cglib增强dto
cglib是实现代理技术一个更加全面的类库.在jdk中也有实现代理技术的类库,而且使用更加方便,但是jdk的动态代理技术必须代理类和被代理类实现相同的接口,像这种必须要实现接口的动态代理技术不利于方法的拓展,当被代理类添加方法时,还需要在接口上添加方法,要更改两个文件.而cglib可以直接给类进行代理,不用要求类和被代理类实现相同的接口.它会生成被代理类的子类的代理对象.

### cglib Enhancer API
Enhancer是cglib最常用的一个类.可以用来生成代理类,既能代理普通的类,也能对接口进行代理.并对回调进行了不同的处理分类,进行了更加细致的处理.
以下是最简单的代理实现

```java
@Test
public void demo(){
    Enhancer enhancer = new Enhancer();
    //申明要代理的类也可以是接口
    enhancer.setSuperclass(HelloWorld.class);
    //申明回调函数
    enhancer.setCallback((MethodInterceptor)(obj,method,args,proxy)->{
            System.out.println("before");
            Object result = proxy.invokeSuper(obj,args);
            System.out.println("after");
            return result;
        });
    HelloWorld o = (HelloWorld)enhancer.create();
    o.sayHello();
}
/* 控制台输出
before
Hello World!
after
*/
```

#### 回调函数
Enhancer类可以注册的回调函数有MethodInterceptor,NoOp,LazyLoader,Dispatcher,InvocationHandler,FixedValue 6种回调,在我们注册代理类时也必须对回调函数进行注册,可以同时进行多种回调函数进行注册.回调函数都实现了Callback接口,表明该类是回调类.

```java
/**
 * All callback interfaces used by {@link Enhancer} extend this interface.
 * @see MethodInterceptor
 * @see NoOp
 * @see LazyLoader
 * @see Dispatcher
 * @see InvocationHandler
 * @see FixedValue
 */
public interface Callback{ }
```

先在测试类中处理好对象的初始化和方法的自动调用

```java
public class ProxyInstanceTest {

    Enhancer enhancer = new Enhancer();
    HelloWorld helloWorld = null;

    @Before
    public void init(){
        enhancer.setSuperclass(HelloWorld.class);
    }

    @After
    public void end(){
        helloWorld = (HelloWorld)enhancer.create();
        helloWorld.sayHello();
        helloWorld.one();
        helloWorld.two();
        helloWorld.three();
        helloWorld.four();
        helloWorld.five();
        helloWorld.six();
    }
}
```

##### MethodInterceptor
```java
public interface MethodInterceptor extends Callback
{
    /**
     * @param 代理对象
     * @param 被代理对象执行的方法
     * @param 被代理对象执行的方法的方法参数
     * @param 被代理对象执行的方法的代理方法
     */
    public Object intercept(Object obj, Method method, Object[] args,
                            MethodProxy proxy) throws Throwable;
}
```

这个回调可以当作 jdk 动态代理的 java.lang.reflect.InvocationHandler#invoke 来使用,是对该方法的增强.

##### InvocationHandler
```java
public interface InvocationHandler extends Callback
{
    /**
     * @see java.lang.reflect.InvocationHandler#invoke(java.lang.Object, java.lang.reflect.Method, java.lang.Object)
     */
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable;

}
```
这个功能和 jdk 动态代理的 java.lang.reflect.InvocationHandler#invoke 基本一致,内部的实现不同.

##### NoOp
```java
public interface NoOp extends Callback
{
    //跳过,不处理,使用被代理对象的方法
    public static final NoOp INSTANCE = new NoOp() { };
}
```

##### LazyLoader
```java
public interface LazyLoader extends Callback {
    //调用方法多次时,该回调只执行一次
    Object loadObject() throws Exception;
}
```

##### Dispatcher
```java
public interface Dispatcher extends Callback {
    //每调用方法一次时,该回调执行一次
    Object loadObject() throws Exception;
}
```

##### FixedValue
```java
public interface FixedValue extends Callback {
    //返回固定的数值
    Object loadObject() throws Exception;
}
```

在这三个回调 `LazyLoader` , `Dispatcher` , `FixedValue` 中,我们可以看到它们的唯一的方法的方法名都是一样的,都是用户在回调的时候返回一个对象.
它们都是在 `net.sf.cglib.proxy.Enhancer#create()` 生成代理对象的时候就起作用,在生成代理对象的过程中, 会调用被代理类的构造方法,并且会调用回调的 `loadObject` 方法.
三者的区别是: `LazyLoader` 和 `Dispatcher` 是用来加载对象的,进行对象的初始化,而且产生的对象必须能被被代理类接收. `LazyLoader` 的回调在被拦截时只会调用一次, `Dispatcher` 的回调每次拦截都会调用一次. `FixedValue` 比较灵活,会根据调用的方法的返回类型来返回具体的对象.


#### 多回调场景
每个被拦截的方法只能执行一个回调,上述其中的一个.虽然如此,但是我们可以动态的执行哪个方法执行哪个回调.

```java
//我们来看一下CallbackFilter的说明
public interface CallbackFilter {
    /**
     * 根据返回的int数据来指定要执行的回调,其值是回调数组里的下标索引
     */
    int accept(Method method);

    boolean equals(Object o);
}
```
因此我们可以这样,给每一个不同的方法设置不同的回调.

```java
@Test
public void filter(){
    Callback methodInterceptor = (MethodInterceptor) (obj,Method,args,proxy) -> {
        System.out.println("before MethodInterceptor");
        Object result = proxy.invokeSuper(obj,args);
        System.out.println("after MethodInterceptor");
        return result;
    };
    Callback noOp = NoOp.INSTANCE;
    Callback lazyLoader = (LazyLoader)()->{
        System.out.println("lazy");
        return new HelloWorld();
    };
    Callback dispatcher = (Dispatcher)() ->{
        System.out.println("dispatcher");
        return new HelloWorld();
    };
    Callback invocationHandler = (InvocationHandler)(proxy,method,args) -> {
        System.out.println("before InvocationHandler");
        HelloWorld helloWorld = new HelloWorld();
        Object result = method.invoke(helloWorld,args);
        System.out.println("after InvocationHandler");
        return result;
    };
    Callback fixedValue = (FixedValue) () -> {
        System.out.println("fixedValue");
        return "fixedValue"
    };
    enhancer.setCallbacks(new Callback[]{methodInterceptor,noOp,lazyLoader,dispatcher,invocationHandler,fixedValue});
    enhancer.setCallbackFilter((method) -> {
        String methodName = method.getName();
        switch (methodName){
            case "one":return 0;
            case "two":return 1;
            case "three":return 2;
            case "four":return 3;
            case "five":return 4;
            default:return 5;
        }
    });
}
/* 控制台返回的数值
fixedValue
before MethodInterceptor
one
after MethodInterceptor
two
lazy
three
dispatcher
four
before InvocationHandler
five
after InvocationHandler
fixedValue
*/
```

### 结合业务场景来使用

#### 建立扩展类对之前的实例进行封装
```java
//使用的cglib来生成代理对象,因此实现了MethodInterceptor
public class CustomerExt implements MethodInterceptor {

    private Customer customer;

    //封装实际要处理的实例对象
    public CustomerExt(Customer customer) {
        this.customer = customer;
    }

    @Override
    public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
        Object result = null;
        //处理的对象是被封装的实例,而不是代理类.
        Class<? extends Customer> customerClass = customer.getClass();
        if (method.getName().contains("setMessage")) {
            //判断代理类要执行的方法,如果是错误日志记录方法则返回true
            Method getMethodMessage = customerClass.getMethod(method.getName());
            Method setMethodMessage = customerClass.getMethod(method.getName().replace("set", "get"), String.class);
            //获取之前该字段的数据
            String declare = (String) getMethodMessage.invoke(customer);
            //判空
            declare=declare==null?"":declare;
            //拼接新字符串
            objects[0] = declare + objects[0];
            //调用setter方法,将新字符串保存在对象中
            result = setMethodMessage.invoke(customer, objects);
        } else {
            //其他方法则跳过
            result = method.invoke(customer, objects);
        }
        return result;
    }
}

```

#### 创建生成代理类的工具类

```java
public class CustomerUtils {

    /**
     * @param customer 被封装的实例对象
     * @return 返回代理类
     */
    public static Customer newInstanceProxy(Customer customer){
        Enhancer enhancer = new Enhancer();
        //申明要代理的类
        enhancer.setSuperclass(Customer.class);
        //申明回调函数
        enhancer.setCallback(new CustomerExt(customer));
        return (Customer)enhancer.create();
    }

}
```

#### 将代理类对象替换之前的实例对象

```java
Customer temp = list.get(i);
//在需要进行错误日志setter方法时,将实例对象替换为代理类对象
Customer customer = CustomerUtils.newInstanceProxy(temp);
```

只需要在调用错误日志setter方法之前,使用代理类实例将真正的实例封装起来就行了,不需要自己取出之前的字符串,然后拼接,再放入实例中,每一个错误日志的setter方法之后都不需要进行上述操作.只需要修改一处代码,将一行变为两行,其余的正常调用错误日志的setter方法就可以了,它会自己拼接,是不是很酷.