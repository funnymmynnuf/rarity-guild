// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IDungeon {
    function scout(uint256) external view returns (uint256 reward);

    function adventure(uint256) external returns (uint256 reward);

    function adventurers_log(uint256) external returns (uint256 ts);
}

interface IRarityGold {
    function claim(uint256 summoner) external;

    function claimable(uint256 summoner) external view returns (uint256 amount);
}

interface IRarity {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function setApprovalForAll(address operator, bool _approved) external;

    function xp_required(uint256 curent_level)
        external
        pure
        returns (uint256 xp_to_next_level);

    function level_up(uint256 _summoner) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function adventure(uint256 _summoner) external;

    function xp(uint256) external returns (uint256 _xp);

    function adventurers_log(uint256) external returns (uint256 _ts);

    function level(uint256) external returns (uint256 _level);
}

contract Guild is Ownable {
    IRarity public rarity;
    IRarityGold public rarity_gold;

    string public guild_name;
    uint256 public guild_master;
    uint256 public tribute;

    mapping(address => IDungeon) dungeons;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet dungeons_list;

    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet guild;

    mapping(uint256 => address) private _original_owner;

    modifier onlyGM() {
        require(
            rarity.ownerOf(guild_master) == _msgSender(),
            "Caller is not the guild master."
        );
        _;
    }

    constructor(
        address rarity_address,
        address gold_address,
        uint256 _guild_master
    ) {
        rarity = IRarity(rarity_address);
        rarity_gold = IRarityGold(gold_address);

        rarity.setApprovalForAll(msg.sender, true);

        guild_master = _guild_master;
        tribute = 0;
        guild_name = "Guild";
    }

    function set_tribute(uint256 new_tribute) external onlyGM {
        tribute = new_tribute;
    }

    function set_name(uint256 new_name) external onlyGM {
        tribute = new_name;
    }

    function add_dungeon(address dungeon) external onlyGM {
        dungeons[dungeon] = IDungeon(dungeon);
        dungeons_list.add(dungeon);
    }

    function remove_dungeon(address dungeon) external onlyGM {
        delete dungeons[dungeon];
        dungeons_list.remove(dungeon);
    }

    function _do_dungeons(uint256 wanderer) internal {
        for (uint256 i = 0; i < dungeons_list.length(); i++) {
            IDungeon dungeon = dungeons[dungeons_list.at(i)];
            if (
                block.timestamp > dungeon.adventurers_log(wanderer) &&
                dungeon.scout(wanderer) > 0
            ) {
                dungeon.adventure(wanderer);
            }
        }
    }

    function _level_up(uint256 wanderer) internal {
        if (rarity.xp(wanderer) >= rarity.xp_required(rarity.level(wanderer))) {
            rarity.level_up(wanderer);
            rarity_gold.claim(wanderer);
        }
    }

    function send_out() external {
        for (uint256 i = 0; i < guild.length(); i++) {
            uint256 wanderer = guild.at(i);

            if (block.timestamp > rarity.adventurers_log(wanderer)) {
                rarity.adventure(wanderer);
                _level_up(wanderer);
            }
            _do_dungeons(wanderer);
        }
    }

    function add_wanderers(uint256[] memory wanderers) external payable {
        require(msg.value >= tribute, "Minimum tribute was not reached.");

        for (uint256 i = 0; i < wanderers.length; i++) {
            rarity.transferFrom(msg.sender, address(this), wanderers[i]);
            _original_owner[wanderers[i]] = msg.sender;
            guild.add(wanderers[i]);
        }
    }

    function withdraw_wanderers(uint256[] memory wanderers) external {
        for (uint256 i = 0; i < wanderers.length; i++) {
            if (
                guild.contains(wanderers[i]) &&
                _original_owner[wanderers[i]] == msg.sender
            ) {
                delete _original_owner[wanderers[i]];
                guild.remove(wanderers[i]);
                rarity.transferFrom(address(this), msg.sender, wanderers[i]);
            }
        }
    }

    function withdraw_tributes() external onlyGM {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
