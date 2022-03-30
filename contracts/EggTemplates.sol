// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./PiamonUtils.sol";

contract EggTemplates {
    address public owner;
    using Counters for Counters.Counter;
    Counters.Counter private _counter;
    uint256 public totalTemplates;

    struct EggTemplate {
        uint256 id;
        string name;
        string c_name;
        string imageUrl;
        string filmUrl;
        string description;
        string c_description;
        int256 currency;
        int256 price;
        string saleOpenTime;
        string saleCloseTime;
        string unboxTime;
        int256 limitedElement;
        int256 limitedRace;
    }

    //templateId => Template
    mapping(uint256 => EggTemplate) public eggTemplates;

    constructor() {
        // Set the transaction sender as the owner of the contract.
        owner = msg.sender;
    }

    function create(
        string memory _name,
        string memory _c_name,
        string memory _imageUrl,
        string memory _filmUrl,
        string memory _description,
        string memory _c_description,
        int256 _currency,
        int256 _price,
        string memory _saleOpenTime,
        string memory _saleCloseTime,
        string memory _unboxTime,
        int256 _limitedElement,
        int256 _limitedRace
    ) public {
        _counter.increment();
        uint256 newId = _counter.current();
        EggTemplate memory newTemplate;
        newTemplate.id = newId;
        newTemplate.name = _name;
        newTemplate.c_name = _c_name;
        newTemplate.imageUrl = _imageUrl;
        newTemplate.filmUrl = _filmUrl;
        newTemplate.description = _description;
        newTemplate.c_description = _c_description;
        newTemplate.currency = _currency;
        newTemplate.price = _price;
        newTemplate.saleOpenTime = _saleOpenTime;
        newTemplate.saleCloseTime = _saleCloseTime;
        newTemplate.unboxTime = _unboxTime;
        newTemplate.limitedElement = _limitedElement;
        newTemplate.limitedRace = _limitedRace;
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
        EggTemplate[] memory returnTemplates = new EggTemplate[](
            totalTemplates
        );
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
