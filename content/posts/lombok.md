# lombok 
 Lombok 是一款通过注解在 java 编译期生成代码的工具,通过内置的注解,可以为我们减少冗余的代码.最常用是在处理 POJO 的时候,我们经常会需要修改 POJO 成员变量,就算是使用 IDE 帮你自动生成带码,你还是需要增加,删除一些代码,而现在只需要修改成员变量就行了.

## lombok 常用注解

### @Getter & @Setter

```java
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.experimental.Accessors;
import org.junit.Test;

@Setter @Getter  //1
@ToString //2
public class SetterGetterExample {

    @Setter(onMethod_={@JsonProperty("ONX_EXAMPLE")}) //3
    private String ONxExamPle;

    @JsonProperty("F_YWXT") //3
    private String fYwxt;

    private boolean noIsPrefix; //4

    private Boolean success; //4

    @Accessors(prefix = "accessors") //5
    private String accessorsPrefix;

    @Accessors(chain=true) //5
    private String accessorsChain;

    @Accessors(fluent = true) //5
    private String accessorsFluent;

    @Setter(AccessLevel.NONE) //6
    @Getter(AccessLevel.NONE) //6
    private String accessLevelNone;

    @Setter(AccessLevel.PRIVATE) //6
    @Getter(AccessLevel.PRIVATE) //6
    private String accessLevelPrivate;

    @Test
    public void demo2() throws JsonProcessingException {
        final SetterGetterExample lombokExample = new SetterGetterExample();
        lombokExample.setONxExamPle("TEST");
        lombokExample.setFYwxt("JSON_PROPERTY");
        // 生成的json字符串是错误的
        System.out.println(new ObjectMapper().writeValueAsString(lombokExample));
    }
}
```

我们来根据标注的知识点来一一解答:

