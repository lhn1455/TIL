# 다형성 (Polymorphism)

- 다형성이란 여러 가지 형태를 띠는 것을 가리킨다.
- 솔리디티에는 다음 두 종류의 다형성이 존재한다.
  - 함수 다형성
  - 계약 다형성
  
## 함수 다형성
- 함수 다형성은 같은 계약 내에서 같은 함수를 여러 개 선언하는 것 또는 계약을 상속하면서 같은 이름의 함수를 갖도록 선언하는 것을 가리킨다.
- 함수는 파라미터의 자료형 또는 파라미터의 개수에 따라 달라진다.
- 다형성에 관해 함수 시그니처를 판단할 때 반환 타입은 고려하지 않는다.
- 이것을 **메서드 오버로딩(method overloading)**이라고도 한다.

다음 코드는 이름이 같지만 입력 파라미터의 자료형이 다른 두 개의 함수를 가진 계약을 나타낸다.   
첫 번째 함수 getVariableData는 파라미터의 자료형으로 int8을 받는다.   
같은 이름의 두번째 함수는 파라미터의 자료형으로 int16을 받는다.   
파라미터의 개수나 자료형을 달리해서 같은 이름의 함수를 작성하는 것은 타당하다.   
```solidity
pragma solidity ^0.5.4;

contract HelloFunctionPolymorphism {
    
    function getVariableData(int8 data) public constant returns (int8 output) {
        return data;
    }

    function getVariableData(int16 data) public constant returns (int16 output) {
        return data;
    }
}
```

## 계약 다형성
- 계약 다형성은 상속 관계에 있는 여러 계약 인스턴스를 상호교환적으로 사용하는 것을 얼컫는다.
- 계약 다형성은 **기본 계약 인스턴스를 사용해 파생 계약 함수를 호출하는 것**을 돕는다.

부모 계약에는 두 개의 함수, `SetInteger`와 `GetInteger`가 있다.   
자식 계약은 부모 계약으로부터 상속해서 `GetInteger`의 자체적인 구현을 제공한다.   
자식 계약은 `ChildContract` 변수 자료형을 사용해 생성할 수 있으며 부모 계약 자료형을 사용해 생성할 수도 있다.   
다형성은 부모-자식 관계에 있는 어떠한 계약이든지 기본 타입 계약 변수를 가지고 사용할 수 있게 해준다.   
계약 인스턴스는 기본 계약과 파생 계약 중 어느 것의 함수를 호출할 것인지 결정한다.

다음 코드를 보자.
```solidity
ParentContract pc = new ChildContract();
```

위의 코드는 자식 계약을 생성하며 부모 계약 타입 변수에 참조를 저장한다. 이것이 계약 다형성이 솔리디티에서 구현된 방법이다.   
다음 예제 코드를 보자.

```solidity
pragma solidity ^0.5.4;

contract ParentContract {
    uint internal simpleInteger;
    
    function SetInteger(uint _value) public {
        simpleInteger = _value;
    }
    
    function GetInteger() public view returns (uint) {
        return 10;
    }
}

contract ChildContract is ParentContract {
    
    function GetInteger() public view returns (uint) {
        return simpleInteger;
    }
}

contract Client {
    ParentContract pc = new ChildContract();
    
    function workWithInheritance() public returns (uint) {
        pc.SetInteger(100);
        return pc.GetInteger(); //결과값 : 100 (10 아님)
        //ChildContract 인스턴스를 생성하여 ParentContract 타입 변수에 참조를 저장
        //ParentContract의 GetInteger를 가져오는 것이 아닌
        //ChildContract의 GetInteger를 가져옴 
    }
}
```