# Rarity Guild

Guild for automating adventures and dungeons, while getting the rewards onto the summoner.

## Goal
The goal of a `Guild` is to help wanderers/summoners to automate the tasks that can be automated, while still giving access to the specific summoner. Since this automation still has to be actively maintained (cronjob, etc), we have a `Guild Master`.

* Guild Management
    * Guild Master
* Bulk Actions
* Individual Summoner Management  


## Guid Management
 The `Guild Master` title is linked to a summoner ID. **And it can be different than the contract owner**, and can be passed upon other summoner

The role of the `Guild Master` is to make sure that all daily tasks are properly scheduled (cronjob etc.). Since bulk actions cost significant gas, there is a concept of tribute (on joining the guild, or donations). Apart from that, a `Guild Master` can:

```
set_guild_master(...)
set_tribute(...) # default to 0. sets the price of adding new summoners to the guild
set_name(...)
set_logo(...)
add_dungeon(...)
remove_dungeon(...)
withdraw_tributes(...)
donate(...)
```
## Bulk Actions

For now the only bulk action is `send_out()`. It loops over every guild member and:
* Goes on a `Rarity` adventure, if the cooldown allows it.
* Levels up and claims gold if possible.
* Goes through every dungeon (which follows the `scout` & `adventure` interface) added by the `Guild Master`.

Suggestion is to run it once a day. Eventually all summoners will have the same cooldown across adventures.

## Individual Summoner Management

The `Guild` contract owns the ERC721 summoner, but exposes an interface to interact individually with each summoner if so required. Such interaction is only possible if you were the original owner of the summoner or if you transfered it from inside the guild.

```
wanderer_transfer_ownership(id) # happens inside the guild
wanderer_level_up(id)
wanderer_claim(id)
wanderer_adventure(id)
wanderer_go_dungeon(id, dungeon_address)
wanderer_point_buy(id)
wanderer_increase_strength(id)
(...)
wanderer_increase_charisma(id)
```


## Tests
The `Rarity`, `RarityGold`, `RarityAttributes` and `Craft (I)` contracts are locally deployed with certain changes to their code to ease testing:
* `Rarity` adventure cooldown is 0.
* `Rarity` XP gain is changed to 250e21