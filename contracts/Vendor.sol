// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./UTO8.sol";

contract Vendor is Ownable {
    UTO8 uto8;

    constructor(address tokenAddress) {
        uto8 = UTO8(tokenAddress);
    }

    function buyUTO8(uint256 amount) public payable {
        require(amount * 100 <= msg.value);
        address ownerAddress = owner();
        payable(ownerAddress).transfer(msg.value);
        bool tokenSent = uto8.transferFrom(ownerAddress, msg.sender, amount);
        require(tokenSent, "Failed to buy UTO8");
    }
}
