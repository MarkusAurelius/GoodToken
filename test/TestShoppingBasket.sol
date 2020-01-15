pragma solidity ^0.5.0;

//pragma solidity >=0.4.0 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ShoppingBasket.sol";

contract TestShoppingBasket {
    ShoppingBasket shoppingBasket;
    uint amountOfCollectedTokens; 

    function beforeEach() public {
        shoppingBasket = ShoppingBasket(DeployedAddresses.ShoppingBasket());
        shoppingBasket = new ShoppingBasket();
        amountOfCollectedTokens = shoppingBasket.addItem(0, "Carrot", 14, 80, 10, "img/carrot.jpg");
    }

    function afterEach() public {
        shoppingBasket.addItem(0,"", 0, 0, 0, "");
        shoppingBasket.purchaseItems();
    }


    function testItemId() public {
        (uint id,,,,,) = shoppingBasket.getItemAttributes(0);
        uint expected = 0;
        Assert.equal(id, expected, "Value of ID has to be 0!");
    }

    function testItemName() public {
        (,string memory name,,,,) = shoppingBasket.getItemAttributes(0);
        string memory expected = "Carrot";
        Assert.equal(name, expected, "Name of item has to be Carrot!");
    }
    
    function testItemQuantity() public {
        (,,uint quantity,,,) = shoppingBasket.getItemAttributes(0);
        uint expected = 14;
        Assert.equal(quantity, expected, "Value of quantity has to 4!");  
    }

    function testItemPrice() public {
        (,,,uint price,,) = shoppingBasket.getItemAttributes(0);
        uint expected = 80;
        Assert.equal(price, expected, "Value of price has to be 0,80 EUR!");  
    }

    function testItemEcoFootprint() public {
        (,,,,uint ecoFootprint,) = shoppingBasket.getItemAttributes(0);
        uint expected = 10;
        Assert.equal(ecoFootprint, expected, "Eco Footprint has to 10!"); 
    }

    function testItemImgRef() public {
        (,,,,,string memory imgRef) = shoppingBasket.getItemAttributes(0);
        string memory expected = "img/carrot.jpg";
        Assert.equal(imgRef, expected, "Name of item has to be Carrot!");
    }

    function testAddItemToBasket() public {
        uint expected = 11;
        Assert.equal(amountOfCollectedTokens, expected, "Amount of collected tokens has to be 11!"); 
    }

    function testAddMultipleItemsToBasket() public {
        uint tokenAmount = 0;
        tokenAmount = shoppingBasket.addItem(1, "Banana", 4, 60, 50, "/img/banana.jpg");
        tokenAmount = shoppingBasket.addItem(2, "Cucumber", 2, 100, 80, "img/cucumber.jpg");
        tokenAmount = shoppingBasket.addItem(3, "Apple", 3, 90, 90, "/img/apple.jpg");
        //tokenAmount = shoppingBasket.purchaseItems();

        uint expected = 63;
        Assert.equal(tokenAmount, expected, "Token amount has to be 63.");

    }

     function testListOfBasketItemIds() public {
        uint tokenAmount = 0;
        tokenAmount = shoppingBasket.addItem(1, "Banana", 4, 60, 50, "/img/banana.jpg");
        tokenAmount = shoppingBasket.addItem(2, "Cucumber", 2, 100, 80, "img/cucumber.jpg");
        tokenAmount = shoppingBasket.addItem(3, "Apple", 3, 90, 90, "/img/apple.jpg");
        //tokenAmount = shoppingBasket.purchaseItems();
        uint[] memory listOfBasketItemIds = shoppingBasket.getListOfBasketItemIds();

        uint expected1 = 0;
        Assert.equal(listOfBasketItemIds[0], expected1, "Value of has to be 0.");
        uint expected2 = 1;
        Assert.equal(listOfBasketItemIds[1], expected2, "Value of has to be 1.");
        uint expected3 = 2;
        Assert.equal(listOfBasketItemIds[2], expected3, "Value of has to be 2.");

    }
}

