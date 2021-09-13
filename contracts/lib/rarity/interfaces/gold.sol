// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRarityGold {
    function claim(uint256 summoner) external;

    function claimable(uint256 summoner) external view returns (uint256 amount);
}
