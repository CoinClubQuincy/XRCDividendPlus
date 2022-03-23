const Plus = artifacts.require("Plus");

module.exports = function (deployer) {
  deployer.deploy(Plus, "Q-Shards","QSHD",100,18);
};