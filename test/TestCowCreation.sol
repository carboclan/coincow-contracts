pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/CoinCowCore.sol";

contract EmptyCowInterface is CowInterface {
    function implementsCow() public pure returns (bool) { return true; }
    function enabled() public view returns (bool) { return true; }
    function name() public view returns (string) { return "EmptyCowInterface"; }
    function coinCowAddress() public view returns (address) { return nonFungibleContract; }

    address nonFungibleContract;

    constructor(address cowAddress) public {
        nonFungibleContract = cowAddress;
    }

    function testCreate() public returns(uint256 tokenId) {
        CoinCowCore core = CoinCowCore(nonFungibleContract);
        tokenId = core.createCow(msg.sender);
    }
}

contract TestCowCreation {
    function testCreate() public {
        CoinCowCore core = new CoinCowCore();
        EmptyCowInterface ci = new EmptyCowInterface(address(core));

        core.registerCowInterface(ci);

        uint256 newId = ci.testCreate();
        Assert.equal(newId, core.totalSupply(), "Created cow id should be equal to totalSupply.");
    }
}
