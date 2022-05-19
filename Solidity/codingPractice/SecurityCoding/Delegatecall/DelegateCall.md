# DELEGATECALL

**delegatecall** 
- 컨트랙트 A를 통해 컨트랙트 B 호출시, B의 storage를 변경기시키 않고, B의 코드를 A에서 실행. msg.sender와 msg.value가 값이 바뀌지 않는다는 것 외에는 메시지 콜과 동일
- 이것은 컨트랙트가 실행 중 다양한 주소의 코드를 동적으로 불러온다는 것을 뜻함. 스토리지, 현재 주소와 잔액은 여전히 호출하는 컨트랙트를 참조하지만 코드는 호출된 주소에서 가져옴
- 이것은 solidity에서 복잡한 데이터 구조 구현이 가능한 컨트랙트의 스토리지에 적용 가능한 재사용 가능한 코드, 라이브러리 구현을 가능하도록 함

- 중요 함수에 접근 권한이 public의 경우 공격자 컨트랙트가 호출할 수 있어 권한 수정이 필요합니다.
- 참조한 라이브러리의 함수 접근 권한이 public인 경우 공격자 컨트랙트가 delegatecall로 호출할 수 있어 권한 수정이 필요합니다.

**피보나치 수열 컨트랙트**

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FibonacciLib {

    uint public start;
    uint public calculatedFibNumber;

    function setStart(uint _start) public {
        start = _start;
    }

    function fibonacci(uint n) internal returns (uint) {
        if( n == 0 ) return start;
        else if ( n== 1) return start + 1;
        else return fibonacci(n-1) + fibonacci(n-2);
    }
}
```

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FibonacciBalance {

    address public fibonacciLibrary;
		
    uint public calculatedFibNumber;

    uint public start = 3;
    uint public withdrawalCounter;

    **bytes4 constant fibSig = bytes4(keccak256("setFibonacci(uint256)"));**

    constructor(address _fibonacciLibrary)  payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function withdraw() public {
        withdrawalCounter += 1;
        require(**fibonacciLibrary.delegatecall(fibSig, withdrawalCounter**));
        msg.sender.transfer(calculatedFibNumber * 1 ether);
    }

    fallback() external {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}
```

- FibonacciLib에 setFibonacci 함수를 호출합니다.
- 공격자의 컨트랙트는 public 권한에 setStart 함수를 호출할 수 있어 start값을 수정 후 ether를 탈취할 수 있습니다.

**예방기법**

- solidity에서 제공하는 라이브러리 키워드를 이용하여 구현합니다.
- 이 라이브러리 구조는 비정상적인 자체 파괴가 안되는 것(non-self-destructable)을 보장하고 상태 변경이 안됨을 보장합니다.
- 일반적으로 delegatecall을 이용할 때는 라이브러리와 메인 두곳에서 호출 가능한 컨텍스트를 주의합니다.
- 일반적으로 delegatecall을 이용할 때는 상태가 변경되지 않는 라이브러리를 이용합니다.