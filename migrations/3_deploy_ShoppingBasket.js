var ShoppingBasket = artifacts.require("./ShoppingBasket.sol");

module.exports = function(deployer) {
    deployer.deploy(ShoppingBasket);
};

