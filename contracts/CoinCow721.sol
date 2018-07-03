pragma solidity ^0.4.23;

import "./ERC721.sol";
import "./CoinCowAccessControl.sol";

contract CoinCow721 is CoinCowAccessControl, ERC721 {
    struct Cow {
        address contractAddress;
        uint64 birthTime;
    }

    Cow[] cows;
    mapping (uint256 => address) public cowIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;
    mapping (uint256 => address) public cowIndexToApproved;

    constructor() public {
        cows.length = 1;
    }

    function implementsERC721() public pure returns (bool) {
        return true;
    }

    function totalSupply() public view returns (uint256 total) {
        total = cows.length - 1;
    }

    function balanceOf(address _owner) public view returns (uint256 count) {
        count = ownershipTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        owner = cowIndexToOwner[_tokenId];
    }

    function approve(address _to, uint256 _tokenId) public whenNotPaused {
        require(ownerOf(_tokenId) == msg.sender);

        cowIndexToApproved[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
        require(_to != address(0));
        require(cowIndexToApproved[_tokenId] == msg.sender);
        require(ownerOf(_tokenId) == _from);

        _transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public whenNotPaused {
        require(_to != address(0));
        require(ownerOf(_tokenId) == msg.sender);

        _transfer(msg.sender, _to, _tokenId);
    }

    /// @dev Assigns ownership of a specific Cow to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // there is no way to overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        cowIndexToOwner[_tokenId] = _to;

        // When creating new snakes _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete cowIndexToApproved[_tokenId];
        }

        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }
}
