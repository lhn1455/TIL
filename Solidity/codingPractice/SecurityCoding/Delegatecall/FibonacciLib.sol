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