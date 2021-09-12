// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./members.sol";

abstract contract GuildBatch is GuildMembers {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    // *************
    // Batch Actions
    // *************
    function _do_dungeons(uint256 summoner) internal {
        for (uint256 i = 0; i < gs_dungeons_list.length(); i++) {
            IDungeon dungeon = gs_dungeons[gs_dungeons_list.at(i)];
            if (
                block.timestamp > dungeon.adventurers_log(summoner) &&
                dungeon.scout(summoner) > 0
            ) {
                dungeon.adventure(summoner);
            }
        }
    }

    function batch_send_out() external {
        for (uint256 i = 0; i < gs_summoners.length(); i++) {
            uint256 summoner = gs_summoners.at(i);

            if (block.timestamp > gs.rarity.adventurers_log(summoner)) {
                gs.rarity.adventure(summoner);
                _level_up(summoner);
            }
            _do_dungeons(summoner);
        }

        // Only GM can set out next_excursion time.
        if (
            gs.rarity.ownerOf(gs.guild_master) == _msgSender() ||
            gs_summoners_owners[gs.guild_master] == _msgSender()
        ) {
            gs.next_excursion = block.timestamp + 1 days;
        }
    }
}
