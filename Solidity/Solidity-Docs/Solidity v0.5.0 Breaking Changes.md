# Solidity v0.5.0 Breaking Changes

> Solidity v0.5.0으로 컴파일된 컨트랙트는 여전히 컨트랙트를 다시 컴파일하고 재배포하는 과정 없이 이전 버전으로 컴파일된 라이브러리와 다른 컨트랙트들과 상호작용 할 수 있다. 데이터 저장 위치와 가시성을 포함하기 위한 인터페이스와 변동성 지정자를 바꾸는것으로 충분하다.   >>[Interoperability With Older Contracts](#interoperability-with-older-contracts)


## Semantic Only Changes (의미론적인 변화)
> 이 섹션은 오직 의미론적인 변화, 즉 이미 존재하는 코드에서 잠재적으로 숨어있는 기존과는 다른 새로운 방식의 변화들을 나열한다.

- 부호를 지닌 오른쪽 시프트 연산자(">>")는 적절한 연산 시프트를 사용한다. 예를 들어, 0으로 반올림하는 것(rounding towards zero) 대신, 음의 무한대로 반올림(rounding towards negative infinity). 
- `do...while`루프에서 `continue`문은 조건문을 건너뛴다. 그리고 이것은 일반적인 `continue`문과 같다. 이것은 루프의 body를 건너뛰기 위해 사용된다. 따라서, 조건이 false일때, 이 루프는 종료된다.
- 특정한 단일 `bytes` 파라미터가 주어졌을때, `.call()`, `.delegatecall()` 그리고 `.staticcall`함수는 더이상 pad 하지 않는다.
- `pure`과 `view`함수는 EVM 버전이 Byzantium이거나 그 이상일 경우 `call` 대신 opcode의 `STATICCALL`을 사용하여 호출 된다. (EVM레벨에서의 상태변화 허용X)
- ABI encoder는 external 함수가 호출될 때와 `abi.encode`가 사용 될때 calldata(`msg.date`와 external 함수 파라미터)로 부터 byte arrays와 string을 적절히 pad한다. unpadded된 encoding을 위해서는 `abi.encodePacked`를 사용.
- ABI decoder는 전달된 calldata가 너무 짧거나 범위를 벗어났을때 함수의 시작부분 또는 `abi.decode()`에서 revert한다. 지저분한 상위 비트는 무시됨.
- external 함수 호추에 모든 사용가능한 가스를 forward한다.   

## Semantic and Syntactic Changes (의미론적, 문법적인 변화)
 > 이 섹션은 문법적, 의미적인 부분에 영향을 주는 중요한 변화들이다.
 - `.call(),` `.delegatecall()`, `staticcall()`, `keccak256()`, `sha256()` 그리고 `ripemd160()`함수는 하나의 `bytes`인자만 받는다. 또한 인자는 pad되지 않는다. 이것은 인자들이 연결되는 방법을 더 분명하고 명확하게 만들기위해 변화되었다. 모든 `.call()` 을 `.call("")`로 바꿔라. 그리고 모든 `.call(signature, a, b, c)`를 `.call(abi.encodeWithSignature(signature, a, b, c))`로 바꾸어 사용해라. (이것만 값 타입으로 허용한다.)
    > `.call()` ➔ `.call("")`   
 `.call(signature, a, b, c)` ➔ `.call(abi.encodeWithSignature(signature, a, b, c))`
- keccak256(a, b, c)를 keccak256(abi.encodePacked(a, b, c))로 변경한다
    > `keccak256(a, b, c)` ➔ `keccak256(abi.encodePacked(a, b, c))`
- call, delegatecall, staticcall은 (bool, bytes memory)를 리턴한다.
    > `bool success = otherContract.call(“f”)` ➔ `(bool success, bytes memory data) = otherContract.call(“f”)`
- 솔리디티는 함수 로컬 변수에 대해 C99-style scoping rules을 적용한다. 즉, 변수가 선언되어지고 난 후, 오직 같은 범위 또는 포함된 범위 안에서만 사용될 수 있다. `for`loop의 초기화 블록에 선언된 변수는 루프 내부 어느 지점에서든 사용이 가능하다.   

## Explicitness Requirements 명시적 요구사항
> 이 섹션은 코드들이 더 명시적으로 되어야하는 부분들을 나열한다. 이 토픽들의 대부분 컴파일러가 의견을 제안할 것이다.
- 모든 함수는 가시성을 명시적으로 작성해야 한다. (변수 포함)
- 구조체, 배열, 매핑 타입 변수는 명시적으로 데이터 위치를 작성해야 한다. (함수의 매개변수와 리턴값 포함 / external 함수의 매개변수의 데이터 위치 : calldata)
    >예시)   
    `uint[] x = m_x` ➔ `uint[] storage x = m_x`   
    `function f(uint[][] x)` ➔ `function f(uint[][] memory x)`   
    > 참고 : [데이터 타입과 타입별 저장위치](https://github.com/lhn1455/TIL/blob/main/Solidity/%EB%8D%B0%EC%9D%B4%ED%84%B0%20%ED%83%80%EC%9E%85%EA%B3%BC%20%ED%83%80%EC%9E%85%EB%B3%84%20%EC%A0%80%EC%9E%A5%EC%9C%84%EC%B9%98.md)

- 컨트랙트 타입은 주소 타입의 멤버를 포함하지 않기 때문에(namespace를 분리하기위해서) 주소 타입 멤버를 사용해야 할 경우, 명시적으로 주소 타입으로 형변환 해야 한다.
예를 들어, c가 컨트랙트라면, transfer함수 호출 시 `address(c)`와 같이 먼저 주소 타입으로 변경한 후 `address(c).transfer(...)`와 같이 사용해야 하며 `c.balance`를 `address(c).balance`로 변경해야 한다.
    > `c.transfer(...)` ➔ `address(c).transfer(...)`   
    `c.balance` ➔ `address(c).balance`
- 상속 관계를 갖는 컨트랙트가 아니라면 명시적으로 형변환이 혀용되지 않는다. 상속관계를 갖지 않더라도 호환 가능한 경우에는 먼저 주소타입으로 형변환 해야 한다. 예를 들어, A,B가 상속관계를 갖지 않는 컨트랙트 타입이지만 호환이 가능하다면 A(address(b))와 같이 할 수 있다.
- 주소타입은 `address`타입과 `address payable` 두 가지로 나뉨. 단, `address payable` 타입에 대해서만 `transfer`함수가 제공한다.
    > `address payable` 타입은 `address` 타입으로 전환이 가능하지만 반대의 경우 성립하지 않음. `address`를 `address payable`로 변환하려면 `uint160`통해서 해야 함. 만약 c가 컨트랙트라면, 오직 c가 `payable fallback` 함수를 가질때만 `address(C)`는 `address payable`가 될 수 있음. 만약 **withdraw pattern**을 사용한다면, 코드를 수정할 필요가 없다. 왜냐하면 `transfer`가 저장된 `address`들 대신에 오직 `msg.sender`에 의해서만 사용되고 `msg.sender`는 `address payable`이기 때문.
- `bytesX`와 `uintY`의 다른 사이즈 간의 형변환은 오른쪽으로 padding하는 `bytesX`와 왼쪽으로 padding하는 `uintY`때문에 형변환이 허용되지 않는다. 이것은 형변환 오류를 일으킬 수 있다.사이즈는 반드시 형변환 전에 타입레벨에서 맞추어져야 한다. 예를 들어, `bytes4`(4 bytes)는 `bytes4 `변수를 `bytes8`(8 bytes)로 형변환 한 후에 `uint64`(8 bytes)로 형변환 할 수 있다. 반대의 경우 `uint64`를 `uint32`(4 bytes)로 변환 후 `bytes4`로 변환한다.
    > 참고   

    |<center> Type Name</center> | <center>Description</center> |
    |---|---|
    | uint8 | 1 byte unsigned integer |
    | uint16 | 2 byte unsigned integer |
    | uint32 | 4 byte unsigned integer |
    | uint64 | 8 byte unsigned integer |
    | uint256 | 32 byte unsigned integer |
    ```solidity
    // how to convert uint to bytes
    
    // 1. 
    uint i = 0;
    i_bytes = abi.encodePacked(i); 
    
    // 2.
    function toBytes(uint256 x) returns (bytes b) {
    b = new bytes(32);
    assembly { mstore(add(b, 32), x) }
    }

    ```

    > v0.5.0이전에는 `bytesX`와 `uintY`사이의 어떠한 형변환도 `uint8X`를 통해 가능했지만 지금은 안됨.   
    예시)   
    uint8(bytes3(0x291807)) ➔ uint8(uint24(bytes3(0x291807))) (the result is 0x07) => 이제 안됨

