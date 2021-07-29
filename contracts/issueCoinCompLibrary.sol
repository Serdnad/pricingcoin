// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./sqrtLibrary.sol";

library IssueCoinComp {
    
    using sqrtLibrary for *;
    
    function calcIssue(uint base, uint stake, uint length, uint totalSessionStake) pure public returns(uint) {
        uint amount;
        
        if (length < 20) {
            amount = 0;
        }
        //If pricing session is 20 or larger then the pricing equation kicks in
        else if (length >= 20) {
            amount = (base * sqrtLibrary.sqrt(stake) * sqrtLibrary.sqrt(length)) * 
                sqrtLibrary.sqrt(totalSessionStake)/sqrtLibrary.sqrt(10**18)/sqrtLibrary.sqrt(10**18);
        }
                
        return amount;
    }
}