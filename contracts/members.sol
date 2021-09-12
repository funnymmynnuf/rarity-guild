// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./proxy.sol";

abstract contract GuildMembers is GuildProxy {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    // *************
    // Member Area
    // *************
    function member_view_summoners(address summoner_owner)
        external
        view
        returns (uint256[] memory summoners)
    {
        uint256 num_summoners = 0;
        for (uint256 i = 0; i < gs_summoners.length(); i++) {
            if (gs_summoners_owners[gs_summoners.at(i)] == summoner_owner) {
                num_summoners++;
            }
        }

        uint256[] memory _summoners = new uint256[](num_summoners);
        for (uint256 i = 0; i < gs_summoners.length(); i++) {
            if (gs_summoners_owners[gs_summoners.at(i)] == summoner_owner) {
                _summoners[i] = gs_summoners.at(i);
            }
        }
        return _summoners;
    }

    function member_add_summoners(uint256[] memory summoners) external payable {
        require(msg.value >= gs.tribute, "Minimum tribute was not reached.");
        require(summoners.length + gs_summoners.length() <= gs.max_summoners);

        for (uint256 i = 0; i < summoners.length; i++) {
            gs.rarity.transferFrom(_msgSender(), address(this), summoners[i]);
            gs_summoners_owners[summoners[i]] = _msgSender();
            gs_summoners.add(summoners[i]);
        }
    }

    function member_withdraw_summoners(uint256[] memory summoners) external {
        for (uint256 i = 0; i < summoners.length; i++) {
            if (
                gs_summoners.contains(summoners[i]) &&
                gs_summoners_owners[summoners[i]] == _msgSender()
            ) {
                delete gs_summoners_owners[summoners[i]];
                gs_summoners.remove(summoners[i]);
                gs.rarity.transferFrom(
                    address(this),
                    _msgSender(),
                    summoners[i]
                );
            }
        }
    }
}
