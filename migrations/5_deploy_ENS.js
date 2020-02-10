var ENS = artifacts.require("@ensdomains/ens/ENSRegistry");
const FIFSRegistrar = artifacts.require("@ensdomains/ens/FIFSRegistrar");
const ReverseRegistrar = artifacts.require("@ensdomains/ens/ReverseRegistrar");
const Resolver = artifacts.require("@ensdomains/resolver/PublicResolver");

var namehash = require('eth-ens-namehash').hash;
var sha3 = require('js-sha3').keccak_256

module.exports = function(deployer, network, accounts) {
    deployer.then(asyncDeployment);

    async function asyncDeployment() {
        let result;

        console.log("== Deploy ENS");
        const ens = await deployer.deploy(ENS, { from: accounts[0] });
        await deployer.deploy(Resolver, ens.address);

        console.log("== Deploy Root-Registra");
        const rootRegistra = await deployer.deploy(FIFSRegistrar, ens.address, namehash(''), { from: accounts[0] });
        await ens.setOwner(namehash(''), rootRegistra.address, { from: accounts[0] });

        console.log('== Deploy PublicResolver');
        const resolver = await deployer.deploy(Resolver, ens.address, { from: accounts[0] });

        console.log("== Deploy Reverse-Registra");
        const reverseRegistra = await deployer.deploy(ReverseRegistrar, ens.address, resolver.address, { from: accounts[0] });

        console.log('== Register eth');
        await rootRegistra.register("0x" + sha3("eth"), accounts[0], { from: accounts[0] })

        console.log('== Register goodlifetoken.eth');
        await ens.setSubnodeOwner(namehash('eth'), "0x" + sha3('goodlifetoken'), accounts[0], { from: accounts[0] })

        console.log('== Register reverse')
        await rootRegistra.register("0x" + sha3("reverse"), accounts[0], { from: accounts[0] })

        console.log('== Register addr.reverse');
        await ens.setSubnodeOwner(namehash('reverse'), "0x" + sha3('addr'), reverseRegistra.address, { from: accounts[0] })

        console.log('ENS-Address', ens.address);
    }
};