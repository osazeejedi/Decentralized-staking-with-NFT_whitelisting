pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BAT is ERC20 {

    constructor(uint256 initialSupply) ERC20("BoredApeToken", "BRT") {
        _mint(msg.sender, initialSupply);
    }
}