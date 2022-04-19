// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PiamonUtils.sol";

contract SalesBatch is Ownable {
    //Variables
    //using Counters for Counters.Counter;
    //Counters.Counter private _blindBoxCounter;

    //address public owner;
    //uint256 public totalMintedPiamon;
    BlindBox[] public blindBoxes;
    PiamonTemplate[] public piamonTemplates;

    constructor() {
        // Set the transaction sender as the owner of the contract.
        //owner = msg.sender;
    }

    //keep white list for a blindbox
    mapping(uint256 => WhiteList[]) public blindBoxWhiteList;

    function addBlindBox(BlindBox memory _blindBox) public onlyOwner {
        blindBoxes.push(_blindBox);
    }

    function addWhiteListStruct(
        uint256 _blindBoxId,
        WhiteList memory _whiteList
    ) public onlyOwner {
        blindBoxWhiteList[_blindBoxId].push(_whiteList);
    }

    function addPiamonTemplateStruct(PiamonTemplate memory _template)
        public
        onlyOwner
    {
        piamonTemplates.push(_template);
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

    function getWhiteList(uint256 _blindBoxId, address _address)
        public
        view
        returns (WhiteList memory whiteListReturn)
    {
        WhiteList[] storage lists = blindBoxWhiteList[_blindBoxId];
        for (uint256 i = 0; i < lists.length; i++) {
            WhiteList storage whiteList = lists[i];
            if (whiteList.minterAddress == _address) {
                whiteListReturn = whiteList;
                break;
            }
        }
    }

    function decreaseWhiteListAvailableQuantity(
        uint256 _blindBoxId,
        address _address
    ) public returns (uint256 remainQuantity) {
        //uint256 remainQty = 0;
        WhiteList[] storage lists = blindBoxWhiteList[_blindBoxId];
        for (uint256 i = 0; i < lists.length; i++) {
            WhiteList storage whiteList = lists[i];
            if (whiteList.minterAddress == _address) {
                if (whiteList.availableQuantity > 0) {
                    whiteList.availableQuantity--;
                }
                remainQuantity = whiteList.availableQuantity;
                break;
            }
        }
    }
}
