// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./PiamonUtils.sol";

contract SalesBatch {
    //Variables
    //using Counters for Counters.Counter;
    //Counters.Counter private _blindBoxCounter;

    address public owner;
    uint256 public totalMintedPiamon;
    BlindBox[] public blindBoxes;

    constructor() {
        // Set the transaction sender as the owner of the contract.
        owner = msg.sender;
    }

    //keep piamon box for a blindbox
    mapping(uint256 => PiamonBox[]) public blindBoxPiamonBoxes;

    //keep white list for a blindbox
    mapping(uint256 => WhiteList[]) public blindBoxWhiteList; //

    function addBlindBox(BlindBox memory _blindBox) public onlyOwner {
        blindBoxes.push(_blindBox);
    }

    function addPiamonBoxStruct(uint256 _blindBoxId, PiamonBox memory _box)
        public
        onlyOwner
    {
        blindBoxPiamonBoxes[_blindBoxId].push(_box);
    }

    function checkIsWhiteListed(uint256 _blindBoxId, address _address)
        public
        view
        returns (bool)
    {
        bool isInWhiteList = false;

        WhiteList[] storage lists = blindBoxWhiteList[_blindBoxId];
        for (uint256 i = 0; i < lists.length; i++) {
            WhiteList storage whiteList = lists[i];
            if (whiteList.minterAddress == _address) {
                isInWhiteList = true;
                break;
            }
        }

        return isInWhiteList;
    }

    function getWhiteListAvailableQuantity(
        uint256 _blindBoxId,
        address _address
    ) public view returns (uint256 quantity) {
        uint256 availableQty = 0;
        WhiteList[] storage lists = blindBoxWhiteList[_blindBoxId];
        for (uint256 i = 0; i < lists.length; i++) {
            WhiteList storage whiteList = lists[i];
            if (whiteList.minterAddress == _address) {
                availableQty = whiteList.availableQuantity;
                break;
            }
        }
        return availableQty;
    }

    function decreaseWhiteListAvailableQuantity(
        uint256 _blindBoxId,
        address _address
    ) public returns (uint256 remainQuantity) {
        uint256 remainQty = 0;
        WhiteList[] storage lists = blindBoxWhiteList[_blindBoxId];
        for (uint256 i = 0; i < lists.length; i++) {
            WhiteList storage whiteList = lists[i];
            if (whiteList.minterAddress == _address) {
                if (whiteList.availableQuantity > 0) {
                    whiteList.availableQuantity--;
                }
                remainQty = whiteList.availableQuantity;
                break;
            }
        }
        return remainQty;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }
}
