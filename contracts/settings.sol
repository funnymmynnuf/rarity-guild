// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interfaces.sol";

struct GuildSettings {
    IRarity rarity;
    IRarityGold rarity_gold;
    IRarityAttributes rarity_attributes;
    uint256 guild_master;
    uint256 tribute;
    uint256 next_excursion;
    uint256 max_summoners;
    string logo;
    string name;
    string guild_type;
}

abstract contract GuildManagement is Ownable {
    GuildSettings public gs;

    mapping(address => IDungeon) gs_dungeons;
    mapping(uint256 => address) gs_summoners_owners;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet gs_dungeons_list;

    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet gs_summoners;

    modifier onlyGM() {
        require(
            gs.rarity.ownerOf(gs.guild_master) == _msgSender() ||
                gs_summoners_owners[gs.guild_master] == _msgSender(),
            "Caller is not the guild master."
        );
        _;
    }

    modifier onlyWandererOwner(uint256 summoner) {
        require(
            gs_summoners_owners[summoner] == _msgSender(),
            "Caller is not the original owner."
        );
        _;
    }

    // *************
    // Contracts
    // *************

    function gm_set_rarity_address(address addr) external onlyGM {
        gs.rarity = IRarity(addr);
    }

    function gm_set_rarity_gold_address(address addr) external onlyGM {
        gs.rarity_gold = IRarityGold(addr);
    }

    function gm_set_rarity_attributes_address(address addr) external onlyGM {
        gs.rarity_attributes = IRarityAttributes(addr);
    }

    // *************
    // Metadata
    // *************

    function gm_set_name(string memory new_name) external onlyGM {
        gs.name = new_name;
    }

    function gm_set_logo(string memory new_logo) external onlyGM {
        gs.logo = new_logo;
    }

    // *************
    // Guild Management
    // *************

    function gm_set_guild_master(uint256 new_guild_master) external onlyGM {
        gs.rarity.summoner(new_guild_master);
        gs.guild_master = new_guild_master;
    }

    function gm_set_tribute(uint256 new_tribute) external onlyGM {
        gs.tribute = new_tribute;
    }

    function gm_set_max_summoners(uint256 new_max_summoners) external onlyGM {
        gs.max_summoners = new_max_summoners;
    }

    function gm_has_dungeon(address dungeon) external view returns (bool has) {
        return gs_dungeons_list.contains(dungeon);
    }

    function gm_get_dungeons()
        external
        view
        returns (address[] memory _dungeons)
    {
        address[] memory rdungeons = new address[](gs_dungeons_list.length());

        for (uint256 i = 0; i < gs_dungeons_list.length(); i++) {
            rdungeons[i] = gs_dungeons_list.at(i);
        }

        return rdungeons;
    }

    function gm_add_dungeons(address[] calldata _dungeons) external onlyGM {
        for (uint256 i = 0; i < _dungeons.length; i++) {
            gs_dungeons[_dungeons[i]] = IDungeon(_dungeons[i]);
            gs_dungeons_list.add(_dungeons[i]);
        }
    }

    function gm_remove_dungeons(address[] calldata _dungeons) external onlyGM {
        for (uint256 i = 0; i < _dungeons.length; i++) {
            delete gs_dungeons[_dungeons[i]];
            gs_dungeons_list.remove(_dungeons[i]);
        }
    }

    function gm_withdraw_tributes() external onlyGM {
        (bool success, ) = _msgSender().call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    // function donate() external payable {}
}
