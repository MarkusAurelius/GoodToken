pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./GoodLifeToken.sol";
import "./roles/MerchantRole.sol";


contract FiatContract {
    function ETH(uint _id) public view returns (uint256);
    function USD(uint _id) public view returns (uint256);
    function EUR(uint _id) public view returns (uint256);
    function GBP(uint _id) public view returns (uint256);
    function updatedAt(uint _id) public view returns (uint);
}

 /*
  * This contract implemnts a sale of the "Good Life Token". Since the contract inherited from the MintedCrowdsale contract
  * only ERC20Mintable tokens can be sold by {GLTMerchantSale}.
  * Token ownership should be transferred to MintedCrowdsale for minting.
  */
  contract GLTMerchantSale is MintedCrowdsale, Ownable, MerchantRole  {
    using SafeMath for uint256; 
    uint256 private _weiRaised;
    uint256 private _rate;
    address payable _owner;
    GoodLifeToken private _token;
    bool private stopped = false;

    /*
     * Constructor
     * @param rate The conversion rate for WEI in EUR cent
     * @param wallet The Ethereum address from which the tokens should be minted
     * @param token The ERC20Mintable token which will be minted and sold by this MintedCrowdsale
     */
    constructor (
        uint256 rate,
        address payable wallet,
        //ERC20Mintable token
        GoodLifeToken token
    )
        public
        Crowdsale(rate, wallet, token) {
        _rate = rate;
        _weiRaised = 0;
        _owner = msg.sender;
        _token = token;

    }

    FiatContract public price;

    /*function getPrice() public returns(uint256 priceOfOneTokenInWei) {
      uint256 oneCent = price.EUR(0);// return price of 0.01 Euro in Wei
      return priceOfOneTokenInEuroWei.mul(oneCent).div(10000000000000000);
    } */


    //Emits an event if a token was purchased
    event TokensPurchased (address indexed account, address beneficiary, uint256 amountOfTokens);


    modifier isAdmin() {
      require(msg.sender == _owner);
      _;
    }

    modifier stopInEmergency { if (!stopped) _; }
    modifier onlyInEmergency { if (stopped) _; }

    function amountOfETHInEUR(uint amountInEUR) internal pure returns (uint256) {
      // returns $0.01 ETH wei
      // For test and main net
      //uint256 ethCentInWei = price.EUR(0);
      uint ethCentInWei = 50000000000000;
      return ethCentInWei.mul(amountInEUR).mul(100);
    } 
    /**
      * Returns the amount of tokens based on the provided amount of EUR.
      * @param amountInEUR The amount in EUR currency that should be returned in amount of tokens. 
      * return The amount of tokens
      */
    function getTokenAmount(uint256 amountInEUR) public view returns(uint256) {
      //multiply 'provided amountInEUR * WEI in EURCent * 100 Cent
      //uint256 weiAmount = amountInEUR * 50000000000000 * 100;
      uint256 weiAmount = amountInEUR.mul(50000000000000).mul(100);
      return  weiAmount.div(_rate);
      //return _getTokenAmount(weiAmount);
    }

    /*
     * Returns the the number of weis for this GLTMerchantSale instance. 
     */
    function weiRaised() public view returns(uint256) {
      return _weiRaised;
    }


   /**
     * @dev low level token purchase 
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * 
     * Emits a {TokensPurchased} event.
     *
     * @param beneficiary Recipient of the token purchase
     * @param amountInEUR Amount of EUR the tokens should be purchased for 
     */
    function buyTokens(address beneficiary, uint256 amountInEUR) public 
        nonReentrant 
        onlyOwner
        stopInEmergency
        onlyMerchant
        payable {
          
          price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591); // MAINNET ADDRESS
          price = FiatContract(0x2CDe56E5c8235D6360CCbb0c57Ce248Ca9C80909); // TESTNET ADDRESS (ROPSTEN)

          uint256 weiAmount = amountOfETHInEUR(amountInEUR);

          _preValidatePurchase(beneficiary, weiAmount);

          // calculate token amount to be created
          uint256 tokens = getTokenAmount(amountInEUR);

          // update state
          _weiRaised = _weiRaised.add(weiAmount);

          emit TokensPurchased(msg.sender, beneficiary, tokens);
          _processPurchase(beneficiary, tokens);
          //emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);

          _updatePurchasingState(beneficiary, weiAmount);

          _forwardFunds();
          _postValidatePurchase(beneficiary, weiAmount);
    }
    // Are we sure?????????????????????????????????????? to use selfdestruct here
    function destroy() public onlyOwner {
      selfdestruct(_owner);
    }
    
    /*
    *
    */
    function destroyAndSend(address payable recipient) public onlyOwner {
      selfdestruct(recipient);
    }

 }