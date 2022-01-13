# Visitor Pattern (방문자 패턴)
> 방문자와 방문 공간을 분리하여, 방문 공간이 방문자를 맞이할 때, 이후에 대한 행동을 방문자에게 위임하는 패턴

## 방문자 패턴의 목적과 사용이유
### Purpose
- (방문자 패턴이 필요 없는 경우) runtime에 object들에게 operation을 포함시키는게 타당할 때
- (방문자 패턴이 필요한 경우) object 내부에 operation들로 인해 cohesion이 떨어질 때   
<br>

### Use When
- object구조에 object 속성과 관계없는 operation이 많이 수행되어야 할 때
- object구조는 변하지 않지만 operation들이 많이 변경될 때
- 같은 인터페이스를 구현하는 다수의 object에 대해 연산을 수행해야 하는 operation이 필요할 때
- 그 operation들이 abstract class 수준이 아닌 concrete class 수준에서 수행되어야할 때(concrete class 마다 operation이여도 다르게 동작해야할 때)   
<br>

###Example
- 여러 object들에 대해 수행되어야 하는 operation이 있는데 이게 모든 class들에게 분배되어있으면 이해하기도, 유지보수하기도 힘듦. 이때 만약 새로운 operation이 추가되면 추가하는데 너무 많은 수정을 해야할 것임   
<br>

### Motivations
- object 구조에 많은 class의 object들이 존재함
- 그리고 이 object들에게는 자신들의 속성과 관련없이 수행되어야 하는 operation들이 존재
- 이때, operation이 기존 object구조와 연관이 없으므로 class의 cohesion을 보호하고자 함 (avoid "polluting")
- object 구조는 거의 바뀌지 않는데 operation들이 빈번히 바뀌어야하는 경우가 생김   
**=> 따라서 visitor pattern이 등장하게 됨!**   
<br>

### Benefits
- 새로운 operation을 추가하는 것이 쉬워짐
- object 속성과 연관된 operation은 object 내에 위치시키고, 연관되지 않는 operation은 분리할 수 있음   
<hr>
<br>
<br>
<br>

# Visitor Pattern (방문자 패턴) 이란?
> 상속 구조   

![visitor_inheritance](/JAVA/DesignPattern/Img/visitor.png)
방문자 패턴은 기존의 object structure와 operation을 캡슐화 한 visitor 부분이 나뉘어진 구조   
visitor 패턴 내의 메서드는 concrete element 개수 만큼 존재함 (#Visitor method = #Concrete element)   
concrete visitor는 각각 Element들을 위한 특정 operation임   
<br>

- ### 이름과 역할

| <center>이름</center> | <center>역할</center> |   
|---|---|
| Visitor | object구조 내의 ConcreteElement 개수 만틈 visit operation을 선언 |
| ConcreteVisitor | visitor에 선언된 operation들을 구현 |
| Element | element들이 visitor를 인자로 받기 위한 accept 메서드를 정의 |
| ConcreteElement | visitor를 인자로 받기 위한 accept 메서드를 구현 |
| ObjectStructure | element들을 나열 / visitor가 element들을 방문하는데 high-level interface를 제공 ex.Car class) |

> flow   

![visitor_flow](/JAVA/DesignPattern/Img/visitor1.png)
 ObjectStructure에서 ConcreteElementA.accpet(Visitor)를 호출하면 ConcreteElement가 Visitor.visit(자기자신)을 호출하고 그러면 Visitor가 A에게 맞는 operationA()를 제공   
즉, ObjectStructure에서 Visitor를 accept하면 ConcreteElementA가 그 Visitor를 accept하고, visitor에게 자기자신을 인자로 넘겨서 visit함수를 호출하게 만듦. 그러면 Visitor는 ConcreteElementA를 위한 operationA를 제공. 그 다음으로 ConcreteElementB가 그 Visitor를 accept하게 되고 위와 마찬가지로 Visitor는 ConcreteElementB에게 operationB를 제공
<br>
<br>

# 예제

![visitor_inheritance(Car)](/JAVA/DesignPattern/Img/visitor2.png)
-> 자동차 파트들이 존재하고 Composite패턴을 활용한 Car 클래스. Car 클래스는 자동차 파트 element들을 추가 할 수 있고 Object Structure로써 accept 메서드를 호출하면 모든 element에서 accept 메서드를 호출하게 한 후 자신을 visit하도록 visitor에게 자기자신을 인자로 넘겨줌

