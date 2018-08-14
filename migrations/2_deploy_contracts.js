const fs = require('fs');

const UserInfo = artifacts.require('./UserInfo.sol');
const CoinCowCore = artifacts.require('./CoinCowCore.sol');
const AuctionHouse = artifacts.require('./AuctionHouse.sol');
const Farm = artifacts.require('./Farm.sol');
const EthSwapCow = artifacts.require('./cows/EthSwapCow.sol');
const BtcSwapCow = artifacts.require('./cows/BtcSwapCow.sol');

module.exports = async function(deployer) {
  deployer.then(async () => {
    await deployer.deploy(UserInfo);
    const userInfo = await UserInfo.deployed();

    await deployer.deploy(CoinCowCore);
    const coinCowCore = await CoinCowCore.deployed();

    await deployer.deploy(Farm, coinCowCore.address);
    const farm = await Farm.deployed();

    await deployer.deploy(AuctionHouse, coinCowCore.address, farm.address);
    const auctionHouse = await AuctionHouse.deployed();
    await coinCowCore.setAuctionHouse(auctionHouse.address);

    await deployer.deploy(EthSwapCow, coinCowCore.address, farm.address);
    const ethSwapCow = await EthSwapCow.deployed();
    await deployer.deploy(BtcSwapCow, coinCowCore.address, farm.address);
    const btcSwapCow = await BtcSwapCow.deployed();

    await ethSwapCow.setData(283675708561669, 14592636);
    await btcSwapCow.setData(6389316883511, 12.5 * 1e18);

    await coinCowCore.registerCowInterface(ethSwapCow.address);
    await coinCowCore.registerCowInterface(btcSwapCow.address);

    try {
      fs.writeFileSync(__dirname + '/../build/contract_addresses.json', JSON.stringify({
        userInfo: userInfo.address,
        coinCowCore: coinCowCore.address,
        auctionHouse: auctionHouse.address,
        farm: farm.address,
        ethSwapCow: ethSwapCow.address,
        btcSwapCow: btcSwapCow.address
      }));
    } catch (e) {
      
    }
  });
};