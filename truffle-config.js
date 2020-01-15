const HDWalletProvider = require('truffle-hdwallet-provider');
const infuraKey = "1803d45e627e4b768d06410f3071e329";
const infuraURL = 'https://ropsten.infura.io/v3/6fe674208a2943f9aeb282f4705b483b';

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

var HDWallet = require('truffle-hdwallet-provider');


module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },

    ropsten: {
    provider: () => new HDWalletProvider(mnemonic, infuraURL),
    network_id: 3,          // Ropsten network id
          gas: 5500000,
    }
  }	  
}
