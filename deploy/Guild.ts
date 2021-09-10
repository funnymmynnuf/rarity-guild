module.exports = async ({
  getNamedAccounts,
  deployments,
  getChainId,
  getUnnamedAccounts,
}) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // the following will only deploy "GenericMetaTxProcessor" if the contract was never deployed or if the code changed since last deployment
  await deploy("Guild", {
    from: deployer,
    chainId: 250,
    // gas: 4000000,
    // Set your own guild master
    args: ["0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb", "0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2", "0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1",  460172],
  });
};
