# Fruitshop-Dapp

Dapp ➔ truffle ➔ react

* react에서 배포한 스마트컨트랙트를 어떻게 작업했는지
* 배포한 컨트랙트 내용을 가져올 때 사용한 web3
* web3에서 메타마스크에 연결하는 방법 : truffle 지원
* react unbox 하는 이유? src > getWeb3.js 사용하기 위해

## 1. Truffle
작업할 디렉토리까지 이동 후 
> Desktop/project/Fruitshop
```
$ npm install -g truffle
$ truffle unbox react
```
> unbox 후 생성된 폴더 및 파일   
특히, client > src > getWeb3.js 확인
![unbox](/Fruitshop/img/dapp1.png)   

## 2. ganache & metamask
ganache 실행   
<br>

or
```
$ ganache-cli
```
- Desktop에서 ganache 앱 실행 시 port : 7545
- ganache-cli 실행 시 port : 8545
    - ganache-cli 실습 시 메타마스크에 계정 불러오기)   
    ![ganache-cli](/Fruitshop/img/ganache.png)   
        > 여기서 0번 account를 가져다 쓰기위해 0번 private key를 복사   

    - metamask   
    ![metamask](/Fruitshop/img/metamask.png)   

        > 비공개키 자리에 0번 private key 복사한것을 붙여넣기  
    - metamask 계정 연결   
    ![metamask](/Fruitshop/img/metamask1.png)   
    > 이후 아래 실습은 Desktop ganache로 진행!
    ++++ 새로운 터미널을 띄워 아래 코드를 입력하면 ganach-cli의 port넘버를 7545로 바꿀 수 있음
    ```
    ganache-cli -p 7545
    ```
    
## 3. truffle-config.js 파일 설정
networks{} 내부에 아래 코드 추가
```javascript
development : {
  host : "127.0.0.1",
  port : 7545, //ganache-cli : 8548
  network_id : "*",
},

```
> 추가 후 truffle-config.js
```javascript
const path = require("path");

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    development : {
      host : "127.0.0.1",
      port : 7545,
      network_id : "*",
    },
    develop: {
      port: 8545
    }
  }
};
```

## 4. contract 작성
- 컨트랙트 생성   
 (새로운 컨트랙트 작성 전 contracts > SimpleStorage.sol / migrations > 2_deploy_contracts.js 지우기)
```
$ truffle create contract Fruitshop
```
contracts 폴더 안에 Fruitshop.sol 생성   
![contract](/Fruitshop/img/contract.png) 


- Fruitshop.sol 작성
> Fruitshop.sol
```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/*
  1. 보낸 사람의 계정에서 사과를 총 몇개 갖고 있는가
  2. 사과를 구매했을 시, 해당 계정(주소)에 사과를 추가함
  3. 사과를 판매시 내가 갖고 있는 사과 * 사과 구매 가격 만큼 토큰을 반환해주고
    사과를 0개로 바꿔준다.
  4. 내 사과를 반환해주는 함수
*/

contract Fruitshop {
  mapping(address=>uint) myApple;  // 주소별로 사과를 저장할 수 있도록 mapping으로 선언
  constructor() public {
  }

  function buyApple() payable public{
    // msg.sender : contract를 요청한 사람의 주소를 담고 있는 내장 객체
    myApple[msg.sender]++;      // 초기화 값이 0 인데 이거를 1로 만들어줌
  }

  function getMyApple() public view returns(uint){
    return myApple[msg.sender];
  }

  function sellApple(uint _applePrice) payable external{
    uint totalPrice = (myApple[msg.sender] * _applePrice);
                      // 내가 갖고 있는 사과 * 가격
    myApple[msg.sender] = 0;    // 사과 0으로 초기화
    msg.sender.transfer(totalPrice);    // 환볼 느낌
  }
}

/*
  truffle version 해보면 해석기는 ver 5 이다.
  근데 vscode 는 ver 8 이라서 여기서 나는 오류가 해설할때는 안날 수 있다.

  solcjs --version
  이건 vscode ver
*/
```

## 5. deploy script(배포 스크립트) 작성

- 배포 스크립트 파일 생성
```
$ truffle create migration Fruitshop
```
migrations 폴더 안에 js파일 생성
![deploy](/Fruitshop/img/deploy.png)   
- _fruitshop.js 파일 수정
```javascript
var Fruitshop = artifacts.require("./Fruitshop.sol");


module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Fruitshop);
};
```

## 6. complie / migrate

```
$ truffle compile
```
![compile](/Fruitshop/img/compile.png)  
client > src > contracts > Fruitshop.json / Migrations.json 생성

```
$ truffle migrate
```
![migrate](/Fruitshop/img/migrate.png)  

