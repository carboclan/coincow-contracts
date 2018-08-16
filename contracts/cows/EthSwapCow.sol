pragma solidity  ^0.4.24;

import "../CoinCowCore.sol";
import "./CowBase.sol";

contract EthSwapCow is CowBase {
    struct MiningParam {
        uint256 ts;
        uint256 totalHashRate;
        uint256 averageBlockTimeUs;
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

    function setData(uint256 hashRate, uint256 blockTimeUs) public onlyCOO {
        MiningParam memory p = MiningParam(now, hashRate, blockTimeUs);
        miningParams.push(p);
    }

    function coinCowAddress() public view returns (address) {
        return nonFungibleContract;
    }

    function name() public view returns (string) {
        return "EthSwapCow";
    }

    function profitUnit() public view returns (string) {
        return "ETH";
    }

    function contractType() public view returns (string) {
        return "PoW";
    }

    function contractUnit() public view returns (string) {
        return "MH/s";
    }

    function milkThreshold() public view returns (uint256) {
        return 0.2 ether;
    }

    function spillThreshold() public view returns (uint256) {
        return 0.5 ether;
    }

    function stealThreshold() public view returns (uint256) {
        return 1 ether;
    }

    function withdrawThreshold() public view returns (uint256) {
        return 1 ether;
    }

    function computeProfit(uint256 _tokenId, uint256 duration, bool isEstimate) public view returns (uint256) {
        Cow storage cow = cowIdToCow[_tokenId];

        MiningParam storage mp = miningParams[miningParams.length - 1];
        if (isEstimate) {
            return duration * 1000000 / mp.averageBlockTimeUs * 3 ether * cow.contractSize * 1000000 / mp.totalHashRate;
        } else {
            uint256 profit = 0;
            uint256 ts = now;
            for (uint256 i = miningParams.length - 1; i >= 0; i--) {
                mp = miningParams[i];
                uint256 tsFrom = ts - duration;
                if (tsFrom < mp.ts) tsFrom = mp.ts;
                profit += (ts - tsFrom) * 1000000 / mp.averageBlockTimeUs * 3 ether * cow.contractSize * 1000000 / mp.totalHashRate;
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