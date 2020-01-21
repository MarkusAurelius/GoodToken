# Good Life Token

### Motivation:

**Merchants:**
Merchants of small organic stores have got frequently the challenge to build and keep up a reliable loyalty customer base. A loyalty programme based on a so-called "Good-Life-Token" should support the merchant to incentivate customers with those tokens to make purchases in his store. 

**Customers:**
Customers will probably change their consumer decisions if they are incentivized with "Good-Life-Tokens" for each purchase they are doing in an organic store that is participating in "Good-Life-Token"-based loyalty programme. Depending on a product a customer is purchasing he gets a certain amount of "Good-Life-Tokens". Each product has got a different Eco Footprint Factor, which serves as a multiplier for the token calculation, that consists of the price of the product (for each cent one token is given) multiplied by the Eco Footprint Factor. It applies that one cent correspondents to one token. The amount of collected tokens is shown in his shopping basket. When finalizing the purchase the amount of token is funded to the wallet of the customer.
When the customer has collected a sufficient a amount of tokens he can spend those for the next purchase. 

For a sustainable loyalty program local merchants who are selling fair traded and local organic products should beable to purchase a Good Life Token for a certain amount of Euros. This token should be given to a customer of his store for every purchase. The amount of token the customer will be provided with depends on the purchase amount. The customer will be able to redeem / to use this tokens for a (partial) payment of one of the next purchases at a merchant store who is participating in this loyalty program.  

**User Stories:**
A merchant is purchasing a certain amount of token for an amount of Euros. This amount of tokens will bestored into his account.

For a purchase that a customer of the merchant is performing an amount of token (depending on the purchase amount) will be transferred from the customer to the merchant.

A customer is making a purchase at a store of a merchant and will partially pay the purchase amount with tokens.

The process flow between all stakeholders looks as follows:
![Alt text](/src/image/contract-diagram.png?raw=true "Process Flow Chart")

The web based demo application is currently able to use only one account because of the [missing capability of Metamask to unlock multiple accounts at the same time.](https://medium.com/metamask/metamask-permissions-system-delay-retrospective-9c49d01039d6)

## Getting Started

This project was developed with the following environment:

- Ubuntu Ubuntu 18.04.2 LTS
- npm 6.9.0
- Truffle v5.0.24 (core: 5.0.24)
- Solidity v0.5.0 (solc-js)
- Node v12.14.1
- Web3.js v1.0.0-beta.37


#### 1 - Requirements:

###### WebServer and Smart Contracts Development/Deployment

- [node](https://nodejs.org)
- [npm](https://www.npmjs.com/)
- Install [truffle](https://www.trufflesuite.com/truffle): `npm install truffle -g`
- Download and install [Ganache Gui](https://www.trufflesuite.com/ganache) or [ganache-cli](https://www.npmjs.com/package/ganache-cli). Follow the provided instructions to install the desired version of Ganache. Make sure you configure your ganache application to use Port Number 8545.
- Install [OpenZeppelin](https://openzeppelin.com/contracts/): `npm install openzeppelin-solidity@2.3.0`
- Install Web3:  `npm install web3`
- Install lite-server: `npm install lite-server --save-dev`


  ```.sh
  npm install -g truffle
  ```

###### Front-end

- A web browser that supports Metamask like Google Chrome, Firefox or Opera
- Install [Metamask Extension](https://metamask.io/)

#### 2 - Clone the repo to your desired folder

```.sh
git clone https://github.com/MarkusAurelius1976/GoodToken.git 
```

#### 3 - Move to the project folder, install dependencies and setup config files

```.sh
cd good-life-token 
npm install
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