- non-payable 함수 또는 modifier를 통해 이 함수로 접근하는 것도 `msg.value`를 사용할 수 없다. **(보안이슈)**
`payable`함수로 바꾸던가 `msg.value`를 사용하는 프로그램 로직을 위해 새로운 internal 함수를 만들어야 한다.

- 명료성의 이유로, 일반적인 input값이 sorce로 사용된다면 command line interface는 지금 `-`를 요구한다. 


## Deprecated Elements (사라질 요소들)

### Command Line and JSON Interfaces
- `--formal` 제거 됨
    - A new formal verification module, the SMTChecker, is enabled via pragma experimental SMTChecker;.
- `--julia` ➔ `--yul` 변경
- `--clone-bin` , `--combined-json clone-bin` 제거
- 비어있는 prefix로 remappling 허용 안함
- JSON AST 필드 `constant`와 `payable` 제거 (➔ `stateMutabiliy`필드를 통해 나타냄)
- JSON AST 필드 `FunctionDefinition`의 `isConstructor` ➔ `kind` 대체 (kind 값 : **constructor, fallback, function**)
- 연결되지않은 이진 hex 파일들에서 라이브러리 주소 placeholder는 `$...$`로 둘러싸인 완전히 명백한 라이브러리 이름의 keccak256 해시값의 첫 36 hex characters이전에는 단지 라이브러리 이름만 사용. 이것은 충돌의 위험을 줄여줌. 이진 파일은 지금 이러한 placeholder부터 라이브러리 이름까지 모두를 mapping리스트로 포함.

