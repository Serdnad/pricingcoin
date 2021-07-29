// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./sqrtLibrary.sol";

library WeightVote {
    
    using sqrtLibrary for *;
    
    function weightUserVote(uint stake, uint lowestStake) pure public returns(uint) {
        return sqrtLibrary.sqrt(stake/lowestStake);
    }
}