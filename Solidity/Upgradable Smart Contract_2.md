# Upgrading smart contracts

## Overview   
[OpenZeppelin Upgrades Plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/)를 사용하여 배포된 스마트 컨트랙트는 주소, 상태, 잔액 등을 변경하지 않으면서 코드 수정을 위해 업그레이드 될 수 있다.

[OpenZeppelin Upgrades Plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/)의 `deployProxy`를 사용하여 새로운 컨트랙트를 배포하면 컨트랙트 인스턴스는 추후에 업그레이드 될 수 있다.

Truffle, Hardhat 구분 없이 모두 사용 가능



**<요약>**

이더리움의 스마트 컨트랙트는 수정이 불가능하다. 일단 한번 배포하고 나면, 변경을 위해 수정할 방법이 없다.

Before Upgrading smart contract )

1. 새로운 버전의 컨트랙트 배포

2. 이전 버전 컨트랙트의 모든 상태를 새로운 버전 컨트랙트로 이전

3. 이전 버전 컨트랙트와 상호작용하던 모든 컨트랙트에서 새로운 버전의 컨트랙트를 사용할 수 있도록 컨트랙트 주소 업데이트

4. 모든 유저들에게 새로운 버전의 컨트랙트를 사용하도록 공표



After Upgrading smart contract )

`deployProxy`는 다음의 트랜잭션을 만든다.

1. implementation contract (`Box` contract)를 배포

2. `ProxyAdmin`contract를 배포 (proxy 관리 컨트랙트)

3. proxy contract 배포 및 초기화 함수 실행



`upgradeProxy`는 다음의 트랜잭션을 만든다.

1. implementation contract(`BoxV2` contract)를 배포

2. `ProxyAdmin`을 호출 (새로 주입된 컨트랙트를 사용하기위해 proxy 컨트랙트를 업데이트 하기위함)



## How upgrades work

업그레이드가 가능한 컨트랙트의 인스턴스를 만들때, openzeppelin upgrades plugins는 실제로 3개의 컨트랙트를 배포한다.

1. 실제 로직을 가지고 있는 컨트랙트 (implementation contract)

2. Proxy 컨트랙트

3. Proxy 컨트랙트를 관리하는 컨트랙트 (ProxyAdmin)



> Proxy contract : 실제 로직을 가지고 있는 컨트랙트를 delegatecall 하는 컨트랙트

> delegatecall은 caller의 컨텍스트에서 모든 코드가 실행된다는 점에서 일반 call과 다르다. (일반 call은 callee의 컨텍스트에서 모든 코드가 실행)

## Upgrading using the Upgrades Plugins

### 1. Truffle  / Hardhat Upgrades Plugins


npm install --save-dev @openzeppelin/truffle-upgrades

npm install --save-dev @openzeppelin/hardhat-upgrades

deployProxy를 사용하기위해서 위의 플러그인을 설치해야 한다.



### 2. 컨트랙트 작성
   기존 컨트랙트 : Box.sol

```solidity
// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Box {
uint256 private _value;

    // Emitted when the stored value changes
    event ValueChanged(uint256 value);

    // Stores a new value in the contract
    function store(uint256 value) public {
        _value = value;
        emit ValueChanged(value);
    }

    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return _value;
    }
}
```

### 3. deployProxy를 사용하여 배포 스크립트 작성
   Truffle은 컨트랙트를 배포하기 위해 migrations 디렉토리를 사용한다.

업그레이드가 가능한 컨트랙트를 배포하기 위해 deployProxy를 사용하여 스크립트를 작성



```solidity
// migrations/3_deploy_upgradeable_box.js
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const Box = artifacts.require('Box');

module.exports = async function (deployer) {
await deployProxy(Box, [42], { deployer, initializer: 'store' });
};
```

### 4. 트러플에 migrate
  ` $ npx truffle migrate`

or

`$ npx truffle migrate --network development`

→ 안된다면,

`$ truffle compile --all`

`$ truffle migrate --reset `시도


5. 업그레이드 컨트랙트 작성
   업그레이드 컨트랙트 : BoxV2.sol

```solidity
// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BoxV2 {
uint256 private _value;

    // Emitted when the stored value changes
    event ValueChanged(uint256 value);

    // Stores a new value in the contract
    function store(uint256 value) public  {

        _value = value;
        emit ValueChanged(value);
    }

    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return _value;
    }

    //추가된 부분
    // Increments the stored value by 1
    function increment() public {
        _value = _value + 1;
        emit ValueChanged(_value);
    }
}
```


6. `upgradeProxy` 사용하여 업그레이드 스크립트 작성
   Box.sol를 BoxV2로 업데이트 하기위해 `upgradeProxy`를 사용함

```solidity
// migrations/4_upgrade_box.js
const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const Box = artifacts.require('Box');
const BoxV2 = artifacts.require('BoxV2');

module.exports = async function (deployer) {
const existing = await Box.deployed();
await upgradeProxy(existing.address, BoxV2, { deployer });
};
```

### 7. 트러플에 migrate
   `$ npx truffle migrate`

or

`$ npx truffle migrate --network development`


### 8. 확인
   Box인스턴스는 최신 버전으로 업그레이드

상태나, 주소는 전과 동일

