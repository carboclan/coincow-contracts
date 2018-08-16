pragma solidity  ^0.4.24;

import "../CoinCowCore.sol";
import "./CowBase.sol";

contract BtcSwapCow is CowBase {
    struct MiningParam {
        uint256 ts;
        uint256 difficulty;
        uint256 btcPerBlock;
    }

    MiningParam[] miningParams;

    constructor(address coreAddress, address farmAddress) public CowBase(coreAddress, farmAddress) {
    }

    function implementsCow() public pure returns (bool) {
        return true;
    }

    function enabled() public view returns (bool) {
        return miningParams.length > 0;
    }

    function setData(uint256 difficulty, uint256 btcPerBlock) public onlyCOO {
        MiningParam memory p = MiningParam(now, difficulty, btcPerBlock);
        miningParams.push(p);
    }

    function coinCowAddress() public view returns (address) {
        return nonFungibleContract;
    }

    function name() public view returns (string) {
        return "BtcSwapCow";
    }

    function profitUnit() public view returns (string) {
        return "BTC";
    }

    function contractType() public view returns (string) {
        return "PoW";
    }

    function contractUnit() public view returns (string) {
        return "GH/s";
    }

    function milkThreshold() public view returns (uint256) {
        return 0.02 ether;
    }

    function spillThreshold() public view returns (uint256) {
        return 0.05 ether;
    }

    function stealThreshold() public view returns (uint256) {
        return 0.1 ether;
    }

    function withdrawThreshold() public view returns (uint256) {
        return 1 ether;
    }

    function computeProfit(uint256 _tokenId, uint256 duration, bool isEstimate) public view returns (uint256) {
        Cow storage cow = cowIdToCow[_tokenId];

        MiningParam storage mp = miningParams[miningParams.length - 1];
        if (isEstimate) {
            return mp.btcPerBlock * duration / (mp.difficulty * 2 ** 32 / (cow.contractSize * 1000000000));
        } else {
            uint256 profit = 0;
            uint256 ts = now;
            for (uint256 i = miningParams.length - 1; i >= 0; i--) {
                mp = miningParams[i];
                uint256 tsFrom = ts - duration;
                if (tsFrom < mp.ts) tsFrom = mp.ts;
                profit += mp.btcPerBlock * (ts - tsFrom) / (mp.difficulty * 2 ** 32 / (cow.contractSize * 1000000000));
                duration -= ts - tsFrom;
                ts = tsFrom;
                if (duration == 0) break;
            }

            return profit;
        }
    }

    function createCow(uint256 hashPower, uint256 duration) public onlyUnderwriter {
        Cow memory cow = Cow(
            true,
            hashPower,
            0,
            uint64(now),
            uint64(now),
            uint64(now + duration * 1 days),
            0,
            0
        );

        CoinCowCore core = CoinCowCore(nonFungibleContract);
        uint256 tokenId = core.createCow(msg.sender);

        cowIdToCow[tokenId] = cow;
        emit CowCreated(tokenId, cow.contractSize);
    }
}