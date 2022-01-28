# Build a DeFi App

> [TokenFarm](https://github.com/lhn1455/TokenFarm)

Step 1. Deploy Dai // 이 단계에서 Dai주소를 가져옴   
step 2. Deploy DAPP // 이 단계에서 DAPP 주소를 가져옴   
step 3. Deploy TokenFarm   


```

//명령어 모음

// truffle terminal

npm i // dependencies install
truffle console
compile
migrate --reset
mDai = await DaiToken.deployed()
accounts = await web3.eth.getAccounts()
accounts[1] // 투자자 계정
balance = await mDai.balanceOf(accounts[1])
balance.toString()
formattedBalance = web3.utils.fromWei(balance)
```


```
// node terminal
npm run start
```

```
// token issue terminal
truffle exec scripts/issue-token.js
```


## contract
- [DaiToken.sol]()
- [DappToken.sol]()
- [TokenFarm.sol]()

## Script
- [issue-token.js]()
- [2_deploy_contract.js]()

## test
- [TokenFarm.test.js]()


# 기본 로직
- DaiToken : 투자자 보유 토큰
- DappToken : 리워드 토큰
- TokenFarm : 스테이킹 컨트랙트


1. Dai 토큰을 보유한 투자자가 Dai 토큰을 스테이킹함
2. 새로운 토큰이 생성되면 Dai 토큰과 1:1 비율로 Dapp 토큰(리워드토큰)을 보상 받음
3. 스테이킹을 철회하고 싶은 경우 언스테이킹을 함

![초기화면](/Dapp/Defi/img/tokenfarm.png)   
> 초기 화면   
<br>
<br>

![권한 부여 화면](/Dapp/Defi/img/tokenfarm1.png)   
> 권한 부여 화면   

<br>
<br>

![초기화면](/Dapp/Defi/img/tokenfarm2.png)   
> 권한 부여 후 스테이킹 과정   

<br>
<br>

![초기화면](/Dapp/Defi/img/tokenfarm3.png)   
> 스테이킹 후 스테이킹 잔액과 mDAI 잔액 변화  

<br>
<br>

![초기화면](/Dapp/Defi/img/tokenfarm4.png)   
> 리워드 토큰 발행 (스테이킹한 토큰과 1:1 비율로 보상)  

<br>
<br>

![초기화면](/Dapp/Defi/img/tokenfarm5.png)   

> 리워드 토큰 잔액 변화   
<br>
<br>


출처 : https://youtu.be/CgXQC4dbGUE

