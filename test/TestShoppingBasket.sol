pragma solidity ^0.5.0;

//pragma solidity >=0.4.0 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ShoppingBasket.sol";

contract TestShoppingBasket {
    ShoppingBasket shoppingBasket;
    bool addItemSuccessful; 

    function beforeEach() public {
        shoppingBasket = ShoppingBasket(DeployedAddresses.ShoppingBasket());
        shoppingBasket = new ShoppingBasket();
        addItemSuccessful = shoppingBasket.addItem("Carrot", 5, 80, 10);

    }

    function afterEach() public {
        shoppingBasket.addItem("", 0, 0, 0);
    }

    function testItemName() public {
        (string memory name,,,,) = shoppingBasket.fetchItem(0);
        string memory expected = "Carrot";
        Assert.equal(name, expected, "Name of item has to be Carrot!");
    }
    
    function testItemSku() public {
        (,uint sku,,,) = shoppingBasket.fetchItem(0);
        uint expected = 0;
        Assert.equal(sku, expected, "Value of SKU has to be 0!");
    }

    function testItemPrice() public {
        (,,,uint price,) = shoppingBasket.fetchItem(0);
        uint expected = 80;
        Assert.equal(price, expected, "Value of SKU has to be 0,80 EUR!");  
    }

    function testItemEcoFootprint() public {
        (,,,,uint ecoFootprint) = shoppingBasket.fetchItem(0);
        uint expected = 10;
        Assert.equal(ecoFootprint, expected, "Eco Footprint has to 10!"); 
    }

    function testAddItem() public {
        bool expected = true;
        Assert.equal(addItemSuccessful, expected, "Item has to be added successfully!"); 
    }

    function testPurchaseItem() public {
        shoppingBasket.addItem("Banana", 4, 60, 5);
        shoppingBasket.addItem("Cucumber", 2, 100, 8);
        shoppingBasket.addItem("Apple", 6, 90, 9);
        uint tokenAmount = shoppingBasket.purchaseItems();
        uint expected = 10;
        Assert.equal(tokenAmount, expected, "Token amount has to be 10.");

    }

}

