# 들어가기
<hr>

### 계약 합성

- 솔리디티는 계약 합성을 지원한다.
- 합성이란 여러 계약 또는 자료형을 조합해서 복합 자료구조와 계약들을 생성할 수 있음을 의미한다.
- `new`키워드를 사용해서 계약을 생성하는 코드에서 `client` 계약은 `HelloWold`계약을 포함한다. [참고_Create Contract](https://github.com/lhn1455/TIL/blob/980937acf340afb3008e6572f852c9cd6072dcc0/Solidity/Create%20Contract.md)
```solidity
pragma solidity ^0.4.19;

contract HelloWorld {
    uint private simpleInt;
    
    function getValue() public view returns (uint) {
        return simpleInt;
    }
    
    function setValue(uint _value) public {
        simpleInt = _value;
    }
}

contract client {
    //new 키워드 사용
    function useNewKeyword() public returns (uint) {
        HelloWorld myObj = new HelloWorld(); 
        
        myObj.setValue(10);
        
        return myObj.getValue();
    }
}
```
- 여기서 `HelloWorld`는 독립적인 계약이고 `client`는 의존적인 계약이다.
- `client`가 의존적인 계약이라고 하는 이유는, 그것이 완전성을 갖기 위해서는 `HelloWorld` 계약에 의존해야 하기 때문이다.
- 문제를 분할해서 여러 건의 계약을 작성한 뒤 계약 합성을 통해 그것들을 엮는 것은 좋은 습관이다.

<hr>


# 상속 (Inheritance)
- 상속은 객체지향의 핵심적인 개념 중 하나이며, 솔리디티는 스마트 계약 간의 상속을 지원한다.
- 상속은 서로 부모-자식 관계를 갖는 복수의 계약을 정의하는 과정이다.
- 상속 관계의 두 계약이 있을 때, 상속을 해주는 쪽은 **부모 계약(parent contract)**, 그로부터 상속 받는 쪽은 **자식 계약(child contract)**이 된다.
- 부모 계약을 **기본 계약(base contract)**, 자식 계약을 **파생 계약(derived contract)**이라고도 부른다.
- 상속은 코드 재사용성과 관계가 깊다.
- 기본 계약과 파생 계약 사이에는 **is-a 관계**가 성립하며, 기본 계약에서 정의한 모든 public 및 internal 스코프 함수, 상태 변수를 파생 계약에서도 사용할 수 있다.
- 사실, 솔리디티 컴파일러는 기본 계약의 바이트 코드를 파생된 계약의 바이트 코드로 복사한다.
- 파생 계약이 기본 계약을 상속하기 위해 `is`키워드를 사용한다.

이는 계약의 버전을 매기고 배포하는 방식이므로 솔리디티 개발자라면 숙지해야 할 가장 중요한 개념 중 하나다.   
솔리디티는 여러 유형의 상속을 지원하며, 다중 상속도 이에 포함된다.   
솔리디티는 기본 계약을 파생 계약으로 복사하며 상속을 통해 단일 계약을 생성한다.   
하나의 주소를 만들어 부모-자식 관계의 계약이 공유한다.   

## 단일 상속 (Single Inheritance)
- 단일 상속은 파생 계약이 기본 계약의 변수, 함수, 수정자, 이벤트를 상속하는 것을 돕는다.   

    ![단일상속](/Solidity/img/img.png)

- 다음 코드는 단일 상속을 설명하는 데 도움이 된다.
- 여기서 두 건의 계약인 `ParentContract`와 `ChildContract`는 모든 public 및 internal 변수와 함수를 상속한다.
- `client` 계약에서 볼 수 있는 것과 같이 `ChildContract`를 사용하면 `GetInteger`와 `SetInteger` 함수를 마치 그것들이 `ChildContract`에 정의된 것처럼 호출할 수 있다.
```solidity
pragma solidity ^0.5.4;

contract ParentContract {
    uint internal simpleInteger;
    
    function SetInteger(uint _value) external {
        simpleInteger = _value;
    }
}

contract ChildContract is ParentContract {
    bool private simpleBool;
    
    function GetInteger() public view returns (uint) {
        return simpleInteger;
    }
}

contract client {
    //계약 인스턴스를 생성함으로써 상속한 ParentContract까지 접근하여 모두 사용할 수 있음
    ChildContract pc = new ChildContract(); 
    
    function workWithInheritance() public returns (uint) {
        pc.SetInteger(100);
        return pc.GetInteger();
    }
}
```

솔리디티 계약의 모든 함수는 가상 함수이며 계약 인스턴스에 기초한다.   
기본 계약 혹은 파생 계약에서 적합한 함수가 호출된다.   
이 주제는 다형성으로 알려져 있다.   
**계약 생성자의 호출은 기본 계약에서 파생 계약 순으로 이루어진다.**   


## 다단계 상속
- 다단계 상속은 단일 상속과 거의 비슷하다.
- 단, 부모-자식 관계가 한 단계에 그치지 않고, 여러 단계로 이루어진다.
- **계약 A**는 **계약 B**의 부모이며, **계약 B**는 **계약 C**의 부모이다.   

    ![다단계 상속](/Solidity/img/inheritance.png)

## 계층적 상속
- 계층적 상속도 단순한 상속과 비숫하지만 단일 계약이 기초가 되어 그로부터 여러 계약이 파생된다.
- 아래 그림에서 계약 A로부터 계약 B와 계약 C가 파생된다.

    ![계층적 상속](/Solidity/img/inheritance1.png)

## 다중 상속
- 솔리디티는 다중 상속을 지원한다.
- 여러 단계의 단일 상속도 있을 수 있지만 같은 기본 계약으로부터 여러 계약이 파생될 수도 있다.
- 이와 같은 파생 계약을 나중에 자식 클래스에서 기본 계약으로 사용할 수 있다.
- 그러한 자식 계약들이 함께 상속할 경우, 다중 상속이 발생한다.   

    ![다중 상속](/Solidity/img/inheritance2.png)

다음 예제 코드는 다중 상속의 예를 나타낸다.   
이 예에서 `SumContract`가 기본 계약이며, 그로부터 `MultiContract`와 `DivideContract` 계약이 파생된다.   
`SumContract` 계약은 `Sum` 함수 구현을 제공하며, `MultiContract`와 `DivideContract` 계약은 각각 `Multiply`와 `Divide` 함수 구현을 제공한다.   
`SumContract`는 `MultiContract`와 `DivideContract` 둘 다로부터 파생된다.   
`SubContract` 계약은 `Sub` 함수 구현을 제공한다.   
`client` 계약은 부모-자식 계층에 속하지 않으며 다른 계약을 사용하기만 한다.   
`client` 계약은 `SubContract` 인스턴스를 생성해서 그것의 Sum 메서드를 호출한다.   

솔리디티는 다중 상속으로 인해 만들어지는 계약의 그래프에서 메서드를 찾을 때 `메서드 찾기 순서(Method Resolution Order, MRO)` 또는 `C3 선형화(linearization)`라고 하는 알고리즘을 따르며,   
이는 파이썬에서와 같다.   
예제에서는 메서드 찾기가 `SubContract`, `MultiContract`, `DivideContract`, `SubContract` 순으로 이뤄진다.

```solidity
pragma solidity ^0.5.4;

contract SumContract {
    function Sum(uint a, uint b) public returns (uint) {
        return a+b;
    }
}

contract MultiContract is SumContract {
    function Multiply(uint a, uint b) public returns (uint) {
        return a*b;
    }
}

contract DivideContract is SumContract {
    function Divide(uint a, uintb) public returns (uint) {
        return a/b;
    }
}

contract SubContract is SumContract, MultiContract, DivideContract {
    function Sub(uint a, uint b) public returns (uint) {
        return a-b;
    }
}

contract client {
    function workWithInheritance() public returns (uint) {
        uint a =20;
        uint b =10;
        SubContract subt = new SubContract();
        return subt.Sub(a,b);
    }
}
```
계약의 이름과 함수 이름을 사용해 특정 계약의 함수를 호출할 수도 있다.
