# 디폴트 가시성 (Default Visibilities)

*솔리디티 업데이트 전 함수 접근자가 명시되지 않으면 dafault로 pulic으로 설정되었습니다. 하지만 업데이트 이후 0.5.0~최신 버전 모두 함수 접근자가 없으면 컴파일 에러가 발생합니다. 따라서 이번 챕터는 가볍게 읽으면서 더 전략적으로 가시성 설정하는 것에 초점을 맞추는 것이 좋을것 같습니다.*

- 함수에 접근자를 명시하여 중요 함수는 특정 조건에 호출될 수 있도록 해야합니다.
- 가시성이란 함수에 적용되는 상속 또는 외부 호출 가능여부를 나타내는 지시어 입니다.
- 함수에서는 가시성을 생략할 수 없고, 상태변수에서 생략하는 경우는 internal이 default입니다.
- 상태변수를 public으로 선언하면 자동으로 동일한 이름의 getter함수가 생성됩니다.
- 함수의 가시성

| 가시성 | 외부호출 | 내부호출 | 상속 | 상태 변수 | 함수 |
| --- | --- | --- | --- | --- | --- |
| external | O | X | O | X | O |
| public | O | O | O | O | O |
| internal | X | O | O | O | O |
| private | X | O | X | O | O |

<aside>
💡 **주의할 점**
상태 변수가 private 또는 internal 이라고 해서 이더리움에 저장된 데이터를 외부에서 볼 수 없다는 것을 의미하는 것은 아닙니다. 상태 변수의 가시성은 단지 위에서 설명한 호출과 상속에서만 관련되는 것이고 컨트랙트에 저장된 데이터는 스토리지 슬롯에 직접 접근하여 얼마든지 그 값을 볼 수 있으므로 중요한 데이터를 저장하지 않는 것이 바람직합니다.

</aside>

- **참고 : 함수의 형식, 함수의 상태 변경 여부**
    - 함수의 형식
    
    | function | 함수명 | ( 전달인자 ) | Visibility | State mutability | Modifier | returns | ( 리턴 타입 ) |
    | --- | --- | --- | --- | --- | --- | --- | --- |
    |  |  |  | external | pure |  |  |  |
    |  |  |  | public | view |  |  |  |
    |  |  |  | internal | payable |  |  |  |
    |  |  |  | private |  |  |  |  |
    - 함수의 상태 변경 여부 (State mutability)
        - 해당 함수가 상태 변수를 변경하는 함수인지 지정합니다. 생략해도 되지만 컴파일 경고를 받을 수 있습니다.
        - pure나 view 함수에서 읽기나 변경을 시도하는 경우에는 컴파일 오류가 발생합니다.
        - 상태 접근을 제한하는 정도는 payable, view, pure 순서로 강화됩니다.
        - 지정하지 않은 함수는 “nonpayable”이라고 하기도 합니다.
        
        | pure | 상태 변수 읽기와 쓰기 불가 |
        | --- | --- |
        | view | 상태 변수 읽기 |
        | payable | 상태(잔액)을 변경(이더 수신) |
        
        <aside>
        💡 **이더리움에서 상태 변경(트랜잭션)에 해당하는 것들**
        
        ✓  상태 변수 쓰기
        ✓  이벤트 발생하기
        ✓  컨트랙트 생성하기
        ✓  selfdestruct 호출
        ✓  이더송금
        ✓  view나 pure로 지정되지 않은 함수 호출
        ✓  저수준 호출(low-level call)
        ✓  상태 변경 opcode를 사용하는 인라인 어셈블리
        
        </aside>
        

**가시성 관련 보안 취약 컨트랙트**

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract HashForEther {
    function withdrawWinnings() public {
        //winner if the last 8 hex characters of the address are 0
        address from = msg.sender;
        uint160 result = uint160(from);
        uint32 add = uint32(result);
        require(add == 0);
        _sendWinnings();
    }

    **function _sendWinnings() public {
        payable(msg.sender).transfer(address(this).balance);
    }**
}
```

- 이 게임은 주소를 추측해서 맞추면 보상이 주어지는 게임입니다.
- 참여자 주소의 마지막 8자의 16진수 문자가 0이면 _sendWinnings 함수를 호출하여 보상을 받습니다.
- 이 코드에서 _sendWinnings함수의 접근 권한이 public이므로 누구라도 호출하여 보상금을 탈취할 수 있습니다.

**실제 공격 사례 컨트랙트**

```solidity
contract WalletLibrary is WalletEvents {

  ...

  // METHODS

  ...

  // constructor is given number of sigs required to do protected
  // "onlymanyowners" transactions as well as the selection of addresses
  // capable of confirming them
  function initMultiowned(address[] _owners, uint _required) {
    m_numOwners = _owners.length + 1;
    m_owners[1] = uint(msg.sender);
    m_ownerIndex[uint(msg.sender)] = 1;
    for (uint i = 0; i < _owners.length; ++i)
    {
      m_owners[2 + i] = uint(_owners[i]);
      m_ownerIndex[uint(_owners[i])] = 2 + i;
    }
    m_required = _required;
  }

  ...

  // constructor - just pass on the owner array to multiowned and
  // the limit to daylimit
  **function initWallet(address[] _owners, uint _required, uint _daylimit) {
    initDaylimit(_daylimit);
    initMultiowned(_owners, _required);
  }**
}
```

- initMultiowned, initWaalet 함수 둘다 접근자가 명시되지 않아 public으로 누구나 호출 가능하여 공격자가 지갑에 소유권을 재설정하여 ether를 탈취할 수 있습니다.