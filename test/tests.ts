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
  let hardhatAttributes;

  let fighter_class = 5;

  beforeEach(async function () {
    accounts = await ethers.getSigners();

    [owner, addr1, guild_master] = await ethers.getSigners();
    const rarity = await ethers.getContractFactory("Rarity");
    hardhatRarity = await rarity.deploy();

    const gold = await ethers.getContractFactory("RarityGold");
    hardhatRarityGold = await gold.deploy(hardhatRarity.address);

    const attributes = await ethers.getContractFactory("rarity_attributes");
    hardhatAttributes = await attributes.deploy(hardhatRarity.address);

    const dungeon1 = await ethers.getContractFactory("rarity_crafting_materials");
    hardhatDungeon1 = await dungeon1.deploy(hardhatRarity.address, hardhatAttributes.address);

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
    const guild = await ethers.getContractFactory("Guild");
    hardhatGuild = await guild.deploy(hardhatRarity.address, hardhatRarityGold.address, guild_master_id);
    await hardhatRarity.connect(addr1).setApprovalForAll(hardhatGuild.address, true);

  });

  it("should be able to add summoners to guild.", async function () {
    let res = await hardhatGuild.connect(addr1).add_wanderers(addr1_summoners);
    assert(addr1_summoners.length == await hardhatRarity.balanceOf(hardhatGuild.address));
    assert(0 == await hardhatRarity.balanceOf(addr1.address));

    for (var summoner in addr1_summoners) {
      owner = await hardhatRarity.ownerOf(summoner);
      assert(owner == hardhatGuild.address);
    }

    // Make sure we save the info of which wanderers belong to addr1
    let summs = await hardhatGuild.view_wanderers(addr1.address);
    for (var i = 0; i < addr1_summoners.length; i++) {
      expect(addr1_summoners[i]).equal(summs[i]);
    }

  });

  it("should be able to withdraw summoners from the guild, only by the original owner.", async function () {

    await hardhatGuild.connect(addr1).add_wanderers(addr1_summoners);
    assert(addr1_summoners.length == await hardhatRarity.balanceOf(hardhatGuild.address));

    // Try to withdraw with another address
    await hardhatGuild.connect(guild_master).withdraw_wanderers(addr1_summoners);
    assert(addr1_summoners.length == await hardhatRarity.balanceOf(hardhatGuild.address));
    assert(1 == await hardhatRarity.balanceOf(guild_master.address));
    assert(0 == await hardhatRarity.balanceOf(addr1.address));

    // Withdraw with original addr1
    let res = await hardhatGuild.connect(addr1).withdraw_wanderers(addr1_summoners);
    assert(0 == await hardhatRarity.balanceOf(hardhatGuild.address));
    assert(addr1_summoners.length == await hardhatRarity.balanceOf(addr1.address));

    for (var summoner in addr1_summoners) {
      owner = await hardhatRarity.ownerOf(summoner);
      assert(owner == addr1.address);
    }

  });

  it("should be able to add summoners only with tribute.", async function () {
    let tribute = ethers.utils.parseEther("0.1");
    await hardhatGuild.connect(guild_master).set_tribute(tribute);
    expect(await hardhatGuild.tribute()).to.equal(tribute);

    await expectRevert.unspecified(hardhatGuild.connect(addr1).add_wanderers(addr1_summoners));

    await hardhatGuild.connect(addr1).add_wanderers(addr1_summoners, {
      value: ethers.utils.parseEther("0.1")
    });

    expect(await ethers.provider.getBalance(hardhatGuild.address)).to.equal(tribute);

  });

  it("should be able to send out summoners on adventures and dungeons, while leveling up and claiming rewards.", async function () {

    // Set dungeons
    await hardhatGuild.connect(guild_master).add_dungeon(hardhatDungeon1.address);

    // Fill guild
    await hardhatGuild.connect(addr1).add_wanderers(addr1_summoners);

    // Send out until level up
    // Rarity and Dungeon contracts changed to have no adventure limit.
    for (var i = 0; i < 5; i++) {
      await hardhatGuild.connect(guild_master).send_out();
    }

    // Check for xp and crafts
    for (var summoner in addr1_summoners) {
      let [_xp, _log, _class, _level] = await hardhatRarity.summoner(summoner);
      let gold = await hardhatRarityGold.balanceOf(summoner);
      let craft1 = await hardhatDungeon1.balanceOf(summoner);

      // Rarity Rewards
      assert(_xp == 250e18);
      assert(_level == 2);

      // Rarity Gold Rewards
      assert(gold == 1000e18);

      if (_class == fighter_class) { // Fighter
        // Dungeon/Craft 1
        assert(craft1 == 35);
      } else {
        assert(craft1 == 0);
      }

    }

  });

  it("should be able to transfer guild ownership.", async function () {
    await expectRevert.unspecified(hardhatGuild.connect(addr1).set_guild_master(addr1_summoners[1]));

    await hardhatGuild.connect(guild_master).set_guild_master(addr1_summoners[0]);
    await hardhatGuild.connect(addr1).set_tribute(1);

    await expectRevert.unspecified(hardhatGuild.connect(guild_master).set_guild_master(addr1_summoners[1]));
    await expectRevert.unspecified(hardhatGuild.connect(guild_master).set_tribute(1));

  });

});