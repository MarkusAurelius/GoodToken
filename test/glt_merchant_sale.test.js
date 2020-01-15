/*

This test file has been updated for Truffle version 5.0. If your tests are failing, make sure that you are
using Truffle version 5.0. You can check this by running "truffle version"  in the terminal. If version 5 is not
installed, you can uninstall the existing version with `npm uninstall -g truffle` and install the latest version (5.0)
with `npm install -g truffle`.

*/
let BN = web3.utils.BN
let GLTMerchantSale = artifacts.require('GLTMerchantSale')
let GoodLifeToken = artifacts.require('GoodLifeToken')
//let catchRevert = require("./exceptionsHelpers.js").catchRevert

contract('GLTMerchantSale', function(accounts) {

    const owner = accounts[0]
    const wallet = accounts[1]
    const merchant = accounts[2]

    const rate = "50000000000000"

    let merchantSale

    beforeEach(async () => {
        var crowdsale = await GLTMerchantSale.deployed({from: accounts[0]})
        var tokenAddress = await crowdsale.token({from: accounts[0]})
        var goodLifeTokenInstance = await GoodLifeToken.at(tokenAddress, {from: accounts[0]})
        merchantSale = await GLTMerchantSale.new(rate, wallet, tokenAddress, {from: accounts[0]})
        goodLifeTokenInstance.addMinter(merchantSale.address)
    })

    it("should raise an amount of wei by purchachsing a given amount of EUR", async() => {
        const amountInEUR = 2000
        await merchantSale.buyTokens(merchant, amountInEUR, {from: accounts[0]})
        var weiRaised = await merchantSale.weiRaised.call({from: accounts[0]})
        var expected = amountInEUR * 50000000000000 * 100 
        assert.equal(weiRaised, expected, "WeiRaised should be 1E+19")
    })

})
