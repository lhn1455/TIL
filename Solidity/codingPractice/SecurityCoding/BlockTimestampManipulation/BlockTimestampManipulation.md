# 블록 타임스탬프 조작 (Block Timestamp Manipulation)

- 채굴자는 블록의 타임스탬프를 조정할 수 있는데, 이로 인해서 스마트 컨트랙트에서 블록 타임스탬프를 잘못 사용하면 문제가 발생할 수 있습니다.
- 예를 들어, 랜덤한 숫자를 위한 `entropy`, 시간을 이용해 펀딩을 잠그는 `시간-잠금 해결책`, 시간에 의존하여 상태를 변경시키는 코드 구문 등에 악의적으로 영향을 끼칠 수 있습니다.

**보안 취약 컨트랙트**

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Roulette {
    uint public pastBlockTime; // forces one bet per block

    constructor() payable {} // initially fund contract

    // fallback function used to make a bet
    fallback () external payable {
        require(msg.value == 10 ether); // must send 10 ether to play
        require(block.timestamp != pastBlockTime); // only 1 transaction per block
        pastBlockTime = block.timestamp;
        **if(block.timestamp % 15 == 0)** { // winner
            payable(msg.sender).transfer(address(this).balance);
        }
    }
}
```

- 이 컨트랙트는 단순한 복권 컨트랙트 입니다.
- 블록 하나당 하나의 트랙잭션은 10이더를 배팅할 수 있습니다.
- `block.timestamp`의 마지막 2 숫자는 불규칙적으로 분산될 것입니다.
- 따라서 이러한 경우, 이 복권의 우승 확률은 1/15가 됩니다.
- 채굴자는 필요한 경우 `block.timestamp` 와 그 별칭 `now`를 조작할 수 있습니다. (`now`는 0.7버전 이후로 `block.timestamp`만 사용한다.)
- 컨트랙트 이더풀에 충분한 이더가 있고, 블록의 문제를 푼 채굴자가 `block.timestamp`의 모듈러 15의 값이 0이 되는 timestamp를 선택하여 이더를 탈취할 수 있습니다.
- 또한 이 컨트랙트에서 한 사람에게 블록당 하나의 베팅을 강요하는 조건은 `front-running attack`에도 취약합니다.

<aside>
💡 실제로, 블록의 타임스탬프는 단순하게 증가합니다. 따라서 채굴자들은 임의로 블록 타임스탬프를 선택할 수 없습니다. (타임스탬프는 반드시 그 이전의 것보다 값이 커야하므로)
채굴자들은 또한 블록 타임 설정하는 것에 한계가 있습니다. 예를 들어 너무 먼 미래의 시간대를 갖는 블록은 네트워크에 의해 거절될 것이기 때문입니다. (노드는 블록의 타임스탬프가 미래의 것이라면 그 블록을 검증하지 않을 것입니다.)

</aside>

- **참고** 
**front-running attack**
    - 채굴자가 작업 증명 알고리즘을 통해 해시 값을 찾고 해당 트랜잭션이 포함된 블록을 채굴해야만 트랜잭션은 유효한 것으로 간주됩니다.
    - 채굴자는 트랜잭션 풀에서 블록에 포함시킬 트랜잭션을 임의로 선택할 수 있습니다.
    - 이때 공격자는 트랜잭션 풀에서 채굴자들이 푸는 문제에 대한 답, 논스 값을 포함하는 트랜잭션 정보를 얻을 수 있습니다.
    - 논스 값을 찾은 채굴자의 권한을 취소하거나 트랜잭션 상태를 공격자가 변경할 수 있습니다.
    
    <aside>
    💡 위의 경우, block.timestamp의 모듈러 15의 값이 0이 되는 timestamp를 트랜잭션 풀에서 볼 수 있습니다. 이것을 본 공격자가 해당 트랜잭션 보다 가스 가격이 높은 동일한 트랜잭션을 호출하면, 이 가스 값이 높은 트랜잭션이 채굴자에 의해 선택될 가능성이 높으므로 먼저 블록에 포함될 것입니다. 공격자의 해당 트랜잭션이 블록에 포함되면 원래 문제를 풀었던 사람은 상금을 받지 못하고 공격자가 상금을 가져가게 됩니다.
    
    </aside>
    

**예방 기법**

- 블록 타임스탬프를 컨트랙트에서 특정 조건 체크를 위한 요소로 사용하면 안됩니다.
- 하지만, 시간과 관련된 조건이 필요한 경우, 예를 들어 컨트랙트가 해지되는 시간, 만기일 적용과 같은 시간 관련 조건이 있을 경우에는 블록의 타임스탬프를 사용하지 말고 `block.number`와 평균 블록 시간을 사용해서 설정하는 것이 좋습니다.
    - 이더리움은 10초당 하나의 블록이 생성되고 일주일이면 대략 60,480개의 블록이 생성됩니다.
    - 블록 번호는 블록 타임스탬프와는 다르게 채굴자가 쉽게 조작할 수 없기 때문에 블록의 생성 시간과 블록 넘버를 사용하면 안전한 컨트랙트를 작성할 수 있습니다.
    
    [이러한 전략을 사용한 BAT ICO 컨트랙트](https://github.com/lhn1455/TIL/blob/main/Solidity/codingPractice/SecurityCoding/BlockTimestampManipulation/BATICO.sol)