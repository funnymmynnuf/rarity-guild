// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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
