pragma solidity  ^0.4.24;

import "./Farm.sol";
import "./AccessControl.sol";

contract AuctionHouse is AccessControl {
    struct Auction {
        address seller;
        uint128 price;
        uint64 ts;
    }

    event FarmOwnerReward(address owner, uint256 amount, uint256 tokenId, uint256 farmId, uint256 ts);
    event AuctionCreated(uint256 tokenId, uint256 price, uint256 ts);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner, uint256 ts);
    event AuctionCancelled(uint256 tokenId, uint256 ts);

    modifier canBeStoredWith128Bits(uint256 _value) {
        require(_value < 340282366920938463463374607431768211455);
        _;
    }

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;
    uint256 public farmCut;
    Farm farm;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) tokenIdToAuction;

    constructor(address core, address farmAddress) public AccessControl(core) {
        farm = Farm(farmAddress);
    }

    function isAuctionHouse() public pure returns (bool) {
        return true;
    }

    function isOnAuction(uint256 tokenId) public view returns(bool) {
        return tokenIdToAuction[tokenId].seller != address(0);
    }

    function setOnwerCut(uint256 cut) public onlyCOO {
        ownerCut = cut;
    }

    function setFarmCut(uint256 cut) public onlyCOO {
        farmCut = cut;
    }

    function getAuction(uint256 tokenId) public view returns(address seller, uint128 price, uint256 ts) {
        Auction storage auction = tokenIdToAuction[tokenId];
        seller = auction.seller;
        price = auction.price;
        ts = auction.ts;
    }

    function createAuction(uint256 tokenId, uint256 price, address seller) external whenNotPaused canBeStoredWith128Bits(price) {
        require(msg.sender == address(nonFungibleContract));
        nonFungibleContract.transferFrom(seller, this, tokenId);

        tokenIdToAuction[tokenId] = Auction(seller, uint128(price), uint64(now));
        emit AuctionCreated(tokenId, price, uint64(now));
    }

    function bid(uint256 _tokenId) public payable whenNotPaused {
        // _bid verifies token ID size
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(msg.value >= auction.price);

        uint256 auctioneerCut = _computeCut(auction.price);
        uint256 farmOwnerCut = _computeFarmCut(auction.price);
        uint256 sellerProceeds = auction.price - auctioneerCut - farmOwnerCut;

        if (farmOwnerCut > 0) {
            uint256 farmId = farm.userToFarmId(auction.seller);
            address owner;
            (owner,,) = farm.getInfo(farmId);
            owner.transfer(farmOwnerCut);
            emit FarmOwnerReward(owner, farmOwnerCut, _tokenId, farmId, now);
        }

        auction.seller.transfer(sellerProceeds);
        nonFungibleContract.transfer(msg.sender, _tokenId);
        delete tokenIdToAuction[_tokenId];

        emit AuctionSuccessful(_tokenId, auction.price, msg.sender, now);
    }

    /// @dev Cancels an auction unconditionally.
    function cancelAuction(uint256 _tokenId) public whenNotPaused {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(auction.seller == msg.sender);

        nonFungibleContract.transfer(msg.sender, _tokenId);
        delete tokenIdToAuction[_tokenId];

        emit AuctionCancelled(_tokenId, now);
    }

    function withdrawBalance() public onlyCFO {
        address(nonFungibleContract).transfer(address(this).balance);
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function _computeCut(uint256 _price) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000. The result of this
        //  function is always guaranteed to be <= _price.
        return _price * ownerCut / 10000;
    }

    function _computeFarmCut(uint256 _price) internal view returns (uint256) {
        return _price * farmCut / 10000;
    }
}
