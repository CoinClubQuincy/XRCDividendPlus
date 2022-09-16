const Coinbank = artifacts.require("CoinBank");

module.exports = function (deployer) {
  deployer.deploy(Coinbank,"0xd2e8d80eec760da7dd35c7c21256e07f28d822d5",1);
};