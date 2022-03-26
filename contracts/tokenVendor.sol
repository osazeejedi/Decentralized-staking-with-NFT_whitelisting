// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 contract Vendor{
    IERC20 BATtoken;
    uint256 rate = 50;
    uint256 minimumBuy;
    uint256 maximumBuy;
    event Buy(address by, uint256 value);

    constructor(address _BATtoken){
        BATtoken = IERC20(_BATtoken);
        maximumBuy = 10000 * 10**18;
    }

    function dispense() public payable{
        require(msg.value <= maximumBuy, "Buy less");
        uint256 tokenBalance = checkTokenBalance();
        require(msg.value*rate <= tokenBalance, "Not enough token available. Try a lower value");
        BATtoken.transfer(msg.sender, msg.value * rate);
        emit Buy(msg.sender, msg.value * rate);
    }

    function checkBalance () external view returns (uint256){
        return address(this).balance;
    }
 }