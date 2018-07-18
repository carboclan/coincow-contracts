pragma solidity ^0.4.23;

import "./AccessControl.sol";

contract Farm is AccessControl {
    event Created(address owner, uint256 farmId, bytes32 name);
    event Joined(address user, uint256 farmId);

    struct FarmInfo {
        address owner;
        bytes32 name;
        uint256 size;
    }

    uint256 public creationFee;
    uint256 public sizeLimit;
    mapping(address => uint256) public userToFarmId;
    mapping(bytes32 => uint256) public farmNameToId;
    FarmInfo[] farms;

    constructor(address core) public AccessControl(core) {
        farms.length = 1;
        creationFee = 0.2 ether;
        sizeLimit = 100;
    }

    function setCreationFee(uint256 fee) public onlyCOO {
        creationFee = fee;
    }

    function setSizeLimit(uint256 limit) public onlyCOO {
        require(limit < 1024 * 1024);
        sizeLimit = limit;
    }

    function total() public view returns(uint256) {
        return farms.length - 1;
    }

    function create(bytes32 name) public payable whenNotPaused ownNothing returns (uint256 farmId) {
        require(farmNameToId[name] == 0);
        require(msg.value >= creationFee);

        farmId = farms.push(FarmInfo(msg.sender, name, 1)) - 1;
        userToFarmId[msg.sender] = farmId;
        farmNameToId[name] = farmId;

        emit Created(msg.sender, farmId, name);
    }

    function getInfo(uint256 farmId) public view returns (address owner, bytes32 name, uint256 size) {
        FarmInfo storage farm = farms[farmId];
        owner = farm.owner;
        name = farm.name;
        size = farm.size;
    }

    function join(uint256 farmId) public whenNotPaused ownNothing {
        require(farmId > 0);
        require(farmId < farms.length);

        FarmInfo storage farm = farms[farmId];
        require(farm.size < sizeLimit);

        farm.size++;
        userToFarmId[msg.sender] = farmId;

        emit Joined(msg.sender, farmId);
    }

    function withdrawBalance() public onlyCFO {
        address(nonFungibleContract).transfer(address(this).balance);
    }

    modifier ownNothing() {
        require(farms[userToFarmId[msg.sender]].owner != msg.sender);
        _;
    }
}
