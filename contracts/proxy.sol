// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./settings.sol";

abstract contract GuildProxy is GuildManagement {
    // *************
    // Individual Wanderer Interaction
    // *************

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    function proxy_summoner_transfer_ownership(
        uint256 summoner,
        address new_owner
    ) external onlyWandererOwner(summoner) {
        gs_summoners_owners[summoner] = new_owner;
    }

    // *************
    // Adventures / Dungeons
    // *************

    function proxy_summoner_adventure(uint256 summoner)
        external
        onlyWandererOwner(summoner)
    {
        if (block.timestamp > gs.rarity.adventurers_log(summoner)) {
            gs.rarity.adventure(summoner);
            _level_up(summoner);
        }
    }

    function proxy_summoner_go_dungeon(uint256 summoner, address dungeon)
        external
        onlyWandererOwner(summoner)
    {
        IDungeon idungeon;

        if (gs_dungeons_list.contains(dungeon)) {
            idungeon = gs_dungeons[dungeon];
        } else {
            idungeon = IDungeon(dungeon);
        }

        if (
            block.timestamp > idungeon.adventurers_log(summoner) &&
            idungeon.scout(summoner) > 0
        ) {
            idungeon.adventure(summoner);
        }
    }

    function proxy_summoner_level_up(uint256 summoner)
        external
        onlyWandererOwner(summoner)
    {
        _level_up(summoner);
    }

    function proxy_summoner_claim(uint256 summoner)
        external
        onlyWandererOwner(summoner)
    {
        gs.rarity_gold.claim(summoner);
    }

    // *************
    // Attributes
    // *************

    function proxy_summoner_point_buy(
        uint256 summoner,
        uint32 _str,
        uint32 _dex,
        uint32 _const,
        uint32 _int,
        uint32 _wis,
        uint32 _cha
    ) external onlyWandererOwner(summoner) {
        gs.rarity_attributes.point_buy(
            summoner,
            _str,
            _dex,
            _const,
            _int,
            _wis,
            _cha
        );
    }

    function proxy_summoner_increase_strength(uint256 summoner)
        external
        onlyWandererOwner(summoner)
    {
        gs.rarity_attributes.increase_strength(summoner);
    }

    function proxy_summoner_increase_dexterity(uint256 summoner)
        external
        onlyWandererOwner(summoner)
    {
        gs.rarity_attributes.increase_dexterity(summoner);
    }

    function proxy_summoner_increase_constitution(uint256 summoner)
        external
        onlyWandererOwner(summoner)
    {
        gs.rarity_attributes.increase_constitution(summoner);
    }

    function proxy_summoner_increase_intelligence(uint256 summoner)
        external
        onlyWandererOwner(summoner)
    {
        gs.rarity_attributes.increase_intelligence(summoner);
    }

    function proxy_summoner_increase_wisdom(uint256 summoner)
        external
        onlyWandererOwner(summoner)
    {
        gs.rarity_attributes.increase_wisdom(summoner);
    }

    function proxy_summoner_increase_charisma(uint256 summoner)
        external
        onlyWandererOwner(summoner)
    {
        gs.rarity_attributes.increase_charisma(summoner);
    }

    function _level_up(uint256 summoner) internal {
        if (
            gs.rarity.xp(summoner) >=
            gs.rarity.xp_required(gs.rarity.level(summoner))
        ) {
            gs.rarity.level_up(summoner);
            gs.rarity_gold.claim(summoner);
        }
    }

    // *************
    // Skills
    // *************

    function proxy_set_skills(uint256 _summoner, uint8[36] memory _skills)
        external
        onlyWandererOwner(_summoner)
    {
        gs.rarity_skills.set_skills(_summoner, _skills);
    }

    // *************
    // Crafting
    // *************

    function proxy_craft(
        uint256 _summoner,
        uint8 _base_type,
        uint8 _item_type,
        uint256 _crafting_materials
    ) external onlyWandererOwner(_summoner) {
        gs.rarity_crafting.craft(
            _summoner,
            _base_type,
            _item_type,
            _crafting_materials
        );
    }
}
