tokenSale = {
    
    web3Provider: null,
    contracts: {},

    init: async function() {
        return await tokenSale.initWeb3();
    },

initWeb3: async function() {
if (window.ethereum) {
    tokenSale.web3Provider = window.ethereum;
    try {
        // Request account access
        window.ethereum.enable();
    } catch (error) {
        // User denied account access...
        console.error("User denied account access")
    }
}
// Legacy dapp browsers...
else if (window.web3) {
    tokenSale.web3Provider = window.web3.currentProvider;
}
// If no injected web3 instance is etected, fall back to Ganache
else {
    tokenSale.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
}
web3 = new Web3(tokenSale.web3Provider);
return tokenSale.initContract();
},

initContract: function() {
   
    $.getJSON('GLTMerchantSale.json', function(data) {

        var gltMerchantSaleArtifact = data;
        // Get the necessary contract artifact file and instantiate it with truffle-contract
        tokenSale.contracts.GLTMerchantSale = TruffleContract(gltMerchantSaleArtifact);
    
        // Set the provider for our contract
        tokenSale.contracts.GLTMerchantSale.setProvider(tokenSale.web3Provider);

    });

    $.getJSON('GoodLifeToken.json', function(data) {
        // Get the necessary contract artifact file and instantiate it with truffle-contract
      var GoodLifeTokenArtifact = data;
      tokenSale.contracts.GoodLifeToken = TruffleContract(GoodLifeTokenArtifact);
      // Set the provider for our contract
      tokenSale.contracts.GoodLifeToken.setProvider(tokenSale.web3Provider);
    });

    $.getJSON('KrakenPriceTicker.json', function(data) {
        // Get the necessary contract artifact file and instantiate it with truffle-contract
      var KrakenPriceTickerArtifact = data;
      tokenSale.contracts.KrakenPriceTicker = TruffleContract(KrakenPriceTickerArtifact);
      // Set the provider for our contract
      tokenSale.contracts.KrakenPriceTicker.setProvider(tokenSale.web3Provider);
    });
  
    return tokenSale.bindEvents();
},

bindEvents: function() {
    $(document).on('click', '.btn-purchase', tokenSale.handlePurchaseTokens);
},



handlePurchaseTokens: function(rateEthEur, tokensPurchased) {
    
    var gltSaleInstance;
    var krakenPriceTickerInstance;
    const gasAmt = 3e6;
    const Web3 = require('web3');
    web3.eth.getAccounts(function(error, accounts) {
        if (error) {
            console.log(error);
        }
            var eurAmount = $("#eur-amount").val();
            var rateEthEur = 0;
            tokenSale.contracts.GLTMerchantSale.deployed().then(async function(instance) {
                gltSaleInstance = instance;
                var account = accounts[0];
                var GLTMerchantContract = web3.eth.contract(
                        tokenSale.contracts.GLTMerchantSale.abi
                );
                var gltWeb3SaleInstance = GLTMerchantContract.at(gltSaleInstance.address);
                
                //There is currently no other chance unless to transfer the tokens to the single active account 
                //due to restrictions of Metamask:
                //https://medium.com/metamask/metamask-permissions-system-delay-retrospective-9c49d01039d6
                if($('#variableRate').is(':checked')) {
                        tokenSale.contracts.KrakenPriceTicker.deployed().then(async function(instance2) {
                            krakenPriceTickerInstance = instance2;
                            return krakenPriceTickerInstance.priceETHEUR({from: accounts[0]});
                        }).then(async function(rateEthEur) {
                            $("#exchange-rate").text(rateEthEur);
                            console.log("ETH-EUR rate: " + rateEthEur)
                            await gltWeb3SaleInstance.buyTokens(accounts[0], eurAmount, rateEthEur, {from: accounts[0], gas: gasAmt}, function(error, result) {
                                if(!error)
                                    console.log(JSON.stringify(result));
                                else
                                    console.error(error);
                                });
                           //return gltSaleInstance.getTokenAmount.call(eurAmount, rateEthEur, {from: accounts[0]});
                           var tokensPurchased = await gltSaleInstance.getTokenAmount.call(eurAmount, rateEthEur, {from: accounts[0]});
                           $("#tokens-purchased").text(tokensPurchased);
                        }).then(async function(result) {
                            $("#account").text(accounts[0]);
                            var tokenAddress = await gltSaleInstance.token({from: accounts[0]});
                            var goodLifeToken = await tokenSale.contracts.GoodLifeToken.at(tokenAddress, {from: accounts[0]});
                            var balanceOfCustomer = await goodLifeToken.balanceOf(accounts[0], {from: accounts[0]});
                            $("#account-balance").text(balanceOfCustomer);
                        }).catch(function(err) {
                            console.log(err.message);
                        });
                } else { 
                        await gltWeb3SaleInstance.buyTokens(accounts[0], eurAmount, 0, {from: accounts[0], gas: gasAmt}, function(error, result){
                            if(!error)
                                console.log(JSON.stringify(result));
                            else
                                console.error(error);
                            });
                            return await gltSaleInstance.getTokenAmount.call(eurAmount, 0, {from: accounts[0]}).then(async function(tokensPurchased) {
                                $("#exchange-rate").text("No exchange rate requested!");
                                $("#tokens-purchased").text(tokensPurchased);
                                $("#account").text(accounts[0]);
                                var tokenAddress = await gltSaleInstance.token({from: accounts[0]});
                                var goodLifeToken = await tokenSale.contracts.GoodLifeToken.at(tokenAddress, {from: accounts[0]});
                                var balanceOfCustomer = await goodLifeToken.balanceOf(accounts[0], {from: accounts[0]});
                                $("#account-balance").text(balanceOfCustomer);
                    }).catch(function(err) {
                        console.log(err.message);
                    });
                }
            }).catch(function(err) {
                console.log(err.message);
            });
        });
    },
};

$(function() {
    $(window).load(function() {
      tokenSale.init();
    });
});