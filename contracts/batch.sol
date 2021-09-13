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
        uint256[] memory to_idle = new uint256[](gs_summoners.length());
        uint256 num_idle = 0;

        for (uint256 i = 0; i < gs_summoners.length(); i++) {
            uint256 summoner = gs_summoners.at(i);

            // What if the tribute changed
            if (gs_summoners_balances[summoner] < gs.tribute) {
                to_idle[i] = summoner;
                num_idle++;
                continue;
            }

            gs_summoners_balances[summoner] -= gs.tribute;

            if (gs_summoners_balances[summoner] < gs.tribute) {
                to_idle[i] = summoner;
                num_idle++;
            }

            if (block.timestamp > gs.rarity.adventurers_log(summoner)) {
                gs.rarity.adventure(summoner);
                _level_up(summoner);
            }
            _do_dungeons(summoner);
        }

        for (uint256 i = 0; i < num_idle; i++) {
            gs_summoners.remove(to_idle[i]);
            gs_idle_summoners.add(to_idle[i]);
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
