// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./PiamonUtils.sol";

contract EggTemplates {
    address public owner;
    using Counters for Counters.Counter;
    Counters.Counter private _counter;
    uint256 public totalTemplates;

    //templateId => Template
    mapping(uint256 => Template) public eggTemplates;

    //templateId => PiamonBox[]
    mapping(uint256 => PiamonBox[]) public templatePiamonBoxes;

    constructor() {
        // Set the transaction sender as the owner of the contract.
        owner = msg.sender;
    }

    function create(
        string memory _name,
        string memory _imageUrl,
        string memory _description
    ) public {
        _counter.increment();
        uint256 newId = _counter.current();
        Template memory newTemplate;
        newTemplate.id = newId;
        newTemplate.name = _name;
        newTemplate.imageUrl = _imageUrl;
        newTemplate.description = _description;
        eggTemplates[newId] = newTemplate;
        totalTemplates++;
    }

    function addPiamonBox(
        Element _element,
        Race _race,
        uint256 _templateId,
        uint16 _computingPower,
        string memory _headPart,
        string memory _earPart,
        string memory _eyePart
    ) public onlyOwner {
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

        templatePiamonBoxes[_templateId].push(newPiamonBox);
    }

    function getAvailableBox(uint256 templateId)
        public
        onlyOwner
        returns (PiamonBox memory box)
    {
        PiamonBox[] storage piamonBoxes = templatePiamonBoxes[templateId];
        uint256 boxesLength = piamonBoxes.length;
        require(boxesLength > 0, "No box available");

        //get rand number from chainlink
        uint256 rndIndex = 122;

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

    function getAllTemplates() public view returns (Template[] memory) {
        Template[] memory returnTemplates = new Template[](totalTemplates);
        for (uint256 i = 0; i < totalTemplates; i++) {
            returnTemplates[i] = eggTemplates[i];
        }
        return returnTemplates;
    }

    function getTemplateById(uint256 templateId)
        public
        view
        returns (Template memory)
    {
        return eggTemplates[templateId];
    }

    function getPiamonBoxesByTemplateId(uint256 templateId)
        public
        view
        returns (PiamonBox[] memory)
    {
        return templatePiamonBoxes[templateId];
    }

    // function getTemplates() public view returns (uint256[] memory) {
    //     return userTemplateIds[msg.sender];
    // }
}