### Constructors
- 생성자는 반드시 `constructor`키워드를 이용하여 정의되어야 함.
- 괄호 없이 기본생성자를 호출하는 것은 허용되지 않음.
- 동일한 상속 관계에서 기본생성자의 인자들을 여러번 지정하는 것은 허용되지 않음.
- 잘못된 인자 갯수로 생성자 호출하는 것은 허용되지 않음. 만약 인자를 주는 것 없이 상속관계를 지정하고 싶다면, 괄호를 삭제.


### Functions
- `callcode` ➔ `delegatecall` (but, inline assembly에서는 여전히 사용 가능)
- `suicide` ➔ `selfdestruct`
- `sha3` ➔ `keccak256`
- `throw` ➔ `revert`, `require`, `assert`

### Conversions
- 10진수 literal에서 bytesXX로의 형변환은 허용되지 않음.
- 크기가 다른 16진수 literal에서 byteXX 형변환은 허용되지 않음.

### Literals and Suffixes
- `years` 사용 안함
- 뒤에 숫자가 없는 .은 허용되지 않음
- 16진수 숫자와 단위 구분자는 함께 사용할 수 없음  
    예시 ) 0x12 wei
- 0X는 허용되지 않음 (0x만 허용)

### Variables
- 빈 구조체 허용 안함
- `var`사용 안함
- 컴포넌트 갯수가 다른 튜플들 사이의 할당은 허용하지 않음
- 컴파일 타임 상수가 아닌 상수에 대한 값은 허용 안함
- 변수의 갯수가 다른 다중 변수 선언은 허용하지 않음
- 초기화되지 않은 스토리지 변수 사용은 허용하지 않음
- 빈 튜플 허용 안함
- 변수 및 구조체에서 순환 의존성을 감지하는 것은 재귀에서 256으로 제한함
- 길이가 0인 고정크기 배열은 허용하지 않음

