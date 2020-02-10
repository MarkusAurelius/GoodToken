//var KrakenPriceTicker = artifacts.require("./oracle/KrakenPriceTicker.sol");
module.exports = deployer => deployer.deploy(artifacts.require("KrakenPriceTicker.sol"));


/*module.exports = function(deployer) {
    deployer.deploy(KrakenPriceTicker);
}*/


