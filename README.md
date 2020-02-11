# Good Life Token

### Motivation:

**Merchants:**
Merchants of small organic stores have got frequently the challenge to build and keep up a reliable loyalty customer base. A loyalty programme based on a so-called "Good-Life-Token" should support the merchant to incentivate customers with those tokens to make purchases in his store. 

**Customers:**
Customers will probably change their consumer decisions if they are incentivized with "Good-Life-Tokens" for each purchase they are doing in an organic store that is participating in "Good-Life-Token"-based loyalty programme. Depending on a product a customer is purchasing he gets a certain amount of "Good-Life-Tokens". Each product has got a different Eco Footprint Factor, which serves as a multiplier for the token calculation, that consists of the price of the product (for each cent one token is given) multiplied by the Eco Footprint Factor. In doing so one cent correspondents to one token. The amount of collected tokens is shown in his shopping basket. When finalizing the purchase the amount of token is funded to the wallet of the customer.
When the customer has collected a sufficient a amount of tokens he will be able spend those for his next purchase. 

For a sustainable loyalty program local merchants who are selling fair traded and local organic products should be able to purchase a Good Life Token for a certain amount of Euros. This token should be given to a customer of his store for every purchase. The amount of token the customer will be provided with depends on the purchase amount, the eco foot print and the quantity of the product. The customer will be able to redeem / to use this tokens for a (partial) payment of one of the next purchases at a merchant store who is participating in this loyalty program.  

**User Stories:**
- As a merhchant I would like to perform a login by using my uport Mobile app in order to invoke the page of the Good Life Token Sale.

- As a merchant I would like to purchase a certain amount of token for a given amount of Euros. This amount of tokens will bes tored into my account.
  The amount of token that I want to purchase as a merchant is either linked to the provided amount of EUR with a fixed rate (1 Good Life Token = 1 EUR Cent) or it is calculated based on the rate of Ether / Euro provided by an external data source (Oracle Kraken Price Ticker). The assumption in doing so is, that a rate of 150 EUR = 1 Ether = 15.000 Good Life Tokens corresponds to the fixed linkage of Euros and tokens. If the rate is higher than this the purchase for the merchant will be more expensive if the rate is below the buying will become cheaper.

- As a customer I would like to select a range of products by putting them into my shopping basket.

- As a customer I would like to be rewarded for a purchase at a store that is participating at the Good Life Token loyalty program by an amount of tokens which depends on the eco foot print, the price and the quantity of the products which I am going to buy. 

- Assign the Ethereum address of the token to a human readable name "goodlifetoken.eth".

**UX Restrictions:**
The UI only consists of very elementary and simple design elements and features.
The display of the processed loyalty transactions is implmented in the GoodLifeToken contract but however not yet in the web application.

The process flow between all stakeholders looks as follows:
![Alt text](/src/images/GoodLifeToken_Flow_Chart.png?raw=true "Process Flow Chart")

The web based demo application is currently able to use only one account because of the [missing capability of Metamask to unlock multiple accounts at the same time.](https://medium.com/metamask/metamask-permissions-system-delay-retrospective-9c49d01039d6)

## Getting Started

This project was developed with the following environment:

- Ubuntu 18.04.2 LTS
- npm 6.9.0
- Truffle v5.1.8 (core: 5.1.8)
- Solidity v0.5.0 (solc-js)
- Node v10.16.3
- Web3.js v1.2.5
- Ngrok 3.2.7
- Express 4.17.1


#### 1 - Requirements:

###### WebServer and Smart Contracts Development/Deployment

- [node](https://nodejs.org)
- [npm](https://www.npmjs.com/)
- Install [truffle](https://www.trufflesuite.com/truffle): `npm install truffle -g`
- Download and install [Ganache Gui](https://www.trufflesuite.com/ganache) or [ganache-cli](https://www.npmjs.com/package/ganache-cli). Follow the provided instructions to install the desired version of Ganache. Make sure you configure your ganache application to use Port Number 8545.
- Install [OpenZeppelin](https://openzeppelin.com/contracts/): `npm install openzeppelin-solidity@2.3.0`
- Install [OpenZeppelin Test Environment](https://docs.openzeppelin.com/test-environment/0.1/): `npm install --save-dev @openzeppelin/test-environment`
- Install OpenZeppelin Test Helpers: `npm install --save-dev @openzeppelin/test-helpers`
- Install Chai: `npm install chai`
- Install Web3:  `npm install web3`
- Install lite-server: `npm install lite-server --save-dev`
- Install bignumber.js: `npm install bignumber.js`
- Install HdWallet-Provider: `npm install --save truffle-hdwallet-provider`


###### Front-end

- A web browser that supports Metamask like Google Chrome, Firefox or Opera
- Install [Metamask Extension](https://metamask.io/)

#### 2 - Clone the repo to your desired folder

```.sh
git clone https://github.com/MarkusAurelius/GoodToken.git 
```

#### 3 - Move to the project folder, install dependencies and setup config files

```.sh
cd good-life-token 
npm install
```

###### Oracle - Oraclize
```.sh
npm install ethereum/web3.js --save
truffle install oraclize-api
npx ethereum-bridge -a 9 -H 127.0.0.1 -p 8545 --dev
```
Please note: Since the test were running into a timeout when executing those together with the other tests please perform the following steps for testing the Oraclize contracts:
```.sh
mv test test_org
mv test_oracle test
truffle test
```
###### Ethereum Name Service
```.sh
npm install @ensdomains/ens --save-dev
npm install @ensdomains/resolver
```

###### Uport
```.sh
npm install --save ngrok express path
```

## Running the project locally

#### Smart Contracts

You can use commands below to compile, migrate and test the smart contracts. Make sure you're running `GanacheGui` or `ganache-cli` on your localhost (127.0.0.1) at Port Number 8545 before running these commands.

- compile: `truffle compile`
- migrate: `truffle migrate`
- run unit tests: `truffle test`

#### Running Web dev-server to serve the Front-End

You'll need to run the following command to start you local dev-server. Once the project is compiled, a webbrowser should open automatically on your local machine. The local dev-server runs at `http://localhost:8080/`

Start web dev-server: `npm run start`

*When you access the application, make sure your selected network on Metamask is either `localhost`, `covan` or `ropsten`.*

