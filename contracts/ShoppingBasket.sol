/*
    This exercise has been updated to use Solidity version 0.5
    Breaking changes from 0.4 to 0.5 can be found here: 
    https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

pragma solidity ^0.5.0;

contract ShoppingBasket {
  using SafeMath for uint; 

  /* set owner */
  address owner;

  /* Add a variable called skuCount to track the most recent sku # */
  uint private skuCount;

  /* amount of tokens that the purchase contains */
  uint private tokenAmount = 0;

  /* Factor that is determined by the number of decimal places, e. g. 2 numbers of decimal places corresponds to a factor of 100*/
  uint private decimalFactor = 100;

  /* */
  uint private ecoFootprintDecimalFactor = 10;


  /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
     Call this mappings items
  */
  mapping(uint => Item) public basket;
  
  /*Struct named Item.
    It consists of a name, sku, quantity, price, state, seller, and buyer
    We've left you to figure out what the appropriate types are,
    if you need help you can ask around :)
    Be sure to add "payable" to addresses that will be handling value transfer
  */
  struct Item {
      string name;
      uint sku;
      uint quantity;
      uint price;
      uint ecoFootprint;
  }

  event LogForAddItemToBasket(uint sku);
  event LogSold(uint tokenAmount);

/* Create a modifer that checks if the msg.sender is the owner of the contract */
  modifier verifyCaller (address _address) { require (msg.sender == _address); _;}


  /* For each of the following modifiers, use what you learned about modifiers
   to give them functionality. For example, the forSale modifier should require
   that the item with the given sku has the state ForSale. 
   Note that the uninitialized Item.State is 0, which is also the index of the ForSale value,
   so checking that Item.State == ForSale is not sufficient to check that an Item is for sale.
   Hint: What item properties will be non-zero when an Item has been added?
   */

  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */
    owner = msg.sender;
    skuCount = 0;
  }

  function addItem(string memory _name, uint _quantity, uint _price, uint _ecoFootprint) public returns(bool) {
    emit LogForAddItemToBasket(skuCount);
    basket[skuCount] = Item({name: _name, sku: skuCount, quantity: _quantity, price: _price, ecoFootprint: _ecoFootprint});
    skuCount = skuCount.add(1);
    tokenAmount = tokenAmount.add(_price.mul(_quantity).mul(_ecoFootprint).div(ecoFootprintDecimalFactor).div(decimalFactor));
    return true;
  }

  /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/

  function purchaseItems() 
    public 
    returns (uint){
       emit LogSold(tokenAmount);
       return tokenAmount;      
       
  }

  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint quantity, uint price, uint ecoFootprint) {
    name = basket[_sku].name;
    sku = basket[_sku].sku;
    quantity = basket[_sku].quantity;
    price = basket[_sku].price;
    ecoFootprint = basket[_sku].ecoFootprint;
    return (name, sku, quantity, price, ecoFootprint);
  }

}
