# 인터페이스 (Interface)
- 인터페이스는 추상 계약과 비슷하지만 차이점이 있다.
- 인터페이스는 어떠한 정의도 포함하지 않는다.
- 인터페이스에는 함수의 선언만 있다.
- 인터페이스에 있는 함수는 어떠한 코드도 포함하지 않는다는 뜻이다.
- 인터페이스를 순수한 추상 계약이라고도 한다.
- 인터페이스는 함수의 시그니처만 포함할 수 있다.
- 또한 어떠한 상태 변수도 포함할 수 없다.
- 다른 계약을 상속한다거나 열거형 또는 구조체를 포함할 수도 없다.
- 그렇지만 인터페이스가 다른 인터페이스를 상속할 수는 있다.
- 함수 시그니처는 세미콜론(;) 문자로 종료한다.
- 인터페이스는 `interface` 키워드와 식별자를 사용해 선언한다.
- 다음 코드 예제에서 인터페이스의 구현을 볼 수 있다.

솔리디티에는 인터페이스를 선언하는 `interface` 키워드가 있다.   
`IHelloWorld` 인터페이스는 두개의 함수 시그니처인 `GetValue`와 `SetValue`를 포함한다.   
구현된 함수는 없다.   
이 계약의 인스턴스를 생성하는 방법은 일반적인 계약의 인스턴스를 생성하는 것과 같다.   
다음 예제 코드를 보자.   

```solidity
pragma solidity ^0.5.4;

interface IHelloWorld {
    function GetValue() public view returns (uint);
    function SetValue(uint _value) public;
}

contract HelloWorld is IHelloWorld {
    uint private simpleInteger;
    
    function GetValue() public view returns (uint) {
        return simpleInteger;
    }
    
    function SetValue(uint _value) public {
        simpleInteger = _value;
    }
}

contract client {
    IHelloWorld myObj;
    
    constructor() public {
        myObj = new HelloWorld();
    }
    
    function GetSetIntegerValue() public returns (uint) {
        myObj.SetValue(100);
        return myObj.GetValue();
    }
}
```