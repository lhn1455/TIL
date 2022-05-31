# 부동소수점 및 정밀도 (Floating Point and Precision)

- 솔리디티는 고정 소수점, 부동 소수점 숫자를 지원하지 않습니다.
- 솔리디티는 정수 유형으로 구현해야 합니다.

**취약점**

- 솔리디티에는 고정소수점 유형이 없기 때문에 개발자는 표준 정수 데이터 타입을 사용하여 자체적으로 구현해야 합니다.

**보안 취약 컨트랙트**

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FunWithNumbers {
    uint constant public tokensPerEth = 10;
    uint constant public weiPerEth = 1e18;
    mapping(address => uint) public balances;

    function buyTokens() external payable {
        // convert wei to eth, then multiply by token rate
        uint tokens = msg.value/weiPerEth*tokensPerEth;
        balances[msg.sender] += tokens;
    }

    function sellTokens(uint tokens) public {
        require(balances[msg.sender] >= tokens);
        uint eth = tokens/tokensPerEth;
        balances[msg.sender] -= tokens;
        payable(msg.sender).transfer(eth*weiPerEth);
    }
}
```

- 위 코드는 간단한 토큰 매매 컨트랙트 입니다.
- 토큰 매매에 대한 수학적 계산은 정확하지만, 부동소수점 숫자는 잘못된 결과를 줍니다.
- 예를 들어, 토큰을 구매할 때 값이 1보다 작은 경우 초기 나누기는 결과가 0이 되고 최종 곱하기의 결과는 0이 됩니다. (200 wei / 1e18 weiPerEth = 0)
- 마찬가지로 토큰을 판매할 때 10개 미만의 토큰이 있으면 결과적으로 0이더가 됩니다.
- 실제로 여기서 반올림하는 것은 항상 버림되므로 29개의 토큰을 팔면 2개의 이더가 됩니다.

**예방 기법**

- 비(ratios)나 비율(rates)을 사용할 때는 분수에서 큰 분자를 사용할 수 있는지 확인해야 합니다.
    - 예를 들어, 위의 예에서는 `tokensPerEth` 비율을 사용했습니다.
    - 큰 수인 `weiPerTokens`를 사용하는 것이 더 좋았을 것입니다.
    - 대응하는 토큰 수를 계산하려면 `msg.sender/weiPerTokens`를 사용할 수 있습니다. 이렇게 하면 좀 더 정확한 결과를 얻을 수 있습니다.
- 작업 순서를 염두에 두고 개발하는 것이 좋습니다.
    - 이 예에서 토큰을 구입하는 계산은 `msg.value/weiPerEth*tokenPerEth`입니다. 나누기는 곱하기 전에 발생합니다.
    - 이 예에서는 먼저 곱셈을 수행한 후에 나누기를 수행하면 더 높은 정밀도를 얻을 수 있습니다.
    
    `msg.value/weiPerEth*tokenPerEth` →`msg.value*tokenPerEth/weiPerEth`
    
- 숫자에 대해 임의의 정밀도를 정의할 때는 값을 더 높은 정밀도로 변환하고 모든 수학 연산을 수행한 다음, 최종적으로 출력에 필요한 정밀도로 다시 변환하는 것이 좋습니다.
    
    <aside>
    → 일반적으로 uint256이 사용됩니다(가스사용에 최적). 이것들은 그 범위에서 약 60배의 크기를 제공하며, 그 중 일부는 수학적 연산의 정밀도에 전담시킬 수 있습니다.   

    → 솔리디티에서는 모든 변수를 높은 정밀도로 유지하고 외부 앱의 낮은 정밀도로 다시 변환하는 것이 더 나은 경우일 수 있습니다.(이것이 본질적으로 ERC20 토큰 컨트랙트에서 decimals 변수가 작동하는 방식입니다.)
    
    </aside>