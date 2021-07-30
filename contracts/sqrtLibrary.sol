// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

library sqrtLibrary {
    
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
    function appraisalReward(uint length) internal pure returns (uint) {
        if(length < 25) {
            return 0;
        }
        else{
            return 2 * sqrt(sqrt(length));
        }
    }
}