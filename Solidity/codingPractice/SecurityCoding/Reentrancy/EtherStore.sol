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


*/