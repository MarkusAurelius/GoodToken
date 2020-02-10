const Web3 = require('web3')
const { waitForEvent } = require('./utils')
const kraken = artifacts.require('./oracle/KrakenPriceTicker.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8545'))

contract('Kraken Price Ticker Tests', accounts => {

  let priceETHEUR
  let krakenPriceTickerInstance
  const gasAmt = 3e6
  const address = accounts[0]

  /*beforeEach(async () => (
    { contract } = await kraken.deployed(),
    { methods, events } = new web3.eth.Contract(
      contract._jsonInterface,
      contract._address
    )
  ))*/

  beforeEach(async () => {
    var contract = await kraken.deployed()
    var jsonInterface = require('../build/contracts/KrakenPriceTicker.json');
    krakenPriceTickerInstance = new web3.eth.Contract(
      jsonInterface.abi,
      contract.address
    )
  })


  it('Should log a new Provable query', async () => {
    console.log("Web3 version: " + Web3.version.api)
    const {
      returnValues: {
        description
      }
    } = await waitForEvent(krakenPriceTickerInstance.events.LogNewProvableQuery)
    assert.strictEqual(
      description,
      'Provable query was sent, standing by for the answer...',
      'Provable query incorrectly logged!'
    )
  })

  it('Callback should log a new ETHEUR price', async () => {
    //let contractInstance = await kraken.deployed()
    //krakenPriceTickerInstance.methods.transfer(web3.utils.toBN(web3.utils.toWei('1', 'ether'))).send({from: address, gas: 21000, gasPrice: 0x00}).then(receipt=> {consol.log(receipt)})
    //.then(function(receipt){console.log(receipt)})
    //krakenPriceTickerInstance.methods.send(web3.utils.toBN(web3.utils.toWei('1', 'ether')), {from: address})
    //await contractInstance.sendTransaction({from: web3.eth.accounts[0], to: krakenPriceTickerInstance.options.address, value: web3.utils.toBN(web3.utils.toWei('1', 'ether'))}, {from: web3.eth.accounts[0]})
    
    //triggerTransferInstance.sendEther(krakenPriceTickerInstance.options.address, web3.utils.toBN(web3.utils.toWei('1', 'ether')))
    
    const {
      returnValues: {
        price
      }
    } = await waitForEvent(krakenPriceTickerInstance.events.LogNewKrakenPriceTicker)
    priceETHEUR = price
    assert.isAbove(
      parseFloat(price),
      0,
      'A price should have been retrieved from Provable call!'
    )
  })

  it('Should set ETHEUR price correctly in contract', async () => {
    const queriedPrice = await krakenPriceTickerInstance.methods
      .priceETHEUR()
      .call()
    assert.strictEqual(
      priceETHEUR,
      queriedPrice,
      'Contract\'s ETHEUR price not set correctly!'
    )
  })

  it('Should log a failed query due to lack of funds', async () => {
    const { events } = await krakenPriceTickerInstance.methods
      .update()
      .send({
        from: address,
        gas: gasAmt
      })
    const description = events.LogNewProvableQuery.returnValues.description
    assert.strictEqual(
      description,
      'Provable query was NOT sent, please add some ETH to cover for the query fee!',
      'Provable query incorrectly logged!'
    )
  })
})
