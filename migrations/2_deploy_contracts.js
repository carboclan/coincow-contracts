const fs = require('fs');

const UserInfo = artifacts.require('./UserInfo.sol');
const CoinCowCore = artifacts.require('./CoinCowCore.sol');
const AuctionHouse = artifacts.require('./AuctionHouse.sol');
const Farm = artifacts.require('./Farm.sol');
const TestCow = artifacts.require('./cows/TestCow.sol');

module.exports = async function(deployer) {
  deployer.then(async () => {
    await deployer.deploy(UserInfo);
    const userInfo = await UserInfo.deployed();

    await deployer.deploy(CoinCowCore);
    const coinCowCore = await CoinCowCore.deployed();

    await deployer.deploy(AuctionHouse, coinCowCore.address);
    const auctionHouse = await AuctionHouse.deployed();
    await coinCowCore.setAuctionHouse(auctionHouse.address);

    await deployer.deploy(Farm, coinCowCore.address);
    const farm = await Farm.deployed();

    await deployer.deploy(TestCow, coinCowCore.address, farm.address, 'Test BTC Cow', 'TH/s', 'POW', 'BTC');
    const testBtcCow = await TestCow.deployed();
    await deployer.deploy(TestCow, coinCowCore.address, farm.address, 'Test BCH Cow', 'TH/s', 'POW', 'BCH');
    const testBchCow = await TestCow.deployed();
    await deployer.deploy(TestCow, coinCowCore.address, farm.address, 'Test ETH Cow', 'TH/s', 'POW', 'ETH');
    const testEthCow = await TestCow.deployed();
    await deployer.deploy(TestCow, coinCowCore.address, farm.address, 'Test LAMA Cow', 'CCC', 'PLATFORM', 'ETH');
    const testLamaCow = await TestCow.deployed();

    await coinCowCore.registerCowInterface(testBtcCow.address);
    await coinCowCore.registerCowInterface(testBchCow.address);
    await coinCowCore.registerCowInterface(testEthCow.address);
    await coinCowCore.registerCowInterface(testLamaCow.address);
    
    try {
      fs.writeFileSync(__dirname + '/../build/contract_addresses.json', JSON.stringify({
        userInfo: userInfo.address,
        coinCowCore: coinCowCore.address,
        auctionHouse: auctionHouse.address,
        farm: farm.address,
        testBtcCow: testBtcCow.address,
        testBchCow: testBchCow.address,
        testEthCow: testEthCow.address,
        testLamaCow: testLamaCow.address
      }));
    } catch (e) {
      
    }
  });
};