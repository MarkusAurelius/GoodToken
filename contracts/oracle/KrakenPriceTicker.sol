pragma solidity >= 0.5.0 < 0.6.0;

import "./provableAPI.sol";

/*
 * Contract which acts as an Oracle and retrieves rates from the Kraken Price Ticker service.
 * This contract was taken from the Github repository 
 * https://github.com/provable-things/ethereum-examples/tree/master/solidity/truffle-examples/kraken-price-ticker
 * The rate calculation was changed from ETH/XBT to ETH/EUR.
 */

contract KrakenPriceTicker is usingProvable {

    string public priceETHEUR;

    event LogNewProvableQuery(string description);
    event LogNewKrakenPriceTicker(string price);
    event Receive(uint value);

    constructor()
        public
        payable
    {
        provable_setProof(proofType_Android | proofStorage_IPFS);
        update(); // Update price on contract creation...
    }
    
    /*
     * Callback function which retrieves the Ether / Euro rate.
     * 
     * @param _myid Id of the request
     * @param _result Result of the query
     * @param _proof
     */
    function __callback(
        bytes32 _myid,
        string memory _result,
        bytes memory _proof
    )
        public
    {
        require(msg.sender == provable_cbAddress());
        update(); // Recursively update the price stored in the contract...
        priceETHEUR = _result;
        emit LogNewKrakenPriceTicker(priceETHEUR);
    }

    /*
     * This function is executing the query towards the Kraken Price Ticker service.
     */
    function update()
        public
        payable
    {
        if (provable_getPrice("URL") > address(this).balance) {
            emit LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee!");
        } else {
            emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
            provable_query(3, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHEUR).result.XETHZEUR.c.0");
            //provable_query(60, "URL", "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD,EUR,GBP).EUR");
        }
    }

    function() external payable {
        emit Receive(msg.value);
    }

}
