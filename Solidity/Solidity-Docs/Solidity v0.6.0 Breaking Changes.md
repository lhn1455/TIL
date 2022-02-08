# Solidity v0.6.0 Breaking Changes

## Changes the Compiler Might not Warn About (컴파일러가 더이상 warning하지 않는 변경사항)
이 섹션은 컴파일러가 더이상 경고 표시 하지 않기때문에 코드를 직접 수정해야 하는 변경사항들에 대해 나열한다.
- 지수의 결과 타입은 기본타입이다. 
> 이것은 대칭연산과 함께 지수타입과 기본타입 모두를 가지고 있는 가장 작은 타입으로 사용이 되어왔다. 추가적으로, 부호가 있는 타입은 지수에 대하여 허용된다.   

## Explicitness Requirements 명시적 요구사항
> 이 섹션은 코드가 더 명시적으로 되어야 하는 변경사항들을 나열하지만 의미론적인 변화는 아니다. 이 토픽들의 대부분 컴파일러가 의견을 제안할 것이다.   

- 함수는 그 함수들이 `virtual` 키워드를 가지고 있거나 인터페이스에 정의된것만 override할 수 있다. 인터페이스의 밖에서 실행하지 않는 함수는 `virtual` 키워드를 작성해야 한다. 함수 또는 제어자를 override할 때는 반드시 새로운 키워드인 `override`를 사용해야하며, 다중의 병렬적 Base에 정의된 함수와 제어자를 override할 때는 모든 Base가 괄호 안에 나열되어야 한다.
> 예시) override(Base1, Base2) //base : 상위 컨트랙트

- 배열의 길이에 접근하는 것은 항상 read-only이다.(Storage 배열 포함) - 더이상 배열의 길이를 조정함으로써 배열의 크기를 조정할 수 없다. 따라서 `push()`,`push(value)` 또는 `pop()`을 사용하거나 full array를 사용해라. 이것은 원래의 내용에 수정사항을 덮어쓰도록 한다.
    > Q. 이렇게 하는 이유는?   
    거대한 storage 배열에 대하여 storage 충돌을 예방하기 위해서
- 컨트랙트의 내부의 모든 함수를 구현하지 않는다면 `abstract`를 사용하여 컨트랙트를 추상컨트랙트로 만들어야 한다. 추상컨트랙트는 `new` 연산(컨트랙트 배포 명령어)을 사용하여 생성되지 않으며 컴파일시에 bytecode를 생성하지 않는다.
- 라이브러리는 모든 함수를 구현해야 한다.(internal 외 모두 포함)
- inline 어셈블리에 선언된 변수명은 더이상 `_slot` 또는 `_offset`으로 끝나지 않는다.
- inline 어셈블리의 변수 선언은 더이상 다른 inline 어셈블리 블록 외부에 선언된 것을 숨기지 않는다. 변수명에 점(dot)를 포함되어도, 그 점(dot)에 따른 접두어는 inline 어셈블리 블륵 외부의 다른 어떤 선언과 충돌을 일으키지 않을 것이다.
- 상태변수 shadowing은 허용되지 않는다. 파생된 컨트랙트는 다른 어떤 Base들에 같은 이름의 상태변수가 존재하지 않는다면 오직 상태변수 `x`만 선언할 수 있다.

## Semantic and Syntactic Changes (의미론적, 문법적인 변화)
> 이 섹션은 코드에서 반드시 수정되어야 할 변경사항들을 나열한 것이다. 
- external 함수 타입에서 `address`으로 형변환이 허용되지 않는다. 대신, external함수 타입이 `selector`member와 유사한 address를 호출하는 member를 만들어라
- 동적 storage 배열에 대한 `push(value)` 함수는 아무것도 리턴하지 않는다.
- "fallback 함수"라고 불리는 익명함수는 `fallback` 키워드를 사용하는 fallback 함수와 `receive` 키워드를 사용하는 receive ether 함수로 분리되었다.
    - receive ether함수가 존재하면, receive ether 함수는 call data가 비었을때마다(ether를 받았는지 아닌지) 호출된다. 이 함수는 `payable`을 내재하고 있다.
    - 새로운 fallback 함수는 (receive ether 함수가 없을때, 이것은 비어있는 call data의 호출을 포함한다.) 다른 어떤 함수도 매칭되지 않았을 때 호출된다. 이 함수를 사용자가 payble만들지 선택할 수 있다. 만약 payble로 정의하지 않았다면, 값을 보내는 기능을 하는 트랜잭션은 revert될 것이다. upgrade 또는 proxy패턴을 따른다면, 사용자는 반드시 새로운 fallback함수를 구현해야한다. 

