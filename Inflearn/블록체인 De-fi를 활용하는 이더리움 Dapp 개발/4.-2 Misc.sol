pragma solidity 0.5.16;

import "./MyLib.sol";

contract Misc {
    
    MyLib.State public myState; //MyLib.State는 라이브러리에 저장된 타입이고 myState라는 상태변수의 타입을 MyLib.State로 정의
    
    using MyLib for MyLib.State; // using 키워드를 써서 MyLib에서 제공하는 메소드를 쓸 수 있음

    function f() public {
        myState.lock(block.number); //myState를 통해서 라이브러리 함수에 바로 접근 가능
    }

    function g()  external view returns (uint256) {
        return myState.lockedAt;
    }
}