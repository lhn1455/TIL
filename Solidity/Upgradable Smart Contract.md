# Upgradable Smart Contract

Ethereum의 트랜잭션과 배포된 컨트랙트 코드는 수정이 불가능   
- 장점 : 모든 노드가 트랜잭션의 유효성과 어카운트의 상태를 쉽게 확인할 수 있음
- 단점 : 한번 배포된 컨트랙트를 수정할 수 없음


## Proxy Contract Architecture

Proxy Contract 아키텍쳐는 모든 메시지 콜이 Proxy Contract를 거치게 됨. 이후 Proxy Contract는 요청받은 Message Call을 로직 컨트랙트로 리다이렉트 시킴.   
Proxy Contract는 리다이렉트시킬 로직 컨트랙트의 주소를 가지고 있기 때문에, 업데이트를 할 때 새로운 컨트랙트를 배포한 뒤, Proxy Contract가 참조하고 있는 컨트랙트의 주소를 업데이트 해야 함
![proxy-contract](/Solidity/img/proxy.png)   

## Proxy Contract
> fallback 함수   

만약 컨트랙트에 호출한 함수가 컨트랙트에 없을 경우 fallback 함수가 호출됨. Proxy Contract의 fallback 함수에는 다른 Logic Contract로 Message Call을 리다이렉트 시키기 위한 로직이 작성되어 있음
> delegatecall   

```solidity
contract A {
    function setN(address _b, uint _n) public {
        _b.delegatecall.gas(6712353)(bytes4(keccak256("setN(uint256)")), _n);
        // A's storage is set, B is not modified
    }
}
contract B {
    uint public n;
    address public sender;
    uint256 public amount;

    function setN(uint _n) {
        n = _n;
    }
}   
```
A 컨트랙트의 setN 함수는 B 컨트랙트로 delegateCall을 요청함. **이때 A 컨트랙트의 context에서 B 컨트랙트의 코드가 실행됨**. 즉, B 컨트랙트의 setN 함수 호출로 인해 상태변수 n이 set되는데, 이때 n은 B 컨트랙트의 Storage가 아니라 A 컨트랙트의 Storage에서 변경됨.

<br>
<br>
<hr>

## 아래의 컨트랙트는 OpenZeppelin에서 제공하는 Proxy Contract. 아래의 코드를 이해하기 위해서는 assembly 코드에서 사용되고 있는 [opcode](https://docs.soliditylang.org/en/v0.4.24/assembly.html#opcodes)에 대해 이해하고 있어야 함.

```
assembly {
    let ptr := mload(0x40)
    calldatacopy(ptr, 0, calldatasize)
    let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
    let size := returndatasize
    returndatacopy(ptr, 0, size)
    switch result
    case 0 { revert(ptr, size) }
    default { return(ptr, size) }
 }
```
1. 우선 `mload(0x40)`를 호출해서 free memory pointer의 주소를 가져옴. 0x40 주소의 메모리는 항상 free한 memory 주소를 가리키는 값을 가지고 있음. EVM의 메모리를 사용하기 위해서는 free한 메모리를 사용해야 하기 때문에 0x40 주소로부터 free memory 주소값을 가져옴

2. 다음으로 `calldatacopy`를 호출하는데, `calldatacopy`는 3개의 파라미터를 가짐. `calldatacopy`의 첫 번째 파라미터는 memory의 position이고, 두번째 파라미터는 calldata의 position. 마지막 세번째 파라미터는 복사할 bytes의 길이를 나타냄. 세번째 파라미터 값으로 사용된 `calldatasize`는 calldata의 length를 리턴.   
=> 정리하면 `calldatacopy`는 calldata의 bytes를 memory로 복사하는 기능을 수행

3. 이제 delegatecall을 호출해서 Proxy Contract의 Message Call을 delegate함. delegatecall은 6개의 parameter로 구성.
    - gas : 함수를 실행하는데 필요한 가스
    - _ impl : 호출할 로직 컨트랙트의 주소
    - ptr : 보낼 데이터의 시작 메모리 주소
    - calldatasize : 보낼 데이터의 사이즈 (결국 ptr이 가리키고 있는 memory주소에 있는 데이터에서부터 calldatasize 만큼 보내게 됨)
    - 0 : memory에서 output 데이터를 가져오는 파라미터로 delegatecall의 결과로 어떤 output을 출력할지 예상할 수 없기 때문에 0으로 set함 (mem[out..(out+outsize)))
    - 0 : output의 사이즈를 나타내는 파라미터로 이 또한 delegatecall의 결과로 output의 사이즈를 예상할 수 없기 때문에 0으로 set.
        ## **solidity의 delegatecall은 오직 true/false만 리턴함.**
4. 다음은 returndatasize opcode를 사용해서 return된 데이터의 사이즈를 구함
5. 다음으로 returndatacopy(ptr, 0, size)를 사용해서 returndata의 position 0부터 size만큼 복사하여 ptr이 가리키는 메모리 주소에 복사함
6. 최종적으로 result의 결과, 즉 delegatecall의 성공/실패 여부에 따라 revert하거나 return을 하게 됨. revert는 말 그대로 Message Call이 revert되는 것이고, return은 메모리에 있는 값을 가지고 리턴

>Proxy Pattern 작동 흐름   

![proxy-Pattern](/Solidity/img/proxy2.png)
- Logic Contract의 주소를 구함 (implementation함수 호출)
- 유저가 요청한 Message Call을 Logic Contract로 리다이렉트
(delegatecall OPCODE호출). Proxy Contract의 delegatecall 호출로 인해 변경되는 storage는 모두 Proxy Contract의 Storage에 반영됨.


