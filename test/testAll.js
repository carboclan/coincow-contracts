// const debug = require('debug')('CC');
// const BigNumber = web3.BigNumber;

const UserInfo = artifacts.require('./UserInfo.sol');
const CoinCowCore = artifacts.require('./CoinCowCore.sol');
const AuctionHouse = artifacts.require('./AuctionHouse.sol');
const Farm = artifacts.require('./Farm.sol');
const EthSwapCow = artifacts.require('./cows/EthSwapCow.sol');
const BtcSwapCow = artifacts.require('./cows/BtcSwapCow.sol');

contract('TestAll', async accounts => {
    let userInfo, coinCowCore, auctionHouse, farm;
    let btcSwapCow, ethSwapCow;

    async function deploy() {
        userInfo = await UserInfo.new();
        coinCowCore = await CoinCowCore.new();

        farm = await Farm.new(coinCowCore.address);

        auctionHouse = await AuctionHouse.new(coinCowCore.address, farm.address);
        await coinCowCore.setAuctionHouse(auctionHouse.address);

        btcSwapCow = await BtcSwapCow.new(coinCowCore.address, farm.address);
        ethSwapCow = await EthSwapCow.new(coinCowCore.address, farm.address);

        await ethSwapCow.setData(283675708561669, 14592636);
        await btcSwapCow.setData(6389316883511, 12.5 * 1e18);

        await coinCowCore.registerCowInterface(btcSwapCow.address);
        await coinCowCore.registerCowInterface(ethSwapCow.address);
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
            await btcSwapCow.createCow(14000, 7);
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