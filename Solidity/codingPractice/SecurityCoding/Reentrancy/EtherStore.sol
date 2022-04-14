// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    //입금함수
    function depositFund() public payable {
        balances[msg.sender] += msg.value;
    }

    //출금함수
    function withdrawFunds (uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        require(_weiToWithdraw <= withdrawalLimit);
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks);

        //변경전
        // requrie(msg.sender.calㅣ.value(_weiToWithdraw)());

        //변경후 (0.6.4 버전 이후)
        (bool success, ) = msg.sender.call {value:_weiToWithdraw}("");
        require(success, "Transfer failed.");

        balances[msg.sender] -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = block.timestamp;
    }
}

/* 
call 함수의 특징
1. 가변적인 gas 소비 (gas값 지정 가능)
2. 성공여부를 true, false로 리턴
3. false시 호출 컨트랙트에서 에러처리
4. 재진입 공격 위험성이 있지만 이스탄불 하드포크(2019)이후 그래도 call 쓸 것을 추천
5. 재진입 공격을 방어하기 위해 주로 The checks-effects-interactions pattern을 함께 사용

(bool success, ) = msg.sender.call.value(amount)("");
        require(success, "Transfer failed."); // 에러처리
*/