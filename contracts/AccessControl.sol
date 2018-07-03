pragma solidity ^0.4.23;

import "./CoinCow721.sol";

contract AccessControl {
    CoinCow721 nonFungibleContract;

    constructor(address core) public {
        nonFungibleContract = CoinCow721(core);
        require(nonFungibleContract.implementsERC721());
    }

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == nonFungibleContract.ceoAddress());
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == nonFungibleContract.cfoAddress());
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == nonFungibleContract.cooAddress());
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == nonFungibleContract.cooAddress() ||
            msg.sender == nonFungibleContract.ceoAddress() ||
            msg.sender == nonFungibleContract.cfoAddress()
        );
        _;
    }

    /// @dev Modifier to allow actions only when the nonFungibleContract IS NOT paused
    modifier whenNotPaused() {
        require(!nonFungibleContract.paused());
        _;
    }

    /// @dev Modifier to allow actions only when the nonFungibleContract IS paused
    modifier whenPaused {
        require(nonFungibleContract.paused());
        _;
    }
}
