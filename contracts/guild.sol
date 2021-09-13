// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./batch.sol";

contract GuildBase is GuildBatch {
    using EnumerableSet for EnumerableSet.AddressSet;

    constructor(
        address rarity_address,
        address gold_address,
        address attributes_address,
        address crafting_address,
        address skills_address,
        uint256 guild_master,
        uint256 max_summoners,
        address[] memory _dungeons
    ) {
        IRarity rarity = IRarity(rarity_address);
        IRarityGold rarity_gold = IRarityGold(gold_address);
        IRarityAttributes rarity_attributes = IRarityAttributes(
            attributes_address
        );
        IRarityCrafting rarity_crafting = IRarityCrafting(crafting_address);
        IRaritySkills rarity_skills = IRaritySkills(skills_address);

        string memory logo = "url";
        string memory name = "Guild";
        string memory guild_type = "Base";
        uint256 tribute = 0;
        uint256 next_excursion = 1631561401;

        for (uint256 i = 0; i < _dungeons.length; i++) {
            gs_dungeons[_dungeons[i]] = IDungeon(_dungeons[i]);
            gs_dungeons_list.add(_dungeons[i]);
        }

        gs = GuildSettings(
            rarity,
            rarity_gold,
            rarity_attributes,
            rarity_crafting,
            rarity_skills,
            guild_master,
            tribute,
            next_excursion,
            max_summoners,
            logo,
            name,
            guild_type
        );
    }
}
