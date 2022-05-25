# solidity version 차이점
| 차이점 | 0.5버전 | 0.8버전 | 업데이트 버전 |
| --- | --- | --- | --- |
| 배열의 length권한 | length의 값을 변경하여 스토리지에 저장된 배열의 크기를 변경할 수 있다. | length는 read-only | 0.6 |
| push(value) 반환값 | 새로운 배열의 길이 반환 | 아무것도 반환하지 않음 | 0.6 |
| fallback 함수 | 익명 함수 형태 | fallback과 receive 키워드를 사용해 fallback 함수를 지정할 수 있다. | 0.6 |
| now와 block.timestamp | 글로벌 변수 now가 블록의 생성 시간을 값으로 가진다. | now는 deprecated되고, block.timestamp로 대체되었다. | 0.7 |
| UTF-8 지원 | - | 유니코드 문자열 지원한다. 문자열 앞에 unicode 키워드를 붙여 사용할 수 있다. (ex. uincode”Hello”) | 0.7 |
| 상태 변환성 키워드 | - | pure와 view 키워드로 함수에서 일어나는 스토리지 CRUD 여부를 나타낸다. | 0.7 |
| 누승법 (exponentiation) | 왼쪽에서부터 파싱abc 연산은 (ab)c 순서로 수행된다. | 오른쪽에서부터 파싱abc 연산은 a(bc) 순서로 수행된다. | 0.8 |
| this, super, _ | 모든 함수에서 사용 가능 | public 함수와 이벤트를 제외하고 사용불가 | 0.8 |
| address 타입과 address payable 타입 | address 타입 자체로 송금 가능한 주소 값 | address 타입 자체는 송금이 불가능한 주소 타입이며, address 타입을 payable(address 타입변수)로 변환하여야 송금 가능한 주소값 (address type)이 됨. | 0.8 |
| 글로벌 변수 tx.origin, msg.sender 타입 | address payable 타입 | 송금이 안되는 address | 0.8 |