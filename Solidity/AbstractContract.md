# 추상 계약 (Abstract Contract)
- 추상 걔약이란 함수 정의의 일부를 가진 계약을 말한다.
- 추상 계약의 인스턴스를 생성할 수 없고, 반드시 자식 계약에서 상속해야만 그것의 함수를 사용할 수 있다.
- 추상 계약은 계약의 구조를 정립하는 데 도움이 된다.
- 추상 계약을 상속한 클래스는 반드시 구현을 해야 한다.
- 만약 자식 계약에서 불완전한 함수를 구현하지 않으면 그것의 인스턴스도 생성할 수 없다.
- 함수 시그니처는 세미콜론(;) 문자를 사용해 끝맺는다.
- 솔리디티에는 추상 계약을 표시하는 키워드가 없다.
- 구현되지 않은 함수가 포함되면 추상 계약이 된다.


다음 예제 코드에서 `abstractHelloWorld` 계약은 아무 정의가 없는 함수 두 개를 포함하는 추상 계약이다.   
`GetValue`와 `SetValue`는 구현이 없는 함수 시그니처다.   
그 밖에 상수를 반환하는 `AddNumber` 메서드도 있다.   
이것과 같이 **추상 계약 내에도 구현을 포함하는 함수가 존재할 수 있다.**   
`HelloWorld` 계약은 `abstractHelloWorld` 추상 계약을 상속해서 모든 메서드를 구현했다.
`client` 계약은 **추상 계약의 변수를 선언**해서 `HelloWorld` **계약의 인스턴스를 생성**하고 그것의 함수를 **호출**한다.

```solidity
pragma solidity ^0.5.4;

contract AbstractHelloWorld {
    //추상메서드
    function GetValue() public view returns (uint);
    function SetValue(uint _value) public;
    
    //구현메서드
    function AddNumber(uint _value) public returns (uint) {
        return 10;
    }
}

contract HelloWorld is AbstractHelloWorld {
    uint private simpleInteger;

    function GetValue() public view returns (uint) {
        return simpleInteger;
    }
    function SetValue(uint _value) public {
        simpleInteger = _value;
    }

 
    function AddNumber(uint _value) public returns (uint) {
        return simpleInteger = simpleInteger + _value;
    }
}

contract client {
    //추상 계약의 변수를 선언
    AbstractHelloWorld myObj;
 
    //HelloWorld 계약 인스턴스 생성
    constructor() public {
        myObj = new HelloWorld();
    }
    
    function GetIntegerValue() public returns (uint) {
        myObj.SetValue(100);
        return myObj.AddNumber(200); //결과값 : 300
    }
}
```