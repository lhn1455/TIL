# 서비스 거부(Denial of Service)

- 사용자가 일정 기간 또는 영구적으로 컨트랙트를 실행할 수 없게 만드는 공격입니다.

**취약점**

컨트랙트가 동작하지 않게 할 수 있는 다양한 방법

1. 외부에서 조작된 매핑 또는 배열을 통한 루핑
    
    인위적으로 부풀려질 수 있는 배열을 사용해서 배열 크기를 크게 만들면 `for`루프를 실행하는데 요구되는 가스가 가스 한도를 초과하게 됩니다. 그렇게 되면 함수가 원하는 대로 동작하지 않게 만들 수 있습니다.
    
    **예시 컨트랙트**
    
    ```solidity
    contract DistributeTokens {
        address public owner; // gets set somewhere
        address[] investors; // array of investors
        uint[] investorTokens; // the amount of tokens each investor gets
    
        // ... extra functionality, including transfertoken()
    
        function invest() external payable {
            investors.push(msg.sender);
            investorTokens.push(msg.value * 5); // 5 times the wei sent
            }
    
        function distribute() public {
            require(msg.sender == owner); // only owner
            for(uint i = 0; i < investors.length; i++) {
                // here transferToken(to,amount) transfers "amount" of
                // tokens to the address "to"
                transferToken(investors[i],investorTokens[i]);
            }
        }
    }
    ```
    
    - 이 패턴은 주로 owner가 투자자들에게 토큰을 분배하길 원할때 발생합니다.
    - 위 예시 컨트랙트에서 `distribute`함수와 같은 경우에 발생합니다.
    - 공격자는 수많은 사용자 계정을 만들어서 investors 배열을 크게 만들 수 있습니다.
    - 따라서, `for`루프를 실행하는데 요구되는 가스가 블록의 가스 한도를 뛰어넘기 때문에 `distribute` 함수는 동작하지 않게 됩니다.
    
2. 소유자 운영
    
    컨트랙트의 기능을 사용하기 위해서 소유자의 작업이 필요한 경우, 권한을 가진 사용자가 개인키를 잃게 되면 컨트랙트를 사용할 수 없게 됩니다.
    
    **예시 컨트랙트**
    
    ```solidity
    bool public isFinalized = false;
    address public owner; // gets set somewhere
    
    function finalize() public {
        require(msg.sender == owner);
        isFinalized = true;
    }
    
    // ... extra ICO functionality
    
    // overloaded transfer function
    function transfer(address _to, uint _value) returns (bool) {
        require(isFinalized);
        super.transfer(_to,_value)
    }
    
    ...
    ```
    
    - 이 패턴은 소유자가 컨트랙트의 특정한 권한을 가지고 다음 상태로 진행하기 위해 반드시 소유자의 작업이 필요한 경우 발생할 수 있습니다.
    - 이 경우, 권한을 얻은 사용자가 그들의 개인키를 잃게 되거나 비활성화 상태가 되면, 토큰 컨트랙트를 사용할 수 없게 됩니다.
    - an Initial Coin Offering(ICO) 컨트랙트 예시 : 컨트랙트의 소유자가 토큰의 전송을 위해 `finalize`를 반드시 수행해야 하는 코드입니다.
    - 이러한 경우에 소유자가 개인키를 잃거나 비활성상태라면,  토큰의 전송을 막기 위해 `finalize`를 호출할 수 없게됩니다.
    
3. 외부 호출을 기반으로 한 진행 상태
    
    이더를 보내야 되는 조건을 갖는 경우에, 사용자가 이더의 수신을 허용하지 않는 컨트랙트를 만들 수 있습니다. 이런 컨트랙트는 외부 호출을 실패하게 하거나 차단해서 컨트랙트가 새로운 상태를 달성하지 못하게 만듭니다.
    

**예방 기법**

1. 외부에서 조작된 매핑 또는 배열을 통한 루핑
    
    루프 조건에 외부 사용자가 인위적으로 조작할 수 있는 변수를 사용하지 않아야 합니다.
    
2. 소유자 운영
    1. 첫번째 해결책은 소유자를 다중 컨트랙트로 만들어야 합니다.
        
        → 소유자를 다중 컨트랙트로 만들어 관리자를 여러명으로 둡니다
        
    2. 두번째 해결책은 `시간-잠금 해결책`을 사용합니다. 컨트랙트 기능을 사용하기 위한 조건에 지정된 시간 이후에는 컨트랙트에 대한 요청이 소유자의 작업 없이도 실행되도록 설정합니다.
        
        `require(msg.sender == owner || block.timestamp > unlockTime);`
        
3. 외부 호출을 기반으로 한 진행 상태
    
    `시간-잠금 해결책`을 이경우에도 사용할 수 있습니다. 외부 호출이 필요한 경우에서 실패하거나 호출이 일어나지 않는 경우에 특정 시간 이후 자동으로 상태를 진행시킬 수 있도록 컨트랙트를 작성하는 방법이 있습니다.