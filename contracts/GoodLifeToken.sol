
pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./roles/CustomerRole.sol";


contract GoodLifeToken is ERC20, ERC20Detailed, ERC20Mintable, ReentrancyGuard, Ownable, CustomerRole  {

    uint public _totalSupply;
    uint transactionCount = 0;
    bytes data;
    address private _owner;
    struct TransactionStruct {
        address sender;
        address recipient;
        uint amount;
        string typeOfTransaction;
    }

    mapping (uint => TransactionStruct) transactionList;

    mapping(address => mapping(address => uint)) allowed;


    modifier merchantHasEnoughTokens(address from, uint tokensToPurchase) {
        require(balanceOf(from) >= tokensToPurchase);
        _;
    }

    modifier customerHasEnoughTokens(address from, uint tokensToRedeem) {
        require(balanceOf(from) >= tokensToRedeem);
        _;
    }



    constructor () public ERC20Detailed("GoodLifeToken", "GLT", 0) {
        _owner = msg.sender;
        _mint(msg.sender,  40000000000000000000);
        //transactionCount = 1;
    }

    //Debugging!!!!!!!!
    function gltOwner() public view returns(address) {
        return _owner;
    }



    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    /*function () external payable{
        buyTokens(msg.sender);
    }*/

    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        _transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
   /* function transferAnyERC20Token(address tokenAddress, uint tokens) public  returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }*/

    function collectTokens(address from, address to, uint purchaseAmount) public 
        merchantHasEnoughTokens(from, purchaseAmount)
        //onlyCustomer
        returns (bool success) {
        
        transactionCount++;
        TransactionStruct memory ts = transactionList[transactionCount];
        ts.sender = from;
        ts.recipient = to;
        ts.amount = purchaseAmount;
        ts.typeOfTransaction = "Collection";
        transactionList[transactionCount] = ts;
        return transferFrom(from, to, purchaseAmount);
    }

    function redeemTokens(address from, uint numberOfTokensToRedeem) nonReentrant public 
        customerHasEnoughTokens(from, numberOfTokensToRedeem)
        //onlyCustomer
        returns (bool success) {

        transactionCount++;
        TransactionStruct memory ts = transactionList[transactionCount];
        ts.sender = from;
        ts.recipient = address(0);
        ts.amount = numberOfTokensToRedeem;
        ts.typeOfTransaction = "Redemption";
        transactionList[transactionCount] = ts;
        _burn(from, numberOfTokensToRedeem);    
        return true;
    }

    function getTransactionCounter() public view returns (uint) {
        return transactionCount;
    }

    function getTransactionSenderAddress(uint transactionId) public view returns (address from) {
        TransactionStruct memory ts = transactionList[transactionId];
        return ts.sender;
    }

    function getTransactionRecipientAddress(uint transactionId) public view returns (address to) {
        TransactionStruct memory ts = transactionList[transactionId];
        return ts.recipient;
    }
   
    function getTransactionAmount(uint transactionId) public view returns (uint amount) {
       TransactionStruct memory ts = transactionList[transactionId];
       return ts.amount;
    }

    function getTransactionType(uint transactionId) public view returns (string memory typeOfTransaction) {
       TransactionStruct memory ts = transactionList[transactionId];
       return ts.typeOfTransaction;
    }

}
