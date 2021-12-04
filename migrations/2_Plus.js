const Plus = artifacts.require("Plus");

module.exports = function (deployer) {
  deployer.deploy(Plus, "Test","TST",100);
};