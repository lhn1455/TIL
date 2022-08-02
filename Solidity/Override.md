# 메서드 오버라이딩
- 메서드 오버라이딩이란 부모 계약의 함수와 같은 이름과 시그니처를 갖는 함수를 파생 계약에서 재정의 하는 것을 가리킨다.
- 다음 코드 조각에서 메서드 오버라이딩의 예를 볼 수 있다.
- 부모 계약에는 두 개의 함수 SetInteger와 GetInteger가 있다.
- 자식 계약은 GetInteger 함수를 부모 계약으로부터 상속하고 그 함수를 오버라이딩해서 자체적으로 구현을 제공한다.


이제 자식 계약에 대한 GetInteger 함수 호출을 할 때 부모 계약 변수를 사용하더라도 자식 계약 인스턴스 함수가 호출된다.   
이것은 계약의 모든 함수가 가상 함수이며 계약 인스턴스에 기초하기 때문이다.   
다음 예제 코드에서 볼 수 있는 바와 같이 대부분의 파생 함수가 호출된다.

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
        return pc.GetInteger(); 
    }
}

```