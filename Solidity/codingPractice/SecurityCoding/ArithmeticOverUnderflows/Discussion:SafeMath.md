# Discussion: Should we remove the SafeMath library for Solidity 0.8?


> The origin of the discussion is that Solidity 0.8 includes checked arithmetic operations by default, and this renders SafeMath unnecessary. What is not under discussion is that internally the library will use the built in checked arithmetic, rather than the current manual overflow checks in SafeMath. The question is whether we want to keep SafeMath for other reasons.

이 토론 솔리디티 0.8 버전 이후로 산술 오버 플로우 / 언더 플로우에 대하여 체크하는 기능을 디폴트로 지정하면서 safeMath 라이브러리에 대한 필요성이 떨어지게 되어 SafeMath를 계속 쓸것인가의 여부에 따라 발생하게 되었다.

문제는 우리가 다른 이유들로 인해 이 라이브러리를 계속 쓰길 원한다는 것이다.

- **Backwards compatibility 이전버전과의 호환성**   
이전 버전의 컨트랙트들을 생각하면, 호환을 위해 SafeMath를 쓰는것이 더 나은 방법일 것이다. 

    vs

    지금이라도 SafeMath를 지우면서 수정해나가는것이 더 나은 방법일 것이다. 또한, 그렇게 하므로써 사용자가 새로운 의미 체계를 검토하고 적절하게 checked와 unchecked를 선택해서 사용할 수 있게 되기 때문이다. 또한 가스 영향도 해야한다.


    >SafeMate가 내장된 check기능을 사용하는 것 보다 더 많은 비용을 소모하는 것은 사실 (비용에 관해서는 아래 내용 추가)


- **Use inside unchecked blocks**   
unchecked를 사용하여 자동 체크를 원하지 않는 부분을 지정할 수 있다.
safeMath를 계속 사용하길 원한다면, 산술연산 부분을 uncheck block으로 감싸면 된다.

- **Have custom revert message for safemath operation**   

    Solidity 0.8.0은 오버플로가 발생하면 revert시키지만 이유를 사용자 정의할 수는 없다. 경우에 따라 "ERC20: 이체 금액이 잔액을 초과함"과 같은 이유 메시지를 전달하고자 할 수도 있는데, 이것을 내장체크 기능에서는 사용할 수 없다. 반면에 SafeMath는 이러한 기능을 제공한다.

<hr>


0.8.0의 default인 checked 기능은 무료가 아니다.
컴파일러는 SafeMath에서 구현한 것과 유사한 몇 가지 오버플로 검사를 추가하고, 이러한 검사가 현재 SafeMath보다 저렴할 것으로 예상하는 것이 합리적이지만 이 검사는 이전에 다루지 않았던 "기본 수학 연산" 비용을 증가시킬 것이라는 점을 명심해야 한다.

예시)

```solidity
function sum(uint[] memory array) internal pure returns (uint result) {
    result = 0;
    for (uint i = 0; i < array.length; ++i) { 
        result += array[i]; 
    }
}
```
이 코드 안에서, 두번의 수학 연산을 진행한다.
1. result += array[i]
2. ++i   

여기서, 2번의 연산을 수행할 때, 굳이 오버플로우 체크가 필요할까?
솔리디티 공식문서에서 제안한것처럼 unckecked를 사용해보자.

```solidity
function sum(uint[] memory array) internal pure returns (uint result) {
    result = 0;
    unchecked { 
        for (uint i = 0; i < array.length; ++i) { 
            result += array[i]; 
        } 
    }
}
```
하지만, 이렇게하면 배열에서 발생할지도 모르는 오버플로우를 예방할 수 없다.   
따라서 이렇게 쓰는 경우가 많다.
```solidity
function add(uint x, uint y) internal pure returns(uint) { 
    return a + b; 
    }

function sum(uint[] memory array) internal pure returns (uint result) {

    result = 0;
    unchecked { 
        for (uint i = 0; i < array.length; ++i) { 
            result = add(result, array[i]); 
            } 
        }
} 

```
이 예시에서, 함수의 추가 비용은 전체 체크 해제를 무의미하게 만들 수 있지만, 루프의 핵심이 상당한 수의 수학 연산을 포함하고 그 중 일부만 보호가 필요한 경우에는 SafeMath가 유용할 것이다.

```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

contract OverflowCost {
    event Log(uint256);
    function add(uint256 x, uint256 y) external { emit Log(x + y); }
    function sub(uint256 x, uint256 y) external { emit Log(x - y); }
    function mul(uint256 x, uint256 y) external { emit Log(x * y); }
    function div(uint256 x, uint256 y) external { emit Log(x / y); }
    function mod(uint256 x, uint256 y) external { emit Log(x % y); }
}

contract OverflowCostUnchecked {
    event Log(uint256);
    function add(uint256 x, uint256 y) external { unchecked { emit Log(x + y); } }
    function sub(uint256 x, uint256 y) external { unchecked { emit Log(x - y); } }
    function mul(uint256 x, uint256 y) external { unchecked { emit Log(x * y); } }
    function div(uint256 x, uint256 y) external { unchecked { emit Log(x / y); } }
    function mod(uint256 x, uint256 y) external { unchecked { emit Log(x % y); } }
}
```
for add(17,42), unchecked saves 61 gas   
for sub(42,17), unchecked saves 58 gas   
for mul(17,42), unchecked saves 81 gas   
for div(42,17), unchecked saves 32 gas   
for mod(42,17), unchecked saves 32 gas   
using 0.8.0 with optimizations.

> **참고**   
Discussion: Should we remove the SafeMath library for Solidity 0.8?   
(https://github.com/OpenZeppelin/openzeppelin-contracts/issues/2465)







