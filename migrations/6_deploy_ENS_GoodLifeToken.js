var namehash = require('eth-ens-namehash').hash;
var zlib = require('pako');

const Web3 = require('web3');
const web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
const web3 = new Web3(web3Provider);

var ETHENS = require('ethereum-ens');
var ethens = new ETHENS(web3Provider);



module.exports = async function(deployer, network, accounts) {

    var GoodLifeToken = artifacts.require("./GoodLifeToken.sol");
    var ENS = artifacts.require("@ensdomains/ens/ENSRegistry");
    const Resolver = artifacts.require("@ensdomains/resolver/PublicResolver");
    var resolver = await Resolver.deployed();
    var ens = await ENS.deployed();

    console.log("== Deploy GoodLifeToken");
    const goodLifeTokenNode = namehash('goodlifetoken.eth');
    const goodLifeToken = await GoodLifeToken.deployed();
    await ens.setResolver(goodLifeTokenNode, resolver.address, { from: accounts[0] });
    await resolver.setAddr(goodLifeTokenNode, goodLifeToken.address);

    const zippedABI = zlib.deflate(JSON.stringify(GoodLifeToken.abi));
    await resolver.setABI(goodLifeTokenNode, 2, zippedABI);

    console.log('== Reverse-Registration');
    var address = await resolver.addr.call(namehash('goodlifetoken.eth'));
    console.log('== GoodLifeToken deployed:', address);

    /*var lookup = address.toLowerCase().substr(2) + '.addr.reverse';
    var nh = namehash(lookup);
    //var name = await resolver.name.call(nh);
    var name = await ethens.reverse(nh).name();
    console.log('== Resolved Name: ', name);*/
}