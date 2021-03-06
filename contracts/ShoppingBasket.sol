pragma solidity ^0.5.0;


import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";


/* 
 * This contract implements a shopping basket that contains different procducts with several attributes.
 * The Shopping Basket represents a purchase of a customer and is hence the prerequiste of a token collection.
 */

contract ShoppingBasket {
  using SafeMath for uint; 
  using SafeMath for uint256;

  /* set owner */
  address private owner;

  /* amount of tokens that the purchase contains */
  uint private tokenAmount = 0;

  /* Factor that is determined by the number of decimal places, e. g. 2 numbers of decimal places corresponds to a factor of 100*/
  uint private decimalFactor = 100;

  /* */
  uint private ecoFootprintDecimalFactor = 10;


  /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
     Call this mappings items
  */
  mapping(uint => Item) private basket;

  uint[64] public listOfBasketItemIds;

  uint private listOfItemsCounter = 0;

  
  /*Struct named Item.
    It consists of a name, sku, quantity, price, state, seller, and buyer
    We've left you to figure out what the appropriate types are,
    if you need help you can ask around :)
    Be sure to add "payable" to addresses that will be handling value transfer
  */
  struct Item {
      uint id;
      string name;
      uint quantity;
      uint price;
      uint ecoFootprint;
      string imgRef;
  }

  event LogForAddItemToBasket(uint id);
  event LogSold(uint tokenAmount);

/* Create a modifer that checks if the msg.sender is the owner of the contract */
  modifier verifyCaller (address _address) { require (msg.sender == _address); _;}



  constructor() public {
    /* Here, set the owner as the person who instantiated the contract*/

    owner = msg.sender;
    //listOfBasketItemIds = new uint[](64);
  }
  
  /*
   * Adds an item / product to the shopping basket.
   * Emits a {LogForAddItemToBasket} event.
   *
   * @param id An unique identifier of the item.
   * @param name The name of the item.
   * @param quantity The number of items.
   * @param price The price of the item.
   * @param ecoFootPrint A factor that represents the eco footprint of the item.
   * @param imgRef A reference to the image of the item.
   *
   * Returns the accumulated ammount of tokens that has been collected so far in the current shopping basket instance.
   */
  function addItem(uint _id, string memory _name, uint _quantity, uint _price, uint _ecoFootprint, string memory _imgRef) public returns(uint) {
    require(_id >= 0 && _id < 32, "id must not be lower than 0 and larger than 32.");
    emit LogForAddItemToBasket(_id);
    basket[_id] = Item({id: _id, name: _name, quantity: _quantity, price: _price, ecoFootprint: _ecoFootprint, imgRef: _imgRef}); 
    tokenAmount = tokenAmount.add(_price.mul(_quantity).mul(_ecoFootprint).div(ecoFootprintDecimalFactor).div(decimalFactor));
    listOfBasketItemIds[listOfItemsCounter] = _id;
    listOfItemsCounter = listOfItemsCounter.add(1);
    return tokenAmount;
  }

  /*
   * This function is called when the customer decides to finalize the purchase.
   * He will perform the payment (what isn't part of this dapp) and receives at the same time the collected tokens on his account.
   * The token amount and the counter variable (which represents the consecutive index) are set to 0.
   *
   * Returns the collected amount of tokens.
   */
  function purchaseItems() 
    public 
    returns (uint){
       emit LogSold(tokenAmount);
       uint collectedAmountOfTokens = tokenAmount;
       tokenAmount = 0;
       listOfItemsCounter = 0;
       delete listOfBasketItemIds;
       return collectedAmountOfTokens;      
       
  }

  /*
   * Returns the amount of currently collected tokens.
   *
   */
  function getCurrentAmountOfCollectedTokens()
    public
    returns (uint) {
      return tokenAmount;
    }
  
  /*
   * Returns all attributes of an item dependent on the provided id of the item.
   *
   * Returns the id, the name, the quantity, the price, the eco footprint and the image referer of the item.
   */
  function getItemAttributes(uint _id) public view returns (uint id, string memory name, uint quantity, uint price, uint ecoFootprint, string memory imgRef) {
    require(_id >= 0 && _id < 32, "id must not be lower than 0 and larger than 32.");
    id = _id;
    name = basket[_id].name;
    quantity = basket[_id].quantity;
    price = basket[_id].price;
    ecoFootprint = basket[_id].ecoFootprint;
    imgRef = basket[_id].imgRef;
    return (id, name, quantity, price, ecoFootprint, imgRef);
  }
  
  /*
   * Returns a list of ids of all items of the current shopping basket. 
   *
   * Returns an array of item ids that are included in the current shopping basket. 
   */
  function getListOfBasketItemIds() public view returns (uint[64] memory) {
    return listOfBasketItemIds;
  }

}
