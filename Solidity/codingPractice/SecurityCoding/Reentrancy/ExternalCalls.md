# External Calls

## External Calls

External call을 할 때, 종종 예기치 못한 위험을 직면하게 된다.
(→ 컨트랙트들이 서로 의존관계라서)   
따라서, External call을 할 때, 보안적인 요소, 잠재적인 위험요소들을 잘 다루어야 한다.

<hr>
<br>

- **Mark untrusted contracts**   

> When interacting with external contracts, name your variables, methods, and contract interfaces in a way that makes it clear that interacting with them is potentially unsafe. This applies to your own functions that call external contracts.   

외부 컨트랙트와 상호 작용할 때 상호 작용이 잠재적으로 안전하지 않다는 것을 분명히 하는 방식으로 변수, 메서드 및 컨트랙트 인터페이스의 이름을 지정해라. (외부 컨트랙트를 호출하는 함수에 적용)

```solidity
// bad
Bank.withdraw(100); // Unclear whether trusted or untrusted

function makeWithdrawal(uint amount) { // Isn't clear that this function is potentially unsafe
    Bank.withdraw(amount);
}

// good
UntrustedBank.withdraw(100); // untrusted external call
TrustedBank.withdraw(100); // external but trusted bank contract maintained by XYZ Corp

function makeUntrustedWithdrawal(uint amount) {
    UntrustedBank.withdraw(amount);
}

```
<hr>

- **Avoid state changes after external calls**

> Whether using raw calls (of the form someAddress.call()) or contract calls (of the form ExternalContract.someMethod()), assume that malicious code might execute. Even if ExternalContract is not malicious, malicious code can be executed by any contracts it calls. 

저수준 콜을 이용하는 것은 무엇이든, 악의적인 코드 시행을 가정해라.   
외부 컨트랙트가 악의적이지 않아도, 그것을 call하는 어떤 컨트랙트에서도 악의적인 코드는 실행될 수 있다.

<br>

> One particular danger is malicious code may hijack the control flow, leading to vulnerabilities due to reentrancy. (See Reentrancy for a fuller discussion of this problem).   

한 가지 특별한 위험은 악성 코드가 제어 흐름을 가로채고 ****재진입 Reentrancy***으로 인한 취약점으로 이어질 수 있다는 것.

<br>

> If you are making a call to an untrusted external contract, avoid state changes after the call. This pattern is also sometimes known as the checks-effects-interactions pattern.

신뢰할 수 없는 외부 컨트랙트를 호출하는 경우 호출 후 상태 변경을 피해라. ****The checks-effects-interactions pattern***

<hr>

- Don't use transfer() or send().

> .transfer() and .send() forward exactly 2,300 gas to the recipient. The goal of this hardcoded gas stipend was to prevent reentrancy vulnerabilities, but this only makes sense under the assumption that gas costs are constant. Recently EIP 1884 was included in the Istanbul hard fork. One of the changes included in EIP 1884 is an increase to the gas cost of the SLOAD operation, causing a contract's fallback function to cost more than 2300 gas.   
**⟹ It's recommended to stop using .transfer() and .send() and instead use .call().**

.transfer() 및 .send()는 정확히 2,300 가스를 소모한다. 이 하드코딩된 가스비 책정의 목표는 재진입 취약성을 방지하는 것이지만 이는 가스 비용이 일정하다는 가정 하에서만 의미가 있다. 최근 EIP 1884가 이스탄불 하드포크에 포함되었는데, EIP 1884에 포함된 변경 사항 중 하나는 SLOAD 작업의 가스 비용이 증가하여 계약의 폴백 기능에 2300 이상의 가스 비용이 발생하는 것(즉, 가스 비용이 일정하다는 가정이 성립하지 않을 수 있음)

**⟹ 따라서, .transfer()와 .send() 대신 .call()을 사용해라**

```solidity
// bad
contract Vulnerable {
    function withdraw(uint256 amount) external {
        // This forwards 2300 gas, which may not be enough if the recipient
        // is a contract and gas costs change.
        msg.sender.transfer(amount);
    }
}

// good
contract Fixed {
    function withdraw(uint256 amount) external {
        // This forwards all available gas. Be sure to check the return value!
        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, "Transfer failed.");
    }
}

```

