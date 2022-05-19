# 엔트로피 환상 (Entropy Illusion)(Bad Randomness)

- Ethereum Blockchain의 모든 트랜잭션은 결정된 상태로 블록에 저장됩니다.
- 이것은 Ethereum 생태계에 불확실성이 없다는 것입니다.**(랜덤함수 없음)**
- 대안으로 RANDAO 방법이 제안되었습니다.

- Randomness
    - 블록체인에서 난수(Random number)가 왜 어려운 문제일까?
        - 아이러니하게도, 컴퓨터가 난수를 생성하려면 난수가 필요합니다. 현재 컴퓨터에서 난수를 생성하는 방법은 시간을 종자(seed)로 삼아서 난수를 생성합니다.
        - 이더리움의 경우, 오라클을 통해 외부(오프체인)에서 난수를 블록체인(온체인)으로 가져오는 방법과 블록해시 값을 사용하는 방법들을 사용해 왔습니다.
        - 이런 방법들에는 문제점이 있습니다.
            1. 블록체인에 데이터를 기입하는 주체에 의한 신뢰의 문제가 있다.
            2. 미래의 블록해시를 채굴자가 먼저 볼 가능성이 있어 유저들 보다 이점을 가지게 된다.
        - 이와 같은 방법의 난수를 Dapp에서 사용하게 되면 형평성에 큰 문제가 생길 수 있습니다.


- RANDAO
    - 다수의 참여자가 제출한 난수를 기반으로 검증가능한 난수를 생성하는 [RANDAO](https://github.com/randao/randao)가 제시되었습니다.
    - RANDAO 난수 생성에는 두 단계(Phase1, Phase2)로 진행됩니다.
        - Phase1 : 난수 생성 참가자들은 임의의 난수 s를 sha3(s)를 RANDAO 컨트랙트에 m ETH와 함께 제출합니다.
        - Phase2 : Phase1에서 시간 경과 이후 (6블록 이후), 난수 생성 참가자들은 실제 난수 s를 제출하는 reveal 과정을 수행해야 하며, 그렇지 않으면 m ETH를 몰수 당합니다.
        - 두 과정을 모두 마치면 난수 생성 참가자는 m ETH와 수수료(참가자 보너스)를 받습니다.
    - 최종적인 난수는 참가자들이 제출한 난수들을 XOR 연한한 값을 사용하게 되며, 이는 최소한 한명의 정직한 참가자가 있으면 난수의 보안성이 지켜질 것입니다.
    
    ![Generate random Number via RANDAO](/Solidity/codingPractice/SecurityCoding/EntropyIllusion(BadRandomness)/img/1.png)
    
    Generate random Number via RANDAO
    
    - 위의 과정을 보면 난수 생성 참여자의 동기부여와 공정성이 매우 잘 고려된 로직이라고 볼 수 있겠습니다. 하지만, Last Revealer 문제가 발생하게 됩니다.
    - 위 슬라이드에 마지막 slot의 참가자처럼 이전 난수를 모두 미리 계산해보고 자신이 제출한 난수를 공개할지 여부를 판단할 수 있게 됩니다.
    - 블록해시로 난수를 생성할 때 채굴자가 이점을 가지는 형평성 문제처럼, RANDAO에서도 Last Revealer와 유저간 불공평한 상황이 발생할 수 있습니다.

**취약점**

- Ethereum 플랫폼에 도박 관련(즉석 복권) 기능을 구현하려 했으나 불확실성을 구현할 수 없어 구축이 다소 어렵습니다
- 일반적으로 Hash, Timestamp, Gas limit, Block numbers를 이용하면 될 것 같지만 이는 채굴자들에 의해 통제될 수 있어 랜덤값은 아닙니다.
- 예를 들어, Block numbers가 해시값이 짝수로 끝나는 경우 보상을 주는 롤렛 스마트 컨트랙트를 고려해 보면, 채굴자는 짝수로 끝나는 해시값을 발견할 때까지 연산 후 블록을 게시할 수 있습니다.

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract GameRandom {

    function play() public payable {
        require(msg.value >= 1 ether);
        uint num = uint(blockhash(block.number));
        bool won = (num % 2) == 0;
        if (won) {
            payable(msg.sender).transfer(2 ether);
        }

    }
}
```

**예방 기법**

- 랜덤값은 원천적으로 블록체인 외부에 있어야 합니다.
- commit-reveal, RandDAO(=RANDAO) 방법을 참조하여 구현할 수 있습니다.
- 블록에 변수는 채굴자에 의해 조작될 수 있으므로 사용하면 안됩니다.

**실제 사례**

- 2018년 2월 Arseny Reutov는 PRNG(랜덤 생성기)를 사용하는 3,649건의 실시간 스마트 컨트랙트 분석을 블로그에 올렸습니다.
- 그는 탈취 될 수 있는 43건의 스마트 컨트랙트를 발견했습니다.