// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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
