const Plus = artifacts.require("Treasury");

module.exports = function (deployer) {
  deployer.deploy(Plus, "Q-Shards","QSHD",100,18,1);
};