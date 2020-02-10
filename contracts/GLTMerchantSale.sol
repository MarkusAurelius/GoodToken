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


 /*
  * This contract implemnts a sale of the "Good Life Token". Since the contract inherited from the MintedCrowdsale contract
  * only ERC20Mintable tokens can be sold by {GLTMerchantSale}.
  * Token ownership should be transferred to MintedCrowdsale for minting.
  */
  contract GLTMerchantSale is MintedCrowdsale, Ownable, MerchantRole  {
    using SafeMath for uint256; 
    uint256 private _weiRaised;
    uint256 private _EURCentWeiRate;
    address payable private _owner;
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
        _EURCentWeiRate = rate;
        _weiRaised = 0;
        _owner = msg.sender;
        _token = token;

    }




    //Emits an event if a token was purchased
    event TokensPurchased (address indexed account, address beneficiary, uint256 amountOfTokens);
    event WeiRaised (uint256 weiRaised, uint256 weiAmount);

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
    function getTokenAmount(uint256 amountInEUR, uint rateETHEUR) public view returns(uint256) {
      
      if(rateETHEUR > 0) {
        uint rateETHTokens = 15000;
        return (rateETHTokens).div(rateETHEUR).mul(amountInEUR);
      } else {      
        //multiply 'provided amountInEUR * WEI in EURCent * 100 Cent
        //uint256 weiAmount = amountInEUR * 50000000000000 * 100;
        uint256 weiAmount = amountInEUR.mul(50000000000000).mul(100);
        return weiAmount.div(_EURCentWeiRate);
      }
    }

    /*
     * Returns the the number of weis for this GLTMerchantSale instance. 
     */
    function weiRaised() public view returns(uint256) {
      //emit WeiRaised(_weiRaised);
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
    function buyTokens(address beneficiary, uint256 amountInEUR, uint rateETHEUR) public
        nonReentrant 
        onlyOwner
        stopInEmergency
        onlyMerchant
        payable 
        returns(uint256) {

          uint256 weiAmount = amountOfETHInEUR(amountInEUR);

          _preValidatePurchase(beneficiary, weiAmount);

          // calculate token amount to be created
          uint256 tokens = getTokenAmount(amountInEUR, rateETHEUR);

          // update state
          _weiRaised = _weiRaised.add(weiAmount);
          emit WeiRaised(_weiRaised, weiAmount);

          _processPurchase(beneficiary, tokens);
          emit TokensPurchased(msg.sender, beneficiary, tokens);          

          _updatePurchasingState(beneficiary, weiAmount);

          _forwardFunds();
          _postValidatePurchase(beneficiary, weiAmount);
          return tokens;
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