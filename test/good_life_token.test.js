/*

This test file has been updated for Truffle version 5.0. If your tests are failing, make sure that you are
using Truffle version 5.0. You can check this by running "truffle version"  in the terminal. If version 5 is not
installed, you can uninstall the existing version with `npm uninstall -g truffle` and install the latest version (5.0)
with `npm install -g truffle`.

*/
let BN = web3.utils.BN
let GLTMerchantSale = artifacts.require('GLTMerchantSale')
let GoodLifeToken = artifacts.require('GoodLifeToken')
let catchRevert = require("./exceptionsHelpers.js").catchRevert

contract('GoodLifeToken', function(accounts) {

    const owner = accounts[0]
    const wallet = accounts[1]
    const merchant = accounts[2]
    const customer = accounts[3]
    const ethRate = "50000000000000"
    const amountOfTokens = 150
    const tokenPurchaseInEUR = 2000

    let merchantSale
    let goodLifeToken

    beforeEach(async () => {
        
        var crowdsale = await GLTMerchantSale.deployed({from: owner})
        var tokenAddress = await crowdsale.token({from: owner})
        goodLifeToken = await GoodLifeToken.at(tokenAddress, {from: owner})
        merchantSale = await GLTMerchantSale.new(ethRate, wallet, tokenAddress, {from: owner})
        await goodLifeToken.addMinter(merchantSale.address)
        await merchantSale.buyTokens(merchant, tokenPurchaseInEUR, 0, {from: owner})
        var balanceOfMerchant = await goodLifeToken.balanceOf(merchant, {from: owner})
        await goodLifeToken.collectTokens(merchant, customer, amountOfTokens, {from: owner})
    })

    afterEach(async () => {
        var badBank = accounts[4] 
        var balanceOfCustomer = await goodLifeToken.balanceOf(customer, {from: owner})
        var balanceOfMerchant = await goodLifeToken.balanceOf(merchant, {from: owner})
        await goodLifeToken.transferFrom(customer, badBank, balanceOfCustomer, {from: owner})
        await goodLifeToken.transferFrom(merchant, badBank, balanceOfMerchant, {from: owner})
    })

    it("Should check the transaction ID", async() => {
        var transactionCounter = await goodLifeToken.getTransactionCounter({from: owner}) 
        var expected = 2 
        assert.equal(transactionCounter, expected, "Transaction id should be 2.") 
    })

    it("Should check the sender address", async() => {
        var transactionCounter = await goodLifeToken.getTransactionCounter({from: owner})
        var senderAddress = await goodLifeToken.getTransactionSenderAddress(transactionCounter, {from: owner})
        var  expected = merchant
        assert.equal(senderAddress, expected, "Sender address should be equal to the merchant address.")
    })

    it("Should check the recipient address", async() => {
        var transactionCounter = await goodLifeToken.getTransactionCounter({from: owner})
        var recipientAddress = await goodLifeToken.getTransactionRecipientAddress(transactionCounter, {from: owner})
        var expected = customer
        assert.equal(recipientAddress, expected, "Recipient address should be equal to the merchant address.");
    })
    
    it("Should check the transaction amount", async() => {
        var transactionCounter = await goodLifeToken.getTransactionCounter({from: owner})
        var transactionAmount = await goodLifeToken.getTransactionAmount(transactionCounter, {from: owner})
        var expected = 150
        assert.equal(transactionAmount, expected, "Transaction amount should be 25.")
    })

    it("Should check the token account balance of the merchant after a token collection", async() => {
        var balanceOfMerchant = await goodLifeToken.balanceOf(merchant, {from: owner})
        var expected = await merchantSale.getTokenAmount(2000, 0, {from: owner}) - 150
        assert.equal(balanceOfMerchant, expected, "Balance of merchant is not correct.")
    })

    it("Should check the token account balance of a customer after a token collection", async() => {
       var balanceOfCustomer = await goodLifeToken.balanceOf(customer, {from: owner})
       var expected = 150
       assert.equal(balanceOfCustomer, expected, "Balance of customer should be 150.")
    })

    it("Should check the token account balance of the merchant after a token redemption", async() => {
        goodLifeToken.redeemTokens(customer, 50)
        var balanceOfCustomer = await goodLifeToken.balanceOf(customer, {from: owner})
        var expected = 100
        assert.equal(balanceOfCustomer, expected, "Balance of customer should be 100.")
    })

    it("Tokens should only be redeemed if for the customer are enough tokens available", async() => {
        await catchRevert(goodLifeToken.redeemTokens(customer, 151, {from: owner}))
    })

    it("Tokens should only be collected by the customer if the merchant has got a sufficient amount of tokens available", async() => {
        var balanceOfMerchant = await goodLifeToken.balanceOf(merchant, {from: owner})
        await catchRevert(goodLifeToken.collectTokens(merchant, customer, 199900, {from: owner}))
    })

})
