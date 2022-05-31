# 최기화되지 않은 스토리지 포인터 (Uninitialized Storage Pointers)

- EVM은 스토리지(storage)와 메모리(memory)에 변수, 데이터를 저장합니다.
    - **스토리지(storage)** : 블록체인 상에 영구적으로 저장되는 변수
    - **메모리(memory)** : 임시적으로 저장되는 변수. 컨트랙트 함수에 대한 외부 호출들이 일어나는 사이에 지워질 수 있습니다.
- 솔리디티는 보통 상태 변수(함수 외부에 선언되는 변수)는 storage로 초기화하고, 함수 내에 선언되는 변수는 memory로 자동 초기화 합니다.

**취약점**

- 변수를 부적절하게 초기화하면 취약한 컨트랙트를 생성할 수 있습니다.
- 로컬 스토리지 변수를 초기화하지 않으면 컨트랙트의 다른 스토리지 변수값이 포함될 수 있습니다. 이부분이 취약점을 유발하거나 악용될 수 있습니다.

**보안 취약 컨트랙트**

```solidity
// A locked name registrar
contract NameRegistrar {

    bool public unlocked = false;  // registrar locked, no name updates

    struct NameRecord { // map hashes to addresses
        bytes32 name;
        address mappedAddress;
    }

    // records who registered names
    mapping(address => NameRecord) public registeredNameRecord;
    // resolves hashes to addresses
    mapping(bytes32 => address) public resolve;

    function register(bytes32 _name, address _mappedAddress) public {
        // set up the new NameRecord
        NameRecord newRecord;
        newRecord.name = _name;
        newRecord.mappedAddress = _mappedAddress;

        resolve[_name] = _mappedAddress;
        registeredNameRecord[msg.sender] = newRecord;

        require(unlocked); // only allow registrations if contract is unlocked
    }
}
```

- 간단한 이름 등록 기능을 가진 컨트랙트 입니다
- 컨트랙트의 잠금이 해제되면 누구나 이름을 등록하고 해당 이름을 주소에 매핑할 수 있습니다.
- 초기에 등록자는 잠겨있으며 마지막의 `require` 함수는 `register`가 이름 레코드를 추가하지 못하도록 합니다.
- 레지스트리를 잠금 해제할 방법이 없으므로 컨트랙트를 사용할 수 없습니다.
- 그러나 `unlocked` 변수에 관계없이 이름 등록을 허용하는 취약점이 있습니다.
- 상태 변수는 컨트랙트에서 나타나는 대로 **슬롯(slot)**에 순차적으로 저장됩니다.
- 따라서 `slot[0]`에 `unlocked`, `slot[1]`에 `registeredNameRecord`, `slot[2]`에 `resolve` 등이 존재합니다.
- 각 슬롯의 크기는 32바이트 입니다. (매핑에는 복잡성이 추가되는데 지금은 무시)
- `Boolean`인 `unlocked`는 **false**의 **0x000…0**(0x를 제외한 64개의 0) 또는 **true**의 **0x000…1**(63개의 0)처럼 보입니다.
- 여기에는 상당한 스토리지 낭비가 있습니다.
- 또한 기본적으로 솔리디티가 struct 같은 복잡한 데이터 타입을 지역 변수로 초기화할 때 스토리지에 저장한다는 것입니다. 따라서 위 코드의 `newRecord`는 기본적으로 스토리지에 저장됩니다.
- 취약점은 `newRecord`가 초기화되지 않았기 때문에 발생합니다.
- 왜냐하면, `newRecord`는 기본값이 스토리지이고 그것은 스토리지 `slot[0]`에 매핑되기 때문입니다.
- `newRecord.name`을 `_name`으로 설정하고, `newRecord.mappedAddress`를 `_mappedAddress`로 설정합니다.
- 이것은 `slot[0]` 및 `slot[1]`의 저장 위치를 갱신하며, 이는 `unlocked`와 `registeredNameRecord` 관련 저장 슬롯을 모두 수정합니다.
- 이는 `unlocked`는 `register` 함수의 bytes32 `_name` 파라미터에 의해 직접 수정될 수 있음을 의미합니다.
- 따라서 `_name`의 마지막 바이트가 0이 아닌 경우 스토리지 `slot[0]`의 마지막 바이트를 수정하고 `uncloked`를 `true`로 직접 변경합니다.
- 이러한 `_name` 값은 `unlocked`를 `true`로 설정했기 때문에 `require` 호출이 성공하도록 합니다.

**예방 기법**

- 솔리디티 컴파일러는 초기화되지 않은 스토리지 변수에 대한 경고를 보여줍니다.
- 스마트 컨트랙트를 작성할 때 memory 또는 storage 지정자를 명시적으로 사용하는 것이 좋습니다.