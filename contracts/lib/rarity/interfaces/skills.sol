// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRaritySkills {
    function set_skills(uint256 _summoner, uint8[36] memory _skills) external;
}
