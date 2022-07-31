# 블록체인 기반의 스마트 컨트랙트 정적 / 동적 설계 기법 (2)
## A Static and Dynamic Design Technique of Smart Contract based on Block Chain

### 스마트 컨트랙트의 정적 설계 기법

![fig3](/Solidity/Design/img/fig3.png)

- 스마트 컨트랙트를 구성하기 위한 메타모델은 위의 그림과 같다.
- 스마트 컨트랙트의 기능을 제공하기 위한 `Contract`와 구성 요소인 `Attribute`와 `Function`으로 구성된다.
- `Contact`는 거래 내역을 제공하는 `Transaction`과 함께 `Block` 내에 포함된다.
- `Block`들 간에는 작업 증명(Proof of Work) 관계가 형성되며 블록체인 내의 계정인 `Account`에 의해 참조된다.
- `Account`들 간에는 네트워크를 구성하여 블록을 형성한다.
- 일반적으로 블록을 형성하기 위해 계정 간에 암호 화폐를 송금하여 블록을 형성한다.
- `Account`,`Block`,`Transaction`은 블록체인 내에 포함되어 있으므로 본 연구에서는 `Contract`에 집중하여   
설계 기법을 제안한다.
- 동적 설계 시 `Account`, `Block`은 배포 및 동기화를 설계하기 위해 포함하여 설계한다.
