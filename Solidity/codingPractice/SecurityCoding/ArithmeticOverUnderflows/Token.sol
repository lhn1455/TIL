// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Token {

    mapping(address => uint256) balances;
    uint256 totalSupply;

    function token(uint256 _initalSupply) public {
        balances[msg.sender] = totalSupply = _initalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        unchecked{
        //balances 데이터 유형이 uint로 음수가 될 수 없음
        //이 조건식은 underflow를 사용하여 우회할 수 있음. 
        //balances에 값이 0인 경우, balances 데이터 유형이 uint이므로 
        //음수가 될 수 없어 양의값을 빼면 양수가 됨.
        require(balances[msg.sender] - _value >= 0);
        //여기도 마찬가지
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
        }
    }

    function balanceOf (address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }
}