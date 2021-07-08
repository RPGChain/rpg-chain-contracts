const D20Token = artifacts.require("D20Token");
const DiceTower = artifacts.require("DiceTower");

module.exports = function (deployer) {
  deployer.deploy(D20Token);
  deployer.deploy(DiceTower);
};