### Syntax
- 함수에 사용되는 `constant`는 더이상 사용 안함
- boolean 표현식에 산술연산 사용 못함.
- unary + 연산자는 허용되지 않음
- literal은 명시적인 타입으로 형변화 없이 abi.encodePacked를 사용할 수 없음
- 하나 이상의 리턴 값을 갖는 함수에 대해서 빈 리턴문은 허용되지 않음
- `loose assembly`문법은 완전히 허용되지 않음. 즉, `jump labels`, `jumps` 그리고 non-functional instruction들은 더이상 사용되지 않음. ( ➔ `switch`, `if`로 대신함)
- 구현없는 함수는 modifier를 사용할 수 없음
- 이름 있는 리턴 값을 가진 함수 타입은 허용되지 않음
- if/while/for문의 내부에서 블록이 아닌 단일구문 변수 선언은 허용되지 않음.
- 새로운 키워드 : `calldata`, `constructor`
- 새로 예약된 키워드 : `alias`, `apply`, `auto`, `copyof`, `define`, `immutable`, `implements`, `macro`, `mutable`, `override`, `partial`, `promise`, `reference`, `sealed`, `sizeof`, `supports`, `typedef`, `unchecked`.


# Interoperability With Older Contracts
> 인터페이스를 정의하는 것 만으로 v0.5.0 이전 버전으로 쓰여진 컨트랙트와 상호작용할 수 있다.

0.5.0버전 이전의 컨트랙트를 이미 배포했다고 가정하자.

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.25;
// This will report a warning until version 0.4.25 of the compiler
// This will not compile after 0.5.0
contract OldContract {
    function someOldFunction(uint8 a) {
        //...
    }
    function anotherOldFunction() constant returns (bool) {
        //...
    }
    // ...
}
```
이것은 솔리디티 v0.5.0으로 더이상 컴파일 되지 않을 것이다. 
> ### 호환가능한 인터페이스를 정의하자   

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
interface OldContract {
    function someOldFunction(uint8 a) external;
    function anotherOldFunction() external returns (bool);
}
```
원래의 컨트랙트의 `anotherOldFunction`이 constant로 선언되어 있음에도 불구하고 view 로 선언하지 않았다. 이것은 솔리디티 v0.5.0 `staticcall`의 시작이 `view` 함수를 호출하기 위해 사용된다는 사실 때문이다. v0.5.0 이전에 `constant` 키워드는 강요되지 않았다. 그래서 `staticcall`과 함께 `constant`로 선언된 함수를 호출하는 것은 `constant` 함수가 
`storage`를 변경하려고 시도할것이기 때문에 revert되었다. 결과적으로 이전 컨트랙트에 대해 인터페이스가 정의되었을때, 이 함수가 무조건 `staticcall`로만 작동한다고 보장하는 경우 `constant`자리에 `view`만 사용하면 된다. 

>### 위와 같이 인터페이스가 정의되었다면, 이전에 배포한 컨트랙트를 쉽게 사용할 수 있다. 
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

interface OldContract {
    function someOldFunction(uint8 a) external;
    function anotherOldFunction() external returns (bool);
}

contract NewContract {
    function doSomething(OldContract a) public returns (bool) {
        a.someOldFunction(0x42);
        return a.anotherOldFunction();
    }
}

```

비슷하게 v0.5.0이전의 라이브러리는 연결되어 있는 동안에 라이브러리 주소에 대한 공급과 실행 없이, 라이브러리 함수를 정의 함으로써 사용될 수 있다.
```solidity
// This will not compile after 0.6.0
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

library OldLibrary {
    function someFunction(uint8 a) public returns(bool);
}

