# Rarity Guild

Guild for automating adventures and dungeons, while getting the rewards onto the summoner.

## Goal
The goal of a `Guild` is to help summoners/summoners to automate the tasks that can be automated, while still giving access to the specific summoner. Since this automation still has to be actively maintained (cronjob, etc), we have a `Guild Master`.

* Guild Management
    * Guild Master
* Bulk Actions
* Individual Summoner Management  


## Guild Management
 The `Guild Master` title is linked to a summoner ID. **And it can be different than the contract owner**, and can be passed upon other summoner

The role of the `Guild Master` is to make sure that all daily tasks are properly scheduled (cronjob etc.). Since bulk actions cost significant gas, there is a concept of tribute (on joining the guild, or donations).

[Guild Management](./contracts/settings.sol)
## Batch Actions

For now the only batch action is `batch_send_out()`. It loops over every guild member and:
* Goes on a `Rarity` adventure, if the cooldown allows it.
* Levels up and claims gold if possible.
* Goes through every dungeon (which follows the `scout` & `adventure` interface) added by the `Guild Master`.

Suggestion is to run it once a day. Eventually all summoners will have the same cooldown across adventures.

[Guild Batch](./contracts/batch.sol)

## Individual Summoner Management

The `Guild` contract owns the ERC721 summoner, but exposes an interface (Rarity, RarityGold, RarityAttributes) to interact individually with each summoner if so required. Such interaction is only possible if you were the original owner of the summoner or if you transfered it from inside the guild. 

[Guild Proxy](./contracts/proxy.sol)
[Guild Members](./contracts/members.sol)


## Tests
The `Rarity`, `RarityGold`, `RarityAttributes` and `Craft (I)` contracts are locally deployed with certain changes to their code to ease testing:
* `Rarity` adventure cooldown is 0.
* `Rarity` XP gain is changed to 250e21