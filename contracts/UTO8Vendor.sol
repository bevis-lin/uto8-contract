// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./UTO8.sol";
import "./UTO8SalesProvider.sol";

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);

    // don't need to define other functions, only using `transfer()` in this case
}

contract UTO8Vendor is Ownable {
    UTO8 uto8;
    IERC20 usdt;
    UTO8SalesProvider uto8SalesProvider;

    constructor(address uto8TokenAddress, address ustdTokenAddress) {
        uto8 = UTO8(uto8TokenAddress);
        usdt = IERC20(address(ustdTokenAddress));

        // transfers USDT that belong to your contract to the specified address
        usdt.transfer(_to, _amount);
    }

    function setUTO8SalesProvider(address contractAddress) public onlyOwner {
        uto8SalesProvider = UTO8SalesProvider(contractAddress);
    }

    function swapUTO8(uint256 uto8BoxId, uint256 amount) public payable {
        require(
            uto8SalesProvider.checkIsUserCanSwap(msg.sender, uto8BoxId, amount),
            "Exceed single limitation"
        );

        //get rate and require usdt
        UTO8Box box = uto8SalesProvider.uto8Boxes(uto8BoxId);
        uint256 requiredUsdt = (box.exchangeRate / 100) * (10**6) * amount;

        //check if user have enough USDT
        uint256 userUsdtBalance = usdt.balanceOf(msg.sender);
        require(
            userUsdtBalance > requiredUsdt,
            "Don't have enough USDT to swap"
        );

        address ownerAddress = owner();
        usdt.transferFrom(msg.sender, payable(ownerAddress), requireUsdt);
        bool tokenSent = uto8.transfer(msg.sender, amount);
        require(tokenSent, "Failed to buy UTO8");

        //add user swap record
        uto8SalesProvider.addUserSwapHistory(msg.sender, uto8BoxId, amount);
    }
}