```
Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.


Starting migrations...
======================
> Network name:    'development'
> Network id:      1658804167259
> Block gas limit: 6721975 (0x6691b7)


1_initial_migration.js
======================

Replacing 'Migrations'
----------------------
> transaction hash:    0xb571f2c69245090d112c6145b7851ea9611365421cca04d2f2172ecab90667c4
> Blocks: 0            Seconds: 0
> contract address:    0x7C728214be9A0049e6a86f2137ec61030D0AA964
> block number:        28
> block timestamp:     1658823586
> account:             0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
> balance:             99.90143822
> gas used:            246892 (0x3c46c)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.00493784 ETH

> Saving migration to chain.
> Saving artifacts
   -------------------------------------
> Total cost:          0.00493784 ETH


2_deploy.js
===========

Replacing 'Box'
---------------
> transaction hash:    0x8e920f75aff63ecef92c4204a26b3e0e766c5ea03a35b676b9a4601bb835fe8b
> Blocks: 0            Seconds: 0
> contract address:    0x86072CbFF48dA3C1F01824a6761A03F105BCC697
> block number:        30
> block timestamp:     1658823586
> account:             0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
> balance:             99.89787414
> gas used:            135691 (0x2120b)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.00271382 ETH

> Saving migration to chain.
> Saving artifacts
   -------------------------------------
> Total cost:          0.00271382 ETH


3_deploy_upgradeable_box.js
===========================

Replacing 'Box'
---------------
> transaction hash:    0x353732d48d2de47880819a2cf99d3ce0130ccc1cb4e7bd60725adecd112c77de
> Blocks: 0            Seconds: 0
> contract address:    0xA586074FA4Fe3E546A132a16238abe37951D41fE
> block number:        32
> block timestamp:     1658823588
> account:             0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
> balance:             99.89461006
> gas used:            135691 (0x2120b)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.00271382 ETH


Deploying 'ProxyAdmin'
----------------------
> transaction hash:    0x046151cab0baf73f2a19922335f4f8f6c6d68f395cb8ecb44f9ef2b21045b2e5
> Blocks: 0            Seconds: 0
> contract address:    0x2D8BE6BF0baA74e0A907016679CaE9190e80dD0A
> block number:        33
> block timestamp:     1658823588
> account:             0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
> balance:             99.88495566
> gas used:            482720 (0x75da0)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.0096544 ETH


Deploying 'TransparentUpgradeableProxy'
---------------------------------------
> transaction hash:    0x0635ff351acce4cdf08b18efb392f5d5abf38873e00133688650f10d99c44ada
> Blocks: 0            Seconds: 0
> contract address:    0x970e8f18ebfEa0B08810f33a5A40438b9530FBCF
> block number:        34
> block timestamp:     1658823589
> account:             0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
> balance:             99.87266858
> gas used:            614354 (0x95fd2)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.01228708 ETH

> Saving migration to chain.
> Saving artifacts
   -------------------------------------
> Total cost:           0.0246553 ETH

Summary
=======
> Total deployments:   5
> Final cost:          0.03230696 ETH
```

```

Compiling your contracts...
===========================
> Everything is up to date, there is nothing to compile.


Starting migrations...
======================
> Network name:    'development'
> Network id:      1658804167259
> Block gas limit: 6721975 (0x6691b7)


1_initial_migration.js
======================

Replacing 'Migrations'
----------------------
> transaction hash:    0x134faaf4aa499a5fea56f7bab6fda08b2b415dd4b22146794824ed11b8e4be38
> Blocks: 0            Seconds: 0
> contract address:    0xB9bdBAEc07751F6d54d19A6B9995708873F3DE18
> block number:        42
> block timestamp:     1658824155
> account:             0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
> balance:             99.84529096
> gas used:            246892 (0x3c46c)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.00493784 ETH

> Saving migration to chain.
> Saving artifacts
   -------------------------------------
> Total cost:          0.00493784 ETH


2_deploy.js
===========

Replacing 'Box'
---------------
> transaction hash:    0x12e75150dec518739f971d3eb81ac819b6b8c59e2cac68f99e24b9ebde42c6b9
> Blocks: 0            Seconds: 0
> contract address:    0xFcCeD5E997E7fb1D0594518D3eD57245bB8ed17E
> block number:        44
> block timestamp:     1658824156
> account:             0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
> balance:             99.84172688
> gas used:            135691 (0x2120b)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.00271382 ETH

> Saving migration to chain.
> Saving artifacts
   -------------------------------------
> Total cost:          0.00271382 ETH


3_deploy_upgradeable_box.js
===========================

Deploying 'TransparentUpgradeableProxy'
---------------------------------------
> transaction hash:    0xc9c03aac570672fc813c4459e9f3debab29673fad53599af33b2a5ebba5eeb60
> Blocks: 0            Seconds: 0
> contract address:    0xdAA71FBBA28C946258DD3d5FcC9001401f72270F
> block number:        46
> block timestamp:     1658824158
> account:             0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
> balance:             99.82888954
> gas used:            614354 (0x95fd2)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.01228708 ETH

> Saving migration to chain.
> Saving artifacts
   -------------------------------------
> Total cost:          0.01228708 ETH


4_upgrade_box.js
================

Deploying 'BoxV2'
-----------------
> transaction hash:    0x13985243294bed4809a84a07899b256644499dd6e97630e7d9bef9873e70344f
> Blocks: 0            Seconds: 0
> contract address:    0x4cFB3F70BF6a80397C2e634e5bDd85BC0bb189EE
> block number:        48
> block timestamp:     1658824158
> account:             0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
> balance:             99.82462154
> gas used:            185887 (0x2d61f)
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.00371774 ETH

> Saving migration to chain.
> Saving artifacts
   -------------------------------------
> Total cost:          0.00371774 ETH

Summary
=======
> Total deployments:   4
> Final cost:          0.02365648 ETH
```
