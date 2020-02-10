pragma solidity ^0.5.0;

//pragma solidity >=0.4.0 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GoodLifeToken.sol";
import "../contracts/GLTMerchantSale.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract TestGLTMerchantSale {

    GLTMerchantSale merchantSaleInst = GLTMerchantSale(DeployedAddresses.GLTMerchantSale());
    GLTMerchantSale merchantSale;
    GoodLifeToken goodLifeToken = GoodLifeToken(DeployedAddresses.GoodLifeToken());
    uint256 rate;

    function beforeEach() public {
        rate = 50000000000000;
        address payable wallet = msg.sender;
        merchantSale = new GLTMerchantSale(rate, wallet, goodLifeToken);
    }


    function testRate() public {
        uint256 rateTest = merchantSale.rate();
        uint256 expected = 50000000000000;
        Assert.equal(rateTest, expected, "Rate should be 50000000000000.");
    }
    
    function testWallet() public {
        address payable wallet = merchantSale.wallet();
        address payable expected = msg.sender;
        Assert.equal(wallet, expected, "Wallet is not the owner of the contract!");
    }

    function testTokenSymbol() public {
       GoodLifeToken token = GoodLifeToken (address(merchantSale.token()));
       string memory symbol = token.symbol();
       string memory expected = "GLT";
       Assert.equal(symbol, expected, "Token symbol should be GLT!"); 
    }


    function testTokenAmount() public {
        uint256 amountInEUR = 2000;
        uint256 tokenAmount = merchantSale.getTokenAmount(amountInEUR, 0);
        uint256 expected = (amountInEUR * 50000000000000 * 100) / rate;
        Assert.equal(tokenAmount, expected, "Amount of tokens should be 200.000.");
    }

}

