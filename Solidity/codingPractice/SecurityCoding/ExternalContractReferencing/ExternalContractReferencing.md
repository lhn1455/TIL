# 외부 컨트랙트 참고 (External Contract Referencing)

- Ethereum 생태계의 이점 중 하나는 코드를 재사용하고 공개된 컨트랙트와 상호작용하는 능력입니다.
- 결과적으로 많은 스마트 컨트랙트는 다른 사람이 만든 스마트 컨트랙트를 호출하게 됩니다.
- 이렇게 다른 사람이 만든 스마트 컨트랙트 호출은 악의적인 목적의 스마트 컨트랙트를 호출할 수 있습니다.

취약점

- solidity에서 어떤 유형의 지갑(주소, 컨트랙트)이든 스마트 컨트랙트를 호출할 수 있습니다.
- 특히 계약자가 악성코드를 숨겨 문제를 발생시킬 수 있습니다.

**외부컨트랙트**

```solidity
// encryption contract
contract Rot13Encryption {

   event Result(string convertedString);

    // rot13-encrypt a string
    function rot13Encrypt (string text) public {
        uint256 length = bytes(text).length;
        for (var i = 0; i < length; i++) {
            byte char = bytes(text)[i];
            // inline assembly to modify the string
            assembly {
                // get the first byte
                char := byte(0,char)
                // if the character is in [n,z], i.e. wrapping
                if and(gt(char,0x6D), lt(char,0x7B))
                // subtract from the ASCII number 'a',
                // the difference between character <char> and 'z'
                { char:= sub(0x60, sub(0x7A,char)) }
                if iszero(eq(char, 0x20)) // ignore spaces
                // add 13 to char
                {mstore8(add(add(text,0x20), mul(i,1)), add(char,13))}
            }
        }
        emit Result(text);
    }

    // rot13-decrypt a string
    function rot13Decrypt (string text) public {
        uint256 length = bytes(text).length;
        for (var i = 0; i < length; i++) {
            byte char = bytes(text)[i];
            assembly {
                char := byte(0,char)
                if and(gt(char,0x60), lt(char,0x6E))
                { char:= add(0x7B, sub(char,0x61)) }
                if iszero(eq(char, 0x20))
                {mstore8(add(add(text,0x20), mul(i,1)), sub(char,13))}
            }
        }
        emit Result(text);
    }
}
```

- 이 컨트랙트는 a-z문자를 받아 x만큼 옮겨 k로 전환하는 암호화 코드입니다.(a-z 문자 검증 없이)

**외부 컨트랙트를 가져다 쓰는 컨트랙트**

```solidity
import "Rot13Encryption.sol";

// encrypt your top-secret info
contract EncryptionContract {
    // library for encryption
    **Rot13Encryption encryptionLibrary**;

    // constructor - initialize the library
    **constructor(Rot13Encryption _encryptionLibrary) {
        encryptionLibrary = _encryptionLibrary;**
    }

    function encryptPrivateData(string privateInfo) {
        // potentially do some operations here
        encryptionLibrary.rot13Encrypt(privateInfo);
     }
 
```

- 이 컨트랙트에서 문제는 **encryptionLibrary 주소가 공개되지 않고 변경되지 않는다는 것**입니다.
- 이 컨트랙트 제공자는 다른(클라우드) 계약을 줄 수 있습니다. (암호화가 아닌 다른 코드)

```solidity
// encryption contract
contract Rot26Encryption {

   event Result(string convertedString);

    // rot13-encrypt a string
    function rot13Encrypt (string text) public {
        uint256 length = bytes(text).length;
        for (var i = 0; i < length; i++) {
            byte char = bytes(text)[i];
            // inline assembly to modify the string
            assembly {
                // get the first byte
                char := byte(0,char)
                // if the character is in [n,z], i.e. wrapping
                if and(gt(char,0x6D), lt(char,0x7B))
                // subtract from the ASCII number 'a',
                // the difference between character <char> and 'z'
                { char:= sub(0x60, sub(0x7A,char)) }
                // ignore spaces
                if iszero(eq(char, 0x20))
                // add 26 to char!
                {mstore8(add(add(text,0x20), mul(i,1)), add(char,26))}
            }
        }
        emit Result(text);
    }

    // rot13-decrypt a string
    function rot13Decrypt (string text) public {
        uint256 length = bytes(text).length;
        for (var i = 0; i < length; i++) {
            byte char = bytes(text)[i];
            assembly {
                char := byte(0,char)
                if and(gt(char,0x60), lt(char,0x6E))
                { char:= add(0x7B, sub(char,0x61)) }
                if iszero(eq(char, 0x20))
                {mstore8(add(add(text,0x20), mul(i,1)), sub(char,26))}
            }
        }
        emit Result(text);
    }
}
```

- 이 컨트랙트는 문자를 26을 더해 암호화를 구현한 코드입니다.(원래 가져다 쓰려던 암호화 코드가 아님)
- 공격자는 이 코드를 암호화 코드로 속여 연결할 수 있습니다.

```solidity
contract Print{
    event Print(string text);

    function rot13Encrypt(string text) public {
        emit Print(text);
    }
 }
```

- 이 컨트랙트는 단순히 암호화 요청 문자를 인쇄하기만 합니다.

```solidity
contract Blank {
     event Print(string text);
     function () {
         emit Print("Here");
         // put malicious code here and it will run
     }
 }
```

- fallback함수에 악성코드를 넣으면 다른 사용자 모르게 악성코드를 실행할 수 있습니다.

**예방 기법**

- 안전한 컨트랙트도 악의적인 목적으로 이용될 수 있습니다.
- 새로운 키워드를 만들어 컨트랙트를 생성하여 사용합니다.

```solidity
constructor() {
    encryptionLibrary = new Rot13Encryption();
}
```

- 이렇게 하면 참조한 컨트랙트가 배포 시점에 Rot13Encyption를 대체할 수 없습니다.
- 또 다른 해결책은 외부 컨트랙트를 하드코딩하는 것입니다.
- 사용자가 외부 함수를 변경할 수 있는 경우, 변경 유무를 확인할 수 있는 검증 메커니즘 구현이 중요합니다.