import { ethers } from "hardhat";
import { Signer } from "ethers";
import { expect, assert } from "chai";
import { expectRevert } from "@openzeppelin/test-helpers";


describe("Guild", function () {
  let accounts: Signer[];

  let Token;
  let hardhatGuild;
  let hardhatRarity;
  let hardhatRarityGold;
  let addr1;
  let addr1_summoners;
  let guild_master;
  let guild_master_id;
  let guild_master_summoners;
  let owner;
  let hardhatDungeon1;
  let hardhatDungeon1repeat;
  let hardhatAttributes;
  let random_owner;


  let fighter_class = 5;
  let fighter;

  beforeEach(async function () {
    accounts = await ethers.getSigners();

    [owner, addr1, guild_master, random_owner] = await ethers.getSigners();
    const rarity = await ethers.getContractFactory("Rarity");
    hardhatRarity = await rarity.deploy();

    const gold = await ethers.getContractFactory("RarityGold");
    hardhatRarityGold = await gold.deploy(hardhatRarity.address);

    const attributes = await ethers.getContractFactory("rarity_attributes");
    hardhatAttributes = await attributes.deploy(hardhatRarity.address);

    const dungeon1 = await ethers.getContractFactory("rarity_crafting_materials");
    hardhatDungeon1 = await dungeon1.deploy(hardhatRarity.address, hardhatAttributes.address);
    hardhatDungeon1repeat = await dungeon1.deploy(hardhatRarity.address, hardhatAttributes.address);

    // Summon for addr1
    addr1_summoners = [];
    for (var _class = 1; _class < 12; _class++) {
      let res = await hardhatRarity.connect(addr1).summon(_class);
      res = await res.wait();

      for (var i = 0; i < res.events.length; i++) {
        var event = res.events[i];
        if (event.event == "summoned") {
          let summoner = event.args.summoner;
          addr1_summoners.push(summoner);

          // Set attributes for fighter
          if (_class == fighter_class) {

            // _str, _dex, _const, _int, _wis, _cha
            hardhatAttributes.connect(addr1).point_buy(summoner, 17, 14, 17, 8, 8, 8);
          }

        }
      }


    }

    // Summon for guild master
    let res = await hardhatRarity.connect(guild_master).summon(1);
    res = await res.wait();
    guild_master_id = res.events[1].args.summoner;

    // Start Guild
    let max_summoners = 10000;
    const guild = await ethers.getContractFactory("GuildBase");
    hardhatGuild = await guild.deploy(hardhatRarity.address, hardhatRarityGold.address, hardhatAttributes.address, guild_master_id, max_summoners, []);
    await hardhatRarity.connect(addr1).setApprovalForAll(hardhatGuild.address, true);

  });

  it("should be able to change the guild settings.", async function () {
    let name = "nono";
    let logo = "url";
    let new_rarity_address = "0xc0068e301df7a4C3487012fB5e422ECeFF61095f";
    let new_rarity_gold_address = "0xc9B313ca531505bd4c558999Aa507E342B4dE4e0";
    let new_rarity_attributes_address = "0x5A682dD1446488948b473388F52F9328e7955D3D";
    let new_guild_tribute = 13377;
    let new_dungeons = ["0x54ca59aeD28c1c103acf25bf49a7A64beF095BE1", "0x34f80aa8Ae38f2453CB94Bb4396DFD09fC053100"]

    await hardhatGuild.connect(guild_master).gm_set_rarity_gold_address(new_rarity_gold_address);
    assert(new_rarity_gold_address == (await hardhatGuild.connect(guild_master).gs()).rarity_gold);

    await hardhatGuild.connect(guild_master).gm_set_rarity_attributes_address(new_rarity_attributes_address);
    assert(new_rarity_attributes_address == (await hardhatGuild.connect(guild_master).gs()).rarity_attributes);

    await hardhatGuild.connect(guild_master).gm_set_name(name);
    assert(name == (await hardhatGuild.connect(guild_master).gs()).name);

    await hardhatGuild.connect(guild_master).gm_set_logo(logo);
    assert(logo == (await hardhatGuild.connect(guild_master).gs()).logo);

    await hardhatGuild.connect(guild_master).gm_set_tribute(new_guild_tribute);
    assert(new_guild_tribute == (await hardhatGuild.connect(guild_master).gs()).tribute);

    await hardhatGuild.connect(guild_master).gm_add_dungeons(new_dungeons);
    assert(true == await hardhatGuild.connect(guild_master).gm_has_dungeon(new_dungeons[0]));
    let saved_dungeons = await hardhatGuild.connect(guild_master).gm_get_dungeons();
    assert(new_dungeons[0] == saved_dungeons[0]);
    assert(new_dungeons[1] == saved_dungeons[1]);
    assert(true == await hardhatGuild.connect(guild_master).gm_has_dungeon(new_dungeons[0]));

    await hardhatGuild.connect(guild_master).gm_remove_dungeons(new_dungeons);
    // console.log("DUNGE");
    // console.log(await hardhatGuild.connect(guild_master).gm_get_dungeons().size);
    // console.log(await hardhatGuild.connect(guild_master).gm_get_dungeons().length);
    // assert([].join("") === await hardhatGuild.connect(guild_master).gm_get_dungeons().join(""));

    await hardhatGuild.connect(guild_master).gm_set_guild_master(addr1_summoners[0]);
    expect(addr1_summoners[0]).equal((await hardhatGuild.connect(addr1).gs()).guild_master);

    await hardhatGuild.connect(addr1).gm_set_rarity_address(new_rarity_address);
    assert(new_rarity_address == (await hardhatGuild.connect(addr1).gs()).rarity);

    // // TODO get fee to subtract
    // let contract_balance = ethers.provider.getBalance(hardhatGuild.address);
    // let prev_guild_master_balance = ethers.provider.getBalance(guild_master.address);
    // await hardhatGuild.connect(guild_master).gm_withdraw_tributes();
    // let curr_guild_master_balance = ethers.provider.getBalance(guild_master.address);
    // // assert(curr_guild_master_balance == prev_guild_master_balance + contract_balance - FEE);

  });

  it("should be able to add summoners to guild.", async function () {
    let res = await hardhatGuild.connect(addr1).member_add_summoners(addr1_summoners);
    assert(addr1_summoners.length == await hardhatRarity.balanceOf(hardhatGuild.address));
    assert(0 == await hardhatRarity.balanceOf(addr1.address));

    for (var summoner in addr1_summoners) {
      owner = await hardhatRarity.ownerOf(summoner);
      assert(owner == hardhatGuild.address);
    }

    // Make sure we save the info of which summoners belong to addr1
    let summs = await hardhatGuild.member_view_summoners(addr1.address);
    for (var i = 0; i < addr1_summoners.length; i++) {
      expect(addr1_summoners[i]).equal(summs[i]);
    }
  });

  it("should be able to withdraw summoners from the guild, only by the original owner.", async function () {

    await hardhatGuild.connect(addr1).member_add_summoners(addr1_summoners);
    assert(addr1_summoners.length == await hardhatRarity.balanceOf(hardhatGuild.address));

    // Try to withdraw with another address
    await hardhatGuild.connect(guild_master).member_withdraw_summoners(addr1_summoners);
    assert(addr1_summoners.length == await hardhatRarity.balanceOf(hardhatGuild.address));
    assert(1 == await hardhatRarity.balanceOf(guild_master.address));
    assert(0 == await hardhatRarity.balanceOf(addr1.address));

    // Withdraw with original addr1
    let res = await hardhatGuild.connect(addr1).member_withdraw_summoners(addr1_summoners);
    assert(0 == await hardhatRarity.balanceOf(hardhatGuild.address));
    assert(addr1_summoners.length == await hardhatRarity.balanceOf(addr1.address));

    for (var summoner in addr1_summoners) {
      owner = await hardhatRarity.ownerOf(summoner);
      assert(owner == addr1.address);
    }

  });

  it("should be able to add summoners only with enough tribute per summoner for 1 run.", async function () {
    let tribute_per_summoner = ethers.utils.parseEther("0.1");
    let total_tribute = ethers.utils.parseEther("1.1");

    await hardhatGuild.connect(guild_master).gm_set_tribute(tribute_per_summoner);
    expect((await hardhatGuild.gs()).tribute).equal(tribute_per_summoner);

    await expectRevert.unspecified(hardhatGuild.connect(addr1).member_add_summoners(addr1_summoners));

    await hardhatGuild.connect(addr1).member_add_summoners(addr1_summoners, {
      value: total_tribute
    });

    expect(await ethers.provider.getBalance(hardhatGuild.address)).to.equal(total_tribute);


    let balances = await hardhatGuild.connect(addr1).member_view_summoners_balances(addr1_summoners);
    for (var i in balances) {
      expect(balances[i]).equal(tribute_per_summoner);
    }

    await hardhatGuild.connect(addr1).batch_send_out();
    assert(0 == await hardhatGuild.connect(guild_master).gm_get_active_summoner_count())
    assert(11 == await hardhatGuild.connect(guild_master).gm_get_idle_summoner_count())

    await hardhatGuild.connect(addr1).member_fund_summoners(addr1_summoners, {
      value: total_tribute
    });
    assert(11 == await hardhatGuild.connect(guild_master).gm_get_active_summoner_count())
    assert(0 == await hardhatGuild.connect(guild_master).gm_get_idle_summoner_count())

  });

  it("should be able to send out summoners on adventures and dungeons, while leveling up and claiming rewards.", async function () {

    // Set dungeons
    await hardhatGuild.connect(guild_master).gm_add_dungeons([hardhatDungeon1.address]);

    // Fill guild
    await hardhatGuild.connect(addr1).member_add_summoners(addr1_summoners);

    // Send out until level up
    // Rarity and Dungeon contracts changed to have no adventure limit.
    for (var i = 0; i < 5; i++) {
      await hardhatGuild.connect(guild_master).batch_send_out();
    }

    // Check for xp and crafts
    for (var summoner in addr1_summoners) {
      let [_xp, _log, _class, _level] = await hardhatRarity.summoner(summoner);
      let gold = await hardhatRarityGold.balanceOf(summoner);
      let craft1 = await hardhatDungeon1.balanceOf(summoner);

      // Rarity Rewards
      assert(_xp == 1215e21);
      assert(_level == 6);

      // Rarity Gold Rewards
      assert(gold == 35e21);

      if (_class == fighter_class) { // Fighter
        // Dungeon/Craft 1
        assert(craft1 == 35);
      } else {
        assert(craft1 == 0);
      }

    }

  });

  it("should be able to transfer guild ownership.", async function () {
    await expectRevert.unspecified(hardhatGuild.connect(addr1).gm_set_guild_master(addr1_summoners[1]));

    await hardhatGuild.connect(guild_master).gm_set_guild_master(addr1_summoners[0]);
    await hardhatGuild.connect(addr1).gm_set_tribute(1);

    await expectRevert.unspecified(hardhatGuild.connect(guild_master).gm_set_guild_master(addr1_summoners[1]));
    await expectRevert.unspecified(hardhatGuild.connect(guild_master).gm_set_tribute(1));

  });

  it("should be able manage one summoner through the guild proxy interface.", async function () {

    await hardhatGuild.connect(guild_master).gm_add_dungeons([hardhatDungeon1.address]);
    await hardhatGuild.connect(addr1).member_add_summoners(addr1_summoners);
    let summoner = addr1_summoners[0];

    // Transfer
    await hardhatGuild.connect(addr1).proxy_summoner_transfer_ownership(summoner, random_owner.address);
    await expectRevert.unspecified(hardhatGuild.connect(addr1).proxy_summoner_adventure(summoner));
    await hardhatGuild.connect(random_owner).proxy_summoner_adventure(summoner);

    // Attributes Point-Buy
    let res = await hardhatRarity.connect(random_owner).summon(fighter_class);
    res = await res.wait();
    summoner = res.events[1].args.summoner;

    await hardhatRarity.connect(random_owner).setApprovalForAll(hardhatGuild.address, true);
    await hardhatGuild.connect(random_owner).member_add_summoners([summoner]);
    await hardhatGuild.connect(random_owner).proxy_summoner_point_buy(summoner, 17, 14, 17, 8, 8, 8);

    // Adventure + level + gold
    let [_xp, _log, _class, _level] = await hardhatRarity.summoner(summoner);
    let gold = await hardhatRarityGold.balanceOf(summoner);

    for (var i = 0; i < 50; i++) {
      await hardhatGuild.connect(random_owner).proxy_summoner_adventure(summoner);
    }

    let [, , , _cur_level] = await hardhatRarity.summoner(summoner);
    let _cur_gold = await hardhatRarityGold.balanceOf(summoner);

    expect(_cur_level).is.gt(_level);
    expect(_cur_gold).is.gt(gold);

    // Dungeons
    assert(true == await hardhatGuild.connect(random_owner).gm_has_dungeon(hardhatDungeon1.address));
    await hardhatGuild.connect(random_owner).proxy_summoner_go_dungeon(summoner, hardhatDungeon1.address);
    await hardhatGuild.connect(random_owner).proxy_summoner_go_dungeon(summoner, hardhatDungeon1repeat.address);


    // Attributes Point-Buy
    await hardhatGuild.connect(random_owner).proxy_summoner_increase_strength(summoner);
    await hardhatGuild.connect(random_owner).proxy_summoner_increase_dexterity(summoner);
    await hardhatGuild.connect(random_owner).proxy_summoner_increase_constitution(summoner);
    await hardhatGuild.connect(random_owner).proxy_summoner_increase_intelligence(summoner);
    await hardhatGuild.connect(random_owner).proxy_summoner_increase_wisdom(summoner);
    await hardhatGuild.connect(random_owner).proxy_summoner_increase_charisma(summoner);

  });

  it("should limit the number of summoners to a defined max.", async function () {

    await hardhatGuild.connect(guild_master).gm_set_max_summoners(0);
    assert(0 == (await hardhatGuild.connect(guild_master).gs()).max_summoners);

    await expectRevert.unspecified(hardhatGuild.connect(addr1).member_add_summoners(addr1_summoners));

    await hardhatGuild.connect(guild_master).gm_set_max_summoners(addr1_summoners.length);
    await hardhatGuild.connect(addr1).member_add_summoners(addr1_summoners);

  });
});
