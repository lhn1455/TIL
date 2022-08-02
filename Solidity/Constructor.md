# 생성자
- 솔리디티는 계약에서 생성자를 선언하는 것을 지원한다.
- 솔리디티에서 생성자는 선택사항이며, 생성자를 명시적으로 선언하지 않으면 컴파일러가 기본 생성자를 넣어준다.
- 생성자는 계약이 배포될 때만 한번 실행된다.
- 이것은 다른 프로그래밍 언어에서와 다른점이다.
- 다른 프로그래밍 언어에서는 새로운 객체 인스턴스가 생성될 때마다 생성자가 실행된다.
- 하지만 솔리디티에서는 **EVM**에 배포되는 시점에만 실행된다.
- 생성자는 상태 변수를 초기화하는 데 사용되며, 솔리디티 코드가 많이 들어가는 것을 피해야한다.
- 생성자는 계약에서 처음으로 실행되는 코드다.
- 다른 프로그래밍 언어에서 여러 개의 생성자를 둘 수 있는 것과 달리, 한 계약에서 하나의 생성자만 있을 수 있다.
- 생성자는 파라미터를 취할 수 있으며, 계약을 배포할 때 인자를 넣어야 한다.


생성자의 가시성은 `public`, `internal`이 될 수 있지만 `external`이나 `private`는 될 수 없다.   
생성자의 가시성을 `internal`로 하면, 추상(abstract)계약 이라는 것이기 때문에, 단독으로는 사용할 수 없다.   
다른 계약에서 상속을 받아서 사용해야 한다.   
```solidity
pragma solidity ^0.5.4;
contract A {
    uint public a;
    constructor(uint _a) internal {
        a = _a;
    }
}

contract B is A(1) {
    constructor() public {

}

}
```

생성자를 상속받는 방법은 두가지이다.
1. 상속받을 때 직접 argument를 넣어서 사용하는 방법
2. modifier-style을 이용하는 방법
내부적으로 기능적인 차이는 없으니 편의에 맞게 사용한다.

```solidity
pragma solidity ^0.5.4;
contract Parent {
    uint x;
    constructor(uint _x) public {
        x = _x;
    }
    
    function getData() public returns(uint) {
        return x;
    }
}
// 첫번째 방법
contract Child1 is Parent(7) {
    constructor(uint _y) public {}
}

// 두번째 방법
contract Child2 is Parent {
    constructor(uint _y) Parent(_y * _y) public {}
}
```
생성자는 데이터를 명시적으로 변환하지 않는다.   
다음 예에서 HelloWorld 계약의 생성자를 정의하고 생성자에서 스토리지 변수값을 5로 설정한다.
```solidity
pragma solidity ^0.5.19;

contract HelloWorld {
    uint private simpleInt;
    
    constructor() public {
        simpleInt = 5;
    }

    function getValue() public view returns (uint) {
        return simpleInt;
    }

    function setValue(uint _value) public {
        simpleInt = _value;
    }
}
```

## 생성자 버전별 특징
- Solidity version 0.5.0 이상
  - 생성자 이름은 `constructor`이어야 한다.
- Solidity version 0.4.22 이상
  - 생성자 이름이 `constructor`이어도 된다.   
  - 생성자 이름이 계약이름과 동일하게 사용되는 문법은 앞으로 사용되지 않을것이다.
    ```solidity
    pragma solidity ^0.4.22;
      
      contract A {
        uint public a;
        
        constructor(uint _a) internal {
            a = _a;
        }
      }
      
      contract B is A(1) {
            constructor() public {
        }
      }
    ```
- Solidity version 0.4.21 이하
  - 생성자 이름은 계약이름과 동일해야 한다.
    ```solidity
    pragma solidity ^0.4.11;
    contract A {
        uint public a;
        
        function A(uint _a) internal {
            a = _a;
        }
    }
    contract B is A(1) {
        function B() public {
            
        }
    }
    ```