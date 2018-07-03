pragma solidity ^0.4.23;

import "./CoinCow721.sol";
import "./AuctionHouse.sol";
import "./cows/CowInterface.sol";

contract CoinCowCore is CoinCow721 {
    event Birth(address owner, uint256 tokenId);

    AuctionHouse public auctionHouse;

    mapping(address => bool) registeredCowInterface;

    constructor() public {
        ceoAddress = msg.sender;
        cooAddress = msg.sender;
    }

    function registerCowInterface(address cowInterfaceAddress) public onlyCEO {
        require(!registeredCowInterface[cowInterfaceAddress]);

        CowInterface cowInterface = CowInterface(cowInterfaceAddress);
        require(cowInterface.implementsCow());
        require(cowInterface.coinCowAddress() == address(this));

        registeredCowInterface[cowInterface] = true;
    }

    function createCow(address owner) external whenNotPaused returns (uint256 tokenId) {
        CowInterface cowInterface = CowInterface(msg.sender);
        require(cowInterface.implementsCow());
        require(cowInterface.enabled());
        require(cowInterface.coinCowAddress() == address(this));

        tokenId = cows.push(Cow(msg.sender, uint64(now))) - 1;
        _transfer(address(0), owner, tokenId);
        emit Birth(owner, tokenId);
    }

    function setAuctionHouse(address _address) public onlyCEO {
        AuctionHouse candidateContract = AuctionHouse(_address);
        require(candidateContract.isAuctionHouse());

        auctionHouse = candidateContract;
    }

    function createAuction(uint256 cowId, uint256 price) public whenNotPaused {
        require(ownerOf(cowId) == msg.sender);

        cowIndexToApproved[cowId] = auctionHouse;
        auctionHouse.createAuction(cowId, price, msg.sender);
    }
}
