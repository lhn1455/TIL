# Build a DeFi App

Step 1. Deploy Dai // 이 단계에서 Dai주소를 가져옴
step 2. Deploy DAPP // 이 단계에서 DAPP 주소를 가져옴
step 3. Deploy TokenFarm


```
truffle console
compile
migrate --reset
mDai = await DaiToken.deployed()
accounts = await web3.eth.getAccounts()
accounts[1] // 투자자 계정
balance = await mDai.balanceOf(accounts[1])
balance
balance.toString()
formattedBalance = web3.utils.fromWei(balance)
.exit

mkdir test
touch test/TokenFarm.test.js



test => chai 사용