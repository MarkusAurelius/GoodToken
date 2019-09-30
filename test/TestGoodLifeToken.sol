pragma solidity ^0.5.0;

//pragma solidity >=0.4.0 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GoodLifeToken.sol";
import "../contracts/GLTMerchantSale.sol";
import "../contracts/ProxyCustomerContract.sol";
import "../contracts/ProxyMerchantContract.sol";
import "./ThrowProxy.sol";


contract TestGoodLifeToken {

    GoodLifeToken goodLifeToken;
    address payable owner;
    address payable badBank;
    address payable merchant;
    address payable customer;
    uint256 ethRate;
    address payable wallet;
    GLTMerchantSale merchantSale;
    ProxyCustomerContract proxyCustomerContract;
    ProxyMerchantContract proxyMerchantContract;
    
    event LogBuyAndCollectTokens(uint numberOfTokens);

    function beforeEach() public {
        owner = msg.sender;
        wallet = owner;
        ethRate = 50000000000000;
        goodLifeToken = GoodLifeToken(DeployedAddresses.GoodLifeToken());
        //goodLifeToken = new GoodLifeToken();
        merchantSale = GLTMerchantSale(DeployedAddresses.GLTMerchantSale());
        //GoodLifeToken gltInstance = new GoodLifeToken();
        //gltInstance.transferOwnership(address (merchantSale));
        proxyCustomerContract = new ProxyCustomerContract();
        proxyMerchantContract = new ProxyMerchantContract();
        merchant = address ( uint160(address(proxyMerchantContract)) );
        customer = address ( uint160(address(proxyCustomerContract)) );

    }

    function afterEach() public {
        badBank = msg.sender;
        goodLifeToken = GoodLifeToken(DeployedAddresses.GoodLifeToken());
        uint balanceOfCustomer = goodLifeToken.balanceOf(customer);
        uint balanceOfMerchant = goodLifeToken.balanceOf(merchant);
        goodLifeToken.transferFrom(customer, badBank, balanceOfCustomer);
        goodLifeToken.transferFrom(merchant, badBank, balanceOfMerchant);
        ethRate = 0;
        merchant = address(0);
        customer = address(0);
    }


    function testTokenName() public {
        string memory tokenName = goodLifeToken.name();
        string memory expected = "GoodLifeToken";
        Assert.equal(tokenName, expected, "Name of Token should be \"Good Life Token\".");
    }

    function testSymbol() public {
        string memory symbol = goodLifeToken.symbol();
        string memory expected = "GLT";
        Assert.equal(symbol, expected, "Name of Token should be \"GLT\".");
    }

    function testDecimals() public {
        uint expectedInt = 0;
        uint decimals = goodLifeToken.decimals();
        Assert.equal(decimals, expectedInt, "Value of decimals should be 0.");
    }

    function testTotalSupply() public {
        
        uint256 totalSupply = goodLifeToken.totalSupply();
        uint256 expected = 40000000000000000000;
        Assert.equal(totalSupply, expected, "Total Supply should be 40000000000000000000.");
    }

   function testTransactionId() public {
      buyAndCollectTokens(150);
      uint transactionCounter = goodLifeToken.getTransactionCounter(); 
      uint expected = 1;
      Assert.equal(transactionCounter, expected, "Transaction Id should be 1."); 
   }

   function testTransactionSenderAddress() public {
      buyAndCollectTokens(150);
      uint transactionCounter = goodLifeToken.getTransactionCounter(); 
      address senderAddress = goodLifeToken.getTransactionSenderAddress(transactionCounter);
      address expected = merchant;
      Assert.equal(senderAddress, expected, "Sender Address should be equal to the merchant address.");
   }

   function testTransactionRecipientAddress() public {
      buyAndCollectTokens(150);
      uint transactionCounter = goodLifeToken.getTransactionCounter();
      address recipientAddress = goodLifeToken.getTransactionRecipientAddress(transactionCounter);
      address expected = customer;
      Assert.equal(recipientAddress, expected, "Recipient Address should be equal to the merchant address.");
   }

   function testTransactionAmount() public {
      buyAndCollectTokens(150);
      uint transactionCounter = goodLifeToken.getTransactionCounter();
      uint transactionAmount = goodLifeToken.getTransactionAmount(transactionCounter);
      uint expected = 150;
      Assert.equal(transactionAmount, expected, "Transaction amount should be 25.");
   }

   function testMerchantBalanceCollectTokens() public {
       buyAndCollectTokens(150);
       uint balanceOfMerchant = goodLifeToken.balanceOf(merchant);
       uint expected = merchantSale.getTokenAmount(2000) - 150;
       Assert.equal(balanceOfMerchant, expected, "Balance of merchant is not correct.");
       
    }

    function testCustomerBalanceCollectTokens() public {
       buyAndCollectTokens(150);
       uint balanceOfCustomer = goodLifeToken.balanceOf(customer);
       uint expected = 150;
       Assert.equal(balanceOfCustomer, expected, "Balance of customer should be 25.");
       
    }

   function testCustomerBalanceRedeemTokens() public {
       buyAndCollectTokens(150);
       goodLifeToken.redeemTokens(customer, 50);
       uint balanceOfCustomer = goodLifeToken.balanceOf(customer);
       uint expected = 100;
       Assert.equal(balanceOfCustomer, expected, "Balance of customer should be 100.");
    }

    function testCheckMinterRole() public {
        //goodLifeToken.addMinter(address (goodLifeToken));
        address ownerGlt = goodLifeToken.gltOwner();        
        bool isMinter = goodLifeToken.isMinter(ownerGlt);
        bool expected = true;
        Assert.equal(isMinter, expected, "Token has to have the Minter Role!");
    }

    /*function testCheckAddMinter() public {
        //goodLifeToken.addMinter(address (goodLifeToken));
        IERC20 ierc20token = goodLifeToken.token(); 
        GoodLifeToken token = GoodLifeToken(address(uint160(ierc20token)));
        token.addMinter(msg.sender);
        address expected = token;
        Assert.equal(address(ierc20token), expected, "Token has to have the Minter Role!");
    }*/

     function testCheckCustomerRole() public {
        //goodLifeToken.addMinter(address (goodLifeToken));
        address ownerGlt = goodLifeToken.gltOwner();        
        bool isCustomer = goodLifeToken.isCustomer(ownerGlt);
        bool expected = true;
        Assert.equal(isCustomer, expected, "Token has to have the Customer Role!");
    }

    /*function testMaxNumberofTokensToRedeem() public {
        buyAndCollectTokens(150);
        GoodLifeToken goodLifeTokenInstance = new GoodLifeToken();
        ThrowProxy throwProxy = new ThrowProxy(address(goodLifeTokenInstance)); //set Thrower as the contract to forward requests to. The target.

        GoodLifeToken(address( uint160( address(throwProxy)) )).redeemTokens(customer, 151);
        //GoodLifeToken(address(throwProxy)).redeemTokens(customer, 151);
        
        (bool r, ) = throwProxy.execute.gas(200000)();
        
        Assert.isFalse(r, "Should be false, as it should throw");
    }*/


    function buyAndCollectTokens(uint numberOfTokens) private {
       
       //use transfer function instead?
       merchantSale = new GLTMerchantSale(ethRate, wallet, goodLifeToken);
       merchantSale.buyTokens(merchant, 2000);
      
       goodLifeToken.collectTokens(merchant, customer, numberOfTokens);
    }
    
}

 