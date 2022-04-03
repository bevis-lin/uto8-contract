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

    mapping(uint256 => PiamonBox[]) public blindBoxPiamonBoxes; //keep piamon box for a blindbox

    function addBlindBox(BlindBox memory _blindBox) public onlyOwner {
        blindBoxes.push(_blindBox);
    }

    function addPiamonBoxStruct(uint256 _blindBoxId, PiamonBox memory _box)
        public
        onlyOwner
    {
        blindBoxPiamonBoxes[_blindBoxId].push(_box);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }
}
