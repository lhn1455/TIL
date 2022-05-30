# 생성자 관리 (Constructors with Care)

- **생성자(constructor)**:  컨트랙트를 초기화할 때 종종 중요하고 권한을 필요로 하는 작업을 수행하는 특수 함수
- 솔리디티 v0.4.22 이전 버전에서는 생성자를 `constructor`로 정의하는 것이 아니라 컨트랙트와 이름이 같은 함수로 생성자를 정의했습니다.
- 이러한 경우에 컨트랙트 이름이 변경되면 원래의 생성자는 생성자의 역할을 하지 못하고 일반 함수가 됩니다. 이 점이 취약점이 될 수 있습니다.

**취약점**

- 컨트랙트 이름이 수정되거나 컨트랙트 이름과 일치하지 않는 생성자 이름에 오타가 있는 경우 생성자는 일반함수 처럼 작동합니다.

```solidity
contract OwnerWallet {
    address public owner;

    // constructor
    function ownerWallet(address _owner) public {
        owner = _owner;
    }

    // Fallback. Collect ether.
    function () payable {}

    function withdraw() public {
        require(msg.sender == owner);
        msg.sender.transfer(this.balance);
    }
}
```

- 해당 코드를 작성할 때 개발자는 생성자를 통해서 `owner` 변수를 컨트랙트 소유자로 설정하는 것을 목적으로 했습니다.
- 하지만 생성자 함수를 보면 이름이 잘못되어 생성자가 아닌 일반 함수로서 작동합니다.
- 따라서 컨트랙트의 소유자가 아닌 일반 사용자가 해당 함수를 호출해서 자신이 컨트랙트의 소유자가 되고, `withdraw` 함수 호출을 통해 컨트랙트의 잔액을 자신의 계좌로 송금할 수 있습니다.

**예방 기법**

- 솔리디티 컴파일러 v0.4.22 이후부터는 컨트랙트 이름과 일치하는 함수 이름 대신에 생성자를 지정하는 `constructor` 키워드 도입