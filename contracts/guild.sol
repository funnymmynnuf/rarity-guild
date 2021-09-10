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

    function summoner(uint256 _summoner)
        external
        view
        returns (
            uint256 _xp,
            uint256 _log,
            uint256 _class,
            uint256 _level
        );
}

contract Guild is Ownable {
    IRarity public rarity;
    IRarityGold public rarity_gold;
    IRarityAttributes public rarity_attributes;

    string public guild_name;
    string public guild_logo;
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

    modifier onlyWandererOwner(uint256 wanderer) {
        require(
            _original_owner[wanderer] == _msgSender(),
            "Caller is not the guild master."
        );
        _;
    }

    constructor(
        address rarity_address,
        address gold_address,
        address attributes_address,
        uint256 _guild_master
    ) {
        rarity = IRarity(rarity_address);
        rarity_gold = IRarityGold(gold_address);
        rarity_attributes = IRarityAttributes(attributes_address);

        rarity.setApprovalForAll(_msgSender(), true);

        guild_master = _guild_master;
        tribute = 0;
        guild_name = "Guild";
        guild_logo = "";
    }

    // *************
    // Guild Management
    // *************
    function set_guild_master(uint256 new_guild_master) external onlyGM {
        rarity.summoner(new_guild_master);
        guild_master = new_guild_master;
    }

    function set_tribute(uint256 new_tribute) external onlyGM {
        tribute = new_tribute;
    }

    function set_name(uint256 new_name) external onlyGM {
        tribute = new_name;
    }

    function set_logo(string memory new_logo) external onlyGM {
        guild_logo = new_logo;
    }

    function add_dungeon(address dungeon) external onlyGM {
        dungeons[dungeon] = IDungeon(dungeon);
        dungeons_list.add(dungeon);
    }

    function remove_dungeon(address dungeon) external onlyGM {
        delete dungeons[dungeon];
        dungeons_list.remove(dungeon);
    }

    function has_dungeon(address dungeon) external view returns (bool has) {
        return dungeons_list.contains(dungeon);
    }

    function withdraw_tributes() external onlyGM {
        (bool success, ) = _msgSender().call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function guild_funds() external view returns (uint256 balance) {
        for (uint256 i = 0; i < guild.length(); i++) {
            if (guild.at(i) == guild_master) {
                return _original_owner[guild_master].balance;
            }
        }
    }

    function donate(address member) external payable {}

    // *************
    // Bulk Actions
    // *************
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

    // *************
    // Member Area
    // *************
    function view_wanderers(address wanderer_owner)
        external
        view
        returns (uint256[] memory wanderers)
    {
        uint256[] memory _wanderers = new uint256[](guild.length());
        for (uint256 i = 0; i < guild.length(); i++) {
            if (_original_owner[guild.at(i)] == wanderer_owner) {
                _wanderers[i] = guild.at(i);
            }
        }
        return _wanderers;
    }

    function add_wanderers(uint256[] memory wanderers) external payable {
        require(msg.value >= tribute, "Minimum tribute was not reached.");

        for (uint256 i = 0; i < wanderers.length; i++) {
            rarity.transferFrom(_msgSender(), address(this), wanderers[i]);
            _original_owner[wanderers[i]] = _msgSender();
            guild.add(wanderers[i]);
        }
    }

    function withdraw_wanderers(uint256[] memory wanderers) external {
        for (uint256 i = 0; i < wanderers.length; i++) {
            if (
                guild.contains(wanderers[i]) &&
                _original_owner[wanderers[i]] == _msgSender()
            ) {
                delete _original_owner[wanderers[i]];
                guild.remove(wanderers[i]);
                rarity.transferFrom(address(this), _msgSender(), wanderers[i]);
            }
        }
    }

    // *************
    // Individual Wanderer Interaction // Wanderer Proxy
    // *************

    function wanderer_transfer_ownership(uint256 wanderer, address new_owner)
        external
        onlyWandererOwner(wanderer)
    {
        _original_owner[wanderer] = new_owner;
    }

    function wanderer_level_up(uint256 wanderer)
        external
        onlyWandererOwner(wanderer)
    {
        _level_up(wanderer);
    }

    function wanderer_claim(uint256 wanderer)
        external
        onlyWandererOwner(wanderer)
    {
        rarity_gold.claim(wanderer);
    }

    function wanderer_adventure(uint256 wanderer)
        external
        onlyWandererOwner(wanderer)
    {
        if (block.timestamp > rarity.adventurers_log(wanderer)) {
            rarity.adventure(wanderer);
            _level_up(wanderer);
        }
    }

    function wanderer_go_dungeon(uint256 wanderer, address dungeon)
        external
        onlyWandererOwner(wanderer)
    {
        IDungeon idungeon;

        if (dungeons_list.contains(dungeon)) {
            idungeon = dungeons[dungeon];
        } else {
            idungeon = IDungeon(dungeon);
        }

        if (
            block.timestamp > idungeon.adventurers_log(wanderer) &&
            idungeon.scout(wanderer) > 0
        ) {
            idungeon.adventure(wanderer);
        }
    }

    function wanderer_point_buy(
        uint256 wanderer,
        uint32 _str,
        uint32 _dex,
        uint32 _const,
        uint32 _int,
        uint32 _wis,
        uint32 _cha
    ) external onlyWandererOwner(wanderer) {
        rarity_attributes.point_buy(
            wanderer,
            _str,
            _dex,
            _const,
            _int,
            _wis,
            _cha
        );
    }

    function wanderer_increase_strength(uint256 wanderer)
        external
        onlyWandererOwner(wanderer)
    {
        rarity_attributes.increase_strength(wanderer);
    }

    function wanderer_increase_dexterity(uint256 wanderer)
        external
        onlyWandererOwner(wanderer)
    {
        rarity_attributes.increase_dexterity(wanderer);
    }

    function wanderer_increase_constitution(uint256 wanderer)
        external
        onlyWandererOwner(wanderer)
    {
        rarity_attributes.increase_constitution(wanderer);
    }

    function wanderer_increase_intelligence(uint256 wanderer)
        external
        onlyWandererOwner(wanderer)
    {
        rarity_attributes.increase_intelligence(wanderer);
    }

    function wanderer_increase_wisdom(uint256 wanderer)
        external
        onlyWandererOwner(wanderer)
    {
        rarity_attributes.increase_wisdom(wanderer);
    }

    function wanderer_increase_charisma(uint256 wanderer)
        external
        onlyWandererOwner(wanderer)
    {
        rarity_attributes.increase_charisma(wanderer);
    }
}
