Collect = {
  web3Provider: null,
  contracts: {},

  initApp: async function() {
    // Load grocerys.
    $.getJSON('../groceries.json', function(data) {
      var groceriesRow = $('#groceriesRow');
      var groceryTemplate = $('#groceryTemplate');

      for (i = 0; i < data.length; i ++) {
        var name = data[i].name;
        var picture = data[i].picture;
        var price = data[i].price;
        var ecoFootprint = data[i].ecoFootprint;
        var id = data[i].id
        groceryTemplate.find('.panel-title').text(name);
        groceryTemplate.find('img').attr('src', picture);
        //groceryTemplate.find('.grocery-quantity').text();
        groceryTemplate.find('.grocery-quantity').attr('id', 'quantity'+ id);
        groceryTemplate.find('.grocery-price').text(price);
        groceryTemplate.find('.grocery-currency').text('EUR');
        groceryTemplate.find('.grocery-ecoFootprint').text(ecoFootprint);
        groceryTemplate.find('.btn-addToBasket').attr('data-id', id);
        groceriesRow.append(groceryTemplate.html());

      }
    });
    return await Collect.initWeb3();

  },

  initWeb3: async function() {
    
    if (window.ethereum) {
      Collect.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dCollect browsers...
    else if (window.web3) {
      Collect.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      Collect.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(Collect.web3Provider);

    return Collect.initContract();
  },

  initContract: function() {
  
    $.getJSON('ShoppingBasket.json', function(data) {
    // Get the necessary contract artifact file and instantiate it with truffle-contract
    var ShoppingBasketArtifact = data;
    Collect.contracts.ShoppingBasket = TruffleContract(ShoppingBasketArtifact);
    
    // Set the provider for our contract
    Collect.contracts.ShoppingBasket.setProvider(Collect.web3Provider);
  
    // Use our contract to retrieve and display the add grocerys
    return Collect.addedToBasket();
    });

    $.getJSON('GLTMerchantSale.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
    var GLTMerchantSaleArtifact = data;
    Collect.contracts.GLTMerchantSale = TruffleContract(GLTMerchantSaleArtifact);
    // Set the provider for our contract
    Collect.contracts.GLTMerchantSale.setProvider(Collect.web3Provider);
    });

    $.getJSON('GoodLifeToken.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
    var GoodLifeTokenArtifact = data;
    Collect.contracts.GoodLifeToken = TruffleContract(GoodLifeTokenArtifact);
    // Set the provider for our contract
    Collect.contracts.GoodLifeToken.setProvider(Collect.web3Provider);
    });

    return Collect.bindEvents();
  },


  bindEvents: function() {
    $(document).on('click', '.btn-addToBasket', Collect.handleAddToBasket);
    $(document).on('click', '.btn-collectTokens', Collect.handleCollectTokens);
  },

  addedToBasket: function(id, itemValues) {

    var shoppingBasketInstance;
    var basketRow = $('#basketRow');
    var basketTemplate = $('#basketTemplate');
    
    Collect.contracts.ShoppingBasket.deployed().then(function(instance) {
      shoppingBasketInstance = instance;
     
          return shoppingBasketInstance.getItemAttributes.call(id);
      }).then(function(itemValues) {
          basketTemplate.find('.panel-title').text(itemValues[1]);
          basketTemplate.find('.basket-quantity').text(itemValues[2]);
          var price = itemValues[3] / 100;
          basketTemplate.find('.basket-price').text(price);
          basketTemplate.find('.basket-currency').text('EUR');
          basketTemplate.find('.basket-ecoFootprint').text(itemValues[4]);
          basketTemplate.find('img').attr('src', itemValues[5]);
          
          basketRow.append(basketTemplate.html());
        }).catch(function(err) {
          console.log(err.message);
        });
  },

  handleAddToBasket: function(event) {
    
    var shoppingBasketInstance;
    var name;
    var price;
    var ecoFootprint;
    var picture;
    var id = $(event.target).data('id');
    var quantity = $('#quantity' + id).val();

    $.getJSON('../groceries.json', function(data) {
      name = data[id].name;
      picture = data[id].picture;
      price = data[id].price * 100;
      currency = 'EUR';
      ecoFootprint = data[id].ecoFootprint;
      });

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      
      //var quantity = $('input[id="quantity"')[id];
      var account = accounts[0];
     
      Collect.contracts.ShoppingBasket.deployed().then(function(instance) {
        shoppingBasketInstance = instance;
      return shoppingBasketInstance.addItem(id, name, quantity, price, ecoFootprint, picture, {from: account});
          }).then(function(result) {
            return Collect.addedToBasket(id);
          });
          /*.catch(function(err) {
            console.log(err.message);
          });*/
        
    });

  },

handleCollectTokens: function(tokensCollected) {
    
    var shoppingBasketInstance;
    var tokenAmount;
    web3.eth.getAccounts(function(error, accounts) {
        if (error) {
            console.log(error);
        }
        Collect.contracts.ShoppingBasket.deployed().then(function(instance) {
        shoppingBasketInstance = instance;
        var account = accounts[0];
        return shoppingBasketInstance.purchaseItems.call({from: accounts[0]});
         }).then(async function(tokensCollected) {
           $("#tokens-collected").text(tokensCollected);
           var crowdsale = await Collect.contracts.GLTMerchantSale.deployed({from: accounts[0]});
           var tokenAddress = await crowdsale.token({from: accounts[0]});
           var goodLifeToken = await Collect.contracts.GoodLifeToken.at(tokenAddress, {from: accounts[0]});
           //There is currently no other chance to transfer the tokens from the single active account 
           //account to the same single active due to restrictions of Metamask of not being able to unlock
           //multiple accounts:
           //https://medium.com/metamask/metamask-permissions-system-delay-retrospective-9c49d01039d6
           //await goodLifeToken.collectTokens(accounts[0], accounts[0], tokensCollected, {from: accounts[0]});
           var balanceOfCustomer = await goodLifeToken.balanceOf(accounts[0], {from: accounts[0]});
           //$("#account-balance").text(balanceOfCustomer);
         }).catch(function(err) {
            console.log(err.message);
         });
    });
  },
};



$(function() {
  $(window).load(function() {
    Collect.initApp();
  });
});
