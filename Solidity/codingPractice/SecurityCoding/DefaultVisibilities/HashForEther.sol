// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract HashForEther {
    function withdrawWinnings() public {
        //winner if the last 8 hex characters of the address are 0
        address from = msg.sender;
        uint160 result = uint160(from);
        uint32 add = uint32(result);
        require(add == 0);
        _sendWinnings();
    }

    function _sendWinnings() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}