pragma solidity 0.5.16;

library MyLib {

    struct State {
        uint256 lockedAt;
        uint256 unlockedAt;
        uint256 lockDuration;
        uint256 cooldownDuration;
    }

    function lock(State storage self, uint256 blockNumber) public {
        self.lockedAt = blockNumber;
    }
}