//App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
//web3 = new Web3(App.web3Provider);

const Web3 = require('web3');
var BigNumber = require('bignumber.js');
const web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');

//const web3 = new Web3('ws://localhost:8546');
const web3 = new Web3(web3Provider);
var GLTMerchantSale = artifacts.require("./GLTMerchantSale.sol");

var GoodLifeToken = artifacts.require("./GoodLifeToken.sol");

module.exports = async function(deployer, network, accounts) {
    var crowdSale;
    const ethRate = new BigNumber(50000000000000); //1 EUR Cent
    const wallet = accounts[0];
    deployer.deploy(GoodLifeToken, { from: accounts[0] }).then(() => {
      return deployer.deploy(GLTMerchantSale,
                             ethRate,
                             wallet, 
                             GoodLifeToken.address,
                             { from: accounts[0] });
    }).then(inst => {
       crowdSale = inst;
       crowdSale.token().then(async(addr) => { tokenAddress = addr;
       			var goodLifeTokenInstance = await GoodLifeToken.at(tokenAddress);
                  goodLifeTokenInstance.addMinter(crowdSale.address)});
                  //goodLifeTokenInstance.addMinter(crowdSale.address);
                  //goodLifeTokenInstance.addMinter(accounts[0])});
 
       	    
      //var token = await GoodLifeToken.deployed();
      //await token.transferOwnership(GoodLifeToken.address);       
    });      
   
}
