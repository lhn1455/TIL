# 예기치 않은 이더 (Unexpected Ether)

일반적으로 스마트 컨트랙트는 어떤 오류나 불이행 계약에 대해 예외처리 또는 복구할 수 있도록 **fallback 함수**를 호출할 수 있어야 합니다.

- fallback함수
    - 특징
        1. 무기명 함수, 이름이 없는 함수
        2. external 필수
        3. payable 필수
        4. bytes 타입의 데이터를 전달받고 리턴값을 가질 수 있음
        5. 함수 내에서 사용할 수 있는 가스는 **2300 가스로 제한**이 있음
    - 쓰는 이유?
        1. 스마트 컨트랙트가 이더를 받을 수 있도록 함
        2. 이더를 받고 난 후 어떤 행동을 취하게 할 수 있음
        3. 컨트랙트에 작성되어 있지 않은 함수가 호출된 경우, 말 그대로 “fallback”으로 실행되는 함수
    - 버전 트레킹
        - 0.6.0 이전 버전의 fallback
        
        ```solidity
        function() external payable {
        
        }
        ```
        
        - 0.6.0 이후 버전의 fallback
            - fallback은 receive와 fallback으로 나뉘어 짐
                - receive : 순수하게 이더만 받을 때 작동
                
                <aside>
                💡 **receive 함수**
                이더리움의 계정들은 서로 이더를 주고받을 수 있습니다. address 타입을 payable로 지정하고 transfer()라는 기본 메소드를 사용하여 이더를 송금할 수 있습니다. 반면에 컨트랙트가 임의의 계정으로부터 이더를 받기 위해서는 특별한 함수 receive()가 필요합니다.
                
                컨트랙트에 receive()라는 함수가 작성되어 있으면 그 컨트랙트에 이더를 송금할 수 있습니다. receive()는 앞에 function이라는 키워드 없이 정의 됩니다.
                
                receive()는 일반적인 함수가 아니기 때문에 몇가지 규칙이 있습니다.
                - **external payable**로 선언해야 합니다.
                - **전달인자**와 **리턴값**을 가질 수 없습니다.
                - **데이터(msg.data)**를 받을 수 없습니다.
                - 함수 내에서 사용할 수 있는 가스는 **2300 가스로 제한**됩니다.
                
                **receive()는 EOA가 송금하거나 컨트랙트에서 transfer() 또는 send()를 사용하여 이더를 보낼 때 실행됩니다. 다만 이스탄불 하드포크에서 제기된 문제점, 즉 opcode의 가스 소비량은 언제든 조정될 수 있으므로 가스 제한을 하는 transfer()와 send()의 사용을 자제하는 것이 좋습니다.**
                
                </aside>
                
                - fallback : 함수를 실행하면서 이더를 보낼때, 불려진 함수가 없을 때 작동
                - 기본형 : 불려진 함수가 특정 스마트 컨트랙트에 없을 때, fallback 함수가 발동
                
                ```solidity
                fallback() external {
                
                }
                
                ```
                
                - payable 적용시 : 이더를 받고 나서도 fallback함수가 발동
                
                ```solidity
                fallback() external payable {
                
                }
                
                receive() external payable {
                
                }
                ```
                

### 1. **Self-destruct/suicide** : 스마트 컨트랙트를 실행불능의 상태로 만드는 함수

블록체인에서 코드가 지워지는 유일한 방법은 주소의 컨트랙트가 **selfdestruct 연산**을 사용했을 때 입니다. 주소에 저장된 남은 ether는 지정된 타겟으로 옮겨지고 스토리지와 코드는 해당 상태에서 지워집니다. 이론적으로 컨트랙트를 제거하는 것이 좋은 아이디어 인것처럼 들리겠지만, 잠재적으로 위험한 행위입니다. 만일 누군가가 제거된 컨트랙트에 ether를 전송하면, 해당 ether는 영구적으로 손실 됩니다.

<aside>
💡 컨트랙트 코드가 **selfdestruct**를 포함하지 않더라도, **delegatecall**이나 **callcode**를 실행해 그 작업을 수행할 수 있습니다. (0.5.0 버전 이후로 callcode는 삭제됨)

컨트랙트를 비활성화하려면, 내부상태를 바꿈으로써 disable해야 합니다. 이때, 내부 상태는 모든 함수를 되돌리는 원인이 됩니다. 이로인해 ether가 즉시 반환되므로 컨트랙트를 사용할 수 없게 됩니다.

