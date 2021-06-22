const D20Token = artifacts.require("D20Token");

module.exports = function (deployer) {
  deployer.deploy(D20Token);
};
