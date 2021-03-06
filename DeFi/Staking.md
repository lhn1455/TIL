# Staking

1. *스테이킹의 개념*
2. *스테이킹을 하는 이유*
3. *스테이킹 리워드를 보장하는 원리*
4. *스테이킹의 이자율 변화*
5. *스테이킹 하는 방법*

## 스테이킹의 개념

스테이킹이란 Proof of Stake(지분증명) 블록체인에서 코인 혹은 토큰을 예치하고, 이자로 토큰을 받아 안정적인 수익을 올리는 방법

> Proof of Stake (지분증명)
> - 지분을 바탕으로 블록을 검증하고 검증인들의 네트워크를 통해 블록을 > 생성하는 방식
> - 검증인은 토큰 보유량에 따른 지분이 클수록 블록을 생성 및 검증할 확률이 높아지고 더 많은 보상을 받을 수 있음.
> - 검증인은 PoS 네트워크를 운영하고 유지하기 위해서 지분이 필요하고, 토큰 보유자는 자신의 지분을 검증인을 통해 네트워크에 예치, 즉 스테이킹 하여 보상을 받음


![staking](/DeFi/img/staking.png)

## 스테이킹을 하는 이유?

- 네트워크 보안성 향상
- 안정적인 블록 생성에 기여
- 기여에 대한 보상 (스테이킹 리워드)

PoS 네트워크를 제어하기 위해서는 지분이 필요. 

각 검증인들이 스테이킹 한 지분에 따라, 블록 생성 권한을 갖고 블록을 검증할 수 있기 때문

Q. 누군가가 51% 이상의 지분을 차지한다면?

→ 블록 생성 및 검증에 대한 과반수의 결정권을 가지게 됨 ⇒ 네트워크 전체를 조작할 수 있음

⇒ 네트워크가 탈취당할 위험이 높아진다는 것을 의미

따라서, 스테이킹 된 토큰 수량이 많을수록 누군가가 51%이상의 지분을 차지하는 것이 어려워지기 때문에 **네트워크 보안성을 향상**시킬 수 있고 **안정적인 블록 생성에 기여**할 수 있음

 스테이킹을 한다는 것 = 네트워크 공격자의 공격 비용을 증가시키기 위해 전체 지분의 양을 늘리는 것 = **네트워크 보안 유지에 기여하는 행위**

하지만, 보상이 존재하지 않으면 네트워크의 보안을 유지하는 데에 기여하려는 사람이 많지 않을 것

그래서 PoS 체인들은 많은 사람을 스테이킹에 참여시키기 위해 **경제적인 보상을 부여**

### 결국, 스테이킹은 PoS 체인의 가장 중요한 요소 중 하나로, 체인은 자신의 네트워크의 블록을 안정적으로 생성하고, 스테이킹을 하는 사람은 보상을 얻는 서로 Win-Win 하는 시스템

## 스테이킹 리워드를 보장하는 원리

- 사전지식
    - 토큰 인플레이션
        새롭게 생성되는 토큰 및 토큰의 증가분을 표현하는 용어 / 토큰의 가격과는 관계 없음    
        + 해당 ‘인플레이션'은 경제학에서의 물가 상승을 의미하는 것과는 다른 개념

        
    - 반감기 
        하나의 블록당 지급하는 리워드 토큰 개수가 줄어드는 시기
        이는 몇 년 주기로 설정되어 있으며, 총 토큰의 발행량을 일정 수량에 수렴하게 만들기 위함
        
    

토큰 인플레이션 공식에 따라 고정된 양의 새로운 토큰이 계속 발행됨. 

스테이킹 리워드는 블록체인을 생성하는 서버인 ‘노드'들이 블록을 생성하는 대가로 주어지는 ‘Block Reward(블록 리워드)’를 나눠 가지는 것

블록의 리워드는 토큰의 인플레이션을 통해 보장

→ 각각의 프로토콜은 각기 다른 토큰 경제학을 기반으로 하나의 블록당 지급하는 리워드 토큰의 개수를 정해놓고 있음. 1년 동안 생성되는 블록의 개수는 프로토콜이 정한 블록 타임을 기반으로 계산할 수 있음. 이에 따라 매해 인플레이션 되는 토큰의 양은 고정되어 있음

![staking](/DeFi/img/staking1.png)

```
( 1년 동안 새롭게 생성되는 토큰(=블록 리워드))
 = 1년 동안 생성되는 블록의 개수 * 생성되는 하나의 블록당 지급하는 리워드 토큰의 개수
 ```

위의 공식에 따라 도출되는 고정된 양의 토큰이 매년 새롭게 발행되기 때문에 스테이킹 유저들 또한 스테이킹에 대한 리워드를 보장받을 수 있음.

참고로, 스테이킹 리워드는 전체 스테이킹된 토큰에서 해당 유저가 스테이킹한 토큰량이 차지하는 비율에 따라 나누어짐

## 스테이킹의 이자율 변화

스테이킹 이자율 변화에 영향을 주는 요인

