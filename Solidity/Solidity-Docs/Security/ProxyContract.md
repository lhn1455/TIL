# Proxy Contract (대리자 컨트랙트)

"대리자" 컨트랙트는 호출 데이터를 받아서 다른 컨트랙트 함수에 전달하는 중개 컨트랙트인데, 저수준 호출 call()을 통해서 대리자 컨트랙트를 거쳐 다른 컨트랙트의 함수를 실행하는 것을 말함

```solidity
//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract MyProxy {
    function callByProxy(address _addr, bytes memory _payload) public returns (bytes memory) {
        ( bool bOk, bytes memory result ) = _addr.call(_payload);
        if (!bOk) {
            revert();
        }
        return result;
    }
}
```
MyProxy 컨트랙트의 callByProxy() 함수는 _addr 컨트랙트에 _payload를 전달함.   
예를 들어, 아래와 같은 MyContract의 sum() 함수를 호출하려면 호출 데이터(payload)를 만들어야 함.
→ abi.encodeWithSignature("sum(uint256,uint256)",_a,_b)

```solidity
//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract MyContract {
    function sum(uint256 _a, uint256 _b) external pure returns (uint256) {
        return _a + _b;
    }
}
```
_a = 100, _b = 500 의 경우 호출 데이터는 아래와 같음 (길어서 개행됨)
```
0xcad0899b000000000000000000000000000000000000000000000000000000000000006400000000000000000000000000000000000000000000000000000000000001f4
```
_addr에 MyContract의 계정 주소를, _paybload에 위에서 만든 호출 데이터를 callByProxy()에 전달하면 MyContract의 sum() 함수가 다시 호출되고 bytes 타이븨 리턴 값을 디코딩하면 600이라는 값을 얻을 수 있음.

> ** 요약
> 1. _a=100, _b=500를 넣어서 payload 만듦   
→ abi.encodeWithSignature("sum(uint256,uint256)",_a,_b)
> 2. callByProxy에 MyContract 계정주소와  _payload 전달
> 3. MyContract의 sum() 함수 호출
> 4. bytes타입으로 리턴받음
> 5. 디코딩 하면 600 나옴

대리자 컨트랙트를 통해 다른 컨트랙트의 함수를 실행할 수 있는 것이 효율적으로 보일 수 있음. 그래서 어떤 목적에 의해 대리자 컨트랙트를 앞에 두고 이 컨트랙트에서 여러 컨트랙트의 함수를 실핼할 수 있도록 권한을 주는 경우가 있음.
![proxy](/Solidity/Solidity-Docs/img/proxy.png)

그러나 이것은 보안적인 측면에서 바람직하지 않음.    
컨트랙트의 외부 함수는 누구든지 실행할 수 있고, 대리자 컨트랙트는 임의의 함수 호출 데이터를 전달할 수 있으므로 대리자 컨트랙트에게 권한을 주는 것은 위험할 수 있음.