> Visitor & Element 인터페이스
```java
interface ICarElementVisitor {
    void visit(Wheel wheel);
    void visit(Engine engine);
    void visit(Body body);
    void visit(Car car);
}

interface ICarElement {
    void accept(ICarElementVisitor visitor);
}

public class VisitorDemo {
    public static void main(String[] args) {
        ICarElement car = new Car();
        car.accept(new CarElementPrintVisitor());
        car.accept(new CarElementDoVisitor());
    }
}
```
Visitor 인터페이스에서는 ConcreteElement 개수 만큼 각각에 상응하는 개수의 operation을 정의하고 있음
Element 인터페이스에서는 Visitor를 인자로 받아 자신을 방문할 수 있도록 하는 accept 메서드를 정의   

**CarElementPrintVisitor**, **CarElementDoVisitor**라는 Concrete Visitor가 존재하며 이는 각각 Concrete Element 개수만큼 상응하는 operation 개수를 가지고 있음

> Concrete Element   
```java
class Wheel implements ICarElement {
    private String name;
    public Wheel(String name) { 
        this.name = name; 
    }

    public String getName() {
        return this.name;
    }
    public void accept(ICarElementVisitor visitor) {
        visitor.visit(this);
    }

    class Engine implements ICarElement {
        public void accpet(ICarElementVisitor visitor) {
            visitor.visit(this);
        }
    }
    class Body implements IcarElement {
        public void accept(ICarElementVisitor visitor) {
            visitor.visit(this);
        }
    }
}
```
각각 Concrete Element에서 accept 메서드를 호출하면 Visitor를 인자로 넘겨받게 되고 그 Visitor에게 자기 자신을 인자로 넘겨주어 자기자신을 visit할 수 있게 만듦

> Concrete Element Car (with Composite Pattern) 
```java
class Car implements ICarElement {
    ICarElement[] elements;
    public Car() {
        this.elements = new ICarElement[] {
            new Wheel("front left"),
            new Wheel("front right"),
            new Wheel("back left"),
            new Wheel("back right"),
            new Body();
            new Engine();
        };
    public void accept(ICarElementVisitor visitor) {
        for(ICarElement elem : elements)
            elem.accept(visitor);
        visitor.visit(this);    
    }
}
```  

composit pattern으로 구현된 Car class는 복수개의 Concrete Element들을 갖을 수 있음. Car에서 accept 메서드를 호출하면 Visitor를 인자로 넘겨받은 후 Car가 포함하고 있는 Concrete Element들이 순차적으로 그 Visitor를 accept하도록 메서드를 호출하도록 함. 모든 Concrete Element들이 accept 메서드를 호출한 후에는 자기자신을 인자로 넘겨주어 자신을 visit하도록 함

> Concrete Visitor (#메소드 = #Concrete Element)   

```java
// 4개의 concrete element -> 4개의 concrete visit method
class CarElementPrintVisitor implements ICarElementVisitor {
    public void visit(Wheel wheel) {
        System.out.println("Visiting " + wheel.getName() + "wheel");
    }
    public void visit(Engine engine) {
        System.out.println("Visiting engine");
    }
    public void visit(Body body) {
        System.out.println("Visiting body");
    }
    public void visit(Car car) {
        System.out.println("Visiting car");
    }
}
```

## 동작 흐름
1. main()
```java
car.accept(new CarElementPrintVisitor());
```

2. Car :: accept()
```java
for(ICarElement elem : elements)
    elem.accept(visitor); //Iterator 1.5 이후
```

3. Engine :: accept()
```java
public void accept(ICarElementVisitor visitor) {
    visitor.visit(this); //자신의 instance 전달
}
```
4. CarElementVisitor :: visit()
```java
class CarElementPrintVisitor implements ICarElementVisitor {
    ...
    pulblic void visit(Engine engine) {
        System.out.println("Visiting engine");
    }
    ...
}
```

## + 동작 흐름 추가 설명
1. 먼저 Composite Pattern으로 구현된 Car object가 ConcreteVisitor를 인자로 받아 accept 메서드를 호출
2. Car object의 accept 메서드는 본인이 포함하고 있는 ConcreteElement들이 순차적으로 accept 메서드를 호출하도록 함
3. 특정 ConcreteElement에서 ConcreteVisitor를 인자로 받아 accept 메서드를 호출하고 나면 그 ConcreteVisitor에게 자기 자신을 인자로 넘겨주어 visit 메서드를 요청
4. ConcreteVisitor에서는 인자로 받은 ConcreteElement에 상응하는 visit메소드(operation)를 호출