// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract GameRandom {

    function play() public payable {
        require(msg.value >= 1 ether);
        
        //수정전
        //bool won = (block.blockhash(blockNumber)%2)==0;

        uint num = uint(blockhash(block.number));
        bool won = (num % 2) == 0;
        if (won) {
            payable(msg.sender).transfer(2 ether);
        }

    }
}