## New Features
> 이 섹션은 Solidity 0.6.0 이전 버전에서는 불가능 했거나, 구현하기 어려웠던 것들을 나열한다.
- try/catch 문은 파일 level에서 선언될 수 있다.
- Array slice가 calldata 배열에 사용될 수 있다. 예를 들어, `abi.decode(msg.data[4:], (uint, uint))`는 function call payload를 decode하는 low-level의 방식이다.
- Natspec은 다중 리턴 파라미터를 지원한다. (`@param`과 같은 이름을 체크하도록 권장)
- Yul과 line 어셈블리는 현재의 함수를 빠져나오는 `leave`를 호출하는 새로운 구문이 있다.
- `address`에사 `address payable`로의 형변환은 payable(x)로 가능하다. (여기서 x는 반드시 address 타입)

## Interface Changes
> 이 섹션은 언어 그 자체와는 관련이 없는 변화를 나열한다. 하지만 이것은 컴파일러 인터페이스에 영향을 미친다. 이러한 것을은 사용자가 command line에서 컴파일러를 어떻게 사용하는지 / 이것의 문법적 인터페이스 / 또는 사용자가 그것에 의해 만들어진 결과값을 어떻게 분석하는지에 대한 방법을 변화시킨다.

- New Error Reporter   
새로운 New Error Reporter가 도입되었고, 그것은 command line에서 에러 메세지에 대한 접근성이 더 좋도록 만드는 것을 목표로 한다. 이것이 default로 사용되어진다. (이전 버전의 error reporter로 돌아가려면 `--old-reporter`)

- Metadata Hash Options   
현재 컴파일러는 컨트랙트 메타데이터안에 세부사항위해 bytecode의 끝에 default로 메타데이터의 IPFS 해시를 첨부한다. 0.6.0이전 버전에서는 컴파일러가 default로 Swarm 해시를 첨부했었고, 이 기능을 계속 지원하도록 새로운 command line option `-metadata-hash`가 도입되었다. 이것은 `-metadata-hash` command line option에 `ipfs` 또는 `swarm`을 값으로 넘김으로써 첨부될 해시를 사용자가 선택할 수 있도록 하였다. 

이러한 변화는 Standard JSON Interface를 기반으로 사용되어질 수 있으며, 컴파일러에 의해 만들어진 메타데이터 JSON에 영향을 미친다.   

메타데이터를 읽기 위한 권장 방법은 CBOR encoding의 길이를 결정하기 위해 마지막 두 바이트를 읽고, 메타데이터 section안에서 설명된 data block안에서 적절한 decoding을 하는것이다.

- Yul Optimizer   
legacy bytecode optimizer와 함께, Yul optimizer는 `--optimizer`
명령어로 컴파일러를 호출할 때 default로 사용된다. 이것은 `--no-optimize-yul` 을 사용하여 비활성화 시킬 수 있다.   
이것은 일반적으로 ABI coder v2를 사용하는 코드에 영향을 미친다.

- C API Changes   
`libsolc` 의 C API를 사용하는 client code는 컴파일러에 의해 사용되는 메모리에 관리된다. 이러한 변경사항에 일치시키기 위해, 몇몇 추가적 변경사항이 있다.   
    - `solidity_free` ➔ `solidity_reset` 이름 변경
    - `solidity_alloc`,`solidity_free` 추가
    - `solidity_compile`의 return ➔ string (**string** that must be explicitly freed via `solidity_free()`)


## How to update your code
- address(f) ➔ f.address // f = external function type
- function () external [payable] {...}   
    ➔ receive() external payable {...}, fallback() external [payable] {...} 또는 둘 다   
    (권장사항 : 가능하다면 `receive`함수만 사용할 것)
- `uint length = array.push(value)` ➔ `array.push(value)`
    - 새로운 길이의 접근은 `array.length`를 통해 접근
- `array.length++` ➔ `array.push()`
    >  `array.length--` ➔ `array.pop()`
- `@dev`함수의 모든 이름있는 리턴 파라미터들에 대해, 문서는 `@return`을 정의함. 이것은 첫번째 키워드로 파라미터의 이름을 포함함. 
    > 예시 )   
    f()  ➔ `function f() public returns(uint value)`  
    `@dev` 문서 내 정의 ➔ `@return value the return value.`   
    튜플 리턴 타입에 리턴 파라미터들이 순서대로 나와있다면, 이름있는 리턴 파라미터와 없는 파라미터를 섞어서 쓸 수 있음.
- inline 어셈블리에서 변수 선언에 유니크한 식별자를 선택해야 함. (inline 어셈블리 블록 외부에 선언된것과 충돌하는 것을 피하기 위해)
- override를 해야하는 모든 non-interface 함수에 `virtual` 키워드 추가
    - 인터페이스 외부에 구현이 안된 모든 함수에 `virtual` 키워드 추가
    - 단일 상속에서, 모든 override된 함수에 `override` 키워드 추가
    - 다중 상속에서, `override{...}` 키워드 추가 (괄호안에 모든 상위 컨트랙트를 나열)
    - 다중 Base가 같은 함수를 정의할 때, 상속하는 컨트랙트는 반드시 모든 상충되는 함수들 override


