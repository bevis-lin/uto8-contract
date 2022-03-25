// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./PiamonUtils.sol";

contract PiamonBoxes {
    address public owner;
    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    //templateId => (Box SerialId => PiamonBox)
    mapping(uint256 => mapping(uint256 => PiamonBox))
        public templatePiamonBoxes;

    function addPiamonBox(
        Element _element,
        Race _race,
        uint256 _templateId,
        uint16 _computingPower,
        string memory _headPart,
        string memory _earPart,
        string memory _eyePart
    ) public onlyOwner {
        _counter.increment();
        uint256 newId = _counter.current();

        PiamonBox memory newPiamonBox;
        PiamonData memory newData;
        newData.element = _element;
        newData.race = _race;
        newData.computingPower = _computingPower;
        newData.headPart = _headPart;
        newData.earPart = _earPart;
        newData.eyePart = _eyePart;
        newPiamonBox.data = newData;
        newPiamonBox.templateId = _templateId;

        templatePiamonBoxes[_templateId][newId] = newPiamonBox;
    }

    function getAvailableBox(uint256 templateId)
        public
        onlyOwner
        returns (PiamonBox memory box)
    {
        //here to implement randomness (not complete)
        uint256 rndIndex = 122;

        PiamonBox storage piamonBox = templatePiamonBoxes[templateId][rndIndex];
        //uint256 boxesLength = piamonBoxes.length;
        //require(boxesLength > 0, "No box available");

        PiamonBox memory returnBox = piamonBoxes[rndIndex];
        piamonBoxes[rndIndex] = piamonBoxes[boxesLength - 1];
        delete piamonBoxes[boxesLength - 1];
        return returnBox;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }
}