- 스테이킹 된 토큰의 비율
- 반감기

![staking](/DeFi/img/staking2.png)

## 스테이킹 된 토큰의 비율

고정된 양의 토큰이 발행되기 때문에, 스테이킹을 한 유저들이 늘어날 수록 1명에게 지급되는 보상이 줄어들 것.

→ 따라서, 스테이킹의 이자율은 결국 유통되는 자금의 몇 %가 스테이킹에 참여하고 있느냐에 따라 달라짐.

100%가 스테이킹되었을 때를 가정하여 최저 이율을 알 수 있음
<br>
<br>
<br>

## 반감기

반감기는 총 토큰의 발행량을 일정 수량에 수렴하게 만듦.

그런데, 총 토큰의 발행량이 일정 수량에 수렴하게 된다는 것 = 매년 생기는 블록 리워드, 즉, 새롭게 발행되는 토큰의 개수가 0개가 된다는것

*Q. 이렇게 되면 스테이킹 한 유저들은 어떠한 보상도 못받게 되는 것인가?*

→ 사실 스테이킹 리워드는 **블록 리워드로 새롭게 생성되는 토큰 + 생성된 블록을 사용하는 사용료**로 구성

따라서, 스테이킹 유저는 결국 블록 생성에 기여하는 것이기 때문에, 그에 대한 보상은 받음.(이자율은 변할 수 있지만, 보상을 위해 새로 발행된 토큰을 통해서든, 내가 만든 블록에 대한 사용료든 무조건 보장받을 수 있음)


💡 **스테이킹에서 말하는 이자율은 토큰의 현금 환산 가치에 대한 이자율이 아님!**   
이는 **토큰 개수에 따른 이자율**로 스테이킹을 통해 토큰의 개수가 늘어나도 토큰 1개에 대한 가격이 변동될 수 있으므로 항상 손실의 위험이 있다는 것을 알아두어야 함. 하지만, 스테이킹을 한 사람에게 인플레이션에 따라 새로 생성된 토큰이 배분되는 것이라면 그냥 보유하는 것에 비해 상대적으로 이익일 것
<br>
<br>

## 스테이킹 하는 방법

![staking](/DeFi/img/staking3.png)

벨리데이터에 내가 보유한 토큰에 대한 지분을 Delegation(위임) 하여 스테이킹 진행

- 노드 : 블록체인을 생성하는 서버
- 검증인(Validator Node, 벨리데이터) : 일반 유저들이 위임한 지분을 가지고 블록을 생성하여 네트워크 보안성을 유지하는 사람

일반적인 유저들은 검증인을 통해서  스테이킹을 진행할 수 있음

노드는 모든 사람이 실행시킬 수 있지만, 토큰 보유 지분을 기반으로 특정 순위에 든 벨리데이터 노드만이 블록을 생성할 수 있음. 따라서, 스테이킹 리워드는 블록을 생성한 데에 대한 리워드를 받는 것이기 때문에, 일반 유저들은 블록 생성 권한이 있는 벨리데이터 노드를 통해 스테이킹을 진행함.

스테이킹 리워드는 블록리워드에서 나오기 때문에 벨리데이터가 블록을 제대로 생성하지 못하면 이를 보장받지 못함. 또한, PoS 체인별로 모든 벨리데이터가 악의적인 행동을 하지 않고 성실하게 블록을 생성하도록, 벨리데이터가 제대로 블록을 생성하지 않으면 벨리데이터 보유 지분 일부를 삭감하는 시스템도 존재. 이 경우에도 온전한 리워드를 받지 못함. 따라서 **나의 리워드를 제대로 보장하고, 안정적으로 블록을 생성**하는 **좋은 벨리데이터**를 찾아야 함.
<br>
<br>

### 좋은 벨리데이터를 찾기 위한 확인 항목

1. *노드 업타임*

2. *Contribution 및 Community 활동*
<br>
<br>

- 노드 업타임 : 벨리데이터가 만들 수 있는 블록 중 생성에 성공한 블록의 비율
    
    → 노드 업타임이 큰 벨리데이터일수록 안정적으로 블록을 생성
    
- Contribution 및 Community 활동 : 깃허브, 트위터, 디스코드와 같은 다양한 커뮤니티 및 SNS 채널들을 통해, 벨리데이터가 해당 생태계에서 벌어지는 논의에 얼마나 활발하게 참여하고 기여하였는가를 확인
    
    → 이러한 기여를 바탕으로 신뢰를 쌓은 벨리데이터를 찾을 수 있음

<br>
<br>
<br>

출처 : https://dsrv-korea.medium.com/%EB%98%91%EB%98%91%ED%95%9C-%EC%95%94%ED%98%B8%ED%99%94%ED%8F%90-%ED%88%AC%EC%9E%90-%EC%B2%AB%EA%B1%B8%EC%9D%8C-%EC%8A%A4%ED%85%8C%EC%9D%B4%ED%82%B9-staking-c6413fab20f9