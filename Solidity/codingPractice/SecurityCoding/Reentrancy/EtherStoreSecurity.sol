// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract EtherStoreSecutiry {

    bool reEntrancyMutex = false;
    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    //입금함수 
    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    //출금함수
    function withdrawFunds (uint256 _weiToWithdraw) public {
        //이전에 함수가 실행 중이 아닐 경우
        require(!reEntrancyMutex);
        
        require(balances[msg.sender] >= _weiToWithdraw);
        require(_weiToWithdraw <= withdrawalLimit);
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks);


        balances[msg.sender] -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = block.timestamp;

        //sender값 수정전에는 함수 실행이 안되도록
        reEntrancyMutex = true;     

        (bool success, ) = msg.sender.call {value:_weiToWithdraw}("");
        require(success, "Transfer failed.");
        
        //call -> transfer로 바꿀 수 있지만 권장 안함
        //payable(msg.sender).transfer(_weiToWithdraw);

        //sender값 수정이 완료되어 함수 실행가능
        reEntrancyMutex = false;
        
    }
}


/* 
예방 기법
1. transfer 함수 호출 (권장 안함)
2. The checks-effects-interactions pattern (외부 호출 전에 값을 먼저 수정)
3. 뮤텍스 이용 (이전 호출을 종료한 후 다음 호출을 실행)
*/