**delegatecall** 
- 컨트랙트 A를 통해 컨트랙트 B 호출시, B의 storage를 변경기시키 않고, B의 코드를 A에서 실행. msg.sender와 msg.value가 값이 바뀌지 않는다는 것 외에는 메시지 콜과 동일
- 이것은 컨트랙트가 실행 중 다양한 주소의 코드를 동적으로 불러온다는 것을 뜻함. 스토리지, 현재 주소와 잔액은 여전히 호출하는 컨트랙트를 참조하지만 코드는 호출된 주소에서 가져옴
- 이것은 solidity에서 복잡한 데이터 구조 구현이 가능한 컨트랙트의 스토리지에 적용 가능한 재사용 가능한 코드, 라이브러리 구현을 가능하도록 함

</aside>

<aside>
💡 “**selfdestruct**”에 의해 컨트랙트가 제거되었더라도, 블록체인의 히스토리에 남아있게 됩니다. 그리고 대부분의 이더리움 노드들이 이를 보유하게 될 것입니다. 그래서 **selfdestruct**를 사용하는 것은 데이터를 하드디스크에서 삭제하는 것과는 다릅니다.

</aside>

- **Self-destruct/suicide** : 스마트 컨트랙트를 실행불능의 상태로 만드는 함수
    - 모든 컨트랙트는 **selfdestruct**함수를 구현할 수 있습니다.
    - 공격자가 악성 계약을 맺고 **selfdestruct**함수를 호출하여 강제로 ether를 해킹할 수 있습니다.
    - 원래 **selfdestruct** 함수의 이름은 **suicide**였지만 **selfdesruct**로 이름을 바꾸었고, 기능은 이전과 동일합니다.
    - 왜 **selfdestruct**함수가 필요할까?
        
        > *“The DAO attack continued for several days and the organization even noticed that their contract had been attacked at that time. However, they could not stop the attack or transfer the Ethers because of the immutability feature of smart contracts. If the contract contains a selfdestruct function, the DAO organization can transfer all the Ethers easily, and reduce the financial loss.”*
        > 
        - DAO에 대한 공격이 계속되어지고 심지어 기관에서 이러한 공격 시도를 알고있음에도 불구하고 그들은 스마트컨트랙트의 불변성이라는 특징 때문에 공격을 멈추거나 이더를 옮길 수 없었다. 만약 컨트랙트가 selfdesruct 함수를 포함하고 있었다면 DAO는 모든 이더를 손쉽게 옮기고, 재정적 손실을 줄일 수 있었을 것이다.
        
        ```solidity
        // SPDX-License-Identifier: GPL-3.0
        pragma solidity >=0.7.0 <0.9.0;
        contract Storage {
         address payable private owner;
         uint256 number;
         
         constructor() {
          owner = payable(msg.sender);
         }
         function store(uint256 num) public {
          number = num;
         }
         function retrieve() public view returns (uint256){
          return number;
         }
         
         **function close() public { 
          selfdestruct(owner);** 
         }
        ```
        
        1. 컨트랙트를 배포하고 store함수를 이용해 100이라는 값을 넣어준 후, retrive를 통해 값이 제대로 들어갔는지 확인
            
            **결과 : 100**
            
            ![Untitled](/Solidity/codingPractice/SecurityCoding/UnexpectedEther/img/1.png)
            
        
        2. close함수에 selfdestruct함수가 들어있으므로, close함수를 눌러 컨트랙트를 중단
            
            ![Untitled](/Solidity/codingPractice/SecurityCoding/UnexpectedEther/img/2.png)
            
        
        3. 중단 된 컨트랙트의 함수가 더이상 작동하지 않는지 retrieve함수를 호출하여 확인
            
            **결과 : 0으로 바뀜**
            
            ![Untitled](/Solidity/codingPractice/SecurityCoding/UnexpectedEther/img/3.png)
            
        4. store함수를 통해 70이라는 값을 넣어준 후, retrieve를 통해 컨트랙트가 정말 중단된 것이 맞는지 확인
            
            **결과 : 0에서 바뀌지 않음. ⇒ 컨트랙트 중단**
            
            ![Untitled](/Solidity/codingPractice/SecurityCoding/UnexpectedEther/img/4.png)
            
    

