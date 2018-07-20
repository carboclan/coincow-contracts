pragma solidity 0.4.21;

contract CowInterface {
    function implementsCow() public pure returns (bool);

    function enabled() public view returns (bool);
    function coinCowAddress() public view returns (address);
    function name() public view returns (string);
}
