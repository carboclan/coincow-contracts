// const debug = require('debug')('CC');
// const BigNumber = web3.BigNumber;

const UserInfo = artifacts.require('./UserInfo.sol');
const CoinCowCore = artifacts.require('./CoinCowCore.sol');
const AuctionHouse = artifacts.require('./AuctionHouse.sol');
const Farm = artifacts.require('./Farm.sol');
const TestCow = artifacts.require('./cows/TestCow.sol');

contract('TestAll', async accounts => {
    let userInfo, coinCowCore, auctionHouse, farm;
    let testBtcCow, testBchCow, testEthCow, testLamaCow;

    async function deploy() {
        userInfo = await UserInfo.new();
        coinCowCore = await CoinCowCore.new();

        auctionHouse = await AuctionHouse.new(coinCowCore.address);
        await coinCowCore.setAuctionHouse(auctionHouse.address);

        farm = await Farm.new(coinCowCore.address);

        testBtcCow = await TestCow.new(coinCowCore.address, farm.address, 'Test BTC Cow', 'TH/s', 'POW', 'BTC');
        testBchCow = await TestCow.new(coinCowCore.address, farm.address, 'Test BCH Cow', 'TH/s', 'POW', 'BCH');
        testEthCow = await TestCow.new(coinCowCore.address, farm.address, 'Test ETH Cow', 'TH/s', 'POW', 'ETH');
        testLamaCow = await TestCow.new(coinCowCore.address, farm.address, 'Test LAMA Cow', 'CCC', 'PLATFORM', 'ETH');

        await coinCowCore.registerCowInterface(testBtcCow.address);
        await coinCowCore.registerCowInterface(testBchCow.address);
        await coinCowCore.registerCowInterface(testEthCow.address);
        await coinCowCore.registerCowInterface(testLamaCow.address);
    }

    describe('Initial state', function() {
        before(deploy);

        it('should own contract', async function() {
            const cooAddress = await coinCowCore.cooAddress();
            assert.equal(cooAddress, accounts[0]);

            const nCows = await coinCowCore.totalSupply();
            assert.equal(nCows.toNumber(), 0);
        });
    });
    
    describe('Auction & Farm', async function () {
        before(deploy);

        it('should work as expected', async function () {
            await testBtcCow.createCow();
            const tokenId = await coinCowCore.totalSupply();
            assert.equal(tokenId, 1);
            assert.equal(await coinCowCore.ownerOf(tokenId), accounts[0]);

            await coinCowCore.createAuction(tokenId, web3.toWei(1, 'ether'));
            assert.equal(await auctionHouse.isOnAuction(tokenId), true);

            const [seller, price] = await auctionHouse.getAuction(tokenId);
            assert.equal(seller, accounts[0]);
            assert.equal(price, web3.toWei(1, 'ether'));
        });
    });
});