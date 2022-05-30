# 생성자 관리 (Constructors with Care)

- **생성자(constructor)**:  컨트랙트를 초기화할 때 종종 중요하고 권한을 필요로 하는 작업을 수행하는 특수 함수
    - **참고** 생성자
        - solidity 언어는 객체지향언어(OOP)이기 때문에, 객체지향 특징 중 하나인 생성자(Constructor)를 가지고 있습니다. 만약, 객체의 초기화 코드가 필요하다면 이 생성자 안에 작성하면 됩니다.
        - solidity 언어는 객체지향이긴하지만 블록체인의 스마트 컨트랙트를 개발하기 위한 용도로 만들어졌기 때문에, 생성자가 가지는 특징 또한 다른 언어들과는 조금 다르니 주의하고 사용해야 합니다.
        - solidity 언어와 다른 객체지향언어와의 차이점은 프로그램 위에 객체를 무한정 만들 수 있는 것이 아닌, 블록체인에 계약서를 단 한번 만들고 이를 사용하는 것이라는 점입니다.
        
        **생성자 특징**
        
        1. **생성자는 계약서가 배포될 때 호출됩니다.**
            
            생성자는 계약서가 배포되는 때에 호출됩니다. 생성자가 실행 된 후에 만들어진 계약서의 최종 코드가 블록체인에 배포되는데, 이 최종 코드에는 생성자 코드는 포함되지 않고, public과 external 함수들이 포함됩니다.
            
            ```solidity
            contract Coin {
            	address public minter;
            
            	constructor() public {
            		minter = msg.sender;
            	}
            }
            ```
            
        2. **생성자가 필수는 아니지만, 사용한다면 단 1개의 생성자만 작성해야 합니다.**
        3. **생성자를 직접 작성하지 않으면 기본생성자(default constructor)가 자동으로 생성됩니다.**
        4. **생성자의 가시성(visibility)는 internal이거나 public이어야 합니다.**
        5. **생성자의 가시성을 internal로 하면, 추상(abstract) 계약서라는 것이기 때문에, 단독으로는 사용을 할 수가 없습니다. 다른 계약서에서 상속을 받아서 사용해야 합니다.**
            
            ```solidity
            pragma solidity ^0.4.22;
            contract A {
            	uint public a;
            	constructor(uint _a) internal {
            		a = _a;
            	}
            }
            
            contract B is A(1) {
            	constructor() public {}
            }
            ```
            
            위의 코드를 배포할 때, 컨트랙트 A로 배포하면 계약을 생성할 수 없다는 메시지가 나오지만, 컨트랙트 B로 배초하면 정상 생성됩니다.
            
        6. **생성자를 상속받는 방법은 두가지 입니다.**
            
            첫번째 방법은 상속받을 때 직접 argument를 넣어서 사용하는 방법이고, 두번째 방법은 modifier-style을 이용하는 방법입니다. 내부적으로 기능적인 차이는 없으니 편의에 맞게 사용하면 됩니다.
            
            ```solidity
            pragma solidity ^0.4.22;
            contract Parent {
            	uint x;
            	constructor(uint _x) public {
            		x = _x;
            	}
            	
            	function getData() public returns(uint) {
            	return x;
            	}
            }
            
            //첫번째 방법
            contract Child1 is Parent(7) {
            	constructor(uint _y) public {}
            }
            
            //두번째 방법
            contract Child2 is Parent {
            	constructor(uint _y) Parent(_y * _y) public {}
            }
            ```
            
    
- 솔리디티 v0.4.22 이전 버전에서는 생성자를 `constructor`로 정의하는 것이 아니라 컨트랙트와 이름이 같은 함수로 생성자를 정의했습니다.
- 이러한 경우에 컨트랙트 이름이 변경되면 원래의 생성자는 생성자의 역할을 하지 못하고 일반 함수가 됩니다. 이 점이 취약점이 될 수 있습니다.

**취약점**

- 컨트랙트 이름이 수정되거나 컨트랙트 이름과 일치하지 않는 생성자 이름에 오타가 있는 경우 생성자는 일반함수 처럼 작동합니다.

**보안취약 컨트랙트**

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

**수정 컨트랙트**
```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract OwnerWallet {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
  

    // Fallback. Collect ether.
    fallback() external payable {}

    function withdraw() public {
        require(msg.sender == owner);
        payable(msg.sender).transfer(address(this).balance);
    }
}
```