1. [@Setter @Getter](https://www.projectlombok.org/features/GetterSetter)
在类上加 @Setter 和 @Getter 注解,即给所有的属性加上 setter getter 方法
2. [@ToString](https://www.projectlombok.org/features/ToString)
默认为生成 toString 方法,其余特性后面介绍
3. [onX 特性](https://www.projectlombok.org/features/experimental/onX)
有些框架的作用点主要是 setter/getter 方法,而不是属性.因此我们得把注解加在 setter getter 方法上,但是我们使用了 @Setter 和 @Getter 之后,我们就无法将一些注解直接加在 setter 和 getter 上.此时 onX ,特性就开始发生作用了,你可以在方法和方法参数上加上你想要的注解,可以尝试执行 demo2 junit 测试方法来测试效果.官网例子:

```java
// 编译之前
@Getter(onMethod_={@Id, @Column(name="unique-id")}) //JDK8
@Setter(onParam_=@Max(10000)) //JDK8
private long unid;

// 编译之后
@Id @Column(name="unique-id")
public long getUnid() { return unid; }
public void setUnid(@Max(10000) long unid) { this.unid = unid; }
```

4. Boolean 和 boolean 数据类型在 getter 方法上的不同
当时 boolean 数据类型时,生成的 getter 是  isXXX 方法名,如果不想使用此方法名,有两种解决方案,
    1. 使用 Boolean 类型
    2. 在 java 源代码文件夹下加上 lombok 全局配置文件 `lombok.config`. 且加上属性配置 `lombok.getter.noisprefix = true` ,(具体配置文件使用规则后面介绍)
![](_v_images/20190908151559643_407160289.png =800x)
5. @Accessors 注解是辅助 @Setter 和 @Getter 作用的.
    1. prefix 去掉前缀然后生成 setter getter
    2. chain 生成链式调用方式的 setter
    3. fluent 生成链式调用方式的 setter ,然后 setter getter 方法名称为 fluent 风格,即 setter 和 getter 方法名为属性名.
6. @Setter 和 @Getter生成方法的访问修饰符
@Setter 和 @Getter 都有设置访问修饰符的属性, 一共有 PUBLIC, MODULE, PROTECTED, PACKAGE, PRIVATE, NONE 6 个级别.其中 NONE 是不生成相应的 setter getter.其他的就是 JDK 的用法.

### @ToString
在类上加上注解 @ToString 可以生成 toString 方法,以类名和以逗号分隔的字段为对象的字符串表示.
@ToString 注解功能比较凌乱.有好几种使用场景及默认配置.因此我们先说说 @ToString 注解的各项属性含义.

```java
/**
 * 只能注解在类上
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.SOURCE)
public @interface ToString {
    /**
     * 默认为 true,默认 toString 方法输出时会加上字段名
     * 为 false 时, toString 方法输出时不会带上字段名
     */
	boolean includeFieldNames() default true;
    /**
     * 排除不需要输出的字段,即不包含在 toString 方法的输出中
     */
	String[] exclude() default {};
    /**
     * 即将过时没必要了解
     */
	String[] of() default {};
    /**
     * 默认为 false,为 true 时,在输出中包含父类的 toString 方法
     */
	boolean callSuper() default false;
    /**
     * 默认为 false,默认 toString 方法调用属性的 getter 方法来输出 field(如果有 getter 的话).比如,this.getXxx()
     * 为 true 时,则直接调用通过 . 符号来调用,比如, this.xxx
     */
	boolean doNotUseGetters() default false;
    /**
     * 默认为 false,
     * 为 true 时,只有加了 @ToString.include 注解的才在 toString 方法的输出中
     */
	boolean onlyExplicitlyIncluded() default false;

	@Target(ElementType.FIELD)
	@Retention(RetentionPolicy.SOURCE)
	public @interface Exclude {}

	@Target({ElementType.FIELD, ElementType.METHOD})
	@Retention(RetentionPolicy.SOURCE)
	public @interface Include {
        /**
         * 配置输出的顺序
         */
		int rank() default 0;
        /**
         * 定制输出内容所标记的字段,includeFieldNames 必须为 true
         */
		String name() default "";
	}
}
```

以上 @ToString 注解的用法已经进行了详细的介绍,下面我们分几种场景来举例,看下实际效果,

```java
@ToString //1
public class ToStringExample extends Parent {
    private static String staticField; //2
    private String include;
    @ToString.Include(rank = -2) //3
    private String rank1;
    @ToString.Include(rank = 1,name = "rank3") //3
    private String rank2;
    @Getter //4
    private String getter;
    @ToString.Exclude //5
    private String exclude;
}
class Parent{ private String parentField; }
// toString
public String toString() {
    return "ToStringExample(rank3=" + this.rank2 + ", include=" + this.include + ", getter=" + this.getGetter() + ", rank1=" + this.rank1 + ")";
}
```

又来到了我们的解答环节,我们直接开始吧,

1. @ToString 注解
@ToString 注解只能加载类上,我们先以默认配置来实现例子,
2. static 修饰符修饰的属性
@ToString 方法不会输出被 static 修饰的属性,static 修饰的为常量, 对于以对象为单位的 toString 方法没必要输出,都是一致的.
3. @ToString.Include 注解
@ToString.Include 是 @ToString 注解的内部实现,用来配合 toString 注解来选择要输出的字段.
@ToString.Include 注解有两个属性:
    1. rank
    给属性标记上顺序,默认为 0,数字越高,越先输出,从上面的 rank1,rank2,include 的输出顺序中可以验证.
    2. name
    修改字段代表的含义,可以从上面 rank2 属性验证作用
4. getter
@ToString 注解生成的 toString 方法输出字段信息时,主要以调用 getter 方法的方式来输出,如果对应字段没有 getter 方法才会直接调用属性.
5. @ToString.Exclude 注解
@ToString.Exclude 与 @ToString.Include 作用是相反的,用来配合 toString 注解来选择不需要输出的字段.

以上是使用 @ToString 的默认配置来举例子的.现在我们对上述例子进行了稍稍修改.

```java
@ToString(includeFieldNames = false,callSuper = true,doNotUseGetters = true,onlyExplicitlyIncluded = true) //1
public class ToStringExample extends Parent {
    private static String staticField;
    private String include;
    @ToString.Include(rank = -2)
    private String rank1;
    @ToString.Include(rank = 1,name = "rank3")
    private String rank2;
    @Getter @ToString.Include //2
    private String getter;
    @ToString.Exclude
    private String exclude;
}
class Parent{ private String parentField; }
//toString
public String toString() {
    return "ToStringExample(super=" + super.toString() + ", " + this.rank2 + ", " + this.getter + ", " + this.rank1 + ")";
}
```

我在上述例子修改后的地方加了标注,主要将所有默认配置修改成相反的配置,然后为了说明 doNotUseGetters 的属性作用,给 getter 属性加了 @ToString.Include 注解
可以对照着上面的 @ToString 的注解说明来验证是否达到了预期的结果,我就不重复说明作用了.