contract NewContract {
    function f(uint8 a) public returns (bool) {
        return OldLibrary.someFunction(a);
    }
}
```

# Example
다음의 예시는 old version 컨트랙트와 new version 컨트랙트를 비교하여 보여준다. 

> Old Version
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.25;
// This will not compile after 0.5.0

contract OtherContract {
    uint x;
    function f(uint y) external {
        x = y;
    }
    function() payable external {}
}

contract Old {
    OtherContract other;
    uint myNumber;

    // Function mutability not provided, not an error.
    function someInteger() internal returns (uint) { return 2; }

    // Function visibility not provided, not an error.
    // Function mutability not provided, not an error.
    function f(uint x) returns (bytes) {
        // Var is fine in this version.
        var z = someInteger();
        x += z;
        // Throw is fine in this version.
        if (x > 100)
            throw;
        bytes memory b = new bytes(x);
        y = -3 >> 1;
        // y == -1 (wrong, should be -2)
        do {
            x += 1;
            if (x > 10) continue;
            // 'Continue' causes an infinite loop.
        } while (x < 11);
        // Call returns only a Bool.
        bool success = address(other).call("f");
        if (!success)
            revert();
        else {
            // Local variables could be declared after their use.
            int y;
        }
        return b;
    }

    // No need for an explicit data location for 'arr'
    function g(uint[] arr, bytes8 x, OtherContract otherContract) public {
        otherContract.transfer(1 ether);

        // Since uint32 (4 bytes) is smaller than bytes8 (8 bytes),
        // the first 4 bytes of x will be lost. This might lead to
        // unexpected behavior since bytesX are right padded.
        uint32 y = uint32(x);
        myNumber += y + msg.value;
    }
}
```

> New Version

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;
// This will not compile after 0.6.0

contract OtherContract {
    uint x;
    function f(uint y) external {
        x = y;
    }
    function() payable external {}
}

contract New {
    OtherContract other;
    uint myNumber;

    // Function mutability must be specified.
    function someInteger() internal pure returns (uint) { return 2; }

    // Function visibility must be specified.
    // Function mutability must be specified.
    function f(uint x) public returns (bytes memory) {
        // The type must now be explicitly given.
        uint z = someInteger();
        x += z;
        // Throw is now disallowed.
        require(x <= 100);
        int y = -3 >> 1;
        require(y == -2);
        do {
            x += 1;
            if (x > 10) continue;
            // 'Continue' jumps to the condition below.
        } while (x < 11);

        // Call returns (bool, bytes).
        // Data location must be specified.
        (bool success, bytes memory data) = address(other).call("f");
        if (!success)
            revert();
        return data;
    }

    using address_make_payable for address;
    // Data location for 'arr' must be specified
    function g(uint[] memory /* arr */, bytes8 x, OtherContract otherContract, address unknownContract) public payable {
        // 'otherContract.transfer' is not provided.
        // Since the code of 'OtherContract' is known and has the fallback
        // function, address(otherContract) has type 'address payable'.
        address(otherContract).transfer(1 ether);

        // 'unknownContract.transfer' is not provided.
        // 'address(unknownContract).transfer' is not provided
        // since 'address(unknownContract)' is not 'address payable'.
        // If the function takes an 'address' which you want to send
        // funds to, you can convert it to 'address payable' via 'uint160'.
        // Note: This is not recommended and the explicit type
        // 'address payable' should be used whenever possible.
        // To increase clarity, we suggest the use of a library for
        // the conversion (provided after the contract in this example).
        address payable addr = unknownContract.make_payable();
        require(addr.send(1 ether));

        // Since uint32 (4 bytes) is smaller than bytes8 (8 bytes),
        // the conversion is not allowed.
        // We need to convert to a common size first:
        bytes4 x4 = bytes4(x); // Padding happens on the right
        uint32 y = uint32(x4); // Conversion is consistent
        // 'msg.value' cannot be used in a 'non-payable' function.
        // We need to make the function payable
        myNumber += y + msg.value;
    }
}

// We can define a library for explicitly converting ``address``
// to ``address payable`` as a workaround.
library address_make_payable {
    function make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }
}
```
