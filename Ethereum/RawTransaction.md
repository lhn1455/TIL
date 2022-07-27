# RawTransaction

## RawTransaction은 어떻게 만들어질까?

`nonce`가 변하면 `txId`도 변한다고 하는데, 정말 바뀌는지 RawTransaction을 만드는 과정을 보며 알아보자

```javascript
import ethers from 'ethers.js'

async function sendTransaction(
    wallet: ethers.Wallet,
    to: string,
    value: ethers.BigNumber
): string {

    const gasPrice = await getGasPrice()
    const gasLimit = getGasLimit()

    const transactionRequest = { gasPrice, gasLimit, to, value }
    const fullTx = await wallet.populateTransaction(transactionRequest)
    const signed = await wallet.signTransaction(fullTx)

    const result = await provider.sendTransaction(signedTx)

    return result.hash
}
```
`ethers.js`모듈을 사용해서 transaction을 전송하는 과정이다
transaction을 보내는 과정에 nonce는 보이지 않는다.

## ethers.js

ehters.js 의 populateTransaction 메서드를 보면,
> "gasPrice, nonce, gasLimit, chainId를 채우고 반환한다"   

라고 명시되어있다.
즉, 객체 초기화 당시 설정한 provider에게 `transactionCount`를 조회하고, 명시적으로
입력하지 않은 `nonce`가 해당 메서드를 통해 채워지는 것이다.

```javascript
//ethers.js populateTransaction method
if (tx.nonce = null) {
    tx.nonce = this.getTransactionCount("pending")
}
```
코드에서 account의 `tansactionCount`를 조회하는 것을 볼 수 있다.
정리하면, `nonce`를 명시적으로 입력하지 않았지만, `SKD` 메서드를 통해 서명 전 필요한 값을 모두 채우는 것이다.

## 그렇다면 서명전에 필요한 값은 무엇일까?
_지금부터 나오는 내용은 최신정보가 아니다. 예를들어 `EIP-1559` 변경사함은 불포함 한다._

필요한 값은 아래와 같다.
- nonce
- gasPrice
- gasLimit
- recipient(to address)
- value(payment)
- data(contract invocation)
- v,r,s (EOA의 ECDSA 디지털 서명의 세가지 구성요소)
> from address가 존재하지 않는 이유는, EOA의 공개키를 v,r,s 구성요소로부터 알아낼 수 있기 때문이다.
> 또한 공개키 복구 과정은 설명하지 않는다.
> v 값에는 chainID 값이 포함된다.   

## 그렇다면 어떻게 rawTransaction이 만들어지는 걸까?
_**트랜잭션은, 필요한 데이터를 포함하는 RLP 인코딩 체계를 사용하여 시리얼라이즈된 바이너리 메세지이다.**_

1. `[nonce, gasPrice, gasLimit, to, value, data, chainID, 0, 0]`의 9개 필드를   
포함하는 트랜잭션 데이터 구조 생성
2. RLP로 인코딩된 트랜잭션 데이터 구조의 시리얼라이즈된 메시지를 생성
3. 시리얼라이즈된 메시지의 Keccak-256 해시를 계산
4. EOA의 개인키로 해시에 서명하여 ECDSA 서명을 계산
5. ECDSA 서명의 계산된 v,r,s 값을 트랜잭션에 추가
6. 서명이 추가된 트랜잭션 데이터를 RLP 인코딩해 시리얼라이즈하여 전파

### 아래는 1~5번까지의 내용이다.

```javascript
const message = rlp([
  nonce, gasPrice, gas, to, value, input, chainid, 0, 0
])
const hash = keccak256(message)
const signature = sign(hash, <private key>)
```
### 아래는 6번의 내용이다.

```javascript
const rawTransaction = rlp([
    nonce, gasPrice, gas, to, value, input, v, r, s
])
const txHash = keccak256(rawTransaction)
```

이렇게 만들어진 트랜잭션을 네트워크에 전파하고, 블록에 포함되면 결국 이더리움 싱글톤 상태가 수정된다.

<br>
<br>
<br>


> ### 참고   
> 이더리움은 글로벌 싱글톤 상태 머신이며, 트랜잭션은 이 상태 머신을 움직여서 상태를 변경할 수 있도록 만든다.