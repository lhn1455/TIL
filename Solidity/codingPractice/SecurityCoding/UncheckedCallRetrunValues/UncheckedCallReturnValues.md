# 확인되지 않은 CALL 반환값 (Unchecked CALL Return Values)


- 솔리디티에서 외부호출을 수행하는 몇가지 방법이 있습니다.
- 이더를 외부 계정으로 송금하기 위해 사용되는 함수는 `transfer`, `send`, `call`이 있습니다
- `call`과 `send`는 호출의 성공 또는 실패 여부를 boolean값으로 리턴하고, 실패해도 revert되지 않습니다.
- 개발자는 보통 에러가 발생하면 revert될 것을 예상하기 때문에, 리턴값을 체크하지 않아서 오류가 발생합니다.
- Send vs Transfer vs Call
    - `send` : 2300 gas를 소비(call과의 차이점), 성공여부를 true 또는 false로 리턴.(실패시 호출 컨트랙트에서 해결)
    - `transfer` : 2300 gas를 소비, 실패시 에러를 발생 → In a failure case, the transfer function reverts.(실패시 revert, 지불받는 컨트랙트가 해결)
        
        → If a payment is made, either the fallback() or receive() function in the receiving contract is triggered. This provides the opportunity for the receiving contract to react upon a payment.(지불이 이루어지면 지불 받는 컨트랙트의 fallback() 또는 receive() 함수가 작동함. 이것은 지불받는 컨트랙트가 지불에 대처할 수 있는 기회를 제공함.)
        
    - `call` : 가변적인 gas 소비 (gas값 지정 가능), 성공여부를 true 또는 false로 리턴→ 재진입(reentrancy) 공격 위험성 있음, 2019년 12월 이후 call 사용을 추천.(실패시 호출 컨트랙트에서 해결)
        
        `(bool success, bytes memory data)= receivingAddress.call{value: 100}("");`
        
        - Let’s have a look on the right side. The value specifies how many wei are transferred to the receiving address. **In the round brackets, we can add additional data like a function signature of a called function and parameters.*If nothing is given there, the fallback() function or the receive() function is called.***
        - Issues with call() With call(), the EVM transfers all gas to the receiving contract, if not stated otherwise. This allows the contract to execute complex operations at the expense of the function caller.Another issue is that it allows for so-called re-entrancy attacks. This means that the receiver contract calls the function again where the call() statement is given. If the sender contract is improperly coded, it can result in draining larger amounts of funds from it than planned. This issue requires more awareness by the contract authors.**(→ 받는 컨트랙트에 남은 가스비를 모두 전달하기 때문에, 충분히 복잡한 코드도 계속 수행할 수 있게되므로 재진입 문제가 발생할 여지가 많다는 의미 / 재진입이 발생하면 보유한 자산을 모두 털릴 수 있음)**
    

**취약 컨트랙트**

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lotto {

    bool public payedOut = false;
    address public winner;
    uint public winAmount;

    // ... extra functionality here

    function sendToWinner() public {
        require(!payedOut);
        payable(winner).send(winAmount);
        payedOut = true;
    }

    function withdrawLeftOver() public {
        require(payedOut);
        payable(msg.sender).send(address(this).balance);
    }
}
```

- 이 코드의 취약점은 `payable(winner).send(winAmount);`에 있습니다.
- 처리 결과를 확인하지 않고 `payedOut = true;`로 하는데 `payable(winner).send(winAmount);`이 실패한 경우 아무나 `withdrawLeftOver` 함수를 호출하여 상금을 탈취할 수 있습니다.

**예방 기법**

- ~~되도록 전송은 안전한 transfer 함수를 사용하세요.~~
    - 2019년 12월 이후 call 사용을 추천.(실패시 호출 컨트랙트에서 해결)
        
        (→ 위에 **Send vs Transfer vs Call** 참고)
        
- send 함수를 사용할 경우 꼭 반환값을 확인하세요.

**보안 취약 예시 컨트랙트**

```solidity
...
  function cash(uint roundIndex, uint subpotIndex){

        uint subpotsCount = getSubpotsCount(roundIndex);

        if(subpotIndex>=subpotsCount)
            return;

        uint decisionBlockNumber = getDecisionBlockNumber(roundIndex,subpotIndex);

        if(decisionBlockNumber>block.number)
            return;

        if(rounds[roundIndex].isCashed[subpotIndex])
            return;
        //Subpots can only be cashed once. This is to prevent double payouts

        uint winner = calculateWinner(roundIndex,subpotIndex);
        uint subpot = getSubpot(roundIndex);

        payable(winner).send(subpot);

        rounds[roundIndex].isCashed[subpotIndex] = true;
        //Mark the round as cashed
}
...
```

- `payable(winner).send(subpot);` 이 코드에서 처리 결과를 확인하지 않습니다.
- `rounds[roundIndex].isCashed[subpotIndex] = true;` 하지만 다음 코드에서 `true` 값으로 설정되어 있기 때문에 우승자가 상금을 지급받은 것으로 처리됩니다.
- 따라서, 이 컨트랙트는 우승자가 상금을 지급받지 못해도 상금을 지급받은 것으로 처리하기 때문에, `send`함수가 실패할 경우 우승자는 상금을 지급받지 못하게 됩니다.