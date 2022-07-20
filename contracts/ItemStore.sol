//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol";

contract ItemStore is Ownable {
    event InGamePurchaseLog(
        string transactionID,
        string tokenName,
        address userAddress,
        uint256 price
    );

    function inGamePurchase(
        string transactionID,
        address tokenAddress,
        uint256 price
    ) public {
        IERC20 tokenToDeduct = IERC20(tokenAddress);
        string tokenName = tokenToDeduct.name();
        uint256 balanceOfToken = tokenToDeduct.balanceOf(msg.sender);
        require(balanceOfToken >= price, "Insufficient fund");

        address ownerAddress = owner();
        tokenToDeduct.safeTransferFrom(msg.sender, ownerAddress, price);
        emit InGamePurchaseLog(transactionID, tokenName, msg.sender, price);
    }
}
