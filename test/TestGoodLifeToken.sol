pragma solidity ^0.5.0;

//pragma solidity >=0.4.0 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GoodLifeToken.sol";
import "./ThrowProxy.sol";


contract TestGoodLifeToken {

    GoodLifeToken goodLifeToken;
    address payable owner;
    uint256 ethRate;
    address payable wallet;
    

    function beforeEach() public {
        owner = msg.sender;
        wallet = owner;
        ethRate = 50000000000000;
        goodLifeToken = GoodLifeToken(DeployedAddresses.GoodLifeToken());

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
        uint256 expected = 5000000000000;
        Assert.equal(totalSupply, expected, "Total Supply should be 40000000000000000000.");
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

    
}

 