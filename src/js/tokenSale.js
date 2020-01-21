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
// If no injected web3 instance is detected, fall back to Ganache
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
  
    return tokenSale.bindEvents();
},

bindEvents: function() {
    $(document).on('click', '.btn-purchase', tokenSale.handlePurchaseTokens);
},


handlePurchaseTokens: function() {
    
    var gltSaleInstance;
    web3.eth.getAccounts(function(error, accounts) {
        if (error) {
            console.log(error);
        }
            var eurAmount = $("#eur-amount").val();
            tokenSale.contracts.GLTMerchantSale.deployed().then(function(instance) {
                gltSaleInstance = instance;
                var account = accounts[0];
                //There is currently no other chance unless to transfer the tokens to the single active account 
                //due to restrictions of Metamask:
                //https://medium.com/metamask/metamask-permissions-system-delay-retrospective-9c49d01039d6
                return gltSaleInstance.buyTokens(accounts[0], eurAmount, {from: accounts[0]});
            }).then(async function(result) {
                var tokenAmount = await gltSaleInstance.getTokenAmount(eurAmount);
                $("#tokens-purchased").text(tokenAmount);
                $("#account").text(accounts[0]);
                var tokenAddress = await gltSaleInstance.token({from: accounts[0]});
                var goodLifeToken = await tokenSale.contracts.GoodLifeToken.at(tokenAddress, {from: accounts[0]});
                var balanceOfCustomer = await goodLifeToken.balanceOf(accounts[0], {from: accounts[0]});
                $("#account-balance").text(balanceOfCustomer);
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