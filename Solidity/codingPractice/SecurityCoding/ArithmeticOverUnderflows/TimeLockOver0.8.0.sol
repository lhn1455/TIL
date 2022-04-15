// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
0.8.0 버전 이후로 SafeMath를 사용하지 않아도 
컴파일러가 자동으로 Under / Overflow를 잡아줌

자동으로 검출하는것이 싫으면
unchecked{..} 를 쓰면 되는데,
SafeMath를 쓸건지, 안 쓸건지는 경우에 따라 선택하면 됨.
*/

contract TimeLock {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lockTime;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime() public {
        
        //남아있는 시간을 얻어 데이터 유형에 최대값을 넘어 0이 되도록 함
        uint256 _secondsToIncrease;
        uint256 max = 2 **256 -1;
        _secondsToIncrease = max - lockTime[msg.sender];
        lockTime[msg.sender] += (_secondsToIncrease + 1) ;
        
    }


    function withdraw() public {
        require(balances[msg.sender] >0 );
        require(block.timestamp > lockTime[msg.sender], "time error");
        uint256 transferValue = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(transferValue);
    }
}