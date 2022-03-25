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

    // function getTemplates() public view returns (uint256[] memory) {
    //     return userTemplateIds[msg.sender];
    // }
}
