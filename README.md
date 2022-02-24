# TechnoLime Store Blockchain Project
Develop a contract for a TechnoLime Store:
- The administrator (owner) of the store should be able to add new products and the quantity of them.
- The administrator should not be able to add the same product twice, just quantity.
- Buyers (clients) should be able to see the available products and buy them by their id.
- Buyers should be able to return products if they are not satisfied (within a certain period in blocktime: 100 blocks).
- A client cannot buy the same product more than one time.
- The clients should not be able to buy a product more times than the quantity in the store unless a product is returned or added by the administrator (owner)
- Everyone should be able to see the addresses of all clients that have ever bought a given product.
<br />

# Implementation comments
Smart contracts coded with Solidity.<br />
Frontend with ReactJS.<br />
Hardhat used for contract deployment and testing.<br />
Testing with Chai.

Although at first I implemented the solution using the Factory pattern, I changed it to a more basic implementation for simplicity and gas optimization.
<br />
<br />

# How to start the backend
Run `npm install` and play around with the following commands:
```shell
npx hardhat compile
npx hardhat test
npx hardhat node
```

After starting a local blockchain node you can open another terminal and deploy the contract using the deploy.js and open a console to the node:
```shell
npx hardhat run scripts/deploy.js --network localhost
npx hardhat console --network localhost
```

For example you can interact with the contract in the console using the following commands:
```shell
const factory = await ethers.getContractFactory('TechnoLimeStore')
const cont = await factory.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3')
var create = await cont.createProduct('iPhone 13', 100, 10)
```
<br />

# How to start the frontend
You need to first change directory to the client app `cd client` then run `npm install`.
Then you can start the frontend using `npm start`.

*In order for you to be able to interact with the contract as Owner, you need to import the first wallet address (from the list provided by the hardhad node command) to your metamask (or other) wallet.