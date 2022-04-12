// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Max3 {
   
    event Max(uint256);
    event Min(uint256);
    event TernaryOperator(uint256);

    //최대값 구하기
    function max3 (uint256 a, uint256 b, uint256 c) public returns(uint256) {
        uint256 max = a;
        if (b > max) max = b;
        if (c > max) max = c;

        emit Max(max);   
        return max;
    }
    //최소값 구하기
    function min3 (uint256 a, uint256 b, uint256 c) public returns(uint256) {
        uint256 min = a;
        if (b < min) min = b;
        if (c < min) min = c;

        emit Min(min);   
        return min;
    }
    //중앙값 구하기 1
    function median (uint256 a, uint256 b, uint256 c) public pure returns(uint256) {
        if ( a >= b)
            if (b >= c )
                return b;
            else if ( a <= c)
                return a;
            else
                return c;
        else if ( a > c )
            return a;
        else if ( b > c )
            return c;
        else 
            return b;

    }
    //중앙값 구하기 2
    function median2 (uint256 a, uint256 b, uint256 c) public pure returns(uint256) {
        if ((b >= a && c <= a) || ( b <= a && c >= a))
            return a;
        else if (( a > b && b > c ) || ( a < b && b < c))
            return b;
        else
        return c;
    }

    //부호 판별
    function judgeSign (int n) public pure returns(string memory) {
        if (n > 0)
            return "plus";
        else if (n < 0)
            return "minus";
        else 
            return "zero";
    }

    //3항 연산자 1
    function ternaryOperator (uint256 b, uint256 c) public pure returns (uint256) {
        uint a = ( b > c )? b : c ;
        return a;
    }
    //3항 연산자 2
     function ternaryOperator2 (uint256 b, uint256 c) public returns (uint256) {
        uint a = ( b > c )? b : c ;
        emit TernaryOperator( a = (  b > c )? b : c);
        return a;

    }

    
}