# Visitor Pattern (방문자 패턴) / 행위패턴
> 방문자와 방문 공간을 분리하여, 방문 공간이 방문자를 맞이할 때, 이후에 대한 행동을 방문자에게 위임하는 패턴   
즉, 로직과 구조를 분리하는 패턴. 로직과 구조가 분리되면 구조를 수정하지 않고도 새로운 동작을 기존 객체 구조에 추가하는 것이 가능
<br>
<br>

# 예제
> 구조   

![visitor_structure](/JAVA/DesignPattern/Img/visitor3.png)   

- ### 이름과 역할

| <center>이름</center> | <center>역할</center> |   
|---|---|
| Visitor | 방문자 클래스의 인터페이스 / visit(Element)을 공용 인터페이스로 씀. Element는 방문 공간 |
| Element | 방문 공간 클래스의 인터페이스 / accept(Visitor)를 공용 인터페이스로 씀. Visitor는 방문자 / 내부적으로 Visitor.visit(this)를 호출 |
| ConcreteVisitor | Visitor를 구체적으로 구현한 클래스 |
| ConcreteElement | Element를 구체적으로 구현한 클래스 |
| Main | 테스트 클래스 |

<br>
<br>

> 구조   

등급별 고객 혜택을 제공하는 쇼핑몰 시스템 만들기   

![visitor_structure](/JAVA/DesignPattern/Img/visitor4.png)   
<br>
<br>


> Benefit.class   
```java
public interface Benefit {
    void getBenefit(GoldMember member);
    void getBenefit(VipMemeber member);
}
```
혜택을 받을 Member 별로 실행 가능한 메서드 정의
<br>
<br>


> DiscountBenefit.class   
```java
public class DiscountBenefit implements Benefit {
    @Override
    public void getBenefit(GoldMember member) {
        System.out.println("Discount for Gold Member");
    }

    @Override
    public void getBenefit(VipMemeber member) {
        System.out.println("Discount for Vip Memeber");
    }
}

```
<br>
<br>


> PointBenefit.class   
```java
public class PointBenefit implements Benefit {
    @Override
    public void getBenefit(GoldMember member) {
        System.out.println("Point for Gold Member");
    }

    @Override
    public void getBenefit(VipMemeber member) {
        System.out.println("Point for Vip Memeber");
    }
}

```
각 멤버 등급별 혜택에 대한 기능 구현   
<br>
<br>


> Member.class   
```java
public class interface Member {
    void getBenefit(Benefit benefit);
}
```
등급별 멤버가 혜택을 받을 수 있도록 메서드를 Member 인터페이스에 선언
<br>
<br>


> GoldMember.class
```java
public class GoldMember implements Member {
    @Override
    public void getBenefit(Benefit benefit) {
        benefit.getBenefit(this);
    }
}
```
<br>
<br>


> VipMember.class
```java
public class VipMember implements Member {
    @Override
    public void getBenefit(Benefit benefit) {
        benefit.getBenefit(this);
    }
}
```
혜택 받는 메서드 구현   
다른 Member가 추가된다고 하더라도 구현 부분은 benefit.getBenefit(this); 만 추가하면 됨. 혹은 혜택이 추가 되더라도 Member는 수정할 필요가 없어짐
<br>
<br>


> Main.class
```java
public static void main(String[] args) {
    Member goldMember = new GoldMember();
    Member vipMember = new VipMember();
    Benefit pointBenefit = new PointBenefit();
    Benefit discountBenefit = new DiscountBenefit();

    goldMember.getBenefit(PointBenefit);
    vipMember.getBenefit(pointBenefit);
    goldMember.getBenefit(discountBenefit);
    vipMember.getBenefit(discountBenefit);
}
```
<br>
<br>

> 실행결과   
```
>>> Point for Gold Member
>>> Point for Vip Member
>>> Discount for Gold Member
>>> Discount for Vip Member
```



