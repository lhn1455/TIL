# 레이스 컨디션/프런트 러닝(Race Conditions/Front Running)

- 레이스 컨디션(race condition) : 경쟁 조건을 의미하며 사용자들이 코드의 실행을 경쟁한다는 의미
- 재진입성은 레이션 컨디션의 한 종류입니다.

**취약점**

- 이더리움 노드는 트랜잭션 풀에서 트랜잭션을 선택하여 블록을 생성합니다.
- 채굴자가 작업 증명 알고리즘을 통해 해시 값을 찾고 해당 트랜잭션이 포함된 블록을 채굴해야만 트랜잭션은 유효한 것으로 간주됩니다.
- 채굴자는 트랜잭션 풀에서 블록에 포함시킬 트랜잭션을 임의로 선택할 수 있습니다. (수수료 많은 순서 등)
- 이때 공격자는 트랜잭션 풀에서 채굴자들이 푸는 문제에 대한 답, 논스 값을 포함하는 트랜잭션 정보를 얻을 수 있습니다.
- 논스 값을 찾은 채굴자의 권한을 취소하거나 트랜잭션 상태를 공격자가 변경할 수 있습니다.

**보안 취약 컨트랙트**

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FindThisHash {
    bytes32 constant public hash =
      0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;

    constructor()  payable {} // load with ether

    function solve(string memory solution) public {
        // If you can find the pre-image of the hash, receive 1000 ether
        require(hash == keccak256(abi.encodePacked(solution)));
        payable(msg.sender).transfer(1000 ether);
    }
}
```

- 특정 해시값을 도출하는 `solution`을 찾으면 그 값을 찾은 사람은 1000이더를 받을 수 있는 컨트랙트 입니다.
- 만약 위 컨트랙트에서 `solution`값이 Ethereum! 이라면 이 값을 `solve`함수의 파라미터로 전달해서 이더를 받습니다.
- 공격자는 바로 이 `solution`을 트랜잭션 풀에서 볼 수 있습니다.
- `solution`을 본 공격자가 해당 트랜잭션보다 가스 가격이 높은 동일한 트랜잭션을 호출하면, 이 가스 값이 높은 트랜잭션이 채굴자에 의해 선탤될 가능성이 높으므로 먼저 블록에 포함될 것입니다.
- 공격자의 해당 트랜재션이 블록에 포함되면 원래 문제를 풀었던 사람은 이더를 받지 못하고 공격자가 1000이더를 받게됩니다.

**예방 기법**

- 위와 같은 공격을 **프론트 러닝(front-running)**이라고 부르는데, 이 공격을 수행할 수 있는 사람은 (트랜잭션의 gasPrice를 수정하는)**사용자**와 (블록에서 트랜잭션을 재정렬할 수 있는)**채굴자** 입니다.
    1. 첫번째 방법은 가스 가격에 상한을 둬서 `gasPrice`를 높여 트랜잭션 우선순위를 갖는 것을 방지할 수 있습니다. *이 방법은 채굴자의 공격은 막을 수 없습니다.*
    2. 두번째 방법은 **`커밋-공개 방식`**을 사용하는 것입니다. 
        
        트랜잭션을 보낼 때는 정보를 숨긴채 전송하고, 해당 트랜잭션이 블록에 포함되면 데이터를 표시하는 트랜잭션을 다시 전송하는 것입니다. 이 방법은 채굴자와 사용자가 트랜잭션의 내용을 결정할 수 없기 때문에 프론트 러닝 트랜잭션을 방지할 수 있습니다.
        

- **Hashing Function**
    - 블록체인에서 보안은 아주 중요한 문제입니다.
    - 따라서 솔리디티는 keccak256이라는 강력한 해시함수를 내장하고 있습니다.
    - Git의 커밋번호를 생성할 때 쓰는 해시 알고리즘이 SHA-1 인데, keccak256은 SHA-3을 사용합니다.
    - 해시 함수는 기본적으로 **입력 스트링을 랜덤 256비트 16진수로 매핑**합니다. 스트링에 약간의 변화라도 있으면 해시값은 크게 달라집니다.
    - 해시 함수는 이더리움에서 여러 용도로 활용되지만, 보통 의사 난수 발생기로 많이 사용됩니다.
        
        ```solidity
        //6e91ec6b618bb462a4a6ee5aa2cb0e9cf30f7a052bb467b0ba58b8748c00d2e5 
        keccak256("aaaab"); 
        //b1f078126895a1424524de5321b339ab00408010b7cf0e6ed451514981e58aa9 
        keccak256("aaaac");
        ```
        
    - 입력값에 한 글자가 달라졌음에도 불구하고 반환값은 완전히 달라짐을 알 수 있습니다.
- **Keccack256**
    - Keccack256은 솔리디티에서 사용하는 해시 함수 입니다.
    - 다양한 길이의 스트링 또는 숫자 입력값을 고정길이의 32bytes 데이터 타입으로 변환시켜 줍니다.
    - 역으로 디코딩 할 수 없는 강력한 암호화 해시 함수 입니다.
    
    ```solidity
    function hash(string memory _string) public pure returns(bytes32) {
         return keccak256(**abi.encodePacked**(_string));
    }
    ```
    
    - abi.encode
        - abi.encodePacked보다 더 복잡한 인코딩 기술입니다.
        - abi.encode는 해시 함수의 충돌을 막기 위해 사용되는 함수입니다.
        - 충돌 예시
            
            ```solidity
            //입력값
            (AAA, BBB) -> AAABBB         
            (AA, ABBB) -> AAABBB
            ```
            
            ```solidity
            function collisionExample(string memory _string1, string memory _string2)
            public pure returns (bytes32) {
                 return keccak256(**abi.encodePacked**(_string1, _string2));
            }
            ```
            
            1. `_string1 = AAA` `_string2 = BBB`의 결과값
            
            ```solidity
            0xf6568e65381c5fc6a447ddf0dcb848248282b798b2121d9944a87599b7921358
            ```
            
            1. `_string1 = AA` `_string2 = ABBB`의 결과값
            
            ```solidity
            0xf6568e65381c5fc6a447ddf0dcb848248282b798b2121d9944a87599b7921358
            ```
            
            ⇒ 1과 2의 입력값이 모두 `AAABBB`로 인식되기 때문에 같은 결과값이 나옵니다.
            
        - 따라서, abi.encode를 사용하여 충돌을 막을 수 있습니다.
            
            ```solidity
            function collisionExample2(string memory _string1, string memory _string2)
            public pure returns (bytes32) {
                 return keccak256(**abi.encode**(_string1, _string2));
            }
            ```
            
            1. `_string1 = AAA` `_string2 = BBB`의 결과값
            
            ```solidity
            0xd6da8b03238087e6936e7b951b58424ff2783accb08af423b2b9a71cb02bd18b
            ```
            
            1. `_string1 = AA` `_string2 = ABBB`의 결과값
            
            ```solidity
            0x54bc5894818c61a0ab427d51905bc936ae11a8111a8b373e53c8a34720957abb
            ```