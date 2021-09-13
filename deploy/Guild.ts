module.exports = async ({
  getNamedAccounts,
  deployments,
  getChainId,
  getUnnamedAccounts,
}) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // the following will only deploy "GenericMetaTxProcessor" if the contract was never deployed or if the code changed since last deployment
  await deploy("GuildBase", {
    from: deployer,
    chainId: 250,
    // gas: 4000000,
    // Set your own guild master
    args: [
      "0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb", // rarity
      "0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2", // rarity gold
      "0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1", // rarity attributes
      "0xf41270836dF4Db1D28F7fd0935270e3A603e78cC", // rarity crafting I
      "0x51C0B29A1d84611373BA301706c6B4b72283C80F", // rarity skills 
      ["0x2A0F1cB17680161cF255348dDFDeE94ea8Ca196A"], // rarity craft I
      460172, // guild_master
      10000 // max_summoners
    ],
  });
};
