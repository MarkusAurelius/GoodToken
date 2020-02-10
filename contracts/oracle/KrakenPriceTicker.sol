pragma solidity >= 0.5.0 < 0.6.0;

import "./provableAPI.sol";

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
