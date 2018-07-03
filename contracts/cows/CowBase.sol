pragma solidity ^0.4.23;

import "../Farm.sol";
import "./CowInterface.sol";

contract CowBase is CowInterface, AccessControl {
    Farm farm;

    constructor(address coreAddress, address farmAddress) public AccessControl(coreAddress) {
        farm = Farm(farmAddress);
    }

    struct Cow {
        bool exists;
        uint256 contractSize;
        uint256 lastStolen;
        uint64 lastMilkTime;
        uint64 startTime;
        uint64 endTime;
        uint256 totalMilked;
        uint256 totalStolen;
    }

    mapping(address => uint256) public balanceOf;
    mapping(uint256 => Cow) cowIdToCow;

    event CowCreated(uint256 tokenId, uint256 contractSize);
    event Milked(address owner, uint256 tokenId, uint256 amount);
    event Stolen(address user, uint256 tokenId, uint256 amount);
    event Withdraw(address user, uint256 amount);

    function profitUnit() public view returns (string);
    function contractType() public view returns (string);
    function contractUnit() public view returns (string);

    function milkThreshold() public view returns (uint256);
    function spillThreshold() public view returns (uint256);
    function stealThreshold() public view returns (uint256);
    function withdrawThreshold() public view returns (uint256);

    function milkAvailable(uint256 _tokenId) public view returns (uint256);

    function milk(uint256 _tokenId) public {
        Cow storage cow = cowIdToCow[_tokenId];
        require(cow.exists);

        address owner = nonFungibleContract.ownerOf(_tokenId);
        require(msg.sender == owner);
        require(farm.userToFarmId(msg.sender) > 0);

        uint256 available = milkAvailable(_tokenId);
        require(available >= milkThreshold());

        balanceOf[msg.sender] += available;
        cow.lastMilkTime = uint64(now);
        cow.totalMilked += available;
        cow.lastStolen = 0;

        emit Milked(msg.sender, _tokenId, available);
    }

    function steal(uint256 _tokenId) public {
        Cow storage cow = cowIdToCow[_tokenId];
        require(cow.exists);
        address owner = nonFungibleContract.ownerOf(_tokenId);
        require(farm.userToFarmId(msg.sender) > 0);
        require(farm.userToFarmId(owner) == farm.userToFarmId(msg.sender));

        uint256 available = milkAvailable(_tokenId);
        require(available >= stealThreshold());

        uint256 stolen = available - spillThreshold();
        balanceOf[msg.sender] += stolen;
        cow.totalStolen += stolen;
        cow.lastStolen = stolen;

        emit Stolen(msg.sender, _tokenId, stolen);
    }

    function withdraw() public {
        require(balanceOf[msg.sender] >= withdrawThreshold());

        emit Withdraw(msg.sender, balanceOf[msg.sender]);
        balanceOf[msg.sender] = 0;
    }

    function isThisType(uint256 _tokenId) public view returns (bool) {
        return cowIdToCow[_tokenId].exists;
    }

    function getCowInfo(uint256 _tokenId) public view returns (
        uint256 contractSize,
        uint256 lastStolen,
        uint256 lastMilkTime,
        uint256 startTime,
        uint256 endTime,
        uint256 totalMilked,
        uint256 totalStolen
    ) {
        Cow storage cow = cowIdToCow[_tokenId];
        if (!cow.exists) return ;

        contractSize = cow.contractSize;
        lastStolen = cow.lastStolen;
        lastMilkTime = cow.lastMilkTime;
        startTime = cow.startTime;
        endTime = cow.endTime;
        totalMilked = cow.totalMilked;
        totalStolen = cow.totalStolen;
    }
}
