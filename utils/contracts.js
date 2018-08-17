const addresses = require('../build/contract_addresses.json');

const userInfoAbi = require('../build/contracts/UserInfo.json').abi;
const btcSwapCow = require('../build/contracts/BtcSwapCow.json').abi;
const ethSwapCow = require('../build/contracts/EthSwapCow.json').abi;
const coinCowCoreAbi = require('../build/contracts/CoinCowCore.json').abi;
const farmAbi = require('../build/contracts/Farm.json').abi;
const auctionHouseAbi = require('../build/contracts/AuctionHouse.json').abi;

module.exports = web3 => ({
  contracts: {
    userInfo:web3.loadContract(userInfoAbi, addresses.userInfo),
    ethSwapCow: web3.loadContract(ethSwapCow, addresses.ethSwapCow),
    btcSwapCow: web3.loadContract(btcSwapCow, addresses.btcSwapCow),
    coinCowCore: web3.loadContract(coinCowCoreAbi, addresses.coinCowCore),
    farm: web3.loadContract(farmAbi, addresses.farm),
    auctionHouse: web3.loadContract(auctionHouseAbi, addresses.auctionHouse)
  }
});