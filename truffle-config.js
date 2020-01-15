/*const HDWalletProvider = require('truffle-hdwallet-provider');
const infuraKey = "3e7667bb2f3b4418a7845fa615e25994";
const infuraURL = 'https://rinkeby.infura.io/v3/3e7667bb2f3b4418a7845fa615e25994';

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

var HDWallet = require('truffle-hdwallet-provider');*/


module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    //develop: {
    //  host: "127.0.0.1",	    
    //  port: 8545,
    //  network_id: "*"	    
    //}
  },
	//rinkeby: {
          //provider: () => new HDWalletProvider(mnemonic, infuraURL),
          //network_id: 4,          // Rinkeby's network id
          //gas: 5500000,
       // }

};
