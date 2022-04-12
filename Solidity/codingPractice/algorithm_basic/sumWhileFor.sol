// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SumWhile {

    function sumWhile(uint256 n) public pure returns(uint256, uint256) {
        uint256 sum;
        uint256 i = 1;

        while (i <= n) {
            sum += i;
            i++;
        }
        return (n, sum);
    } 

    function sumFor(uint256 n) public pure returns(uint256, uint256) {
        uint256 sum;
        uint256 i;

        for (i =1; i <= n; i++ ) {
            sum += i;
        }
        return (n, sum);
    } 
    

    function sumGauss(uint256 n) public pure returns(uint256, uint256) {
        uint256 sum;

        sum = (1 + n) * (n / 2);
        return (n, sum);
    } 

    function sumOf(uint256 a, uint256 b) public pure returns (uint256, uint256, uint256) {
        uint256 sum;
        uint256 i;
        
        if(a < b) {
            for (i=a; i<=b; i++ ) {
                sum += i;
            }
        }

        else if (a > b) {
            for (i=b; i <=a; i++) {
                sum += i;
            }
        }
        else
        return (a, b, a);

        return( a, b, sum);
    }
    
    function sumOf2(uint256 a, uint256 b) public pure returns(uint256, uint256, uint256) {
        uint256 sum;
        uint256 i;
        uint256 max;
        uint256 min;

        if (a < b) {
            max = b;
            min = a;    
        }
        else if (a > b) {
            max = a;
            min = b;
        }
    
        for (i=min; i<=max; i++) {
            sum += i;
        }

        return (a,b,sum);
    }
    
} 