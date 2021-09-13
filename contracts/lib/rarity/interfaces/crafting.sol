// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRarityCrafting {
    function craft(
        uint256 _summoner,
        uint8 _base_type,
        uint8 _item_type,
        uint256 _crafting_materials
    ) external;
}
