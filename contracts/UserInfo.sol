pragma solidity ^0.4.23;

contract UserInfo {
    mapping(bytes32 => address) public addressOf;
    mapping(address => bytes32) public nameOf;
    mapping(address => string) public avatarOf;

    event Registered(address user, bytes32 name, string avatarUrl);

    function canRegister(bytes32 name) public view returns (bool) {
        return addressOf[name] == address(0);
    }

    function register(bytes32 name, string avatarUrl) public {
        require(canRegister(name));

        addressOf[name] = msg.sender;
        nameOf[msg.sender] = name;
        avatarOf[msg.sender] = avatarUrl;

        emit Registered(msg.sender, name, avatarUrl);
    }

    function setAvatar(string avatarUrl) public {
        avatarOf[msg.sender] = avatarUrl;
    }
}
