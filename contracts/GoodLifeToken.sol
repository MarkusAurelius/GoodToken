
pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./roles/CustomerRole.sol";
import "./Pausable.sol";

/*
 *    This contract implements the GoodLifeToken that is issued and Minted by a {GLTMerchantSale}
 *    This token can only be purchased by a merchant. The {GoodlifeToken} is transferred to the
 *    wallet of the customer if he is doing a purchase at the store who is owned by the merchant.
 *    This Token is an ERC20 token and is therfore inherited from an ERC20 token. Moreover it is a an
 *    ERC20Mintable token, because it will only created when a merchant purchases this token for a certain
 *    amount of EUR. This token is designed as a stable coin.
 */

contract GoodLifeToken is ERC20, ERC20Detailed, ERC20Mintable, ReentrancyGuard, Ownable, CustomerRole, Pausable  {
    using SafeMath for uint; 
    using SafeMath for uint256;

    uint public _totalSupply;
    uint private transactionCount = 1;
    bytes private data;
    address private _owner;
    struct TransactionStruct {
        address sender;
        address recipient;
        uint amount;
        string typeOfTransaction;
    }
    //Store a list of transactions with an unique ascendant identifier
    mapping (uint256 => TransactionStruct) private transactionList;
    //mapping(address => mapping(address => uint)) allowed;


    /**
     *   Checks if the merchant has got a sufficient amount of tokens which he can the customer reward with.
     */
    modifier merchantHasEnoughTokens(address from, uint tokensToPurchase) {
        require(balanceOf(from) >= tokensToPurchase);
        _;
    }
    /**
     *   Checks if the the customer has owns a sufficient amount of tokens for the redemption.
     */
    modifier customerHasEnoughTokens(address from, uint tokensToRedeem) {
        require(balanceOf(from) >= tokensToRedeem);
        _;
    }

    //Event emitted during a token collection, which contains the sender address (merchant), the recipient address (customer) and the amount of tokens 
    event LogCollectTokens(address from, address to, uint amountOfTokens); 
    //Event emitted during a token redemption, which contains the recipient address (customer) and the amount of tokens
    event LogRedeemTokens(address from, uint numberOfTokensToRedeem); 
    //Event emitted that contains the transaction counter which correponds the number of transactions performed successfully
    event LogTransactionCounter(uint transactionCount);

    /* 
     * Constructor - Creates an ERC20Detailed token provided with the name and the symbol
     */
    constructor () public ERC20Detailed("GoodLifeToken", "GLT", 0) {
        _owner = msg.sender;
        _mint(msg.sender,  40000000000000000000);
        //transactionCount = 1;
    }

    function gltOwner() public view returns(address) {
        return _owner;
    }



    /* 
     * Don't accept ETH
     */
    /*function () external payable{
        buyTokens(msg.sender);
    }*/

    /* Transfer tokens from the from account to the to account.
     * This function is current primarily used for testing purposes.
     *
     * The calling account must already have sufficient tokens approve(...)-d
     * for spending from the from account and
     * - From account must have sufficient balance to transfer
     * - Spender must have sufficient allowance to transfer
     * - 0 value transfers are allowed
    */

    function transferFrom(address from, address to, uint tokens) public whenNotPaused returns (bool success) {
        _transfer(from, to, tokens);
        return true;
    }

    /*
     * Collects a given amount of tokens by substracting this from the merchant's account (from) and adding
     * the provided amount of tokens to the customer's account.
     *
     * Emits a {LogCollectTokens} and a {LogTransactionCounter} event.
     *
     * Requirements:
     * - `sender` (merchant) has to have a sufficient amount of tokens (>0).

     * @param from The address where the transaction is sent from.
     * @param to The address where the transaction is sent to
     * @param amountOfTokens  
     * 
    */
    function collectTokens(address from, address to, uint amountOfTokens) public 
        whenNotPaused
        merchantHasEnoughTokens(from, amountOfTokens)
        //onlyCustomer
        returns (bool success) {

        emit LogCollectTokens(from, to, amountOfTokens); 
        require(transactionCount > 0 && transactionCount < 256, "id must not be lower than 0 and larger than 255.");
        transactionCount = transactionCount.add(1);
        TransactionStruct memory ts = transactionList[transactionCount];
        ts.sender = from;
        ts.recipient = to;
        ts.amount = amountOfTokens;
        ts.typeOfTransaction = "Collection";
        transactionList[transactionCount] = ts;
        emit LogTransactionCounter(transactionCount);

        return transferFrom(from, to, amountOfTokens);
    }

    /*
     * Redeems a certain amount of tokens by substracting this from the customers's account (from).
     * The redeemed tokens are burned.
     *
     * Emits a {LogRedeemTokens} and a {LogTransactionCounter} event.
     *
     * Requirements:
     * - `sender` (merchant) has to have a sufficient amount of tokens (> 0).
     *
     * @param from The address where the transaction is sent from.
     * @numberOfTokensToRedeem Number of tokens that will be redeemed.
     *
     * 
     */
    function redeemTokens(address from, uint numberOfTokensToRedeem) 
        whenNotPaused
        nonReentrant public 
        customerHasEnoughTokens(from, numberOfTokensToRedeem)
        //onlyCustomer
        returns (bool success) {
        
        emit LogRedeemTokens(from, numberOfTokensToRedeem); 
        require(transactionCount > 0 && transactionCount < 256, "id must not be lower than 0 and larger than 255.");
        transactionCount = transactionCount.add(1);
        TransactionStruct memory ts = transactionList[transactionCount];
        ts.sender = from;
        ts.recipient = address(0);
        ts.amount = numberOfTokensToRedeem;
        ts.typeOfTransaction = "Redemption";
        transactionList[transactionCount] = ts;
        _burn(from, numberOfTokensToRedeem);    
        emit LogTransactionCounter(transactionCount);
        return true;
    }

    /**
     * Returns the transaction counter of the transaction (for display purposes)
     */
    function getTransactionCounter() public view returns (uint) {
        return transactionCount;
    }

    /*
     * Returns the sender address of the transaction (for display purposes)
     *
     * @param transactionId The id of the transaction the sender address should be retrieved for.
     */
    function getTransactionSenderAddress(uint transactionId) public view returns (address from) {
        require(transactionId > 0 && transactionId < 256, "id must not be lower than 0 and larger than 255.");
        TransactionStruct memory ts = transactionList[transactionId];
        return ts.sender;
    }

    /*
     * Returns the recipient address of the transaction (for display purposes)
     *
     * @param transactionId The id of the transaction the recipient address should be retrieved for.
     */
    function getTransactionRecipientAddress(uint transactionId) public view returns (address to) {
        require(transactionId > 0 && transactionId < 256, "id must not be lower than 0 and larger than 255.");
        TransactionStruct memory ts = transactionList[transactionId];
        return ts.recipient;
    }
    
    /*
     * Returns the token amount of the transaction (for display purposes)
     *
     * @param transactionId The id of the transaction the transaction amount should be retrieved for.
     */
    function getTransactionAmount(uint transactionId) public view returns (uint amount) {
       require(transactionId > 0 && transactionId < 256, "id must not be lower than 0 and larger than 255.");
       TransactionStruct memory ts = transactionList[transactionId];
       return ts.amount;
    }
    
    /*
     * Returns the type of the transaction (for display purposes)
     *
     * @param transactionId The id of the transaction the transaction type should be retrieved for.
     */
    function getTransactionType(uint transactionId) public view returns (string memory typeOfTransaction) {
       require(transactionId > 0 && transactionId < 256, "id must not be lower than 0 and larger than 255.");
       TransactionStruct memory ts = transactionList[transactionId];
       return ts.typeOfTransaction;
    }

}
