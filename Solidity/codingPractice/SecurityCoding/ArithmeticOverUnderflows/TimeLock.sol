// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract TimeLock {


    /*
입금 후 1주일 동안 출금을 금지하여 안전하게 보관해주는 컨트랙트
- 공격자는 현재 남아있는 시간을 확인할 수 있음
- 이것을 userLockTime이라고 하고, lockTime[msg.sender]가
0이 될 수 있도록
(2^256 - userLockTime) = _secondsToIncrease 를 계산하여
increaseLockTime(_secondesToIncrease) 함수를 호출하면
lockTime[msg.sender]는 0 이됨
 */


    mapping(address => uint256) public balances;
    mapping(address => uint256) public lockTime;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint256 _secondsToIncrease) public {
        //남아있는 시간을 얻어 데이터 유형에 최대값을 넘어 0이 되도록 함
        lockTime[msg.sender] += _secondsToIncrease;
    }

    function withdraw() public {
        require(balances[msg.sender] >0 );
        require(block.timestamp > lockTime[msg.sender], "time error");
        uint256 transferValue = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(transferValue);
    }
}

/*
예방 기법
1. Under / Overflow를 막기 위해 산술 연산자를 대체하는
    표준 수학 라이브러리 사용 (오픈제플린 - SafeMath) 
    ***→0.8.0버전 이후 컴파일러가 잡아줌***
2. EVM은 0으로 나눌 경우 Under / Overflow를 발생시키지 않음

 */


