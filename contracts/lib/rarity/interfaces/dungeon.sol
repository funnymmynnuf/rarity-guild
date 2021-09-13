// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IDungeon {
    function scout(uint256) external view returns (uint256 reward);

    function adventure(uint256) external returns (uint256 reward);

    function adventurers_log(uint256) external returns (uint256 ts);
}
