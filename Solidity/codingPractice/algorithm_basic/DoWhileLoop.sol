// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DoWhileLoop {

    mapping (uint => uint) blockNumber;
    uint256 counter; //0

    event uintNumber(uint256);

    function setNumber() public {
        blockNumber[counter++] = block.number; //55 //57
        // blockNumberp[1] = 55
        emit uintNumber(block.number); //55 //57
        emit uintNumber(counter); // 1 //2

    }

    function getNumber() public  {
        uint256 i; //0
        do {
            emit uintNumber(blockNumber[i]); //55 | //55 -> 57로 변경
            emit uintNumber(i); //0 | //0 -> 1로 변경
            emit uintNumber(counter); //1 | //2 ->2 동일
            i++; //1 | //1 -> 2로 변경
        } while (i < counter);  //1 < 1 루프 빠져나옴 |  //1 <2 루프 속으로 다시 들어감 2<2 루프 빠져나옴
    }

    /*
    do~ while 문

    일단 do 한번 무조건 돌고 그다음 while 조건이 참이면 다시 do , 거짓이면 빠져나옴
    */
}