### 2. Pre-sent ether(미리 보낸 ether)

- 공격자는 수 많은 개인 지갑을 만들 수 있습니다.
- 취약한 어떤 스마트 컨트랙트가 계약만 체결하면 보상으로 약간의 ether를 제공한다고 할때, 공격자는 수 많은 개인 지갑을 만들어 ether를 탈취할 수 있습니다.

**변할 수 있는 this.balance값을 활용한 취약한 컨트랙트**

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract EtherGame {
    uint public payoutMileStone1 = 3 ether;
    uint public mileStone1Reward = 2 ether;
    uint public payoutMileStone2 = 5 ether;
    uint public mileStone2Reward = 3 ether;
    uint public finalMileStone = 10 ether;
    uint public finalReward = 5 ether;

    mapping(address => uint) redeemableEther;

    function play() public payable {
        require(msg.value == 0.5 ether);
        uint currentBalance = address(this).balance + msg.value;

        require(currentBalance <= finalMileStone);

        if(currentBalance == payoutMileStone1) {
            redeemableEther[msg.sender] += mileStone1Reward;
        }
        else if (currentBalance == payoutMileStone2) {
            redeemableEther[msg.sender] += mileStone2Reward;
        }
        else if (currentBalance == finalMileStone) {
            redeemableEther[msg.sender] += finalMileStone;
        }
        return;
    }

    function claimReward() public {
        require(address(this).balance == finalMileStone);

        require(redeemableEther[msg.sender] > 0);
        uint transferValue = redeemableEther[msg.sender];
        redeemableEther[msg.sender] = 0;
        payable(msg.sender).transfer(transferValue);
    }
}
```

- 게임 참여자가 0.5 이더를 보내고 그 합니 2,3,4,10 이더가 되었을 때 보상을 받을 수 있는 게임 컨트랙트 입니다.
- 공격자가 0.1 이더를 보낼 경우 this.balance는 0.1 이더가 합산되어 2,3,4,10 정수 값이 되지 못합니다.
- 이로 인해 이 후 게임 참여자는 아무도 보상을 받을 수 없습니다.
- 또는 보상 이정표를 놓친 공격자가 10 이더를 보내 게임을 더이상 진행하지 못하게 할 수도 있습니다.

**예방기법**

- 이 컨트랙트의 취약점은 this.balance의 오용으로 발생합니다.
- 컨트랙트 로직은 인위적으로 조작할 수 있기 때문에 this.balance 잔액에 의존하지 않아야 합니다.
- this.balance를 이용할 경우 예상치 못한 잔액을 고려해야 합니다.
- 합산된 ether의 정확한 값이 필요할 경우 합산을 위한 변수를 사용하고 안전하게 추적해야 합니다.
- 이 합산 변수는 selfdestruct 호출에 영향을 받지 않습니다.

**취약점을 보안한 컨트랙트**

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract EtherGameUpgrade {
    uint public payoutMileStone1 = 3 ether;
    uint public mileStone1Reward = 2 ether;
    uint public payoutMileStone2 = 5 ether;
    uint public mileStone2Reward = 3 ether;
    uint public finalMileStone = 10 ether;
    uint public finalReward = 5 ether;
    uint public depositedWei;

    mapping(address => uint) redeemableEther;

    function play() public payable {
        require(msg.value == 0.5 ether);
        **uint currentBalance = depositedWei + msg.value;**

        require(currentBalance <= finalMileStone);

        if(currentBalance == payoutMileStone1) {
            redeemableEther[msg.sender] += mileStone1Reward;
        }
        else if (currentBalance == payoutMileStone2) {
            redeemableEther[msg.sender] += mileStone2Reward;
        }
        else if (currentBalance == finalMileStone) {
            redeemableEther[msg.sender] += finalMileStone;
        }
        **depositedWei += msg.value;**
        return;
    }

    function claimReward() public {
        **require(depositedWei == finalMileStone);**

        require(redeemableEther[msg.sender] > 0);
        uint transferValue = redeemableEther[msg.sender];
        redeemableEther[msg.sender] = 0;
        payable(msg.sender).transfer(transferValue);
    }
}
```

- ether 합산을 위해 **depositedWei** 변수를 이용합니다.
- **this.balance**를 더이상 사용하지 않습니다.