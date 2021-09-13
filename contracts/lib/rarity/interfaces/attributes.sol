// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRarityAttributes {
    function point_buy(
        uint256 _summoner,
        uint32 _str,
        uint32 _dex,
        uint32 _const,
        uint32 _int,
        uint32 _wis,
        uint32 _cha
    ) external;

    function increase_strength(uint256 _summoner) external;

    function increase_dexterity(uint256 _summoner) external;

    function increase_constitution(uint256 _summoner) external;

    function increase_intelligence(uint256 _summoner) external;

    function increase_wisdom(uint256 _summoner) external;

    function increase_charisma(uint256 _summoner) external;
}