.call()은 재진입 공격에 취약하므로 다른 예방 조치를 취해야 함. 재진입 공격을 방지하려면 **The checks-effects-interactions pattern**을 사용

<hr>
<br>

- Handle errors in external calls (외부 호출에서의 오류 처리)

> Solidity offers low-level call methods that work on raw addresses: address.call(), address.callcode(), address.delegatecall(), and address.send(). These low-level methods never throw an exception, but will return false if the call encounters an exception. On the other hand, contract calls (e.g., ExternalContract.doSomething()) will automatically propagate a throw (for example, ExternalContract.doSomething() will also throw if doSomething() throws).   
If you choose to use the low-level call methods, make sure to handle the possibility that the call will fail, by checking the return value.


Solidity는 원시 주소에서 작동하는 낮은 수준의 호출 메서드인 address.call(), address.callcode(), address.delegatecall() 및 address.send()를 제공함. 이러한 저수준 메서드는 예외를 던지지 않지만 호출에 예외가 발생하면 **false를 반환**. 반면에 컨트랙트 호출(예: ExternalContract.doSomething())은 자동으로 throw를 던짐. (예를 들어, ExternalContract.doSomething()은 doSomething()이 throw되는 경우에도 throw를 던짐.

**저수준 호출 방법을 사용하기로 선택한 경우 반환 값을 확인하여 호출이 실패할 가능성을 처리해야 함**

```solidity
// bad
someAddress.send(55);
someAddress.call.value(55)(""); // this is doubly dangerous, as it will forward all remaining gas and doesn't check for result
someAddress.call.value(100)(bytes4(sha3("deposit()"))); // if deposit throws an exception, the raw call() will only return false and transaction will NOT be reverted

// good
(bool success, ) = someAddress.call.value(55)("");
if(!success) {
    // handle failure code
}

ExternalContract(someAddress).deposit.value(100)();

```

## ✎ Send vs Transfer vs Call
- send : 2300 gas를 소비(call과의 차이점), 성공여부를 true 또는 false로 리턴. (실패시 호출 컨트랙트에서 해결) 
- transfer : 2300 gas를 소비, 실패시 에러를 발생
    → In a failure case, the transfer function reverts. (실패시 revert, 지불받는 컨트랙트가 해결)

    → If a payment is made, either the fallback() or receive() function in the receiving contract is triggered. This provides the opportunity for the receiving contract to react upon a payment. (지불이 이루어지면 지불 받는 컨트랙트의 fallback() 또는 receive() 함수가 작동함. 이것은 지불받는 컨트랙트가 지불에 대처할 수 있는 기회를 제공함.)

- call : 가변적인 gas 소비 (gas값 지정 가능), 성공여부를 true 또는 false로 리턴   
    → 재진입(reentrancy) 공격 위험성 있음, 2019년 12월 이후 call 사용을 추천. 
    ```solidity
    (bool success, bytes memory data)= receivingAddress.call{value: 100}("");
    ```
    - Let’s have a look on the right side. The value specifies how many wei are transferred to the receiving address. **In the round brackets, we can add additional data like a function signature of a called function and parameters.**   
    ***If nothing is given there, the fallback() function or the receive() function is called.***

    - Issues with call()
With call(), the EVM transfers all gas to the receiving contract, if not stated otherwise. This allows the contract to execute complex operations at the expense of the function caller.   
Another issue is that it allows for so-called re-entrancy attacks. This means that the receiver contract calls the function again where the call() statement is given. If the sender contract is improperly coded, it can result in draining larger amounts of funds from it than planned. This issue requires more awareness by the contract authors.   
 **(→ 받는 컨트랙트에 남은 가스비를 모두 전달하기 때문에, 충분히 복잡한 코드도 계속 수행할 수 있게되므로 재진입 문제가 발생할 여지가 많다는 의미 / 재진입이 발생하면 보유한 자산을 모두 털릴 수 있음)**

> **참고**   
Send vs Transfer vs Call    
(https://blockchain-academy.hs-mittweida.de/courses/solidity-coding-beginners-to-intermediate/lessons/solidity-2-sending-ether-receiving-ether-emitting-events/topic/sending-ether-send-vs-transfer-vs-call/)

<hr>
<br>

- Favor pull over push for external calls(외부 호출에 대해 Push보다 Pull방식 선호)

> External calls can fail accidentally or deliberately. To minimize the damage caused by such failures, **it is often better to isolate each external call into its own transaction that can be initiated by the recipient of the call.** This is especially relevant for payments, where it is better to let users withdraw funds rather than push funds to them automatically. (This also reduces the chance of problems with the gas limit.) Avoid combining multiple ether transfers in a single transaction.

외부 호출은 실수로 또는 의도적으로 실패할 수 있음. 이러한 실패로 인한 피해를 최소화하려면 **각 외부 호출을 호출 수신자가 시작할 수 있는 자체 트랜잭션으로 분리하는 것이 좋음.** 이것은 특히 지불과 관련이 있는데, 사용자가 자금을 자동으로 푸시하는 것보다 사용자가 자금을 인출하게 하는 것이 더 나은 지불 방법임 제시. (이는 또한 가스 한도 문제의 가능성을 줄임) **단일 트랜잭션에서 여러 이더 전송을 결합XX**

```solidity
// bad
contract auction {
    address highestBidder;
    uint highestBid;

    function bid() payable {
        require(msg.value >= highestBid);

        if (highestBidder != address(0)) {
            (bool success, ) = highestBidder.call.value(highestBid)("");
            require(success); // if this call consistently fails, no one else can bid
        }

       highestBidder = msg.sender;
       highestBid = msg.value;
    }
}

// good
contract auction {
    address highestBidder;
    uint highestBid;
    mapping(address => uint) refunds;

    function bid() payable external {
        require(msg.value >= highestBid);

        if (highestBidder != address(0)) {
            refunds[highestBidder] += highestBid; // record the refund that this user can claim
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdrawRefund() external {
        uint refund = refunds[msg.sender];
        refunds[msg.sender] = 0;
        (bool success, ) = msg.sender.call.value(refund)("");
        require(success);
    }
}

```

<hr>
<br>

- Don't delegatecall to untrusted code

> The delegatecall function is used to call functions from other contracts as if they belong to the caller contract. Thus the callee may change the state of the calling address. This may be insecure. An example below shows how using delegatecall can lead to the destruction of the contract and loss of its balance.

delegatecall 함수는 호출자 컨트랙트에 속한 것처럼 다른 계약의 함수를 호출하는 데 사용함(대리 호출). 따라서 수신자는 호출 주소의 상태를 변경할 수 있음. 이것은 안전하지 않을 수 있음. 아래 예는 delegatecall을 사용하면 계약이 파괴되고 잔액이 손실될 수 있는 방법을 보여줌.

```solidity
contract Destructor
{
    function doWork() external
    {
        selfdestruct(0);
    }
}

contract Worker
{
    function doWork(address _internalWorker) public
    {
        // unsafe
        _internalWorker.delegatecall(bytes4(keccak256("doWork()")));
    }
}
```

> If Worker.doWork() is called with the address of the deployed Destructor contract as an argument, the Worker contract will self-destruct. Delegate execution only to trusted contracts, and never to a user supplied address.

배포된 Destructor 컨트랙트의 주소를 인수로 사용하여 Worker.doWork()가 호출되면 Worker 컨트랙트는 자체 소멸됨. **신뢰할 수 있는 컨트랙트에만 실행을 위임하고 사용자가 제공한 주소에는 절대 위임XX**
<hr>
<br>


## Warning

Don't assume contracts are created with zero balance An attacker can send ether to the address of a contract before it is created. Contracts should not assume that their initial state contains a zero balance   

컨트랙트가 제로 잔고로 생성된다고 가정XX.   
공격자는 생성되기 전에 컨트랙트 주소로 이더를 보낼 수 있음. 컨트랙트가 초기 상태에 잔액이 0이라고 가정해서는 안됨.