## 7. App.js 수정
```javascript
import React, { Component, useReducer } from "react";
import FruitshopContract from "./contracts/Fruitshop.json";
import getWeb3 from "./getWeb3";
import { useState, useEffect } from "react";

import "./App.css";

const App = () => {
  const [myApple,setMyApple] = useState(0)
  // instance, address, web3 상태에 저장하기
  // 상태저장하려면 store에 저장해야하고
  //store에 저장하려면 reducers와 actions에 각각을 추가해야 함
  let initalState = {web3:null, instance:null, account:null}
  const [state, dispatch] = useReducer(reducer,initalState)

//reducer
  function reducer(state,action){
    switch(action.type){
      case "INIT":
        let {web3,instance,account} = action
        return{
          ...state,
          web3,
          instance,
          account
        }
    }
  }

  const buyApple = async () =>{
    //instance 값 가져와야 함
    let {instance, account, web3} = state;
    await instance.buyApple({
      from : account,
      value : web3.utils.toWei("10","ether"),    //wei
      gas : 90000,
    })
    setMyApple(prev => prev+1)  // 블록에 있는 내용을 가져와서 뿌리는걸로 수정해보기 + 숫자 조정해보기
  }

  const sellApple = async () =>{
    let {instance, account, web3} = state
    await instance.sellApple(web3.utils.toWei("10","ether"),{
      from : account,
      gas : 90000,
    })
    setMyApple(0)
  }

 // 현재 내가 갖고 있는 사과를 리턴해주는 함수를 만든다.
  const getApple = async (instance)=>{
    if(instance == null) return
    let result = await instance.getMyApple()
    setMyApple(result.toNumber())
  }

  const getweb = async ()=>{
    const contract = require("@truffle/contract")

    let web3 = await getWeb3()
    let fruitshop = contract(FruitshopContract)
    fruitshop.setProvider(web3.currentProvider)

    let instance = await fruitshop.deployed() //이것은 지역변수라서 상태저장을 해야함

    // 계정(address) 가져오기
    let accounts = await web3.eth.getAccounts()

    // action
    let InitActions = {
      type : 'INIT',
      web3,
      instance,
      account:accounts[0]
    }
    dispatch(InitActions)

    getApple(instance)

    // 내 계정 : 0x0A1d2A25D5BF8646da58602715222F2Ab40A755e
    // account : ['0x0A1d2A25D5BF8646da58602715222F2Ab40A755e']
  }

  // componentDidMount Web3 가져와서 메타마스크 연결 할거임
  useEffect(()=>{
    getweb()
  },[])

  return(
    <div>
      <h1>사과 가격 : 10 ETH</h1>
      <button onClick={()=>buyApple()}>BUY</button>
      <p>내가 가지고 있는 사과 : {myApple}</p>
      <button onClick={()=>sellApple()}>SELL (판매 가격은 : {myApple * 10} ETH)</button>
    </div>
  )
}


export default App;
```

## 8. @truffle/contract
디렉토리를 client로 확인 후 install
```
$ npm install @truffle/constract
```
Q. @truffle/contract를 사용하는 이유?   
코드가 깔끔하게 나오기 때문

```javascript
const getweb = async ()=> {
    const contract = require("@truffle/contract")
    let web3 = await getWeb3()
    let fruitshop = contract(FruitshopContract)
    fruitshop.setProvider(web3.currentProvider)
    let instance = await fruitshop.deployed()

    console.log(instance);
}
```

## 9. npm run start
```
$ npm run start
```

![meta](/Fruitshop/img/meta.png)

> 이후 Fruitshop이 deploy되지 않았다는 오류가 뜨면 client > src > contracts 에서 .json파일 삭제 후 다시 compile & migrate   
**compile과 migrate는 배포파일까지 작성 완료 후 해야 함!**   

- buy 클릭 후   

![meta](/Fruitshop/img/meta1.png)   

- buy 하는 트랜잭션 완료 : 10 ETH 차감  

![buy](/Fruitshop/img/buy.png)

- sell 클릭 후   

![sell](/Fruitshop/img/sell.png)

- sell 하는 트랜잭션 완료 : 10 ETH 복구

![sell2](/Fruitshop/img/sell2.png)

# + injected web3
- user ➔ client가 web3를 통해서 접근 ➔ 메타마스크 중 어떤 계정과 연결
- 가나쉬 /1000ETH가 있는 계정과 연결
- 그럼 이 메타마스크는 수많은 블록체인이 연결되어 있는 하나의 노드와 RPC 통신을 할 수 있음
- 네트워크와 통신이 되어야 지갑의 기능을 할 수 있음

# + src > App.js (SimpleStorageContract 삭제 전)
컴파일을 진행하면 생기는 .json파일을 import 해옴   
➔ 두가지 값을 가져옴

state 상태   
componentDidMount = useEffect[]와 같은 것임

- RPC 통신
```javascript
const accounts = await web3.eth.getAccounts();
```
➔ 10개의 계정들이 나옴
```javascript
const networkId = await web3.eth.net.getId();
```
➔ 여기서 networkId는 "*"(=all)임. (참고로 가나쉬 5777) 

```javascript
const deployedNetwork = SimpleStorageContract.networks[networkId];
```
SimpleStorageContract.json 파일에서
```json
"networks": {
    "5777": {
      "events": {},
      "links": {},
      "address": "0xF3833bB61AF21BFEC9324Ea7a62Ef8d5622DB4D9",
      "transactionHash": "0xfee2c7d25811e46a5488d5cef188300564d6daf8ad83c4ed5244e9fbd6f9a840"
    }
},
```
이부분을 넣은 것임

```javascript
const instance = new web3.eth.Contract(
    SimpleStorageContract.abi,      // abi 값을 넣어준거임
    deployedNetwork && deployedNetwork.address,     // 위에 주소값을 넣는다.
);
```

# + ) componentDidMount
componentDidMount ➔ web3 가져와서 메타마스크 연결

```javascript
useEffect(() => {

}, [])
```
이 부분을 추가하여 getWeb3 가져옴

1. import
```javascript
import getWeb3 from "./getWeb3";
```

getWeb3의 return 값은 Promise 객체라서 받을때 then 또는 async await으로 받아야 함

```javascript
const getweb = async ()=> {
    let web3 = await getWeb3()
    console.log(web3);
}
useEffect(()=>{
    getweb()
},[])
```
> 개발자 모드에서 콘솔로 확인










