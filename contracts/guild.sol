// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "./batch.sol";

contract GuildBase is GuildBatch {
    constructor(
        address rarity_address,
        address gold_address,
        address attributes_address,
        uint256 guild_master,
        uint256 max_summoners
    ) {
        IRarity rarity = IRarity(rarity_address);
        IRarityGold rarity_gold = IRarityGold(gold_address);
        IRarityAttributes rarity_attributes = IRarityAttributes(
            attributes_address
        );
        string memory logo = "url";
        string memory name = "Guild";
        string memory guild_type = "Base";
        uint256 tribute = 0;
        uint256 next_excursion = 1631211660;

        gs = GuildSettings(
            rarity,
            rarity_gold,
            rarity_attributes,
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
